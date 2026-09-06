$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$bootstrap = Get-Content -Raw (Join-Path $root 'install-shipglows.ps1')
if (($bootstrap -split '\r?\n' | Where-Object { $_ -match 'FlutterConfiguration' }).Count -ne 4) { throw 'Configured Flutter helper must be in archive extraction, update source, rollback and launcher copy lists.' }
$guard = Get-Content -Raw (Join-Path $root 'skills/references/agent-runtime-awareness.md')
foreach ($required in @('APP-AUTH-LAUNCH-GUARD','authentication is not yet implemented','exposes no protected data','state that exception explicitly','Missing, broken or misconfigured existing auth blocks','A login screen proves only','end-to-end validation','exact remaining proof and user-only step')) {
    if (-not $guard.Contains($required)) { throw "Shared launch auth guard missing: $required" }
}
Import-Module (Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-flutter-config-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $fixture)
try {
    & (Get-Module ShipGlows.DevServer) {
        param($Fixture)
        function Assert-Config([bool]$Value,[string]$Message) { if (-not $Value) { throw $Message } }
        function Expect-Blocked([scriptblock]$Action) { $blocked=$false; try { & $Action | Out-Null } catch { $blocked=$true }; Assert-Config $blocked 'Invalid configuration was accepted.' }
        function Get-SgCommandPath { param($Names) "C:\fixture\$($Names[0])" }
        $settings=[pscustomobject]@{FlutterDevice='windows';FlutterDeviceId='windows';DartDefineFile=$null}
        [IO.File]::WriteAllText((Join-Path $Fixture 'pubspec.yaml'),"name: public_fixture`ndependencies:`n  flutter: any")
        $publicOnly=Get-SgFlutterConfiguration $Fixture $settings 3010
        Assert-Config (-not $publicOnly.HasRecipe) 'A public fixture without auth must not require a fabricated provider recipe.'
        [IO.File]::WriteAllText((Join-Path $Fixture 'pubspec.yaml'),"name: fixture`ndependencies:`n  auth0_flutter: any")
        Expect-Blocked { Get-SgFlutterConfiguration $Fixture $settings 3010 }
        [IO.File]::WriteAllText((Join-Path $Fixture 'config.py'),'# fixture resolver, never executed')
        $recipe=[ordered]@{schemaVersion='shipglows.flutter-recipe.v1';configurationScript='config.py';doppler=@{project='fixture';config='dev'};publicDefines=@('AUTH0_DOMAIN','AUTH0_CLIENT_ID','AUTH0_AUDIENCE','AUTH_BYPASS');publicEnvironment=@('AUTH0_DOMAIN');requiredDefines=@('AUTH0_DOMAIN','AUTH0_CLIENT_ID','AUTH0_AUDIENCE');forbiddenTrueDefines=@('AUTH_BYPASS')}
        $recipePath=Join-Path $Fixture '.shipglows.flutter.json'
        function Save-Recipe { $recipe | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $recipePath }
        Save-Recipe
        $script:response=[ordered]@{schemaVersion='shipglows.flutter-configuration.v1';dartDefines=[ordered]@{AUTH0_DOMAIN='fixture.invalid';AUTH0_CLIENT_ID='fixture-client';AUTH0_AUDIENCE='fixture-api';AUTH_BYPASS='false'};environment=@{AUTH0_DOMAIN='fixture.invalid'}}
        $script:argsSeen=@()
        $runner={param($File,$Arguments) $script:argsSeen=$Arguments; Assert-Config ($env:AUTH_BYPASS -ceq 'false') 'Bypass policy was not applied in child environment.'; [pscustomobject]@{ExitCode=0;Output=($script:response|ConvertTo-Json -Depth 5 -Compress)}}
        $prior=[Environment]::GetEnvironmentVariable('AUTH_BYPASS','Process')
        [Environment]::SetEnvironmentVariable('AUTH_BYPASS','original','Process')
        try {
            $first=Get-SgFlutterConfiguration $Fixture $settings 3010 $runner
            Assert-Config ($first.HasRecipe -and $first.Defines['AUTH0_CLIENT_ID'] -ceq 'fixture-client') 'Public Dart configuration lost.'
            Assert-Config ($first.Environment['AUTH0_DOMAIN'] -ceq 'fixture.invalid') 'Android environment projection lost.'
            Assert-Config ($env:AUTH_BYPASS -ceq 'original') 'Parent environment was not restored.'
            Assert-Config ('--no-fallback' -in $script:argsSeen -and '--preserve-env=AUTH_BYPASS' -in $script:argsSeen) 'Doppler scope/fallback policy missing.'
            $second=Get-SgFlutterConfiguration $Fixture $settings 3010 $runner
            Assert-Config ($first.Fingerprint -ceq $second.Fingerprint) 'Identical configuration fingerprint is unstable.'
            $entry=[pscustomobject]@{flutterConfigurationFingerprint=$first.Fingerprint}
            Assert-Config (Test-SgFlutterSessionConfiguration $entry $second) 'Identical session should be reused.'
            $script:response.dartDefines.AUTH0_CLIENT_ID='rotated-client'
            $rotated=Get-SgFlutterConfiguration $Fixture $settings 3010 $runner
            Assert-Config (-not(Test-SgFlutterSessionConfiguration $entry $rotated)) 'Rotated configuration reused an old session.'
            $script:response.dartDefines.AUTH0_CLIENT_ID='fixture-client'
            foreach($target in @('chrome','web-server','android')) {
                $settings.FlutterDevice=$target
                $changed=Get-SgFlutterConfiguration $Fixture $settings 3010 $runner
                Assert-Config ($changed.Fingerprint -cne $first.Fingerprint) 'Target change did not invalidate session.'
                if($target -in @('chrome','web-server')) { Assert-Config ('http://127.0.0.1:3010' -in $script:argsSeen) 'Assigned web origin was lost.' }
            }
            $settings.FlutterDevice='windows'
            $settings.FlutterDevice='android'; $settings.FlutterDeviceId='emulator-5554'
            $deviceA=Get-SgFlutterConfiguration $Fixture $settings 3010 $runner
            $settings.FlutterDeviceId='emulator-5556'
            $deviceB=Get-SgFlutterConfiguration $Fixture $settings 3010 $runner
            Assert-Config ($deviceA.Fingerprint -cne $deviceB.Fingerprint) 'Resolved Android device change did not invalidate session.'
            $settings.FlutterDevice='windows'; $settings.FlutterDeviceId='windows'
            foreach($missing in $recipe.requiredDefines) {
                $old=$script:response.dartDefines[$missing]; $script:response.dartDefines[$missing]=''
                Expect-Blocked {Get-SgFlutterConfiguration $Fixture $settings 3010 $runner}
                $script:response.dartDefines[$missing]=$old
            }
            $script:response.dartDefines.AUTH_BYPASS='true'
            Expect-Blocked {Get-SgFlutterConfiguration $Fixture $settings 3010 $runner}
            $script:response.dartDefines.AUTH_BYPASS='false'
            $script:response.environment['SERVICE_SECRET']='fixture-never-persist'
            Expect-Blocked {Get-SgFlutterConfiguration $Fixture $settings 3010 $runner}
            $script:response.environment.Remove('SERVICE_SECRET')
            Expect-Blocked {Get-SgFlutterConfiguration $Fixture $settings 3010 {param($f,$a) [pscustomobject]@{ExitCode=1;Output='private failure detail'}}}
            Assert-Config ($env:AUTH_BYPASS -ceq 'original') 'Parent environment was not restored on failure.'
            Expect-Blocked {Get-SgFlutterConfiguration $Fixture $settings 3010 {param($f,$a) [pscustomobject]@{ExitCode=0;Output='{broken'}}}
            $recipe.doppler.config='production'; Save-Recipe
            Expect-Blocked {Read-SgFlutterRecipe $Fixture}
            $recipe.doppler.config='dev'; $recipe.configurationScript='../outside.py'; Save-Recipe
            Expect-Blocked {Read-SgFlutterRecipe $Fixture}
            $recipe.configurationScript='config.py'; Save-Recipe
            [IO.File]::WriteAllText((Join-Path $Fixture '.shipglows.env'),"SHIPGLOWS_FLUTTER_DEVICE=windows`nSHIPGLOWS_DART_DEFINE_FILE=.dart_tool/missing.json")
            $fresh=Get-SgRuntimeSettings $Fixture
            Assert-Config ($null -eq $fresh.DartDefineFile) 'A declared recipe still depends on an ignored checkout file.'

            # Exercise the actual Start entrypoint: a failed desired configuration
            # cannot stop an existing session or falsely return it as configured.
            function ConvertTo-SgCanonicalPath {param($p) $p}
            function Reconcile-SgRegistry {param($c) [pscustomobject]@{projects=@([pscustomobject]@{path=$Fixture;name='fixture';kind='flutter-web';port=3010;flutterDevice='windows';status='running';flutterConfigurationFingerprint=$first.Fingerprint})}}
            function Test-SgProjectCatalogEntry {$true}
            function Test-SgProcessIdentity {$true}
            function Get-SgProjectEnvironment {[pscustomobject]@{Port=3010}}
            function Get-SgFlutterConfiguration {throw 'fixture config unavailable'}
            $script:stopCalled=$false
            function Stop-SgProject {$script:stopCalled=$true}
            Expect-Blocked {Start-SgProject ([pscustomobject]@{}) $Fixture}
            Assert-Config (-not $script:stopCalled) 'Preflight failure stopped a working session.'
            function Get-SgFlutterConfiguration {$first}
            $reused=Start-SgProject ([pscustomobject]@{}) $Fixture
            Assert-Config ($reused.status -eq 'running' -and -not $script:stopCalled) 'Verified same configuration should not restart.'
            function Resolve-SgPowerShellExecutable {throw 'fixture missing host'}
            function Get-SgFlutterConfiguration {$rotated}
            Expect-Blocked {Start-SgProject ([pscustomobject]@{}) $Fixture}
            Assert-Config (-not $script:stopCalled) 'Missing launch host stopped a working session.'

            # Explicit targets are transient and reach configuration resolution.
            $script:observedTarget='';$script:observedId=''
            function Get-SgFlutterCommandPath {'C:\fixture\flutter.bat'}
            function Resolve-SgFlutterAndroidDevice { 'emulator-5556' }
            function Get-SgFlutterConfiguration {param($p,$s,$port) $script:observedTarget=$s.FlutterDevice;$script:observedId=$s.FlutterDeviceId;throw 'fixture stop after preflight'}
            Expect-Blocked {Start-SgProject ([pscustomobject]@{}) $Fixture -FlutterDevice android}
            Assert-Config ($script:observedTarget -eq 'android' -and $script:observedId -eq 'emulator-5556') 'Resolved Android device did not reach session fingerprint input.'
            Assert-Config ((Get-SgRuntimeSettings $Fixture).FlutterDevice -eq 'windows') 'Explicit target changed the durable project settings.'

            # With no durable port, pin preflight to a free port before reserve.
            function Test-SgProcessIdentity {$false}
            function Get-SgProjectEnvironment {$null}
            function Get-SgFreePort {32201}
            $script:observedPort=0
            function Get-SgFlutterConfiguration {param($p,$s,$port) $script:observedPort=$port;return $first}
            function Reserve-SgProjectPort {param($c,$p,$port,$explicit) Assert-Config ($port -eq $script:observedPort -and $port -eq 32201 -and $explicit) 'Reserved Web port diverges from preflight.';throw 'fixture stop after port proof'}
            Expect-Blocked {Start-SgProject ([pscustomobject]@{}) $Fixture -FlutterDevice chrome}
            Assert-Config ($script:observedPort -eq 32201) 'Stale stored Web port was used for configuration.'
        } finally {[Environment]::SetEnvironmentVariable('AUTH_BYPASS',$prior,'Process')}
    } $fixture
    Write-Host 'Flutter authenticated configuration and session reuse: OK'
} finally {
    $resolved=[IO.Path]::GetFullPath($fixture)
    $tempRoot=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')+'\'
    if($resolved.StartsWith($tempRoot,[StringComparison]::OrdinalIgnoreCase) -and (Split-Path $resolved -Leaf) -like 'sg-flutter-config-*') {Remove-Item -LiteralPath $resolved -Recurse -Force}
}
