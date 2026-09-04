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

if ($PSVersionTable.PSEdition -ne 'Core') {
    [Console]::Error.WriteLine('Run ShipGlows through s.cmd or shipglows-dev.cmd; direct Windows PowerShell execution is only a bootstrap surface.')
    exit 70
}
$managedMarker = $env:SHIPGLOWS_MANAGED_PWSH
$currentHost = [IO.Path]::GetFullPath((Get-Process -Id $PID).Path)
if ([string]::IsNullOrWhiteSpace($managedMarker) -or [IO.Path]::GetFullPath($managedMarker) -ine $currentHost) {
    [Console]::Error.WriteLine('ShipGlows refused an unmanaged PowerShell Core host. Use s.cmd or shipglows-dev.cmd.')
    exit 70
}
$expectedManagedRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64')).TrimEnd('\')
if (-not $currentHost.StartsWith($expectedManagedRoot + '\',[StringComparison]::OrdinalIgnoreCase)) {
    [Console]::Error.WriteLine('ShipGlows refused a PowerShell host outside its managed toolchain coordinate.')
    exit 70
}

# Keep the environment control plane outside the DevServer bootstrap: its
# read-only commands must not create the workspace, registry, or menu cache.
if ($Action.Trim().ToLowerInvariant() -eq 'env') {
    if (@($ShortcutPath).Count -ne 1 -or $ShortcutPath[0].Trim().ToLowerInvariant() -notin @('inspect','plan','verify','status','apply','prepare','prepare-apply')) {
        [Console]::Error.WriteLine('Usage: s env <inspect|plan|verify|status|apply|prepare|prepare-apply> [-ProjectPath <path>] [-PlanDigest <digest>]')
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

# Private data remains a redacted control plane: no project scan, no startup,
# and no ambient agent access.
if ($Action.Trim().ToLowerInvariant() -eq 'private-data') {
    $privateDataCommandIndex = if (@($ShortcutPath).Count -ge 3 -and $ShortcutPath[0].Trim().ToLowerInvariant() -eq '--format') { 2 } else { 0 }
    if (@($ShortcutPath).Count -le $privateDataCommandIndex -or $ShortcutPath[$privateDataCommandIndex].Trim().ToLowerInvariant() -notin @('status','doctor','capability','sync','connect','migrate','open')) {
        [Console]::Error.WriteLine('Usage: s private-data <status|doctor|capability <namespace> <read|write>|connect --repo <URL> [--existing --dir <absolute-path>] [--apply]|migrate --manifest <absolute-path> [--apply]|open [--apply]|sync <pull|push> [--apply]>')
        exit 2
    }
    $privateDataCandidates = @(
        [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\private_data.py')),
        [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cli\private_data.py'))
    )
    $privateDataScript = $privateDataCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $privateDataScript) {
        [Console]::Error.WriteLine('ShipGlows private-data control-plane script not found in the source or installed runtime.')
        exit 2
    }
    $python = @(Get-Command python.exe -CommandType Application -ErrorAction SilentlyContinue; Get-Command python3.exe -CommandType Application -ErrorAction SilentlyContinue) | Where-Object { $_ } | Select-Object -First 1
    if (-not $python) {
        [Console]::Error.WriteLine('ShipGlows private-data commands require Python 3.')
        exit 2
    }
    & $python.Source $privateDataScript @($ShortcutPath)
    exit $LASTEXITCODE
}

function Test-SgImmediateAction([string]$RequestedAction, [string[]]$RemainingPath) {
    return @($RemainingPath).Count -eq 0 -and $RequestedAction.Trim().ToLowerInvariant() -in @('h','help','x','exit')
}

function Show-SgShortcutHelp {
    Write-Host ''
    Write-Host 'ShipGlows Windows shortcuts' -ForegroundColor Cyan
    Write-Host '  s d      Dashboard'
    Write-Host '  s e      Start a project'
    Write-Host '  s status                           Show every project surface and state'
    Write-Host '  s status -ProjectPath <path>       Show one project, its port role, and next action'
    Write-Host '  s start -ProjectPath <path>       Start a web project, app, or Chrome extension'
    Write-Host '  s reload -ProjectPath <path>      Hot reload an attached managed Flutter session'
    Write-Host '  s open -ProjectPath <path>        Open the URL, app session, or extension loading tools'
    Write-Host '  s stop -ProjectPath <path>        Stop the exact managed project'
    Write-Host '  s m r    Restart a project'
    Write-Host '  s m t    Stop a project'
    Write-Host '  s m w    Unregister a stopped project (files are preserved)'
    Write-Host '  s m o    Stop all projects'
    Write-Host '  s m l    View project logs'
    Write-Host '  s m n    Navigate to a project in a child PowerShell shell'
    Write-Host '  s a      Manage CLI authentication with official interactive flows'
    Write-Host '  s capabilities    Print the closed CLI capability snapshot as JSON'
    Write-Host '  s private-data ...              Manage the explicit private-data connection and capability'
    Write-Host '  s env inspect|plan|verify|status|apply    Manage the current project environment'
    Write-Host '  s u      Update ShipGlows from the active stable or linked channel'
    Write-Host '  s update status  Show the active ShipGlows update channel'
    Write-Host '  s tools status   Preview global developer-tool updates without changing them'
    Write-Host '  s tools update   Update ShipGlows-owned global developer tools after confirmation'
    Write-Host '  s x      Quit ShipGlows'
    Write-Host '  s         Interactive menu'
    Write-Host ''
    Write-Host 'Project journeys' -ForegroundColor Cyan
    Write-Host '  Web project      Start -> Open the managed local URL -> Stop'
    Write-Host '  Flutter app      Start live (Windows by default when supported) -> Develop/reload -> Stop'
    Write-Host '                   .shipglows.env can explicitly select windows, android, chrome, or web-server.' -ForegroundColor DarkGray
    Write-Host '  Chrome extension Start -> Open / load project -> Developer mode -> Load unpacked -> Stop'
    Write-Host '  Chrome support currently targets CRXJS projects with @crxjs/vite-plugin and dev:chrome.' -ForegroundColor DarkGray
    Write-Host ''
    Write-Host 'Windows uses native project manifests and tools; Linux environment, PM2 and Caddy commands remain unavailable.' -ForegroundColor DarkGray
}

if (Test-SgImmediateAction $Action $ShortcutPath) {
    $immediateAction = $Action.Trim().ToLowerInvariant()
    if ($immediateAction -in @('x','exit')) { exit 0 }
    Show-SgShortcutHelp
    exit 0
}

$module = Join-Path $PSScriptRoot 'ShipGlows.DevServer.psm1'
Import-Module $module -Force -DisableNameChecking
$runtimeStatusModule = Join-Path $PSScriptRoot 'ShipGlows.RuntimeStatus.psm1'
Import-Module $runtimeStatusModule -Force -DisableNameChecking
$authModule = Join-Path $PSScriptRoot 'ShipGlows.Auth.psm1'
$script:authenticationModuleLoaded = $false
$config = Get-SgDevConfig
Ensure-SgDirectory $config.Workspace
Ensure-SgDirectory $config.LogDirectory

function Invoke-SgRequiredStart([string]$Path, [int]$RequestedPort = 0, [switch]$Visible) {
    $results = New-Object 'System.Collections.Generic.List[object]'
    Start-SgProject $config $Path $RequestedPort -FlutterVisible:$Visible | ForEach-Object {
        $item = $_
        if ($null -ne $item -and $item.PSObject.Properties['status'] -and $item.PSObject.Properties['path'] -and $item.PSObject.Properties['lastError']) {
            [void]$results.Add($item)
        } else {
            Write-Host ([string]$item)
        }
    }
    if ($results.Count -ne 1) { throw 'Application startup did not return one structured result.' }
    $result = $results[0]
    if ($result.status -eq 'error') {
        $reason = if ($result.lastError) { [string]$result.lastError } else { 'Application startup failed.' }
        throw $reason
    }
    if ($result.status -ne 'running') { throw "Application startup returned unexpected status: $($result.status)" }
    return $result
}

function Resolve-SgAction([string]$RequestedAction, [string[]]$RemainingPath) {
    $namedActions = @('menu','dashboard','status','start','reload','stop','restart','register','unregister','clone','logs','open','stop-all','refresh','navigate','auth','capabilities','update','update-status','tools-status','tools-update','refresh-update-status','help','exit')
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
        'update status' = 'update-status'
        'tools status' = 'tools-status'
        'tools update' = 'tools-update'
        'h'   = 'help'
        'x'   = 'exit'
    }
    if ($shortcuts.ContainsKey($shortcut)) { return $shortcuts[$shortcut] }
    throw "Unknown Windows shortcut path: $shortcut. Run 's h' to list supported shortcuts."
}

try { $Action = Resolve-SgAction $Action $ShortcutPath }
catch {
    Write-SgError $_.Exception.Message
    exit 2
}

# Update routes are recovery paths: an older installed runtime may be unable to
# refresh a capability snapshot that a newer runtime has already corrected.
# Let those routes reach the official updater/status implementation first.
if ($Action -notin @('update','update-status')) {
    [void](Write-SgCliCapabilitySnapshot $config)
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
$git = $null
$gh = $null
$curl = $null

function Initialize-SgGitTools([switch]$IncludeGitHub) {
    if (-not $git) { $script:git = Get-SgApplication 'git.exe' @((Join-Path $programFiles 'Git\cmd\git.exe'), (Join-Path $programFilesX86 'Git\cmd\git.exe')) }
    if ($IncludeGitHub -and -not $gh) { $script:gh = Get-SgApplication 'gh.exe' @((Join-Path $programFiles 'GitHub CLI\gh.exe'), (Join-Path $programFilesX86 'GitHub CLI\gh.exe')) }
}

function Import-SgAuthenticationModule {
    if ($script:authenticationModuleLoaded) { return }
    Import-Module $authModule -Force -DisableNameChecking
    $script:authenticationModuleLoaded = $true
}

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
    $items = @(Get-SgProjectCatalogForDisplay $config)
    switch ($Action) {
        'start' { $items = @($items) }
        'navigate' { $items = @($items) }
        'logs' { $items = @($items | Where-Object { $_.IsRegistered -and $_.logPath }) }
        'open' { $items = @($items | Where-Object { $_.IsRegistered }) }
        default { $items = @($items | Where-Object { $_.IsRegistered }) }
    }
    if ($items.Count -eq 0) {
        if ($Action -eq 'open') { Write-SgWarn 'No registered project is available to open. Clone or register a project first.' }
        else { Write-SgWarn 'No projects discovered in the ShipGlows workspace.' }
        return $null
    }
    if ($choiceUiAvailable) {
        $labels = New-Object 'System.Collections.Generic.List[string]'
        $identityByLabel = @{}
        foreach ($item in $items) {
            $label = if ($Action -eq 'navigate') { [string]$item.Name } else { "$($item.Name)  $(Format-SgProjectStatus $item)" }
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
            else { Write-Host ("[{0}] {1}  {2}" -f $index,$item.Name,(Format-SgProjectStatus $item)) }
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
    Initialize-SgGitTools -IncludeGitHub
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

function Show-SgShipGlowsStatus {
    $status = Read-SgShipGlowsStatusCache $config
    $version = if ($status -and $status.installedVersion) { [string]$status.installedVersion } else { Get-SgInstalledShipGlowsVersion $config }
    if (-not $version) { $version = '…' }
    $level = if ($status) { [string]$status.level } else { 'unknown' }
    $color = switch ($level) {
        'current' { 'Green' }
        'update' { 'DarkYellow' }
        'major-update' { 'Red' }
        default { 'DarkGray' }
    }
    Write-Host ("ShipGlows v{0}" -f $version) -ForegroundColor $color
    if ($status -and $status.level -ne 'current') { Write-Host ([string]$status.message) -ForegroundColor $color }
    elseif (-not $status) { Write-Host 'Verification de mise a jour en arriere-plan...' -ForegroundColor DarkGray }
}

function Show-SgWindowsDashboard {
    $items = @(Get-SgProjectCatalogForDisplay $config)
    Write-Host ''
    Write-Host 'ShipGlows DevServer Windows' -ForegroundColor Yellow
    Write-Host '============================' -ForegroundColor Yellow
    Show-SgShipGlowsStatus
    if ($items.Count -eq 0) { Write-Host 'No projects discovered in the ShipGlows workspace.'; return }
    $index = 1
    foreach ($entry in $items) {
        Write-Host ("[{0}] {1}  {2}" -f $index,$entry.Name,(Format-SgProjectStatus $entry))
        $index++
    }
}

function Show-SgProjectStatus([object]$Entry) {
    if (-not $Entry) { throw 'No registered project was selected.' }
    $flutterDevice = if ($Entry.PSObject.Properties['flutterDevice']) { [string]$Entry.flutterDevice } else { '' }
    $experience = Get-SgProjectExperience ([string]$Entry.kind) ([int]$Entry.port) $flutterDevice
    Write-Host ''
    Write-Host ([string]$Entry.Name) -ForegroundColor Cyan
    Write-Host (Format-SgProjectStatus $Entry)
    Write-Host "Open: $($experience.OpenAction)"
    if ($Entry.status -in @('starting','running')) {
        Write-Host "Next: $($experience.OpenNextAction)"
    } else {
        Write-Host "Next: run s start -ProjectPath `"$($Entry.path)`"."
    }
}

function Write-SgRegisteredProjectGuidance([object]$Entry) {
    $flutterDevice = if ($Entry.PSObject.Properties['flutterDevice']) { [string]$Entry.flutterDevice } else { '' }
    $experience = Get-SgProjectExperience ([string]$Entry.kind) ([int]$Entry.port) $flutterDevice
    Write-SgInfo "$($experience.Label) detected: $($Entry.Name)"
    Write-SgInfo "Next: run s start -ProjectPath `"$($Entry.path)`"."
}

function Invoke-SgRegisterProject([string]$Path, [string]$SuccessLabel = 'Registered project') {
    $registered = @(Register-SgProject $config $Path)
    if ($registered.Count -eq 0) { throw "No runnable surface was registered for: $Path" }
    Write-SgInfo "$SuccessLabel`: $Path"
    foreach ($entry in $registered) { Write-SgRegisteredProjectGuidance $entry }
}

function Register-SgClonedProject([string]$Destination) {
    try {
        Invoke-SgRegisterProject $Destination 'Registered clone'
    } catch {
        throw "Clone completed but project preparation failed for '$Destination': $($_.Exception.Message)"
    }
    $shellPath = (Get-Process -Id $PID).Path
    $preparationOutput = & $shellPath -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath env prepare -ProjectPath $Destination | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "Clone completed but configuration diagnosis failed for '$Destination'."
    }
    try {
        $preparation = $preparationOutput | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Clone completed but configuration diagnosis returned invalid output for '$Destination': $($_.Exception.Message)"
    }
    Write-SgInfo "Configuration diagnosis: $($preparation.classification)"
    foreach ($item in @($preparation.notices) + @($preparation.blocked)) {
        Write-SgWarn "$($item.path): $($item.message)"
    }
    if ($preparation.classification -eq 'repairable') {
        Write-SgWarn ('Review then apply the proposed ShipGlows configuration with: s env prepare-apply -ProjectPath "{0}" -PlanDigest {1}' -f $Destination, $preparation.digest)
    }
    if ($preparation.classification -eq 'blocked') {
        throw "Clone completed but configuration diagnosis found blocking errors for '$Destination'. Existing project files were preserved."
    }
    Write-SgInfo "Registered clone: $Destination"
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
    Initialize-SgGitTools
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
    $shell = $env:SHIPGLOWS_MANAGED_PWSH
    if (-not (Test-Path -LiteralPath $shell -PathType Leaf)) { throw 'The managed PowerShell runtime is unavailable for project navigation.' }

    Write-SgInfo "Opening a child PowerShell shell in $($entry.path). Type exit to return."
    Push-Location -LiteralPath $entry.path
    try { & $shell -NoLogo -NoProfile -ExecutionPolicy Bypass -NoExit }
    finally { Pop-Location }
}

function Get-SgUpdateSource {
    param([switch]$AllowDirty)
    $statePath = Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'development-channel.json'
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        return [pscustomobject]@{ Channel='stable'; Root=''; Branch='main'; Upstream='origin/main'; Installer=''; Skills='managed' }
    }
    try { $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json }
    catch { throw 'The ShipGlows developer-channel state is invalid; update stopped before bootstrap.' }
    if ($state.channel -cne 'linked' -or [string]::IsNullOrWhiteSpace([string]$state.root) -or -not [IO.Path]::IsPathRooted([string]$state.root)) {
        throw 'The ShipGlows developer-channel state is incomplete; update stopped before bootstrap.'
    }
    $root = [IO.Path]::GetFullPath([string]$state.root)
    $installer = Join-Path $root 'install-shipglows.ps1'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
        throw 'The linked ShipGlows checkout is incomplete; update stopped before bootstrap.'
    }
    $git = Get-SgApplication 'git.exe' @()
    if (-not $git) { throw 'Git is required to update a linked ShipGlows checkout.' }
    $insideWorkTree = (& $git -C $root rev-parse --is-inside-work-tree 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or $insideWorkTree -ne 'true') {
        throw 'The linked ShipGlows checkout is incomplete; update stopped before bootstrap.'
    }
    $dirty = @(& $git -C $root status --porcelain)
    if ($LASTEXITCODE -ne 0) { throw 'The linked ShipGlows checkout could not be inspected.' }
    if ($dirty.Count -gt 0 -and -not $AllowDirty) {
        throw "The linked ShipGlows checkout has uncommitted changes, so the update stopped to preserve them. Inspect them with: git -C `"$root`" status --short. Commit or deliberately resolve those changes, then retry 's update'. No files were stashed or replaced."
    }
    $branch = (& $git -C $root branch --show-current).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $branch) { throw 'The linked ShipGlows checkout is detached; update stopped before bootstrap.' }
    $upstream = (& $git -C $root rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $upstream) { throw "The linked ShipGlows branch '$branch' has no upstream; update stopped before bootstrap." }
    return [pscustomobject]@{ Channel='linked'; Root=$root; Branch=$branch; Upstream=$upstream; Installer=$installer; Skills='live'; Dirty=($dirty.Count -gt 0) }
}

function Show-SgUpdateStatus {
    $source = Get-SgUpdateSource -AllowDirty
    $dirty = if ($source.PSObject.Properties['Dirty'] -and $source.Dirty) { 'dirty' } else { 'clean' }
    Write-Host "ShipGlows update status: channel=$($source.Channel) branch=$($source.Branch) upstream=$($source.Upstream) skills=$($source.Skills) source=$dirty" -ForegroundColor Cyan
    if ($source.Channel -eq 'linked') { Write-Host 'Linked skills already follow the checkout. Start a new Codex or Claude session after source changes.' -ForegroundColor DarkGray }
}

function Get-SgDeveloperToolAllowlist {
    return @(Get-SgDeveloperToolWingetDefinitions | ForEach-Object { "$($_.Name) ($($_.PackageId))" }) + @(
        'pnpm',
        'ShipGlows-managed coding agents, service CLIs, wrappers, and Playwright runtime'
    )
}

function Get-SgDeveloperToolWingetDefinitions {
    return @(
        [pscustomobject]@{Name='Git';PackageId='Git.Git'},
        [pscustomobject]@{Name='GitHub CLI';PackageId='GitHub.cli'},
        [pscustomobject]@{Name='Node.js LTS and bundled npm';PackageId='OpenJS.NodeJS.LTS'},
        [pscustomobject]@{Name='mise';PackageId='jdx.mise'},
        [pscustomobject]@{Name='uv';PackageId='astral-sh.uv'},
        [pscustomobject]@{Name='Google Cloud CLI';PackageId='Google.CloudSDK'},
        [pscustomobject]@{Name='Doppler CLI';PackageId='Doppler.Doppler'}
    )
}

function Show-SgDeveloperToolsStatus {
    Write-Host 'ShipGlows developer-tool update status (read-only)' -ForegroundColor Cyan
    Write-Host 'Managed scope:' -ForegroundColor DarkGray
    Get-SgDeveloperToolAllowlist | ForEach-Object { Write-Host "  - $_" }
    Write-Host 'Project manifests, lockfiles, node_modules, SDK licences, IDEs, and Windows Update are excluded.' -ForegroundColor DarkGray

    $toolModule = Join-Path $PSScriptRoot 'ShipGlows.MobileToolchain.psm1'
    if (-not (Test-Path -LiteralPath $toolModule -PathType Leaf)) { throw 'The bounded tool-status runner is unavailable.' }
    Import-Module $toolModule -Force -DisableNameChecking

    $winget = Get-SgApplication 'winget.exe'
    if ($winget) {
        Write-Host ''; Write-Host 'WinGet allowlisted update preview:' -ForegroundColor Cyan
        foreach ($definition in Get-SgDeveloperToolWingetDefinitions) {
            $result = Invoke-SgBoundedProcess -File $winget -Arguments @('list','--id',$definition.PackageId,'--exact','--source','winget','--upgrade-available','--disable-interactivity') -TimeoutSeconds 60
            Write-Host "$($definition.Name):" -ForegroundColor DarkGray
            if ($result.TimedOut) { Write-SgWarn '  preview timed out.' }
            elseif ($result.Output) { Write-Host $result.Output.Trim() }
            elseif ($result.ExitCode -ne 0) { Write-Host '  no available update was reported.' -ForegroundColor Green }
            else { Write-Host '  no available update was reported.' -ForegroundColor Green }
        }
    } else { Write-SgWarn 'WinGet is unavailable; WinGet-managed tools could not be checked.' }

    $npm = Get-SgApplication 'npm.cmd'
    if ($npm) {
        foreach ($definition in @(@{Name='npm';Command=$npm},@{Name='pnpm';Command=(Get-SgApplication 'pnpm.cmd')})) {
            $installed = if ($definition.Command) { Invoke-SgBoundedProcess -File $definition.Command -Arguments @('--version') -TimeoutSeconds 30 } else { $null }
            $latest = Invoke-SgBoundedProcess -File $npm -Arguments @('view',"$($definition.Name)@latest",'version','--registry=https://registry.npmjs.org/') -TimeoutSeconds 45
            $installedText = if ($installed -and -not $installed.TimedOut -and $installed.ExitCode -eq 0) { $installed.Output.Trim() } else { 'unavailable' }
            $latestText = if (-not $latest.TimedOut -and $latest.ExitCode -eq 0) { $latest.Output.Trim() } else { 'unavailable' }
            Write-Host "$($definition.Name): installed=$installedText latest=$latestText"
        }
    } else { Write-SgWarn 'npm is unavailable; npm and pnpm registry versions could not be checked.' }
}

function Invoke-SgDeveloperToolsUpdate {
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) {
        throw 'Developer-tool updates require an interactive console for explicit confirmation.'
    }
    Write-Host 'ShipGlows will update only these global developer-tool surfaces:' -ForegroundColor Cyan
    Get-SgDeveloperToolAllowlist | ForEach-Object { Write-Host "  - $_" }
    Write-Host 'No project dependency, manifest, lockfile, credential, SDK licence, IDE, or Windows Update will be changed.' -ForegroundColor DarkGray
    $choice = Read-Host 'Update global developer tools now? [y/N]'
    if ($choice.Trim().ToLowerInvariant() -notin @('y','yes','o','oui')) { Write-SgInfo 'Developer-tool update cancelled; nothing was changed.'; return }

    $shipglowsDir = Split-Path -Parent $PSScriptRoot
    $installer = Join-Path $shipglowsDir 'cli\windows\install-devserver.ps1'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw 'The installed ShipGlows developer-tool convergence engine is unavailable; run s update first.' }
    Write-SgInfo 'Updating global developer tools without changing the ShipGlows update channel...'
    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $installer -ShipglowsDir $shipglowsDir -UpdateDeveloperTools
    if ($LASTEXITCODE -ne 0) { throw 'Developer-tool update failed.' }
    Write-SgInfo 'Developer-tool update completed. Open a fresh shell before using updated global commands.'
}

function Invoke-SgUpdate {
    $source = Get-SgUpdateSource
    if ($source.Channel -eq 'linked') {
        $installerPath = $source.Installer
        # A linked checkout is the maintainer channel, not an ordinary runtime
        # install.  Preserve that surface so its live Codex skills are
        # reconciled after the runtime payload is refreshed.
        $installerArguments = @('-InstallMode','full','-InstallSurface','maintainer','-Branch',$source.Branch)
    } else {
        if (-not $curl) { $script:curl = Get-SgApplication 'curl.exe' @((Join-Path $env:WINDIR 'System32\curl.exe')) }
        if (-not $curl) { throw 'curl.exe is unavailable. Download install-shipglows.ps1 from the official ShipGlows repository.' }
        $installerUrl = 'https://raw.githubusercontent.com/commandglows/shipglows/main/install-shipglows.ps1'
        $installerPath = $null
        $installerArguments = @('-InstallMode','full')
    }
    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("shipglows-update-" + [guid]::NewGuid().ToString('N'))
    $shipglowsDir = Split-Path -Parent $PSScriptRoot

    try {
        if ($source.Channel -eq 'stable') {
            [void][IO.Directory]::CreateDirectory($tempRoot)
            $installerPath = Join-Path $tempRoot 'install-shipglows.ps1'
            Write-SgInfo 'Downloading the current ShipGlows Windows installer...'
            & $curl --proto '=https' --tlsv1.2 -fsSL $installerUrl -o $installerPath
            if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
                throw 'ShipGlows installer download failed.'
            }
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

        Write-SgInfo "Updating ShipGlows from $($source.Channel) channel ($($source.Branch))..."
        & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $installerPath @installerArguments -ShipglowsDir $shipglowsDir
        if ($LASTEXITCODE -ne 0) { throw 'ShipGlows update failed.' }
        Write-SgInfo 'Update completed. Run s again to use the updated CLI.'
    } finally {
        if ($source.Channel -eq 'stable' -and (Test-Path -LiteralPath $tempRoot)) {
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
    Import-SgAuthenticationModule
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

$script:catalogRefreshPath = "$($config.ProjectIndexPath).refreshing"
$script:catalogRefreshObserved = $false
$script:backgroundRefreshStarted = $false
$script:updateStatusRefreshStarted = $false

function Start-SgBackgroundUpdateStatusRefresh {
    if ($script:updateStatusRefreshStarted) { return }
    $script:updateStatusRefreshStarted = $true
    $cachedStatus = Read-SgShipGlowsStatusCache $config
    if (Test-SgShipGlowsStatusCacheFresh $cachedStatus) { return }
    $paths = Get-SgRuntimeStatusPaths $config
    $claim = $null
    try { $claim = [IO.File]::Open($paths.RefreshPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None) }
    catch [IO.IOException] { return }
    finally { if ($claim) { $claim.Dispose() } }

    try {
        $startInfo = [Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $env:SHIPGLOWS_MANAGED_PWSH
        $startInfo.Arguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" refresh-update-status"
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
        $startInfo.RedirectStandardInput = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $process = [Diagnostics.Process]::Start($startInfo)
        if (-not $process) { throw 'Background ShipGlows update check did not start.' }
        $process.StandardInput.Close()
        $process.Dispose()
    } catch {
        Remove-Item -LiteralPath $paths.RefreshPath -Force -ErrorAction SilentlyContinue
        $script:updateStatusRefreshStarted = $false
    }
}

function Complete-SgBackgroundCatalogRefresh {
    if ($script:catalogRefreshObserved -and -not (Test-Path -LiteralPath $script:catalogRefreshPath -PathType Leaf)) {
        if (-not (Test-SgProjectCatalogRefreshRequired $config -DiskOnly)) {
            Clear-SgProjectCatalogMemoryCache $config
        } else {
            # Allow the next menu iteration to retry a failed or invalidated
            # refresh instead of pinning stale state for the whole session.
            $script:backgroundRefreshStarted = $false
        }
        $script:catalogRefreshObserved = $false
    }
}

function Start-SgBackgroundCatalogRefresh {
    if ($script:backgroundRefreshStarted) { return }
    $script:backgroundRefreshStarted = $true
    if (Test-Path -LiteralPath $script:catalogRefreshPath -PathType Leaf) {
        if (((Get-Date) - (Get-Item -LiteralPath $script:catalogRefreshPath).LastWriteTime).TotalMinutes -lt 5) { $script:catalogRefreshObserved = $true; return }
        Remove-Item -LiteralPath $script:catalogRefreshPath -Force -ErrorAction SilentlyContinue
    }
    $claim = $null
    try { $claim = [IO.File]::Open($script:catalogRefreshPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None) }
    catch [IO.IOException] { $script:catalogRefreshObserved = $true; return }
    finally { if ($claim) { $claim.Dispose() } }

    $refresher = Join-Path $PSScriptRoot 'ShipGlows.ProjectCatalogRefresh.ps1'
    $powershell = $env:SHIPGLOWS_MANAGED_PWSH
    if (-not (Test-Path -LiteralPath $refresher -PathType Leaf) -or $refresher -match '["\r\n]') {
        Remove-Item -LiteralPath $script:catalogRefreshPath -Force -ErrorAction SilentlyContinue
        $script:backgroundRefreshStarted = $false
        return
    }
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $powershell
    $startInfo.Arguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$refresher`""
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.EnvironmentVariables['SHIPGLOWS_CATALOG_WORKSPACE'] = $config.Workspace
    $startInfo.EnvironmentVariables['SHIPGLOWS_CATALOG_RUNTIME'] = $config.RuntimeDirectory
    try {
        $process = [Diagnostics.Process]::Start($startInfo)
        if (-not $process) { throw 'Background refresh process did not start.' }
        $process.StandardInput.Close()
        $process.Dispose()
        $script:catalogRefreshObserved = $true
    } catch {
        Remove-Item -LiteralPath $script:catalogRefreshPath -Force -ErrorAction SilentlyContinue
        $script:backgroundRefreshStarted = $false
    }
}

function Wait-SgBackgroundCatalogRefresh {
    $deadline = (Get-Date).AddSeconds(10)
    while ((Test-Path -LiteralPath $script:catalogRefreshPath -PathType Leaf) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 50 }
}

function Invoke-Menu {
    $menuItems = @(
        '1  Clone a repository',
        '2  Register a local project',
        '3  Start a project',
        '4  Stop a project',
        '5  Restart a project',
        '6  View logs',
        '7  Open / load project',
        '8  Stop all projects',
        '9  Unregister a project',
        'n  Navigate to a project',
        'a  Authentication',
        'r  Refresh',
        't  Update developer tools',
        'u  Update ShipGlows',
        '0  Quit ShipGlows'
    )
    while ($true) {
        Complete-SgBackgroundCatalogRefresh
        Start-SgBackgroundCatalogRefresh
        Start-SgBackgroundUpdateStatusRefresh
        if ($choiceUiAvailable) {
            $selected = Read-SgChoice 'What do you want to do?' $menuItems
            if (-not $selected) { continue }
            $choice = $selected.Substring(0,1)
        } else {
            Write-Host ''; Write-Host '1) Clone  2) Register  3) Start  4) Stop  5) Restart  6) Logs  7) Open  8) Stop all  9) Unregister  n) Navigate  a) Authentication  r) Refresh  t) Update tools  u) Update ShipGlows  0) Quit ShipGlows'
            $choice = Read-Host 'Choice'
        }
        # The user's think time is the refresh window. Adopt a completed
        # background snapshot before dispatch without delaying the command.
        Complete-SgBackgroundCatalogRefresh
        try {
            switch ($choice) {
                '1' { Invoke-Clone }
                '2' { $path = Read-SgInput 'Project path' $config.Workspace; if ($path) { Invoke-SgRegisterProject $path } }
                '3' { $entry = Get-SelectedProject 'start'; if ($entry) { Invoke-SgRequiredStart $entry.path $Port | Out-Null } }
                '4' { $entry = Get-SelectedProject 'stop'; if ($entry) { [void](Stop-SgProject $config $entry.path) } }
                '5' { $entry = Get-SelectedProject 'restart'; if ($entry) { [void](Stop-SgProject $config $entry.path); Invoke-SgRequiredStart $entry.path $Port | Out-Null } }
                '6' { $entry = Get-SelectedProject 'logs'; if ($entry) { Invoke-Logs $entry } }
                '7' { $entry = Get-SelectedProject 'open'; if ($entry) { Open-SgManagedProject $entry } }
                '8' { foreach ($entry in @(Read-SgRegistry $config).projects) { [void](Stop-SgProject $config $entry.path) } }
                '9' { $entry = Get-SelectedRegisteredProject 'Choose a stopped project to unregister'; if ($entry) { Unregister-SgProject $config $entry.path } }
                'n' { Invoke-Navigate }
                'a' { Invoke-SgAuthenticationMenu }
                'r' { Wait-SgBackgroundCatalogRefresh; Get-SgProjectCatalog $config -ForceRefresh | Out-Null }
                't' { Invoke-SgDeveloperToolsUpdate; return }
                'u' { Invoke-SgUpdate; return }
                '0' { return }
                default { Write-SgWarn 'Unknown choice.' }
            }
        } catch { Write-SgError $_.Exception.Message }
        if ($choice -eq 'u') { return }
        if (-not $choiceUiAvailable) { Read-Host 'Press Enter to continue' | Out-Null }
    }
}

try {
    switch ($Action) {
        'menu' { Invoke-Menu }
        'dashboard' { Show-SgWindowsDashboard; Start-SgBackgroundUpdateStatusRefresh }
        'status' {
            if ($ProjectPath) {
                $path = ConvertTo-SgCanonicalPath $ProjectPath
                $entry = @((Reconcile-SgRegistry $config).projects | Where-Object { $_.path -eq $path }) | Select-Object -First 1
                if (-not $entry) { throw "Project is not registered: $path" }
                Show-SgProjectStatus $entry
            } else { Show-SgWindowsDashboard }
        }
        'refresh' { Get-SgProjectCatalog $config -ForceRefresh | Out-Null; Show-SgWindowsDashboard }
        'clone' { Invoke-Clone }
        'register' { Invoke-SgRegisterProject $ProjectPath }
        'unregister' { if ($ProjectPath) { Unregister-SgProject $config $ProjectPath } else { $entry = Get-SelectedRegisteredProject 'Choose a stopped project to unregister'; if ($entry) { Unregister-SgProject $config $entry.path } } }
        'start' {
            if ($ProjectPath) { Invoke-SgRequiredStart $ProjectPath $Port | Out-Null }
            else { $entry = Get-SelectedProject 'start'; if ($entry) { Invoke-SgRequiredStart $entry.path $Port | Out-Null } }
        }
        'reload' {
            if (-not $ProjectPath) { throw 'Usage: s reload -ProjectPath <path>' }
            $path = ConvertTo-SgCanonicalPath $ProjectPath
            $entry = @((Reconcile-SgRegistry $config).projects | Where-Object { $_.path -eq $path }) | Select-Object -First 1
            if (-not $entry) { throw "Project is not registered: $path" }
            if ($entry.kind -ne 'flutter-web' -or $entry.status -ne 'running') { throw 'Reload requires a running managed Flutter session.' }
            [void](Invoke-SgFlutterSupervisorCommand $entry 'reload' 15)
            Write-SgInfo "$($entry.name) reload succeeded"
        }
        'stop' { if ($ProjectPath) { [void](Stop-SgProject $config $ProjectPath) } else { $entry = Get-SelectedProject 'stop'; if ($entry) { [void](Stop-SgProject $config $entry.path) } } }
        'restart' {
            if ($ProjectPath) { [void](Stop-SgProject $config $ProjectPath); Invoke-SgRequiredStart $ProjectPath $Port | Out-Null }
            else { $entry = Get-SelectedProject 'restart'; if ($entry) { [void](Stop-SgProject $config $entry.path); Invoke-SgRequiredStart $entry.path $Port | Out-Null } }
        }
        'logs' { if ($ProjectPath) { $entry = @(Read-SgRegistry $config).projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $ProjectPath) } | Select-Object -First 1; if ($entry -and (Get-SgProjectKind $entry.path) -ne $entry.kind) { throw 'The registered project surface no longer matches its manifest.' } } else { $entry = Get-SelectedProject 'logs' }; if ($entry) { Invoke-Logs $entry } }
        'open' { if ($ProjectPath) { $entry = @(Read-SgRegistry $config).projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $ProjectPath) } | Select-Object -First 1; if ($entry -and (Get-SgProjectKind $entry.path) -ne $entry.kind) { throw 'The registered project surface no longer matches its manifest.' } } else { $entry = Get-SelectedProject 'open' }; if ($entry) { Open-SgManagedProject $entry } }
        'stop-all' { foreach ($entry in @(Read-SgRegistry $config).projects) { [void](Stop-SgProject $config $entry.path) } }
        'select-start' { $entry = Get-SelectedProject 'start'; if ($entry) { Invoke-SgRequiredStart $entry.path $Port | Out-Null } }
        'select-stop' { $entry = Get-SelectedProject 'stop'; if ($entry) { [void](Stop-SgProject $config $entry.path) } }
        'select-unregister' { $entry = Get-SelectedRegisteredProject 'Choose a stopped project to unregister'; if ($entry) { Unregister-SgProject $config $entry.path } }
        'select-restart' { $entry = Get-SelectedProject 'restart'; if ($entry) { [void](Stop-SgProject $config $entry.path); Invoke-SgRequiredStart $entry.path $Port | Out-Null } }
        'select-logs' { $entry = Get-SelectedProject 'logs'; if ($entry) { Invoke-Logs $entry } }
        'navigate' { Invoke-Navigate }
        'auth' { Invoke-SgAuthenticationMenu }
        'capabilities' { Read-SgCliCapabilitySnapshot $config | ConvertTo-Json -Depth 5 -Compress }
        'update' { Invoke-SgUpdate }
        'update-status' { Show-SgUpdateStatus }
        'tools-status' { Show-SgDeveloperToolsStatus }
        'tools-update' { Invoke-SgDeveloperToolsUpdate }
        'refresh-update-status' {
            $paths = Get-SgRuntimeStatusPaths $config
            try { Update-SgShipGlowsStatusCache $config { Get-SgOfficialShipGlowsVersion } | Out-Null }
            finally { Remove-Item -LiteralPath $paths.RefreshPath -Force -ErrorAction SilentlyContinue }
        }
        'help' { Show-SgShortcutHelp }
        'exit' { return }
    }
} catch { Write-SgError $_.Exception.Message; exit 1 }
