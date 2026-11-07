$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# A registered surface whose folder vanished (git mv during a tree migration) shows as missing and can be unregistered.

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Write-Package([string]$Path) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    '{"devDependencies":{"vite":"latest"},"scripts":{"dev":"vite"}}' | Set-Content -LiteralPath (Join-Path $Path 'package.json') -Encoding UTF8
}

function Write-TauriProject([string]$Path) {
    New-Item -ItemType Directory -Path (Join-Path $Path 'src-tauri') -Force | Out-Null
    '{"surface":"tauri"}' | Set-Content -LiteralPath (Join-Path $Path '.shipglows.runtime.json') -Encoding UTF8
    '{"build":{"devUrl":"http://127.0.0.1:3006","beforeDevCommand":"pnpm tauri:dev"}}' | Set-Content -LiteralPath (Join-Path $Path 'src-tauri\tauri.conf.json') -Encoding UTF8
}

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-missing-surface-{0}" -f [guid]::NewGuid().ToString('N'))
$workspace = Join-Path $fixture 'workspace'
$runtime = Join-Path $fixture 'runtime'

try {
    New-Item -ItemType Directory -Path $workspace,$runtime -Force | Out-Null
    Import-Module (Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking
    $config = [pscustomobject]@{
        Workspace = [IO.Path]::GetFullPath($workspace)
        RuntimeDirectory = [IO.Path]::GetFullPath($runtime)
        RegistryPath = Join-Path $runtime 'registry.json'
        LockPath = Join-Path $runtime 'registry.lock'
        ProjectIndexPath = Join-Path $runtime 'project-index.json'
        LogDirectory = Join-Path $runtime 'logs'
        PortStart = 32100
        PortEnd = 32120
    }

    $moved = Join-Path $workspace 'alpha\website'
    $runningGone = Join-Path $workspace 'alpha\running'
    $kept = Join-Path $workspace 'beta\site'
    foreach ($path in @($moved,$runningGone,$kept)) { Write-Package $path; Register-SgProject $config $path | Out-Null }
    $manifestMoved = Join-Path $workspace 'gamma\desktop-app'
    Write-TauriProject $manifestMoved
    Register-SgProject $config $manifestMoved | Out-Null

    # A session that claims to be running with the current process identity counts as live.
    $start = (Get-Process -Id $PID).StartTime.ToUniversalTime().ToString('o')
    & (Get-Module ShipGlows.DevServer) {
        param($Config, $Path, $ProcessId, $StartTimeUtc)
        Invoke-SgRegistryMutation $Config {
            param($data)
            $entry = @($data.projects | Where-Object { $_.path -eq $Path })[0]
            foreach ($record in @($entry) + @(Get-SgEntrySessions $entry)) {
                $record.status = 'running'
                $record | Add-Member -NotePropertyName pid -NotePropertyValue $ProcessId -Force
                $record | Add-Member -NotePropertyName startTimeUtc -NotePropertyValue $StartTimeUtc -Force
            }
        } | Out-Null
    } $config $runningGone $PID $start

    Remove-Item -LiteralPath $moved,$runningGone -Recurse -Force
    New-Item -ItemType Directory -Path (Join-Path $manifestMoved 'desktop') -Force | Out-Null
    Move-Item -LiteralPath (Join-Path $manifestMoved 'src-tauri') -Destination (Join-Path $manifestMoved 'desktop\src-tauri')

    $missing = @(Get-SgMissingProjects $config | ForEach-Object { [string]$_.path })
    Assert-Sg ($missing -contains $moved -and $missing -contains $runningGone -and $missing -contains $manifestMoved -and $missing -notcontains $kept) 'Missing surfaces were not detected.'
    $movedEntry = @((Read-SgRegistry $config).projects | Where-Object { $_.path -eq $moved })[0]
    Assert-Sg ((Format-SgProjectStatus $movedEntry) -like 'missing |*') 'A stopped surface without folder is not shown as missing.'
    $manifestMovedEntry = @((Read-SgRegistry $config).projects | Where-Object { $_.path -eq $manifestMoved })[0]
    Assert-Sg ((Format-SgProjectStatus $manifestMovedEntry) -like 'missing |*') 'A surface whose manifest moved is not shown as missing.'

    Unregister-SgProject $config $moved
    Unregister-SgProject $config $manifestMoved
    $paths = @((Read-SgRegistry $config).projects | ForEach-Object { [string]$_.path })
    Assert-Sg ($paths -notcontains $moved -and $paths -notcontains $manifestMoved -and $paths -contains $kept) 'Unregister did not remove only the missing surfaces.'

    $blocked = $false
    try { Unregister-SgProject $config $runningGone } catch { $blocked = $_.Exception.Message -like 'Project is still running*' }
    Assert-Sg $blocked 'A live session without folder was unregistered.'

    Unregister-SgMissingProjects $config 3>$null
    $paths = @((Read-SgRegistry $config).projects | ForEach-Object { [string]$_.path })
    Assert-Sg ($paths -contains $runningGone -and $paths -contains $kept) 'Bulk unregister removed a live or present surface.'

    # The freed port of the removed surface is available to the next reservation.
    $movedPort = [int]$movedEntry.port
    if ($movedPort -gt 0) {
        $reused = Join-Path $workspace 'gamma\site'
        Write-Package $reused; Register-SgProject $config $reused | Out-Null
        $reservation = Reserve-SgProjectPort $config $reused $movedPort $true
        Assert-Sg ($reservation.Port -eq $movedPort) 'The port of the unregistered surface was not released.'
    }
    $manifestMovedPort = [int]$manifestMovedEntry.port
    if ($manifestMovedPort -gt 0) {
        $reusedTauriPort = Join-Path $workspace 'delta\desktop-app'
        Write-TauriProject $reusedTauriPort
        Register-SgProject $config $reusedTauriPort | Out-Null
        $reservation = Reserve-SgProjectPort $config $reusedTauriPort $manifestMovedPort $true
        Assert-Sg ($reservation.Port -eq $manifestMovedPort) 'The port of the unregistered moved-manifest surface was not released.'
    }

    Write-Host 'devserver-missing-surface: ok'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
