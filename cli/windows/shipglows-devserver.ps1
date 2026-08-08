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
Import-Module $module -Force -DisableNameChecking
$config = Get-SgDevConfig
Ensure-SgDirectory $config.Workspace
Ensure-SgDirectory $config.LogDirectory

function Get-SgGumCommand {
    $bundled = Join-Path $PSScriptRoot 'gum.exe'
    if (Test-Path -LiteralPath $bundled -PathType Leaf) { return $bundled }
    $command = Get-Command gum.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    return $null
}

$gum = Get-SgGumCommand

function Read-SgInput([string]$Prompt, [string]$Placeholder = '') {
    if (-not $gum) { return Read-Host $Prompt }
    $arguments = @('input','--prompt',"$Prompt ")
    if ($Placeholder) { $arguments += @('--placeholder',$Placeholder) }
    $value = (& $gum @arguments | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { return $null }
    return $value
}

function Read-SgChoice([string]$Header, [string[]]$Options) {
    if (-not $gum) { return $null }
    $value = (& $gum choose --header $Header --cursor-prefix '> ' --selected-prefix '* ' @Options | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { return $null }
    return $value
}

function Get-SelectedProject {
    $registry = Reconcile-SgRegistry $config
    $items = @($registry.projects)
    if ($items.Count -eq 0) { Write-SgWarn 'No registered projects.'; return $null }
    if ($gum) {
        $labels = @($items | ForEach-Object { "$($_.name)  [$($_.status)]  $($_.kind)  :$($_.port)" })
        $selected = Read-SgChoice 'Choose a project' $labels
        if (-not $selected) { return $null }
        $index = [Array]::IndexOf([string[]]$labels, $selected)
        if ($index -lt 0) { return $null }
        return $items[$index]
    } else {
        Show-SgDashboard $config
        $choice = Read-Host 'Project number'
        if ($choice -notmatch '^\d+$' -or [int]$choice -lt 1 -or [int]$choice -gt $items.Count) { Write-SgWarn 'Invalid project number.'; return $null }
        return $items[[int]$choice - 1]
    }
}

function Invoke-Clone {
    $url = if ($RepositoryUrl) { $RepositoryUrl } else { Read-SgInput 'Git URL' 'https://github.com/owner/repository.git' }
    if (-not $url) { return }
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
    $menuItems = @(
        '1  Clone a repository',
        '2  Register a local project',
        '3  Start a project',
        '4  Stop a project',
        '5  Restart a project',
        '6  View logs',
        '7  Open in browser',
        '8  Stop all projects',
        '9  Refresh',
        '0  Exit'
    )
    while ($true) {
        Show-SgDashboard $config
        if ($gum) {
            $selected = Read-SgChoice 'What do you want to do?' $menuItems
            if (-not $selected) { return }
            $choice = $selected.Substring(0,1)
        } else {
            Write-Host ''; Write-Host '1) Clone  2) Register  3) Start  4) Stop  5) Restart  6) Logs  7) Open  8) Stop all  9) Refresh  0) Exit'
            $choice = Read-Host 'Choice'
        }
        try {
            switch ($choice) {
                '1' { Invoke-Clone }
                '2' { $path = Read-SgInput 'Project path' $config.Workspace; if ($path) { Register-SgProject $config $path | Out-Null } }
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
        if (-not $gum) { Read-Host 'Press Enter to continue' | Out-Null }
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
