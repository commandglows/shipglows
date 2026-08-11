[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Action = 'menu',
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ShortcutPath = @(),
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

function Resolve-SgAction([string]$RequestedAction, [string[]]$RemainingPath) {
    $namedActions = @('menu','dashboard','start','stop','restart','register','clone','logs','open','stop-all','refresh','navigate','update','help','exit')
    if (@($RemainingPath).Count -eq 0 -and $RequestedAction -in $namedActions) { return $RequestedAction }

    $tokens = @($RequestedAction) + @($RemainingPath)
    $shortcut = (($tokens | ForEach-Object { $_.Trim().ToLowerInvariant() }) -join ' ')
    $shortcuts = @{
        'd'   = 'dashboard'
        'e'   = 'select-start'
        'm r' = 'select-restart'
        'm t' = 'select-stop'
        'm o' = 'stop-all'
        'm l' = 'select-logs'
        'm n' = 'navigate'
        'u'   = 'update'
        'h'   = 'help'
        'x'   = 'exit'
    }
    if ($shortcuts.ContainsKey($shortcut)) { return $shortcuts[$shortcut] }
    throw "Unknown Windows shortcut path: $shortcut. Run 's h' to list supported shortcuts."
}

function Show-SgShortcutHelp {
    Write-Host ''
    Write-Host 'ShipGlows Windows shortcuts' -ForegroundColor Cyan
    Write-Host '  s d      Dashboard'
    Write-Host '  s e      Start a project'
    Write-Host '  s m r    Restart a project'
    Write-Host '  s m t    Stop a project'
    Write-Host '  s m o    Stop all projects'
    Write-Host '  s m l    View project logs'
    Write-Host '  s m n    Navigate to a project in a child PowerShell shell'
    Write-Host '  s u      Update ShipGlows from the official repository'
    Write-Host '  s         Interactive menu'
    Write-Host ''
    Write-Host 'Linux-only Flox, PM2 and Caddy shortcuts are intentionally unavailable.' -ForegroundColor DarkGray
}

try { $Action = Resolve-SgAction $Action $ShortcutPath }
catch {
    Write-SgError $_.Exception.Message
    exit 2
}

function Get-SgGumCommand {
    $bundled = Join-Path $PSScriptRoot 'gum.exe'
    if (Test-Path -LiteralPath $bundled -PathType Leaf) { return $bundled }
    $command = Get-Command gum.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    return $null
}

function Get-SgFzfCommand {
    $command = Get-Command fzf.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    return $null
}

function Get-SgApplication([string]$Name, [string[]]$KnownPaths = @()) {
    $command = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    foreach ($path in $KnownPaths) {
        if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) { return $path }
    }
    return $null
}

$gum = Get-SgGumCommand
$fzf = Get-SgFzfCommand
$choiceUiAvailable = [bool]($fzf -or $gum)
$programFiles = [Environment]::GetFolderPath('ProgramFiles')
$programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
$git = Get-SgApplication 'git.exe' @((Join-Path $programFiles 'Git\cmd\git.exe'), (Join-Path $programFilesX86 'Git\cmd\git.exe'))
$gh = Get-SgApplication 'gh.exe' @((Join-Path $programFiles 'GitHub CLI\gh.exe'), (Join-Path $programFilesX86 'GitHub CLI\gh.exe'))
$curl = Get-SgApplication 'curl.exe' @((Join-Path $env:WINDIR 'System32\curl.exe'))

function Get-SgSelectedIndex([string[]]$Labels, [string]$Selected) {
    for ($index = 0; $index -lt $Labels.Count; $index++) {
        if ($Labels[$index] -eq $Selected) { return $index }
    }
    return -1
}

