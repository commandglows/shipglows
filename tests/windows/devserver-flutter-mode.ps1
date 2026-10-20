# Managed Flutter run mode: debug by default, profile on request, never release.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Expect-Sg([scriptblock]$Action, [string]$Message) { $blocked=$false; try { & $Action | Out-Null } catch { $blocked=$true }; Assert-Sg $blocked $Message }

# Entry point and backend wrapper expose the bounded parameter.
$entrypoint = Get-Content -Raw (Join-Path $root 'cli\windows\shipglows-devserver.ps1')
Assert-Sg ($entrypoint -match "\[ValidateSet\('','debug','profile'\)\]\[string\]\`$FlutterMode") 'shipglows-devserver.ps1 must declare -FlutterMode debug|profile.'
Assert-Sg ($entrypoint -match '-FlutterMode \$FlutterMode -Restart') 'The start action must forward -FlutterMode to Start-SgProject.'
Assert-Sg ($entrypoint -match '\[-FlutterMode debug\|profile\]') 's h must document -FlutterMode.'
Assert-Sg ($entrypoint -notmatch "'release'") 'The CLI must never offer a release run mode.'
$backend = Get-Content -Raw (Join-Path $root 'cli\windows\ShipGlows.Backend.ps1')
Assert-Sg ($backend -match "\[ValidateSet\('','debug','profile'\)\]\[string\]\`$FlutterMode" -and $backend -match '-FlutterMode \$FlutterMode -Restart') 'Start-SgProject must accept and forward -FlutterMode.'

