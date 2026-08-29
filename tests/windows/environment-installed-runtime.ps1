$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$bootstrap = Join-Path $root 'install-shipglows.ps1'
$installer = Join-Path $root 'cli\windows\install-devserver.ps1'
$entrypoint = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$environmentSource = Join-Path $root 'cli\environment'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('sg-environment-installed-runtime-' + [guid]::NewGuid().ToString('N'))

function Assert-Contains([string]$Text, [string]$Pattern, [string]$Message) {
    if ($Text -notmatch $Pattern) { throw $Message }
}

function Import-BootstrapExtractionFunction([string]$Path) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw 'Could not parse the Windows bootstrap for extraction proof.' }
    $functionAst = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Extract-ShipglowsWindowsFiles' }, $true)
    if (-not $functionAst) { throw 'Windows bootstrap extraction function was not found.' }
    return $functionAst.Extent.Text
}

function Import-NamedFunction([string]$Path, [string]$Name) {
    $tokens = $null; $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw "Could not parse function source: $Path" }
    $functionAst = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $Name }, $true)
    if (-not $functionAst) { throw "Function was not found: $Name" }
    return $functionAst.Extent.Text
}

function Fail([string]$Message) { throw $Message }

try {
    $bootstrapText = [IO.File]::ReadAllText($bootstrap)
    $installerText = [IO.File]::ReadAllText($installer)
    Assert-Contains $bootstrapText 'cli/\(\?:private_data\\\.py\|environment/' 'Windows bootstrap does not use the closed private-data and environment package allowlist.'
    Assert-Contains $bootstrapText 'environmentDirectory\s*=\s*Join-Path\s+\$ShipglowsDir' 'Windows bootstrap does not target the selected runtime.'
    Assert-Contains $bootstrapText "'cli\\environment'" 'Windows bootstrap does not target runtime\cli\environment.'
    Assert-Contains $installerText "cli\\environment\\shipglows_environment\.py" 'Native installer does not validate the packaged environment command.'
    Assert-Contains $installerText "cli\\environment\\schemas\\shipglows-environment-v1\.schema\.json" 'Native installer does not validate the packaged environment schema.'
    Assert-Contains $installerText 'ShipGlows\.PowerShellBootstrap\.ps1' 'Native command wrappers do not route through the managed PowerShell bootstrap.'
    Assert-Contains ([IO.File]::ReadAllText($entrypoint)) "PSEdition -ne 'Core'" 'The installed frontend source does not refuse direct Desktop execution.'

    Invoke-Expression (Import-NamedFunction $installer 'Assert-SgEnvironmentPythonPackage')
    $pythonCommand = Get-Command python.exe -ErrorAction Stop
    Assert-SgEnvironmentPythonPackage -PythonPath $pythonCommand.Source -EnvironmentDirectory $environmentSource

    Invoke-Expression (Import-BootstrapExtractionFunction $bootstrap)
    $archiveSource = Join-Path $tempRoot 'archive-source\shipglows-test'
    $archiveWindows = Join-Path $archiveSource 'cli\windows'
    $archiveEnvironment = Join-Path $archiveSource 'cli\environment'
    New-Item -ItemType Directory -Path $archiveWindows,(Join-Path $archiveEnvironment 'schemas') -Force | Out-Null
    foreach ($windowsFile in @('ShipGlows.DevServer.psm1','ShipGlows.RuntimeStatus.psm1','ShipGlows.FlutterSupervisor.ps1','ShipGlows.ProjectCatalogRefresh.ps1','ShipGlows.CodexMcp.psm1','ShipGlows.MobileToolchain.psm1','ShipGlows.BuildArtifacts.psm1','shipglows-build-artifacts.ps1','ShipGlows.McpCatalog.json','ShipGlows.InstallerEngine.psm1','ShipGlows.InstallerConsole.psm1','ShipGlows.AgentInstructions.psm1','ShipGlows.Auth.psm1','ShipGlows.DeveloperCorpus.psm1','ShipGlows.PowerShellRuntime.psm1','ShipGlows.PowerShellRuntime.json','ShipGlows.PowerShellBootstrap.ps1','shipglows-devserver.ps1','shipglows.ps1','install-devserver.ps1')) {
        Copy-Item -LiteralPath (Join-Path $root "cli\windows\$windowsFile") -Destination (Join-Path $archiveWindows $windowsFile)
    }
    Copy-Item -LiteralPath (Join-Path $root 'shipglows-version.json') -Destination (Join-Path $archiveSource 'shipglows-version.json')
    Copy-Item -LiteralPath (Join-Path $root 'cli\private_data.py') -Destination (Join-Path $archiveSource 'cli\private_data.py')
    foreach ($pythonFile in @('__init__.py','core.py','mise_backend.py','preparation.py','shipglows_environment.py')) {
        Copy-Item -LiteralPath (Join-Path $environmentSource $pythonFile) -Destination (Join-Path $archiveEnvironment $pythonFile)
    }
    Copy-Item -LiteralPath (Join-Path $environmentSource 'schemas\shipglows-environment-v1.schema.json') -Destination (Join-Path $archiveEnvironment 'schemas\shipglows-environment-v1.schema.json')
    $archive = Join-Path $tempRoot 'complete.zip'
    & (Join-Path $env:WINDIR 'System32\tar.exe') -a -cf $archive -C (Split-Path $archiveSource -Parent) (Split-Path $archiveSource -Leaf)
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the complete installer fixture archive.' }
    $extract = Join-Path $tempRoot 'archive-extract'
    New-Item -ItemType Directory -Path $extract | Out-Null
    $entries = @(Extract-ShipglowsWindowsFiles -ArchivePath $archive -DestinationPath $extract -FullMode $true)
    if ($entries.Count -ne 28) { throw "Installer extracted $($entries.Count) files instead of the closed set of 28." }
    if (-not ($entries -match 'ShipGlows\.DeveloperCorpus\.psm1$')) { throw 'Installer did not extract the developer corpus channel module.' }
    if (-not ($entries -match 'ShipGlows\.RuntimeStatus\.psm1$') -or -not ($entries -match 'shipglows-version\.json$')) { throw 'Installer did not extract the runtime-status module and version metadata.' }
    if (-not ($entries -match 'shipglows\.ps1$')) { throw 'Installer did not extract the ShipGlows command entrypoint.' }
    if (-not ($entries -match 'private_data\.py$')) { throw 'Installer did not extract the private-data control plane.' }
    if (-not ($entries -match 'preparation\.py$')) { throw 'Installer did not extract the environment preparation engine.' }
    if (-not (Test-Path -LiteralPath (Join-Path $extract 'shipglows-test\cli\environment\schemas\shipglows-environment-v1.schema.json') -PathType Leaf)) { throw 'Installer did not extract the environment schema.' }

    Remove-Item -LiteralPath (Join-Path $archiveWindows 'ShipGlows.FlutterSupervisor.ps1') -Force
    $incompleteArchive = Join-Path $tempRoot 'incomplete.zip'
    & (Join-Path $env:WINDIR 'System32\tar.exe') -a -cf $incompleteArchive -C (Split-Path $archiveSource -Parent) (Split-Path $archiveSource -Leaf)
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the incomplete installer fixture archive.' }
    $rejected = $false
    try { [void](Extract-ShipglowsWindowsFiles -ArchivePath $incompleteArchive -DestinationPath $extract -FullMode $true) }
    catch { $rejected = $_.Exception.Message -match 'missing native Windows DevServer.*environment control-plane, or private-data control-plane files' }
    if (-not $rejected) { throw 'Installer accepted an incomplete environment package archive.' }

    $runtime = Join-Path $tempRoot 'runtime'
    $bin = Join-Path $runtime 'bin'
    $environmentDestination = Join-Path $runtime 'cli\environment'
    $project = Join-Path $tempRoot 'unmanaged-project'
    $state = Join-Path $tempRoot 'state'
    $workspace = Join-Path $tempRoot 'workspace-must-not-exist'
    $localAppData = Join-Path $tempRoot 'localappdata-must-not-exist'
    New-Item -ItemType Directory -Path $bin,$environmentDestination,$project | Out-Null
    Copy-Item -LiteralPath $entrypoint -Destination (Join-Path $bin 'shipglows-devserver.ps1')
    Copy-Item -Path (Join-Path $environmentSource '*') -Destination $environmentDestination -Recurse

    $previousState = $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT
    $previousWorkspace = $env:SHIPGLOWS_WINDOWS_WORKSPACE
    $previousLocalAppData = $env:LOCALAPPDATA
    $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT = $state
    $env:SHIPGLOWS_WINDOWS_WORKSPACE = $workspace
    $env:LOCALAPPDATA = $localAppData
    try {
        $python = (Get-Command python.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
        $output = & $python (Join-Path $environmentDestination 'shipglows_environment.py') inspect --project $project 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Installed runtime inspect failed: $($output -join [Environment]::NewLine)" }
        $result = ($output -join [Environment]::NewLine) | ConvertFrom-Json
        if ($result.command -ne 'inspect' -or $result.desired.project.root -ne [IO.Path]::GetFullPath($project) -or $result.desired.management -ne 'unmanaged') { throw 'Installed runtime returned an unexpected inspect result.' }
        if (Test-Path -LiteralPath $workspace) { throw 'Installed runtime inspect initialized the DevServer workspace.' }
        if (Test-Path -LiteralPath $state) { throw 'Installed runtime inspect wrote environment state.' }
        if (Test-Path -LiteralPath $localAppData) { throw 'Installed runtime inspect initialized DevServer registry or menu-cache state.' }
    } finally {
        $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT = $previousState
        $env:SHIPGLOWS_WINDOWS_WORKSPACE = $previousWorkspace
        $env:LOCALAPPDATA = $previousLocalAppData
    }

    Write-Host 'Windows packaged environment control plane: OK (installed s env adapter requires post-install live proof)' -ForegroundColor Green
} finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
