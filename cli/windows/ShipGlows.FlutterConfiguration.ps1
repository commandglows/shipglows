# Loaded into the DevServer module; project resolvers may return PUBLIC client
# configuration only. Doppler service credentials never enter launch artifacts.
function Assert-SgFlutterRecipePath([string]$Path,[string]$ProjectPath) {
    $root=[IO.Path]::GetFullPath($ProjectPath).TrimEnd('\','/')
    $current=[IO.Path]::GetFullPath($Path)
    while ($current.Length -ge $root.Length) {
        $item=Get-Item -LiteralPath $current -Force -ErrorAction Stop
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Flutter recipe paths cannot traverse reparse points.' }
        if ($current.Equals($root,[StringComparison]::OrdinalIgnoreCase)) { return }
        $current=Split-Path -Parent $current
    }
    throw 'Flutter recipe path is outside the project.'
}

function Read-SgFlutterRecipe([string]$ProjectPath) {
    $path = Join-Path $ProjectPath '.shipglows.flutter.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $manifest = Join-Path $ProjectPath 'pubspec.yaml'
        if ((Test-Path -LiteralPath $manifest) -and (Get-Content -LiteralPath $manifest -Raw) -match '(?m)^\s+(auth0_flutter|firebase_auth|clerk_flutter)\s*:') {
            throw 'This authenticated Flutter project needs a declared .shipglows.flutter.json launch recipe. Refusing an unconfigured launch.'
        }
        return $null
    }
    Assert-SgFlutterRecipePath $path $ProjectPath
    if ((Get-Item -LiteralPath $path).Length -gt 65536) { throw 'Flutter launch recipe exceeds 64 KiB.' }
    try { $recipe = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop } catch { throw 'Flutter launch recipe is not valid JSON.' }
    $keys = @('schemaVersion','configurationScript','doppler','publicDefines','publicEnvironment','requiredDefines','forbiddenTrueDefines')
    if ($null -eq $recipe -or $recipe -is [array] -or (@($recipe.PSObject.Properties.Name | Sort-Object) -join ',') -cne (@($keys | Sort-Object) -join ',')) { throw 'Flutter launch recipe fields are invalid.' }
    if ($recipe.schemaVersion -cne 'shipglows.flutter-recipe.v1') { throw 'Unsupported Flutter launch recipe version.' }
    foreach ($field in @('publicDefines','publicEnvironment','requiredDefines','forbiddenTrueDefines')) {
        if ($recipe.$field -isnot [array]) { throw "Flutter recipe $field must be an array." }
        foreach ($key in $recipe.$field) {
            if ($key -isnot [string] -or $key -cnotmatch '^[A-Z][A-Z0-9_]{0,95}$' -or $key -match '(SECRET|PASSWORD|TOKEN|PRIVATE_KEY)') { throw "Flutter recipe $field contains a non-public or invalid key." }
        }
        if (@($recipe.$field | Select-Object -Unique).Count -ne $recipe.$field.Count) { throw "Flutter recipe $field contains duplicate keys." }
    }
    foreach ($key in @($recipe.requiredDefines) + @($recipe.forbiddenTrueDefines)) {
        if ($key -cnotin $recipe.publicDefines) { throw 'Flutter required/forbidden keys must be declared public defines.' }
    }
    if ($recipe.publicDefines.Count -eq 0) { throw 'Flutter recipe has no public defines.' }
    $dopplerNone = $recipe.doppler -is [string] -and $recipe.doppler -ceq 'NONE'
    if (-not $dopplerNone -and ($null -eq $recipe.doppler -or (@($recipe.doppler.PSObject.Properties.Name | Sort-Object) -join ',') -cne 'config,project' -or $recipe.doppler.project -isnot [string] -or $recipe.doppler.project -cnotmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]{0,95}$' -or $recipe.doppler.config -isnot [string] -or $recipe.doppler.config -cnotmatch '^(dev|stg|staging)(_[a-zA-Z0-9_-]+)?$')) { throw 'Flutter recipe must declare Doppler as NONE or provide an exact development/staging project and config.' }
    $relative = [string]$recipe.configurationScript
    if ([IO.Path]::IsPathRooted($relative) -or $relative -notmatch '\.py$') { throw 'Flutter configurationScript must be a relative Python file.' }
    $scriptPath = [IO.Path]::GetFullPath((Join-Path $ProjectPath $relative))
    $root = [IO.Path]::GetFullPath($ProjectPath).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    if (-not $scriptPath.StartsWith($root,[StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) { throw 'Flutter configurationScript must exist inside its project.' }
    Assert-SgFlutterRecipePath $scriptPath $ProjectPath
    $recipe | Add-Member -NotePropertyName ScriptPath -NotePropertyValue $scriptPath
    $recipe | Add-Member -NotePropertyName RecipePath -NotePropertyValue $path
    return $recipe
}

function ConvertTo-SgPublicFlutterMap([object]$Value,[string[]]$Allowed,[string]$Label) {
    if ($null -eq $Value -or $Value -isnot [pscustomobject]) { throw "Flutter $Label must be an object." }
    $map = [ordered]@{}
    foreach ($property in @($Value.PSObject.Properties | Sort-Object Name)) {
        $propertyValue = $property.Value
        if ($propertyValue -is [datetime] -and $property.Name -in @('BUILD_TIMESTAMP','BUILD_AT_UTC','BUILD_AT_PARIS')) {
            $format = if ($property.Name -eq 'BUILD_AT_PARIS') { 'yyyy-MM-dd HH:mm' } else { "yyyy-MM-dd'T'HH:mm:ss'Z'" }
            $propertyValue = if ($property.Name -eq 'BUILD_AT_PARIS') { $propertyValue.ToString($format,[Globalization.CultureInfo]::InvariantCulture) } else { $propertyValue.ToUniversalTime().ToString($format,[Globalization.CultureInfo]::InvariantCulture) }
        }
        if ($property.Name -cnotin $Allowed -or $propertyValue -isnot [string] -or $propertyValue.Length -gt 8192 -or $propertyValue -match '[\x00-\x1f]') { throw "Flutter $Label contains an undeclared or invalid public parameter." }
        $map[$property.Name] = $propertyValue
    }
    return $map
}

function ConvertFrom-SgFlutterJson([string]$Json) {
    $parameters = @{ InputObject=$Json; ErrorAction='Stop' }
    if ((Get-Command ConvertFrom-Json).Parameters.ContainsKey('DateKind')) { $parameters.DateKind = 'String' }
    return ConvertFrom-Json @parameters
}

function Invoke-SgPublicFlutterResolver([string]$File,[string[]]$Arguments) {
    Import-Module (Join-Path $PSScriptRoot 'ShipGlows.MobileToolchain.psm1') -DisableNameChecking
    # Reuse the native transport, but keep stdout separate: Doppler can emit a
    # policy notice on stderr even when its public JSON command succeeds.
    return & (Get-Module ShipGlows.MobileToolchain) {
        param($File,$Arguments)
        $process=$null
        try {
            $process=Start-SgEncodedProcess -File $File -Arguments $Arguments -Capture
            $stdout=$process.StandardOutput.ReadToEndAsync()
            $stderr=$process.StandardError.ReadToEndAsync()
            if (-not $process.WaitForExit(30000)) {
                Stop-SgProcessTree $process.Id $process.StartTime.ToUniversalTime()
                return [pscustomobject]@{ExitCode=-1;Output=''}
            }
            $process.WaitForExit()
            [void]$stderr.Result
            return [pscustomobject]@{ExitCode=$process.ExitCode;Output=$stdout.Result}
        } finally {
            if ($process) { $transportPath=[string]$process.SgTransportPath; $process.Dispose(); if($transportPath -and (Test-Path -LiteralPath $transportPath)){Remove-Item -LiteralPath $transportPath -Force} }
        }
    } $File $Arguments
}

function Get-SgFlutterConfiguration([string]$ProjectPath,[object]$Settings,[int]$Port,[scriptblock]$Runner = $null) {
    $recipe = Read-SgFlutterRecipe $ProjectPath
    $target = [string]$Settings.FlutterDevice
    $origin = if ($target -in @('chrome','web-server')) {
        if ($Port -lt 1024 -or $Port -gt 65535) { throw 'Authenticated Flutter Web needs its assigned managed port before launch.' }
        "http://127.0.0.1:$Port"
    } else { '' }
    $defines = [ordered]@{}
    $publicEnvironment = [ordered]@{}
    $sourceHash = ''
    if ($recipe) {
        $python = Get-SgCommandPath @('python.exe','python3.exe')
        if (-not $python) { throw 'The declared Flutter recipe requires Python. No unauthenticated fallback is allowed.' }
        $resolverTarget = if ($target -in @('chrome','web-server')) { 'web' } elseif ($target -eq 'windows') { 'windows' } else { 'android' }
        $arguments = @()
        $runnerFile = $python
        if ($recipe.doppler -cne 'NONE') {
            $doppler = Get-SgCommandPath @('doppler.exe')
            if (-not $doppler) { throw 'The declared Flutter recipe requires Doppler. No unauthenticated fallback is allowed.' }
            $arguments += @('run','--project',[string]$recipe.doppler.project,'--config',[string]$recipe.doppler.config,'--no-fallback','--no-check-version')
            if ($recipe.forbiddenTrueDefines.Count -gt 0) { $arguments += '--preserve-env=' + ($recipe.forbiddenTrueDefines -join ',') }
            $arguments += @('--',$python)
            $runnerFile = $doppler
        }
        # Python is the runner without Doppler; never pass it again as its own script.
        $arguments += @($recipe.ScriptPath,'--configuration-json','--target',$resolverTarget)
        if ($origin) { $arguments += @('--web-origin',$origin) }
        if (-not $Runner) { $Runner = { param($File,$Arguments) Invoke-SgPublicFlutterResolver $File $Arguments } }
        $saved = @{}
        try {
            # Public policy flags only; never enumerate, save or export secrets.
            # Forced off with or without Doppler so an ambient bypass never reaches the resolver.
            foreach ($key in $recipe.forbiddenTrueDefines) { $saved[$key] = [Environment]::GetEnvironmentVariable($key,'Process'); [Environment]::SetEnvironmentVariable($key,'false','Process') }
            $result = & $Runner $runnerFile $arguments
        } finally { foreach ($key in $saved.Keys) { [Environment]::SetEnvironmentVariable($key,$saved[$key],'Process') } }
        if (-not $result -or $result.ExitCode -ne 0) { throw 'Flutter configuration preflight failed. Check the declared configuration source and required public client configuration; the existing session was preserved.' }
        if ([string]$result.Output -eq '' -or ([string]$result.Output).Length -gt 65536) { throw 'Flutter resolver returned an empty or oversized response.' }
        try { $resolved = ConvertFrom-SgFlutterJson ([string]$result.Output) } catch { throw 'Flutter resolver did not return the public configuration contract.' }
        if ($null -eq $resolved -or $resolved -is [array] -or (@($resolved.PSObject.Properties.Name | Sort-Object) -join ',') -cne 'dartDefines,environment,schemaVersion' -or $resolved.schemaVersion -cne 'shipglows.flutter-configuration.v1') { throw 'Unsupported Flutter public configuration response.' }
        $defines = ConvertTo-SgPublicFlutterMap $resolved.dartDefines $recipe.publicDefines 'defines'
        $publicEnvironment = ConvertTo-SgPublicFlutterMap $resolved.environment $recipe.publicEnvironment 'environment'
        foreach ($key in $recipe.requiredDefines) { if (-not $defines.Contains($key) -or [string]::IsNullOrWhiteSpace([string]$defines[$key])) { throw "Flutter public configuration is missing $key." } }
        foreach ($key in $recipe.forbiddenTrueDefines) { if (-not $defines.Contains($key) -or $defines[$key] -cne 'false') { throw 'Flutter authentication bypass must be explicitly disabled.' } }
        $sourceHash = (Get-FileHash -LiteralPath $recipe.RecipePath -Algorithm SHA256).Hash + (Get-FileHash -LiteralPath $recipe.ScriptPath -Algorithm SHA256).Hash
    } elseif ($Settings.DartDefineFile) {
        if ((Get-Item -LiteralPath $Settings.DartDefineFile).Length -gt 65536) { throw 'Flutter define file exceeds 64 KiB.' }
        try { $legacy = ConvertFrom-SgFlutterJson (Get-Content -LiteralPath $Settings.DartDefineFile -Raw) } catch { throw 'Flutter define file is not valid JSON.' }
        $allowed = @($legacy.PSObject.Properties.Name)
        if (@($allowed | Where-Object { $_ -match '(SECRET|PASSWORD|TOKEN|PRIVATE_KEY)' }).Count -gt 0) { throw 'Flutter defines may not contain service secrets.' }
        $defines = ConvertTo-SgPublicFlutterMap $legacy $allowed 'defines'
        foreach ($key in $defines.Keys) { if ($key -match '(AUTH_BYPASS|OPEN_ACCESS)' -and $defines[$key] -eq 'true') { throw 'A normal Flutter launch cannot enable an authentication bypass.' } }
    }
    $mode = if ($Settings.PSObject.Properties['FlutterMode'] -and [string]$Settings.FlutterMode) { [string]$Settings.FlutterMode } else { 'debug' }
    if ($mode -notin @('debug','profile')) { throw 'Flutter launch mode must be debug or profile.' }
    # A fresh managed Flutter run gets a fresh build timestamp, but timestamps
    # alone must not invalidate a live session during a reuse check.
    $stableDefines = [ordered]@{}
    foreach ($key in $defines.Keys) {
        if ($key -notin @('BUILD_TIMESTAMP','BUILD_AT_UTC','BUILD_AT_PARIS')) { $stableDefines[$key] = $defines[$key] }
    }
    $identity = [ordered]@{ target=$target; deviceId=[string]$Settings.FlutterDeviceId; mode=$mode; origin=$origin; source=$sourceHash; dartDefines=$stableDefines; environment=$publicEnvironment }
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $fingerprint = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(($identity | ConvertTo-Json -Depth 8 -Compress))))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
    return [pscustomobject]@{ Fingerprint=$fingerprint; Defines=$defines; Environment=$publicEnvironment; HasRecipe=($null -ne $recipe) }
}

function Test-SgFlutterSessionConfiguration([object]$Entry,[object]$Configuration) {
    return [bool]($Entry.PSObject.Properties['flutterConfigurationFingerprint'] -and [string]$Entry.flutterConfigurationFingerprint -ceq $Configuration.Fingerprint)
}
