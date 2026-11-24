$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Without an interactive console (agent tools, CI, stdin on NUL), a command without
# -ProjectPath must never open the Gum/fzf/Read-Host picker: it resolves the project from
# the working directory, or fails fast naming the running projects and the -ProjectPath form.
$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$entrypointPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\shipglows-devserver.ps1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    foreach ($name in @('Test-SgInteractiveConsole','Resolve-SgWorkingDirectoryProject')) {
        if (-not (Get-Command $name -Module ShipGlows.DevServer -ErrorAction SilentlyContinue)) { throw "The DevServer module does not export $name." }
    }

    $app = [pscustomobject]@{ name='nococaine-app'; path='C:\workspace\nococaine\app'; running=$true }
    $site = [pscustomobject]@{ name='nococaine-site'; path='C:\workspace\nococaine\site'; running=$false }
    $other = [pscustomobject]@{ name='other'; path='C:\workspace\other'; running=$true }
    $prefixTwin = [pscustomobject]@{ name='nococaine-twin'; path='C:\workspace\nococaine-twin'; running=$true }
    $isRunning = { param($Entry) [bool]$Entry.running }
    $projects = @($app, $site, $other, $prefixTwin)

    # A parent folder holding exactly one running project resolves to that project.
    $resolved = Resolve-SgWorkingDirectoryProject $projects 'C:\workspace\nococaine' $isRunning 'stop'
    if ($resolved.path -ne $app.path) { throw "Parent working directory did not resolve to its single running project: $($resolved.path)" }

    # The project folder itself, or any folder inside it, resolves to that project even when stopped (stop is idempotent).
    if ((Resolve-SgWorkingDirectoryProject $projects 'C:\workspace\nococaine\site\lib\src' $isRunning 'stop').path -ne $site.path) { throw 'A folder inside a registered project did not resolve to it.' }
    if ((Resolve-SgWorkingDirectoryProject $projects 'C:\WORKSPACE\NOCOCAINE\APP\' $isRunning 'stop').path -ne $app.path) { throw 'Project path matching is not case- and trailing-separator-insensitive.' }

    # A name prefix is not a parent folder.
    $short = [pscustomobject]@{ name='noco'; path='C:\workspace\noco'; running=$true }
    if ((Resolve-SgWorkingDirectoryProject @($short, $app) 'C:\workspace\nococaine' $isRunning 'stop').path -ne $app.path) { throw 'A registered project whose path is only a name prefix of the working directory was treated as its parent.' }

    # The deepest registered project containing the working directory wins.
    $nested = [pscustomobject]@{ name='nested'; path='C:\workspace\nococaine\app\packages\ui'; running=$true }
    if ((Resolve-SgWorkingDirectoryProject @($app,$nested) 'C:\workspace\nococaine\app\packages\ui\lib' $isRunning 'stop').path -ne $nested.path) { throw 'The deepest registered project containing the working directory was not chosen.' }

    # Several running projects under the working directory: fail fast, name them, give the -ProjectPath command.
    $ambiguous = $null
    try { Resolve-SgWorkingDirectoryProject @($app, $other, $prefixTwin) 'C:\workspace' $isRunning 'stop' | Out-Null } catch { $ambiguous = $_.Exception.Message }
    if (-not $ambiguous) { throw 'Several running projects under the working directory were resolved instead of failing.' }
    foreach ($path in @($app.path, $other.path, $prefixTwin.path)) { if (-not $ambiguous.Contains("s stop -ProjectPath $path")) { throw "Ambiguity message does not give the -ProjectPath command for $path`: $ambiguous" } }

    # Nothing registered or running under the working directory: fail fast with the running projects elsewhere.
    $none = $null
    try { Resolve-SgWorkingDirectoryProject $projects 'C:\elsewhere' $isRunning 'stop' | Out-Null } catch { $none = $_.Exception.Message }
    if (-not $none -or -not $none.Contains("s stop -ProjectPath $($other.path)") -or $none.Contains("-ProjectPath $($site.path)")) { throw "Unresolved working directory did not list only the running projects: $none" }
    $idle = $null
    try { Resolve-SgWorkingDirectoryProject @($site) 'C:\workspace' $isRunning 'stop' | Out-Null } catch { $idle = $_.Exception.Message }
    if (-not $idle -or $idle -notlike '*No managed project is running*') { throw "Idle registry did not report that nothing runs: $idle" }

    # Entrypoint behaviour: the stop selection and the generic picker never open a picker without a console.
    $source = Get-Content -Raw $entrypointPath
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput($source, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw 'The DevServer entrypoint does not parse.' }
    foreach ($name in @('Get-SgStopSelection','Get-SelectedProject','Read-SgInput')) {
        $function = $ast.Find({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name }, $true)
        if (-not $function) { throw "The DevServer entrypoint does not define $name." }
        . ([scriptblock]::Create($function.Extent.Text))
    }
    if (-not $source.Contains("'stop' { if (`$ProjectPath) { [void](Stop-SgProject `$config `$ProjectPath -Target (Get-SgRequestedTarget)) } else { `$entry = Get-SgStopSelection;")) { throw 'Stop without -ProjectPath does not go through Get-SgStopSelection.' }

    $config = [pscustomobject]@{}
    $choiceUiAvailable = $true
    $gum = 'gum.exe'
    function Test-SgInteractiveConsole { $false }
    function Read-SgChoice { throw 'PICKER OPENED without an interactive console.' }
    function Invoke-SgGum { throw 'PICKER OPENED without an interactive console.' }
    function Read-Host { throw 'PROMPT OPENED without an interactive console.' }
    function Get-SgProjectCatalog { @([pscustomobject]@{ Name='nococaine-app'; Id='app'; IsRegistered=$true; logPath='x' }) }
    function Read-SgRegistry { [pscustomobject]@{ schemaVersion=1; projects=@($app, $site, $other) } }
    function Get-SgLiveSessions { param($Entry) if ($Entry.running) { @([pscustomobject]@{ target='android' }) } else { @() } }
    function Write-SgInfo { param($Message) }

    $selected = Get-SgStopSelection 'C:\workspace\nococaine'
    if ($selected.path -ne $app.path) { throw "Unattended stop did not resolve the running project under the working directory: $($selected.path)" }

    foreach ($action in @('stop','restart','logs','open','start','unregister')) {
        $failure = $null
        try { Get-SelectedProject $action | Out-Null } catch { $failure = $_.Exception.Message }
        if (-not $failure -or $failure -like '*OPENED*' -or $failure -notlike '*-ProjectPath*') { throw "Picker for '$action' did not fail fast without a console: $failure" }
    }
    $inputFailure = $null
    try { Read-SgInput 'Project path' 'C:\workspace' | Out-Null } catch { $inputFailure = $_.Exception.Message }
    if (-not $inputFailure -or $inputFailure -like '*OPENED*') { throw "Text prompt did not fail fast without a console: $inputFailure" }

    # With a console, the interactive picker remains the stop selection.
    function Test-SgInteractiveConsole { $true }
    function Get-SelectedProject { param($Action) if ($Action -ne 'stop') { throw 'Wrong picker action.' }; $other }
    if ((Get-SgStopSelection 'C:\workspace\nococaine').path -ne $other.path) { throw 'Interactive stop no longer uses the project picker.' }

    Write-Host 'Windows DevServer unattended selection: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
