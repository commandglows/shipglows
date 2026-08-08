[CmdletBinding()]
param(
    [ValidateSet('menu','dashboard','start','stop','restart','register','clone','logs','open','stop-all','refresh')]
    [string]$Action = 'menu',
    [string]$ProjectPath = '',
    [string]$RepositoryUrl = '',
    [int]$Port = 0
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$module = Join-Path $PSScriptRoot 'ShipGlows.DevServer.psm1'
Import-Module $module -Force
$config = Get-SgDevConfig
Ensure-SgDirectory $config.Workspace
Ensure-SgDirectory $config.LogDirectory

function Get-SelectedProject {
    $registry = Reconcile-SgRegistry $config
    $items = @($registry.projects)
    if ($items.Count -eq 0) { Write-SgWarn 'No registered projects.'; return $null }
    Show-SgDashboard $config
    $choice = Read-Host 'Project number'
    if ($choice -notmatch '^\d+$' -or [int]$choice -lt 1 -or [int]$choice -gt $items.Count) { Write-SgWarn 'Invalid project number.'; return $null }
    return $items[[int]$choice - 1]
}

function Invoke-Clone {
    $url = if ($RepositoryUrl) { $RepositoryUrl } else { Read-Host 'Git URL (https or SSH)' }
    if (-not (Test-SgGitUrl $url)) { throw 'Only HTTPS and SSH Git URLs without embedded credentials are accepted.' }
    $name = (Split-Path ($url -replace '\.git$','') -Leaf)
    $destination = Join-Path $config.Workspace $name
    if (Test-Path -LiteralPath $destination) { throw "Clone destination already exists: $destination" }
    Ensure-SgDirectory $config.Workspace
    & git.exe clone -- $url $destination
    if ($LASTEXITCODE -ne 0) { throw 'Git clone failed.' }
    Register-SgProject $config $destination | Out-Null
    Write-SgInfo "Registered clone: $destination"
}

function Invoke-Logs($entry) {
    if (-not $entry.logPath) { Write-SgWarn 'No log file is registered for this project.'; return }
    if (Test-Path -LiteralPath $entry.logPath) { Get-Content -LiteralPath $entry.logPath -Tail 80 }
    if ($entry.errorLogPath -and (Test-Path -LiteralPath $entry.errorLogPath)) { Write-Host '--- stderr ---' -ForegroundColor Yellow; Get-Content -LiteralPath $entry.errorLogPath -Tail 80 }
}

function Invoke-Menu {
    while ($true) {
        Show-SgDashboard $config
        Write-Host ''; Write-Host '1) Clone  2) Register  3) Start  4) Stop  5) Restart  6) Logs  7) Open  8) Stop all  9) Refresh  0) Exit'
        $choice = Read-Host 'Choice'
        try {
            switch ($choice) {
                '1' { Invoke-Clone }
                '2' { $path = Read-Host "Project path [$($config.Workspace)]"; Register-SgProject $config $path | Out-Null }
                '3' { $entry = Get-SelectedProject; if ($entry) { Start-SgProject $config $entry.path $Port | Out-Null } }
                '4' { $entry = Get-SelectedProject; if ($entry) { Stop-SgProject $config $entry.path } }
                '5' { $entry = Get-SelectedProject; if ($entry) { Stop-SgProject $config $entry.path; Start-SgProject $config $entry.path $Port | Out-Null } }
                '6' { $entry = Get-SelectedProject; if ($entry) { Invoke-Logs $entry } }
                '7' { $entry = Get-SelectedProject; if ($entry -and $entry.port) { Start-Process "http://127.0.0.1:$($entry.port)" } }
                '8' { foreach ($entry in @(Read-SgRegistry $config).projects) { Stop-SgProject $config $entry.path } }
                '9' { Reconcile-SgRegistry $config | Out-Null }
                '0' { return }
                default { Write-SgWarn 'Unknown choice.' }
            }
        } catch { Write-SgError $_.Exception.Message }
        Read-Host 'Press Enter to continue' | Out-Null
    }
}

try {
    switch ($Action) {
        'menu' { Invoke-Menu }
        'dashboard' { Show-SgDashboard $config }
        'refresh' { Reconcile-SgRegistry $config | Out-Null; Show-SgDashboard $config }
        'clone' { Invoke-Clone }
        'register' { Register-SgProject $config $ProjectPath | Out-Null }
        'start' { Start-SgProject $config $ProjectPath $Port | Out-Null }
        'stop' { Stop-SgProject $config $ProjectPath }
        'restart' { Stop-SgProject $config $ProjectPath; Start-SgProject $config $ProjectPath $Port | Out-Null }
        'logs' { $entry = @(Read-SgRegistry $config).projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $ProjectPath) } | Select-Object -First 1; if ($entry) { Invoke-Logs $entry } }
        'open' { $entry = @(Read-SgRegistry $config).projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $ProjectPath) } | Select-Object -First 1; if ($entry -and $entry.port) { Start-Process "http://127.0.0.1:$($entry.port)" } }
        'stop-all' { foreach ($entry in @(Read-SgRegistry $config).projects) { Stop-SgProject $config $entry.path } }
    }
} catch { Write-SgError $_.Exception.Message; exit 1 }