function Read-SgInput([string]$Prompt, [string]$Placeholder = '') {
    # Once fzf is available, avoid Bubble Tea console capture altogether.
    if ($fzf -or -not $gum) { return Read-Host $Prompt }
    $arguments = @('input','--prompt',"$Prompt ")
    if ($Placeholder) { $arguments += @('--placeholder',$Placeholder) }
    $value = (& $gum @arguments | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { return $null }
    return $value
}

function Read-SgChoice([string]$Header, [string[]]$Options) {
    if (-not $choiceUiAvailable) { return $null }
    $lines = @($Options | ForEach-Object { "$_" -replace '[\r\n]+', ' ' } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($lines.Count -eq 0) { return $null }

    # fzf has reliable redirected-input/output behavior in Windows PowerShell.
    # Prefer it over Gum, whose Bubble Tea console redraw can lose rows on some
    # managed Windows terminals (including Shadow + WezTerm).
    if ($fzf) {
        $value = (($lines -join [Environment]::NewLine) | & $fzf --height=~60% --layout=reverse --border --prompt "$Header > " --no-multi | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { return $null }
        return $value
    }

    # Gum on Windows can collapse a PowerShell-splatted array into one option.
    # Its newline-delimited stdin contract preserves one selectable item per line.
    # Explicit colors prevent invisible black-on-black items on managed Windows
    # terminals whose inherited ANSI defaults differ from a normal console.
    $style = @(
        '--item.foreground', '255',
        '--item.background', '0',
        '--cursor.foreground', '0',
        '--cursor.background', '212',
        '--selected.foreground', '0',
        '--selected.background', '212',
        '--header.foreground', '255',
        '--header.background', '0'
    )
    $value = (($lines -join [Environment]::NewLine) | & $gum choose --header $Header --cursor-prefix '> ' --selected-prefix '* ' @style | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { return $null }
    return $value
}

function Get-SelectedProject {
    $registry = Reconcile-SgRegistry $config
    $items = @($registry.projects)
    if ($items.Count -eq 0) { Write-SgWarn 'No registered projects.'; return $null }
    if ($choiceUiAvailable) {
        $labels = @($items | ForEach-Object { "$($_.name)  [$($_.status)]  $($_.kind)  :$($_.port)" })
        $selected = Read-SgChoice 'Choose a project' $labels
        if (-not $selected) { return $null }
        $index = Get-SgSelectedIndex $labels $selected
        if ($index -lt 0) { return $null }
        return $items[$index]
    } else {
        Show-SgDashboard $config
        $choice = Read-Host 'Project number'
        if ($choice -notmatch '^\d+$' -or [int]$choice -lt 1 -or [int]$choice -gt $items.Count) { Write-SgWarn 'Invalid project number.'; return $null }
        return $items[[int]$choice - 1]
    }
}

function Invoke-SgGitHubLogin {
    if (-not $gh) { throw 'GitHub CLI is unavailable. Rerun the ShipGlows full installer.' }
    & $gh auth status --hostname github.com *> $null
    if ($LASTEXITCODE -eq 0) { return $true }
    Write-SgInfo 'GitHub authentication will open in your browser. ShipGlows never reads or stores your token.'
    & $gh auth login --hostname github.com --git-protocol https --web
    if ($LASTEXITCODE -ne 0) { throw 'GitHub authentication was cancelled or failed.' }
    & $gh auth setup-git
    if ($LASTEXITCODE -ne 0) { throw 'GitHub authentication succeeded but Git credential setup failed.' }
    return $true
}

function Invoke-SgGitHubClone {
    if (-not $choiceUiAvailable) { throw 'The GitHub repository browser requires fzf or Gum; use Enter Git URL instead.' }
    [void](Invoke-SgGitHubLogin)
    $json = (& $gh repo list --limit 200 --json nameWithOwner,description,isPrivate,url | Out-String)
    if ($LASTEXITCODE -ne 0) { throw 'GitHub repository listing failed.' }
    # Windows PowerShell 5.1 preserves a JSON top-level array as one pipeline
    # object when ConvertFrom-Json is nested directly inside @(...). Assigning
    # first lets the following array expression enumerate each repository.
    $parsedRepositories = $json | ConvertFrom-Json
    $repositories = @($parsedRepositories)
    if ($repositories.Count -eq 0) { throw 'No GitHub repositories are available for this account.' }
    $labels = @($repositories | ForEach-Object {
        $visibility = if ($_.isPrivate) { 'private' } else { 'public' }
        $description = if ($_.description) { " - $($_.description)" } else { '' }
        "$($_.nameWithOwner)  [$visibility]$description"
    })
    $selected = Read-SgChoice 'Search your GitHub repositories' $labels
    if (-not $selected) { return }
    $index = Get-SgSelectedIndex $labels $selected
    if ($index -lt 0) { throw 'The selected GitHub repository could not be resolved.' }
    $repository = $repositories[$index]
    $name = @($repository.nameWithOwner -split '/')[-1]
    $destination = Join-Path $config.Workspace $name
    if (Test-Path -LiteralPath $destination) { throw "Clone destination already exists: $destination" }
    & $gh repo clone $repository.nameWithOwner $destination
    if ($LASTEXITCODE -ne 0) { throw 'GitHub repository clone failed.' }
    Register-SgProject $config $destination | Out-Null
    Write-SgInfo "Registered clone: $destination"
}

function Invoke-CloneUrl {
    $url = if ($RepositoryUrl) { $RepositoryUrl } else { Read-SgInput 'Git URL' 'https://github.com/owner/repository.git' }
    if (-not $url) { return }
    if (-not (Test-SgGitUrl $url)) { throw 'Only HTTPS and SSH Git URLs without embedded credentials are accepted.' }
    if (-not $git) { throw 'Git is unavailable. Rerun the ShipGlows full installer.' }
    $name = (Split-Path ($url -replace '\.git$','') -Leaf)
    $destination = Join-Path $config.Workspace $name
    if (Test-Path -LiteralPath $destination) { throw "Clone destination already exists: $destination" }
    Ensure-SgDirectory $config.Workspace
    & $git clone -- $url $destination
    if ($LASTEXITCODE -ne 0) { throw 'Git clone failed.' }
    Register-SgProject $config $destination | Out-Null
    Write-SgInfo "Registered clone: $destination"
}

function Invoke-Clone {
    if ($RepositoryUrl -or -not $choiceUiAvailable) { Invoke-CloneUrl; return }
    $choice = Read-SgChoice 'Clone a repository' @('Browse my GitHub repositories','Enter a Git URL','Back')
    switch ($choice) {
        'Browse my GitHub repositories' { Invoke-SgGitHubClone }
        'Enter a Git URL' { Invoke-CloneUrl }
        default { return }
    }
}

function Invoke-Logs($entry) {
    if (-not $entry.logPath) { Write-SgWarn 'No log file is registered for this project.'; return }
    if (Test-Path -LiteralPath $entry.logPath) { Get-Content -LiteralPath $entry.logPath -Tail 80 }
    if ($entry.errorLogPath -and (Test-Path -LiteralPath $entry.errorLogPath)) { Write-Host '--- stderr ---' -ForegroundColor Yellow; Get-Content -LiteralPath $entry.errorLogPath -Tail 80 }
}

function Invoke-Navigate {
    $entry = Get-SelectedProject
    if (-not $entry) { return }
    $shell = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $shell -PathType Leaf)) {
        $shell = Get-SgApplication 'pwsh.exe' @()
    }
    if (-not $shell) { throw 'No compatible PowerShell executable is available for project navigation.' }

    Write-SgInfo "Opening a child PowerShell shell in $($entry.path). Type exit to return."
    Push-Location -LiteralPath $entry.path
    try { & $shell -NoLogo -NoProfile -ExecutionPolicy Bypass -NoExit }
    finally { Pop-Location }
}

function Invoke-SgUpdate {
    if (-not $curl) { throw 'curl.exe is unavailable. Download install-shipglows.ps1 from the official ShipGlows repository.' }

    $installerUrl = 'https://raw.githubusercontent.com/commandglows/shipglows/main/install-shipglows.ps1'
    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("shipglows-update-" + [guid]::NewGuid().ToString('N'))
    $installerPath = Join-Path $tempRoot 'install-shipglows.ps1'
    $shipglowsDir = Split-Path -Parent $PSScriptRoot

    try {
        [void][IO.Directory]::CreateDirectory($tempRoot)
        Write-SgInfo 'Downloading the current ShipGlows Windows installer...'
        & $curl --proto '=https' --tlsv1.2 -fsSL $installerUrl -o $installerPath
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
            throw 'ShipGlows installer download failed.'
        }

        $parseTokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile(
            $installerPath,
            [ref]$parseTokens,
            [ref]$parseErrors
        )
        if ($parseErrors -and $parseErrors.Count -gt 0) {
            throw 'The downloaded ShipGlows installer failed PowerShell syntax validation.'
        }

        & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $installerPath -InstallMode full -ShipglowsDir $shipglowsDir
        if ($LASTEXITCODE -ne 0) { throw 'ShipGlows update failed.' }
        Write-SgInfo 'Update completed. Run s again to use the updated CLI.'
    } finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
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
        'u  Update ShipGlows',
        '0  Exit'
    )
    while ($true) {
        Show-SgDashboard $config
        if ($choiceUiAvailable) {
            $selected = Read-SgChoice 'What do you want to do?' $menuItems
            if (-not $selected) { return }
            $choice = $selected.Substring(0,1)
        } else {
            Write-Host ''; Write-Host '1) Clone  2) Register  3) Start  4) Stop  5) Restart  6) Logs  7) Open  8) Stop all  9) Refresh  u) Update  0) Exit'
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
                'u' { Invoke-SgUpdate; return }
                '0' { return }
                default { Write-SgWarn 'Unknown choice.' }
            }
        } catch { Write-SgError $_.Exception.Message }
        if (-not $choiceUiAvailable) { Read-Host 'Press Enter to continue' | Out-Null }
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
        'select-start' { $entry = Get-SelectedProject; if ($entry) { Start-SgProject $config $entry.path $Port | Out-Null } }
        'select-stop' { $entry = Get-SelectedProject; if ($entry) { Stop-SgProject $config $entry.path } }
        'select-restart' { $entry = Get-SelectedProject; if ($entry) { Stop-SgProject $config $entry.path; Start-SgProject $config $entry.path $Port | Out-Null } }
        'select-logs' { $entry = Get-SelectedProject; if ($entry) { Invoke-Logs $entry } }
        'navigate' { Invoke-Navigate }
        'update' { Invoke-SgUpdate }
        'help' { Show-SgShortcutHelp }
        'exit' { return }
    }
} catch { Write-SgError $_.Exception.Message; exit 1 }