Import-Module (Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking

# Status rendering records the mode without changing non-Flutter output.
$windowsDebug = Get-SgProjectExperience 'flutter-web' 0 'windows' 'debug'
Assert-Sg ($windowsDebug.PortLabel -eq 'Live session | debug') 'Flutter Windows status must display the debug mode.'
$windowsProfile = Get-SgProjectExperience 'flutter-web' 0 'windows' 'profile'
Assert-Sg ($windowsProfile.PortLabel -eq 'Live session | profile') 'Flutter Windows status must display the profile mode.'
Assert-Sg ((Get-SgProjectExperience 'flutter-web' 0 'windows').PortLabel -eq 'Live session') 'Entries without a recorded mode keep their legacy label.'
Assert-Sg ((Get-SgProjectExperience 'vite' 4321 '' 'profile').PortLabel -eq 'URL :4321') 'Web projects must ignore the Flutter mode.'
$status = Format-SgProjectStatus ([pscustomobject]@{ status='running'; kind='flutter-web'; port=0; Name='BeatGlows'; flutterDevice='windows'; flutterMode='profile' })
Assert-Sg ($status -eq 'running | Flutter Windows app | Live session | profile') "Unexpected status line: $status"
$legacy = Format-SgProjectStatus ([pscustomobject]@{ status='stopped'; kind='flutter-web'; port=0; Name='Legacy'; flutterDevice='windows' })
Assert-Sg ($legacy -eq 'stopped | Flutter Windows app | Live session') "Legacy entries must not invent a mode: $legacy"

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-flutter-mode-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $fixture)
try {
    [void](New-Item -ItemType Directory -Path (Join-Path $fixture 'windows'))
    # .shipglows.env: debug by default, profile when declared, anything else fails closed.
    Assert-Sg ((Get-SgRuntimeSettings $fixture).FlutterMode -ceq 'debug') 'The default Flutter mode must be debug.'
    [IO.File]::WriteAllText((Join-Path $fixture '.shipglows.env'), "SHIPGLOWS_FLUTTER_DEVICE=windows`nSHIPGLOWS_FLUTTER_MODE=profile`n")
    $declared = Get-SgRuntimeSettings $fixture
    Assert-Sg ($declared.FlutterMode -ceq 'profile' -and $declared.FlutterDevice -ceq 'windows') 'SHIPGLOWS_FLUTTER_MODE=profile was not honored.'
    [IO.File]::WriteAllText((Join-Path $fixture '.shipglows.env'), "SHIPGLOWS_FLUTTER_MODE=release`n")
    Expect-Sg { Get-SgRuntimeSettings $fixture } 'SHIPGLOWS_FLUTTER_MODE=release must be rejected.'
    Remove-Item -LiteralPath (Join-Path $fixture '.shipglows.env') -Force

    & (Get-Module ShipGlows.DevServer) {
        param($Fixture)
        function Assert-Core([bool]$Value,[string]$Message) { if (-not $Value) { throw $Message } }
        # Start-SgProjectCore: the explicit parameter overrides settings, reaches the launch spec and the registry entry.
        function ConvertTo-SgCanonicalPath { param($p) $p }
        function Reconcile-SgRegistry { param($c) [pscustomobject]@{ projects=@([pscustomobject]@{ path=$Fixture; name='fixture'; kind='flutter-web'; port=0; flutterDevice='windows'; status='stopped' }) } }
        function Test-SgProjectCatalogEntry { $true }
        function Test-SgProcessIdentity { $false }
        function Get-SgProjectEnvironment { $null }
        function Get-SgFlutterConfiguration { param($ProjectPath,$Settings,$Port) $script:configuredMode=$Settings.FlutterMode; [pscustomobject]@{ Fingerprint='fixture'; Defines=@{}; Environment=@{}; HasRecipe=$false } }
        function Reserve-SgProjectPort { [pscustomobject]@{ Port=0; Token='mode-token' } }
        function Release-SgProjectPort { }
        function Get-SgProjectLogKey { 'fixture-mode' }
        function Rotate-SgLogFile { }
        function Protect-SgOwnerOnlyPath { }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { param($ProjectPath,$Kind,$Port,$FlutterVisible,$FlutterProfilePath,$FlutterDevice,$DartDefineFile,$FlutterLaunchDirectory,$FlutterLaunchIdentity,$FlutterMode='debug') $script:launchMode=$FlutterMode; throw 'fixture stop after launch spec' }
        $config = [pscustomobject]@{ RuntimeDirectory=(Join-Path $Fixture 'runtime'); LogDirectory=(Join-Path $Fixture 'logs') }
        foreach ($case in @(@{ Mode='profile'; Expected='profile' }, @{ Mode=''; Expected='debug' })) {
            $script:launchMode=$null; $script:configuredMode=$null
            try { [void](Start-SgProjectCore $config $Fixture -FlutterDevice windows -FlutterMode $case.Mode) } catch { if ($_.Exception.Message -ne 'fixture stop after launch spec') { throw } }
            Assert-Core ($script:configuredMode -ceq $case.Expected) "Configuration preflight saw mode '$($script:configuredMode)' instead of '$($case.Expected)'."
            Assert-Core ($script:launchMode -ceq $case.Expected) "Launch spec received mode '$($script:launchMode)' instead of '$($case.Expected)'."
        }
        $rejected=$false
        try { [void](Start-SgProjectCore $config $Fixture -FlutterDevice windows -FlutterMode release) } catch { $rejected=$true }
        Assert-Core $rejected 'Start-SgProjectCore accepted a release mode.'
        function Reconcile-SgRegistry { param($c) [pscustomobject]@{ projects=@([pscustomobject]@{ path=$Fixture; name='web'; kind='vite'; port=3010; status='stopped' }) } }
        $webRejected=$false
        try { [void](Start-SgProjectCore $config $Fixture -FlutterMode profile) } catch { $webRejected=$_.Exception.Message -match 'requires a Flutter project' }
        Assert-Core $webRejected 'A non-Flutter project accepted -FlutterMode.'
    } $fixture

    # Registry entry template records flutterMode next to flutterDevice.
    $module = Get-Content -Raw (Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1')
    Assert-Sg ($module -match "flutterMode = \`$\(if \(\`$kind -eq 'flutter-web'\) \{ \`$resolvedFlutterMode \} else \{ \`$null \}\)") 'The registry entry must persist flutterMode for Flutter surfaces only.'
    Assert-Sg ($module -notmatch "'--release'|-FlutterMode release") 'The DevServer module must never launch a release session.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}

# Supervisor: profile adds --profile, disables the source watcher and refuses reload (Flutter cannot restart a profile app).
$supervisorPath = [IO.Path]::GetFullPath((Join-Path $root 'cli\windows\ShipGlows.FlutterSupervisor.ps1'))
. $supervisorPath -TestMode -Mode profile
$profileArgs = @(New-SgFlutterRunArguments 'windows' 0 '' $false 'profile')
Assert-Sg ($profileArgs[0] -ceq 'run' -and $profileArgs[1] -ceq '--machine' -and $profileArgs[2] -ceq '--profile' -and $profileArgs[3] -ceq '-d' -and $profileArgs[4] -ceq 'windows') "Unexpected profile argv: $($profileArgs -join ' ')"
Assert-Sg ('--release' -notin $profileArgs) 'Profile mode must never imply --release.'
$debugArgs = @(New-SgFlutterRunArguments 'windows' 0 '' $false)
Assert-Sg ('--profile' -notin $debugArgs -and '--release' -notin $debugArgs) 'Debug mode must not add a build-mode flag.'
Expect-Sg { New-SgFlutterRunArguments 'windows' 0 '' $false 'release' } 'The supervisor accepted a release run mode.'
$hotReload = (New-SgFlutterMachineRequestJson 6 'app.restart' 'app-1').Substring(1) | ForEach-Object { $_.Substring(0, $_.Length - 1) } | ConvertFrom-Json
Assert-Sg ($hotReload.params.fullRestart -eq $false -and $hotReload.params.debounce -eq $true) 'Debug reload must remain a debounced hot reload.'
$supervisorSource = Get-Content -Raw $supervisorPath
Assert-Sg ($supervisorSource -match "\`$Mode -ne 'profile' -and \(Test-Path -LiteralPath \`$lib") 'Profile sessions must not start the source watcher.'
Assert-Sg ($supervisorSource -match "if\(\`$command\.Method -eq 'reload'\)\{if\(\`$Mode -eq 'profile'\)\{throw 'Restart is not supported in profile mode\.'\}") 'The supervisor must refuse reload in profile mode before touching Flutter.'
Assert-Sg ($supervisorSource -cnotmatch 'fullRestart=\$true|\$FullRestart') 'No managed command may request a Flutter full restart.'
Assert-Sg ($supervisorSource -match "\[ValidateSet\('debug','profile'\)\]\[string\]\`$Mode = 'debug'") 'The supervisor must bound -Mode to debug|profile.'
Assert-Sg ($entrypoint -match 'flutterMode -eq ''profile''\) \{ throw "Flutter profile sessions support neither hot reload nor hot restart') 's reload must refuse a profile session with the s restart alternative before any IPC.'

Write-Host 'Windows DevServer Flutter run mode regression: OK'
