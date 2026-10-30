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

    $missing = @(Get-SgMissingProjects $config | ForEach-Object { [string]$_.path })
    Assert-Sg ($missing -contains $moved -and $missing -contains $runningGone -and $missing -notcontains $kept) 'Missing surfaces were not detected.'
    $movedEntry = @((Read-SgRegistry $config).projects | Where-Object { $_.path -eq $moved })[0]
    Assert-Sg ((Format-SgProjectStatus $movedEntry) -like 'missing |*') 'A stopped surface without folder is not shown as missing.'

    Unregister-SgProject $config $moved
    $paths = @((Read-SgRegistry $config).projects | ForEach-Object { [string]$_.path })
    Assert-Sg ($paths -notcontains $moved -and $paths -contains $kept) 'Unregister did not remove only the missing surface.'

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

    Write-Host 'devserver-missing-surface: ok'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
