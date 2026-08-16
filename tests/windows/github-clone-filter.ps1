$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-github-clone-filter-{0}" -f [guid]::NewGuid().ToString('N'))
$workspace = Join-Path $fixture 'workspace'
$runtime = Join-Path $fixture 'runtime'
$git = (Get-Command git.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source

function New-SgFixtureRepository([string]$Name, [string]$Origin, [switch]$RunnableSurface) {
    $path = Join-Path $workspace $Name
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    & $git -C $path init --quiet
    if ($LASTEXITCODE -ne 0) { throw "Unable to initialize Git fixture: $path" }
    & $git -C $path remote add origin $Origin
    if ($LASTEXITCODE -ne 0) { throw "Unable to set Git fixture origin: $path" }
    if ($RunnableSurface) {
        $surface = Join-Path $path 'site'
        New-Item -ItemType Directory -Path $surface -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $surface 'package.json') -Value '{"scripts":{"dev":"vite"},"devDependencies":{"vite":"latest"}}' -Encoding UTF8
    }
    return $path
}

try {
    New-Item -ItemType Directory -Path $workspace,$runtime -Force | Out-Null
    [void](New-SgFixtureRepository 'https-project' 'https://github.com/Example/Already-Here.git' -RunnableSurface)
    [void](New-SgFixtureRepository 'ssh-project' 'git@github.com:example/ssh-project.git')
    [void](New-SgFixtureRepository 'ssh-uri-project' 'ssh://git@github.com/Example/ssh-uri-project.git')
    [void](New-SgFixtureRepository 'other-host' 'https://gitlab.com/example/not-github.git')

    Import-Module $modulePath -Force -DisableNameChecking
    $config = [pscustomobject]@{
        Workspace = [IO.Path]::GetFullPath($workspace)
        RuntimeDirectory = [IO.Path]::GetFullPath($runtime)
        RegistryPath = Join-Path $runtime 'registry.json'
        LockPath = Join-Path $runtime 'registry.lock'
        ProjectIndexPath = Join-Path $runtime 'project-index.json'
        LogDirectory = Join-Path $runtime 'logs'
        PortStart = 32000
        PortEnd = 32020
    }

    Assert-Sg ((ConvertTo-SgGitHubRepositoryIdentity 'HTTPS://github.com/Example/Already-Here.git') -eq 'example/already-here') 'HTTPS GitHub identity was not normalized.'
    Assert-Sg ((ConvertTo-SgGitHubRepositoryIdentity 'git@github.com:Example/Already-Here.git') -eq 'example/already-here') 'SCP-style SSH GitHub identity was not normalized.'
    Assert-Sg ((ConvertTo-SgGitHubRepositoryIdentity 'ssh://git@github.com/Example/Already-Here.git') -eq 'example/already-here') 'SSH URI GitHub identity was not normalized.'
    Assert-Sg ((ConvertTo-SgGitHubRepositoryIdentity 'Example/Already-Here') -eq 'example/already-here') 'GitHub owner/name identity was not normalized.'
    Assert-Sg (-not (ConvertTo-SgGitHubRepositoryIdentity 'https://gitlab.com/example/already-here.git')) 'A non-GitHub remote was accepted.'

    $installed = @(Get-SgInstalledGitHubRepositoryIdentities $config $git)
    Assert-Sg ($installed.Count -eq 3) 'Installed GitHub repositories were not deduplicated across runnable and non-runnable clones.'
    foreach ($expected in @('example/already-here','example/ssh-project','example/ssh-uri-project')) {
        Assert-Sg ($installed -contains $expected) "Installed GitHub repository was missed: $expected"
    }

    $available = @(
        [pscustomobject]@{ nameWithOwner = 'EXAMPLE/ALREADY-HERE'; url = 'https://github.com/Example/Already-Here' },
        [pscustomobject]@{ nameWithOwner = 'example/ssh-project'; url = 'https://github.com/example/ssh-project' },
        [pscustomobject]@{ nameWithOwner = 'example/new-project'; url = 'https://github.com/example/new-project' },
        [pscustomobject]@{ nameWithOwner = 'example/new-project'; url = 'https://github.com/example/new-project' }
    )
    $filtered = @(Select-SgGitHubCloneCandidates $available $installed)
    Assert-Sg ($filtered.Count -eq 1 -and $filtered[0].nameWithOwner -eq 'example/new-project') 'Clone picker did not remove installed repositories and duplicate API rows.'
    Assert-Sg (@(Select-SgGitHubCloneCandidates @() $installed).Count -eq 0) 'Empty GitHub repository input was not stable.'

    [void](New-SgFixtureRepository 'new-project' 'https://github.com/example/new-project.git')
    $installedAfterClone = @(Get-SgInstalledGitHubRepositoryIdentities $config $git)
    Assert-Sg (@(Select-SgGitHubCloneCandidates $available $installedAfterClone).Count -eq 0) 'A newly cloned repository remained available without a new process.'

    Write-Host 'Windows GitHub clone filter: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
