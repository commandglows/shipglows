$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
Import-Module $modulePath -Force -DisableNameChecking

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-project-environment-schema-' + [guid]::NewGuid().ToString('N'))
try {
    $project = Join-Path $fixture 'legacy'
    New-Item -ItemType Directory -Path $project -Force | Out-Null
    $path = Join-Path $project 'ENVIRONMENT.md'
    $legacy = @'
# User notes

- Assigned port: `9999`

<!-- >>> ShipGlows development environment >>> -->
## ShipGlows development environment

- Server manager: `shipglows-devserver`
- Assigned port: `3001`
- Canonical local URL: `http://127.0.0.1:3001`
- Live status authority: Windows ShipGlows DevServer registry
<!-- <<< ShipGlows development environment <<< -->
'@
    [IO.File]::WriteAllText($path, $legacy, [Text.UTF8Encoding]::new($false))

    [void](Write-SgProjectEnvironment $project 3002)
    $environment = Get-SgProjectEnvironment $project
    $content = [IO.File]::ReadAllText($path)
    if ($environment.Schema -ne 'shipglows-project-environment/v1' -or $environment.Port -ne 3002) { throw 'Legacy v0 was not migrated to the exact v1 schema.' }
    if ($content -notmatch [regex]::Escape('# User notes') -or $content -notmatch [regex]::Escape('- Assigned port: `9999`')) { throw 'Content outside the managed block was not preserved.' }
    if ([regex]::Matches($content, [regex]::Escape('- Environment schema: `shipglows-project-environment/v1`')).Count -ne 1) { throw 'The v1 schema marker is missing or duplicated.' }

    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    [void](Write-SgProjectEnvironment $project 3002)
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $hash) { throw 'The v1 rewrite is not byte-idempotent.' }

    [void](Write-SgProjectEnvironment $project 0)
    $preserved = Get-SgProjectEnvironment $project
    if ($preserved.Port -ne 3002) { throw 'A zero registry port erased the durable project port.' }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $hash) { throw 'A zero registry port rewrote an already durable environment.' }

    foreach ($invalid in @(
        [pscustomobject]@{ Name='future'; Content="# Notes`n`n<!-- >>> ShipGlows development environment >>> -->`n## ShipGlows development environment`n`n- Environment schema: ``shipglows-project-environment/v2```n- Server manager: ``shipglows-devserver```n<!-- <<< ShipGlows development environment <<< -->`n"; Error='Unsupported ShipGlows project environment schema' },
        [pscustomobject]@{ Name='incomplete'; Content="# Notes`n`n<!-- >>> ShipGlows development environment >>> -->`nDo not overwrite me.`n"; Error='incomplete or duplicated' },
        [pscustomobject]@{ Name='duplicate'; Content="<!-- >>> ShipGlows development environment >>> -->`n<!-- <<< ShipGlows development environment <<< -->`n<!-- >>> ShipGlows development environment >>> -->`n<!-- <<< ShipGlows development environment <<< -->`n"; Error='incomplete or duplicated' }
    )) {
        $invalidProject = Join-Path $fixture $invalid.Name
        New-Item -ItemType Directory -Path $invalidProject -Force | Out-Null
        $invalidPath = Join-Path $invalidProject 'ENVIRONMENT.md'
        [IO.File]::WriteAllText($invalidPath, $invalid.Content, [Text.UTF8Encoding]::new($false))
        $before = (Get-FileHash -LiteralPath $invalidPath -Algorithm SHA256).Hash
        $rejected = $false
        try { [void](Write-SgProjectEnvironment $invalidProject 3006) } catch { $rejected = $_.Exception.Message -match [regex]::Escape($invalid.Error) }
        if (-not $rejected -or (Get-FileHash -LiteralPath $invalidPath -Algorithm SHA256).Hash -ne $before) { throw "Invalid $($invalid.Name) block was not rejected without mutation." }
    }

    Write-Host 'Windows project environment schema regression: OK'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
