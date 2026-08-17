[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Action = 'menu',
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ShortcutPath = @(),
    [string]$ProjectPath = '',
    [string]$PlanDigest = '',
    [switch]$Offline,
    [string]$RepositoryUrl = '',
    [int]$Port = 0
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Keep the environment control plane outside the DevServer bootstrap: its
# read-only commands must not create the workspace, registry, or menu cache.
if ($Action.Trim().ToLowerInvariant() -eq 'env') {
    if (@($ShortcutPath).Count -ne 1 -or $ShortcutPath[0].Trim().ToLowerInvariant() -notin @('inspect','plan','verify','status','apply')) {
        [Console]::Error.WriteLine('Usage: s env <inspect|plan|verify|status|apply> [-ProjectPath <path>]')
        exit 2
    }
    $environmentCandidates = @(
        [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\environment\shipglows_environment.py')),
        [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cli\environment\shipglows_environment.py'))
    )
    $environmentScript = $environmentCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $environmentScript) {
        [Console]::Error.WriteLine("ShipGlows environment control-plane script not found in the source or installed runtime.")
        exit 2
    }
    $python = @(
        Get-Command python.exe -CommandType Application -ErrorAction SilentlyContinue
        Get-Command python3.exe -CommandType Application -ErrorAction SilentlyContinue
    ) | Where-Object { $_ } | Select-Object -First 1
    if (-not $python) {
        [Console]::Error.WriteLine('ShipGlows environment commands require Python 3.')
        exit 2
    }
    $resolvedProject = if ($ProjectPath) { $ProjectPath } else { (Get-Location).Path }
    $environmentArguments = @($environmentScript, $ShortcutPath[0].Trim().ToLowerInvariant(), '--project', $resolvedProject)
    if ($PlanDigest) { $environmentArguments += @('--plan-digest', $PlanDigest) }
    if ($Offline) { $environmentArguments += '--offline' }
    & $python.Source @environmentArguments
    exit $LASTEXITCODE
}

$module = Join-Path $PSScriptRoot 'ShipGlows.DevServer.psm1'
Import-Module $module -Force -DisableNameChecking
$authModule = Join-Path $PSScriptRoot 'ShipGlows.Auth.psm1'
$mobileModule = Join-Path $PSScriptRoot 'ShipGlows.MobileToolchain.psm1'
Import-Module $authModule -Force -DisableNameChecking
Import-Module $mobileModule -Force -DisableNameChecking
$config = Get-SgDevConfig
Ensure-SgDirectory $config.Workspace
Ensure-SgDirectory $config.LogDirectory

function Resolve-SgAction([string]$RequestedAction, [string[]]$RemainingPath) {
    $namedActions = @('menu','dashboard','start','stop','restart','register','unregister','clone','logs','open','stop-all','refresh','navigate','auth','update','help','exit')
    if (@($RemainingPath).Count -eq 0 -and $RequestedAction -in $namedActions) { return $RequestedAction }

    $tokens = @($RequestedAction) + @($RemainingPath)
    $shortcut = (($tokens | ForEach-Object { $_.Trim().ToLowerInvariant() }) -join ' ')
    $shortcuts = @{
        'd'   = 'dashboard'
        'e'   = 'select-start'
        'm r' = 'select-restart'
        'm t' = 'select-stop'
        'm w' = 'select-unregister'
        'm o' = 'stop-all'
        'm l' = 'select-logs'
        'm n' = 'navigate'
        'a'   = 'auth'
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
    Write-Host '  s m w    Unregister a stopped project (files are preserved)'
    Write-Host '  s m o    Stop all projects'
    Write-Host '  s m l    View project logs'
    Write-Host '  s m n    Navigate to a project in a child PowerShell shell'
    Write-Host '  s a      Manage CLI authentication with official interactive flows'
    Write-Host '  s env inspect|plan|verify|status|apply    Manage the current project environment'
    Write-Host '  s u      Update ShipGlows from the official repository'
    Write-Host '  s x      Quit ShipGlows'
    Write-Host '  s         Interactive menu'
    Write-Host ''
    Write-Host 'Windows uses native project manifests and tools; Linux environment, PM2 and Caddy commands remain unavailable.' -ForegroundColor DarkGray
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

function Read-SgChoice([string]$Header, [string[]]$Options, [hashtable]$IdentityByLabel = $null) {
    if (-not $choiceUiAvailable) { return $null }
    $lines = @($Options | ForEach-Object { "$_" -replace '[\r\n]+', ' ' } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($lines.Count -eq 0) { return $null }

    # fzf has reliable redirected-input/output behavior in Windows PowerShell.
    # Prefer it over Gum, whose Bubble Tea console redraw can lose rows on some
    # managed Windows terminals (including Shadow + WezTerm).
    if ($fzf) {
        $value = (($lines -join [Environment]::NewLine) | & $fzf --height=~60% --layout=reverse --border --prompt "$Header > " --no-multi | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { return $null }
        if ($IdentityByLabel) {
            if (-not $IdentityByLabel.ContainsKey($value)) { throw 'The selected item could not be resolved to an exact identity.' }
            return [string]$IdentityByLabel[$value]
        }
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
    if ($IdentityByLabel) {
        if (-not $IdentityByLabel.ContainsKey($value)) { throw 'The selected item could not be resolved to an exact identity.' }
        return [string]$IdentityByLabel[$value]
    }
    return $value
}

function Get-SelectedProject([string]$Action = 'navigate', [string]$Header = 'Choose a project') {
    $items = @(Get-SgProjectCatalog $config)
    switch ($Action) {
        'start' { $items = @($items) }
        'navigate' { $items = @($items) }
        'logs' { $items = @($items | Where-Object { $_.IsRegistered -and $_.logPath }) }
        'open' { $items = @($items | Where-Object { $_.IsRegistered -and $_.status -in @('starting','running') -and [int]$_.port -gt 0 }) }
        default { $items = @($items | Where-Object { $_.IsRegistered }) }
    }
    if ($items.Count -eq 0) { Write-SgWarn 'No projects discovered in the ShipGlows workspace.'; return $null }
    if ($choiceUiAvailable) {
        $labels = New-Object 'System.Collections.Generic.List[string]'
        $identityByLabel = @{}
        foreach ($item in $items) {
            $label = if ($Action -eq 'navigate') { [string]$item.Name } else { "$($item.Name)  [$($item.status)]  $($item.kind)  :$($item.port)" }
            if ($identityByLabel.ContainsKey($label)) { throw "Duplicate project choice label: $label" }
            $identityByLabel[$label] = [string]$item.Id
            [void]$labels.Add($label)
        }
        $backOption = '0  Back to menu'
        [void]$labels.Add($backOption)
        $identityByLabel[$backOption] = ''
        $identity = Read-SgChoice $Header $labels.ToArray() $identityByLabel
        if (-not $identity) { return $null }
        return Resolve-SgProjectCatalogEntry $config $identity -RequireRegistered:($Action -notin @('start','navigate'))
    } else {
        $index = 1
        foreach ($item in $items) {
            if ($Action -eq 'navigate') { Write-Host ("[{0}] {1}" -f $index,$item.Name) }
            else { Write-Host ("[{0}] {1}  {2}  {3}  {4}" -f $index,$item.status,$item.kind,$item.port,$item.Name) }
            $index++
        }
        Write-Host '[0] Back to menu'
        $choice = Read-Host 'Project number'
        if ($choice -eq '0') { return $null }
        if ($choice -notmatch '^\d+$' -or [int]$choice -lt 1 -or [int]$choice -gt $items.Count) { Write-SgWarn 'Invalid project number.'; return $null }
        $selected = $items[[int]$choice - 1]
        return Resolve-SgProjectCatalogEntry $config $selected.Id -RequireRegistered:($Action -notin @('start','navigate'))
    }
}

function Invoke-SgGitHubLogin {
    if (-not $gh) { throw 'GitHub CLI is unavailable. Rerun the ShipGlows full installer.' }
    & $gh auth status --hostname github.com *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-SgInfo 'GitHub authentication will open in your browser. ShipGlows never reads or stores your token.'
        & $gh auth login --hostname github.com --git-protocol https --web
        if ($LASTEXITCODE -ne 0) { throw 'GitHub authentication was cancelled or failed.' }
    }
    # Ensure authenticated private HTTPS clones retrieve credentials from gh even
    # when the account was connected before ShipGlows was installed.
    & $gh auth setup-git
    if ($LASTEXITCODE -ne 0) { throw 'GitHub credential setup failed.' }
    return $true
}

function Get-SelectedRegisteredProject([string]$Header = 'Choose a registered project') {
    return Get-SelectedProject 'unregister' $Header
}

function Show-SgWindowsDashboard {
    $items = @(Get-SgProjectCatalog $config)
    Write-Host ''
    Write-Host 'ShipGlows DevServer Windows' -ForegroundColor Yellow
    Write-Host '============================' -ForegroundColor Yellow
    if ($items.Count -eq 0) { Write-Host 'No projects discovered in the ShipGlows workspace.'; return }
    $index = 1
    foreach ($entry in $items) {
        $status = if ($entry.status) { $entry.status } else { 'unknown' }
        $port = if ([int]$entry.port -gt 0) { [string]$entry.port } else { '-' }
        Write-Host ("[{0}] {1}  {2}  {3}  {4}" -f $index,$status,$entry.kind,$port,$entry.Name)
        $index++
    }
}

function Register-SgClonedProject([string]$Destination) {
    try {
        Register-SgProject $config $Destination | Out-Null
        Write-SgInfo "Registered clone: $Destination"
    } catch {
        Write-SgWarn "Clone completed but was not registered: $($_.Exception.Message)"
    }
}

function Invoke-SgGitHubClone {
    if (-not $choiceUiAvailable) { throw 'The GitHub repository browser requires fzf or Gum; use Enter Git URL instead.' }
    [void](Invoke-SgGitHubLogin)
    $jsonLines = @(& $gh api --paginate '/user/repos?affiliation=owner,organization_member&per_page=100&sort=updated' --jq '.[] | {nameWithOwner: .full_name, description, isPrivate: .private, url: .html_url}')
    if ($LASTEXITCODE -ne 0) { throw 'GitHub repository listing failed.' }
    # Parse one compact JSON object per line so pagination remains compatible
    # with Windows PowerShell 5.1 and does not collapse the picker into one row.
    $repositories = @($jsonLines | Where-Object { $_ } | ForEach-Object { $_ | ConvertFrom-Json })
    if ($repositories.Count -eq 0) { throw 'No GitHub repositories are available for this account.' }
    $installedRepositories = @(Get-SgInstalledGitHubRepositoryIdentities $config $git)
    $repositories = @(Select-SgGitHubCloneCandidates $repositories $installedRepositories)
    if ($repositories.Count -eq 0) {
        Write-SgInfo 'All available GitHub repositories are already installed in the ShipGlows workspace.'
        return
    }
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
    $temporaryDestination = Join-Path $config.Workspace (".$name.shipglows-clone-" + [guid]::NewGuid().ToString('N'))
    # Explicit HTTPS prevents a user's GitHub CLI SSH preference from making
    # the picker depend on their local SSH configuration or keys. Authentication
    # remains owned by GitHub CLI.
    try {
        & $gh repo clone $repository.url $temporaryDestination
        if ($LASTEXITCODE -ne 0) { throw 'GitHub repository clone failed.' }
        Move-Item -LiteralPath $temporaryDestination -Destination $destination -ErrorAction Stop
        Clear-SgProjectCatalogCache $config
    } catch {
        if (Test-Path -LiteralPath $temporaryDestination) {
            Remove-Item -LiteralPath $temporaryDestination -Recurse -Force -ErrorAction SilentlyContinue
        }
        throw
    }
    Register-SgClonedProject $destination
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
    $temporaryDestination = Join-Path $config.Workspace (".$name.shipglows-clone-" + [guid]::NewGuid().ToString('N'))
    try {
        & $git clone -- $url $temporaryDestination
        if ($LASTEXITCODE -ne 0) { throw 'Git clone failed.' }
        Move-Item -LiteralPath $temporaryDestination -Destination $destination -ErrorAction Stop
        Clear-SgProjectCatalogCache $config
    } catch {
        if (Test-Path -LiteralPath $temporaryDestination) {
            Remove-Item -LiteralPath $temporaryDestination -Recurse -Force -ErrorAction SilentlyContinue
        }
        throw
    }
    Register-SgClonedProject $destination
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

function Open-SgManagedProject([object]$Entry) {
    Open-SgProject $config $Entry | Out-Null
}

function Invoke-Navigate {
    $entry = Get-SelectedProject 'navigate'
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

function Get-SgAuthenticationMenuState {
    param($Definition)
    $runner = { param($File,$Arguments,$TimeoutSeconds) Invoke-SgBoundedProcess -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds }
    return Get-SgAuthenticationState -Definition $Definition -Runner $runner
}

function Invoke-SgAuthenticationMenu {
    while ($true) {
        $definitions = @(Get-SgAuthenticationDefinitions)
        $labels = New-Object 'System.Collections.Generic.List[string]'
        $byLabel = @{}
        foreach ($definition in $definitions) {
            $state = Get-SgAuthenticationMenuState $definition
            $label = "$($definition.Category) - $($definition.Name)  [$($state.Status)]"
            [void]$labels.Add($label); $byLabel[$label] = $definition
        }
        [void]$labels.Add('0  Back to menu')
        if ($choiceUiAvailable) {
            $selected = Read-SgChoice 'Authentication - official CLI flows only' $labels.ToArray()
            if (-not $selected -or $selected -eq '0  Back to menu') { return }
        } else {
            Write-Host ''; for($i=0;$i -lt $definitions.Count;$i++){Write-Host ("[{0}] {1}" -f ($i+1),$labels[$i])}; Write-Host '[0] Back to menu'
            $number=Read-Host 'Tool number'; if($number -eq '0'){return}; if($number -notmatch '^\d+$' -or [int]$number -lt 1 -or [int]$number -gt $definitions.Count){Write-SgWarn 'Invalid tool number.';continue}; $selected=$labels[[int]$number-1]
        }
        $definition = $byLabel[$selected]
        $command = Get-SgApplication $definition.Command @()
        if (-not $command) { Write-SgWarn "$($definition.Name) CLI is unavailable. Rerun the full installer."; continue }
        if ($definition.LoginMode -eq 'project') { Write-SgWarn "$($definition.Name) authentication is project-scoped. Navigate to the project and run its official development command."; continue }
        $action = if($choiceUiAvailable){Read-SgChoice "$($definition.Name) authentication" @('Connect or reconnect','Logout','Back')}else{Read-Host 'Choose connect, logout, or back'}
        if (-not $action -or $action -match '^(Back|back)$') { continue }
        if ($action -match '^(Logout|logout)$') {
            $confirm=(Read-Host "Logout $($definition.Name) on this Windows account? [y/N]").Trim().ToLowerInvariant()
            if($confirm -notin @('y','yes')){Write-SgInfo 'Logout cancelled.';continue}
            if(-not @($definition.LogoutArguments).Count){Write-SgWarn "$($definition.Name) has no safe native logout command; use its own account UI.";continue}
            & $command @($definition.LogoutArguments)
        } elseif ($definition.LoginMode -eq 'interactive-cli') {
            Write-SgInfo "$($definition.Name) will open its official interactive authentication flow. ShipGlows never reads or stores credentials."
            & $command
        } else {
            Write-SgInfo "$($definition.Name) will open its official authentication flow. ShipGlows never reads or stores credentials."
            & $command @($definition.LoginArguments)
            if($definition.Name -eq 'GitHub' -and $LASTEXITCODE -eq 0){& $command auth setup-git}
        }
        if($LASTEXITCODE -ne 0){Write-SgWarn "$($definition.Name) authentication was cancelled, failed, or remains provider-managed."}else{Write-SgInfo "$($definition.Name) authentication flow finished; status will be refreshed locally."}
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
        '9  Unregister a project',
        'n  Navigate to a project',
        'a  Authentication',
        'r  Refresh',
        'u  Update ShipGlows',
        '0  Quit ShipGlows'
    )
    while ($true) {
        Show-SgWindowsDashboard
        if ($choiceUiAvailable) {
            $selected = Read-SgChoice 'What do you want to do?' $menuItems
            if (-not $selected) { continue }
            $choice = $selected.Substring(0,1)
        } else {
            Write-Host ''; Write-Host '1) Clone  2) Register  3) Start  4) Stop  5) Restart  6) Logs  7) Open  8) Stop all  9) Unregister  n) Navigate  a) Authentication  r) Refresh  u) Update  0) Quit ShipGlows'
            $choice = Read-Host 'Choice'
        }
        try {
            switch ($choice) {
                '1' { Invoke-Clone }
                '2' { $path = Read-SgInput 'Project path' $config.Workspace; if ($path) { Register-SgProject $config $path | Out-Null } }
                '3' { $entry = Get-SelectedProject 'start'; if ($entry) { Start-SgProject $config $entry.path $Port | Out-Null } }
                '4' { $entry = Get-SelectedProject 'stop'; if ($entry) { Stop-SgProject $config $entry.path } }
                '5' { $entry = Get-SelectedProject 'restart'; if ($entry) { Stop-SgProject $config $entry.path; Start-SgProject $config $entry.path $Port | Out-Null } }
                '6' { $entry = Get-SelectedProject 'logs'; if ($entry) { Invoke-Logs $entry } }
                '7' { $entry = Get-SelectedProject 'open'; if ($entry) { Open-SgManagedProject $entry } }
                '8' { foreach ($entry in @(Read-SgRegistry $config).projects) { Stop-SgProject $config $entry.path } }
                '9' { $entry = Get-SelectedRegisteredProject 'Choose a stopped project to unregister'; if ($entry) { Unregister-SgProject $config $entry.path } }
                'n' { Invoke-Navigate }
                'a' { Invoke-SgAuthenticationMenu }
                'r' { Get-SgProjectCatalog $config -ForceRefresh | Out-Null }
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
        'dashboard' { Show-SgWindowsDashboard }
        'refresh' { Get-SgProjectCatalog $config -ForceRefresh | Out-Null; Show-SgWindowsDashboard }
        'clone' { Invoke-Clone }
        'register' { Register-SgProject $config $ProjectPath | Out-Null }
        'unregister' { if ($ProjectPath) { Unregister-SgProject $config $ProjectPath } else { $entry = Get-SelectedRegisteredProject 'Choose a stopped project to unregister'; if ($entry) { Unregister-SgProject $config $entry.path } } }
        'start' {
            if ($ProjectPath) { Start-SgProject $config $ProjectPath $Port | Out-Null }
            else { $entry = Get-SelectedProject 'start'; if ($entry) { Start-SgProject $config $entry.path $Port | Out-Null } }
        }
        'stop' { if ($ProjectPath) { Stop-SgProject $config $ProjectPath } else { $entry = Get-SelectedProject 'stop'; if ($entry) { Stop-SgProject $config $entry.path } } }
        'restart' {
            if ($ProjectPath) { Stop-SgProject $config $ProjectPath; Start-SgProject $config $ProjectPath $Port | Out-Null }
            else { $entry = Get-SelectedProject 'restart'; if ($entry) { Stop-SgProject $config $entry.path; Start-SgProject $config $entry.path $Port | Out-Null } }
        }
        'logs' { if ($ProjectPath) { $entry = @(Read-SgRegistry $config).projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $ProjectPath) } | Select-Object -First 1; if ($entry -and (Get-SgProjectKind $entry.path) -ne $entry.kind) { throw 'The registered project surface no longer matches its manifest.' } } else { $entry = Get-SelectedProject 'logs' }; if ($entry) { Invoke-Logs $entry } }
        'open' { if ($ProjectPath) { $entry = @(Read-SgRegistry $config).projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $ProjectPath) } | Select-Object -First 1; if ($entry -and (Get-SgProjectKind $entry.path) -ne $entry.kind) { throw 'The registered project surface no longer matches its manifest.' } } else { $entry = Get-SelectedProject 'open' }; if ($entry) { Open-SgManagedProject $entry } }
        'stop-all' { foreach ($entry in @(Read-SgRegistry $config).projects) { Stop-SgProject $config $entry.path } }
        'select-start' { $entry = Get-SelectedProject 'start'; if ($entry) { Start-SgProject $config $entry.path $Port | Out-Null } }
        'select-stop' { $entry = Get-SelectedProject 'stop'; if ($entry) { Stop-SgProject $config $entry.path } }
        'select-unregister' { $entry = Get-SelectedRegisteredProject 'Choose a stopped project to unregister'; if ($entry) { Unregister-SgProject $config $entry.path } }
        'select-restart' { $entry = Get-SelectedProject 'restart'; if ($entry) { Stop-SgProject $config $entry.path; Start-SgProject $config $entry.path $Port | Out-Null } }
        'select-logs' { $entry = Get-SelectedProject 'logs'; if ($entry) { Invoke-Logs $entry } }
        'navigate' { Invoke-Navigate }
        'auth' { Invoke-SgAuthenticationMenu }
        'update' { Invoke-SgUpdate }
        'help' { Show-SgShortcutHelp }
        'exit' { return }
    }
} catch { Write-SgError $_.Exception.Message; exit 1 }
