# Backend contract and launch gate. Loaded into the DevServer module.
function Assert-SgBackendFields($Value, [string[]]$Fields) {
    if ($null -eq $Value -or $Value -isnot [pscustomobject] -or
        (@($Value.PSObject.Properties.Name | Sort-Object) -join ',') -cne (@($Fields | Sort-Object) -join ',')) {
        throw 'Backend manifest fields are invalid (unknown and missing fields are forbidden).'
    }
}

function Get-SgBackendDigest([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Assert-SgBackendJsonKeys($Element) {
    if ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Object) {
        $seen=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
        foreach ($property in $Element.EnumerateObject()) {
            if (-not $seen.Add($property.Name)) { throw 'Backend manifest contains duplicate JSON fields.' }
            Assert-SgBackendJsonKeys $property.Value
        }
    } elseif ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Array) {
        foreach ($item in $Element.EnumerateArray()) { Assert-SgBackendJsonKeys $item }
    }
}

function Resolve-SgBackendFile([string]$Root, $Relative) {
    if ($Relative -isnot [string] -or [string]::IsNullOrWhiteSpace($Relative) -or [IO.Path]::IsPathRooted($Relative)) { throw 'Backend inputs must be project-relative files.' }
    $path = [IO.Path]::GetFullPath((Join-Path $Root $Relative))
    $prefix = [IO.Path]::GetFullPath($Root).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    if (-not $path.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Backend input is absent or outside the project.' }
    Assert-SgFlutterRecipePath $path $Root
    return $path
}

function Read-SgBackendManifest([string]$ProjectPath) {
    $path = Join-Path $ProjectPath '.shipglows.backend.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Backend declaration required: add .shipglows.backend.json, including an explicit justified mode none for a project without a backend.' }
    Assert-SgFlutterRecipePath $path $ProjectPath
    if ((Get-Item -LiteralPath $path).Length -gt 65536) { throw 'Backend manifest exceeds 64 KiB.' }
    $raw = [IO.File]::ReadAllText($path)
    try { $document=[Text.Json.JsonDocument]::Parse($raw) } catch { throw 'Backend manifest is not valid JSON.' }
    try { Assert-SgBackendJsonKeys $document.RootElement } finally { $document.Dispose() }
    try { $manifest = ConvertFrom-Json -InputObject $raw -ErrorAction Stop } catch { throw 'Backend manifest is not valid JSON.' }
    Assert-SgBackendFields $manifest @('schemaVersion','provider','mode','reason','command','dependencies','readiness')
    if ($manifest.schemaVersion -isnot [string] -or $manifest.mode -isnot [string] -or $manifest.provider -isnot [string] -or $manifest.schemaVersion -cne 'shipglows.backend.v1' -or $manifest.mode -cnotin @('none','local','remote') -or $manifest.provider -cnotin @('none','custom','convex','supabase','firebase','http')) { throw 'Unsupported backend schema, provider or mode.' }
    if ($manifest.dependencies -isnot [array]) { throw 'Backend dependencies must be an array of project-relative input files.' }
    if ($manifest.mode -eq 'none') {
        if ($manifest.provider -cne 'none' -or $manifest.reason -isnot [string] -or $manifest.reason.Trim().Length -lt 12 -or $null -ne $manifest.command -or $null -ne $manifest.readiness -or $manifest.dependencies.Count -ne 0) { throw 'Backend mode none requires provider none, a meaningful reason, null command/readiness and empty dependencies.' }
    } else {
        if ($manifest.provider -eq 'none' -or $null -ne $manifest.reason) { throw 'Required backends cannot use provider none or an exception reason.' }
        Assert-SgBackendFields $manifest.readiness @('url','statusCode','timeoutSeconds')
        $uri = $null
        if ($manifest.readiness.url -isnot [string] -or -not [uri]::TryCreate($manifest.readiness.url,[UriKind]::Absolute,[ref]$uri) -or $uri.Scheme -cnotin @('http','https') -or $uri.UserInfo -or $uri.Query -or $uri.Fragment) { throw 'Backend readiness requires a public HTTP(S) URL without credentials, query or fragment.' }
        if ($manifest.readiness.statusCode -isnot [long] -and $manifest.readiness.statusCode -isnot [int]) { throw 'Backend statusCode must be an integer.' }
        if ($manifest.readiness.statusCode -lt 200 -or $manifest.readiness.statusCode -gt 299 -or $manifest.readiness.timeoutSeconds -isnot [long] -and $manifest.readiness.timeoutSeconds -isnot [int] -or $manifest.readiness.timeoutSeconds -lt 1 -or $manifest.readiness.timeoutSeconds -gt 120) { throw 'Backend readiness requires a 2xx status and timeout between 1 and 120 seconds.' }
        if ($manifest.mode -eq 'local' -and -not $uri.IsLoopback) { throw 'Local backend readiness must use a loopback URL.' }
        if ($manifest.mode -eq 'remote' -and $null -ne $manifest.command) { throw 'Remote backend commands are forbidden.' }
    }
    $inputs = @()
    foreach ($relative in $manifest.dependencies) {
        $inputPath = Resolve-SgBackendFile $ProjectPath $relative
        $inputs += "$relative=$((Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash)"
    }
    $executable = $null
    if ($manifest.mode -eq 'local') {
        Assert-SgBackendFields $manifest.command @('executable','arguments','authorized')
        if ($manifest.command.authorized -isnot [bool] -or -not $manifest.command.authorized -or $manifest.command.executable -isnot [string] -or $manifest.command.executable -cnotmatch '^[A-Za-z0-9_.-]+\.exe$' -or $manifest.command.arguments -isnot [array]) { throw 'Local backend requires an explicitly authorized executable and argument array.' }
        foreach ($argument in $manifest.command.arguments) {
            if ($argument -isnot [string] -or $argument -match '[\x00-\x1f]') { throw 'Backend command arguments must be single-line strings.' }
        }
        if ($manifest.dependencies.Count -eq 0) { throw 'Local backend must declare its command/configuration input dependencies.' }
        $executable = Get-SgCommandPath @($manifest.command.executable)
        if (-not $executable) { throw 'Declared backend executable is unavailable.' }
        $inputs += "executable=$executable=$((Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash)"
    }
    return [pscustomobject]@{ Manifest=$manifest; Executable=$executable; Fingerprint=(Get-SgBackendDigest ($raw + ($inputs -join "`n"))); ProjectPath=$ProjectPath }
}

function Test-SgBackendReady($Readiness) {
    $handler = New-Object Net.Http.HttpClientHandler
    $handler.AllowAutoRedirect = $false
    $client = New-Object Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromSeconds([Math]::Min(3,$Readiness.timeoutSeconds))
    try {
        $response = $client.GetAsync([string]$Readiness.url,[Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
        try { return [int]$response.StatusCode -eq [int]$Readiness.statusCode } finally { $response.Dispose() }
    } catch { return $false } finally { $client.Dispose(); $handler.Dispose() }
}

function Stop-SgBackend($Backend) {
    if ($null -eq $Backend -or $Backend.mode -ne 'local' -or -not $Backend.process) { return }
    if (Test-SgProcessIdentity $Backend.process) {
        if (-not (Stop-SgManagedJob $Backend.process)) { Stop-SgProcessTree ([int]$Backend.process.pid) }
        $deadline = [DateTime]::UtcNow.AddSeconds(8)
        while ((Test-SgProcessIdentity $Backend.process) -and [DateTime]::UtcNow -lt $deadline) { Start-Sleep -Milliseconds 100 }
        if (Test-SgProcessIdentity $Backend.process) { throw 'Backend process extinction could not be proved.' }
    }
}

function Test-SgBackendListenerOwned($Process, [int]$Port) {
    if (-not (Test-SgProcessIdentity $Process)) { return $false }
    $listeners=@(Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return $false }
    $parents=@{}
    foreach ($item in @(Get-CimInstance Win32_Process -Property ProcessId,ParentProcessId)) { $parents[[int]$item.ProcessId]=[int]$item.ParentProcessId }
    foreach ($listener in $listeners) {
        $current=[int]$listener.OwningProcess
        $seen=New-Object 'System.Collections.Generic.HashSet[int]'
        while ($current -ne [int]$Process.pid -and $current -gt 0 -and $parents.ContainsKey($current) -and $seen.Add($current)) { $current=$parents[$current] }
        if ($current -ne [int]$Process.pid) { return $false }
    }
    return $true
}

function Stop-SgProject([object]$Config, [string]$ProjectPath, [switch]$PreserveBackend) {
    $path=ConvertTo-SgCanonicalPath $ProjectPath
    $mutex=New-Object Threading.Mutex($false,('Local\ShipGlowsBackend-' + (Get-SgBackendDigest ($Config.RegistryPath + $path.ToLowerInvariant()))))
    $locked=$false
    try {
        try { $locked=$mutex.WaitOne(30000) } catch [Threading.AbandonedMutexException] { $locked=$true }
        if (-not $locked) { throw 'Project launch or stop is already in progress.' }
        return Stop-SgProjectCore $Config $path -PreserveBackend:$PreserveBackend
    } finally { if ($locked) { $mutex.ReleaseMutex() }; $mutex.Dispose() }
}

function Initialize-SgBackend($Config, $Plan, $Existing) {
    $manifest = $Plan.Manifest
    $state = [pscustomobject]@{ mode=$manifest.mode; provider=$manifest.provider; fingerprint=$Plan.Fingerprint; status='ready'; checkedAtUtc=$null; instanceId=[guid]::NewGuid().ToString('N'); process=$null }
    if ($manifest.mode -eq 'none') { $state.status='not-required'; $state.checkedAtUtc=[DateTime]::UtcNow.ToString('o'); return $state }
    $created = $false
    try {
        if ($manifest.mode -eq 'local') {
            if ($Existing -and $Existing.fingerprint -eq $Plan.Fingerprint -and $Existing.process -and (Test-SgProcessIdentity $Existing.process)) {
                $state = $Existing
            } else {
                $uri = [uri]$manifest.readiness.url
                if (-not (Test-SgPortAvailable $uri.Port)) { throw 'Backend port is occupied by an unverified or different backend; existing session preserved.' }
                $directory = Join-Path $Config.RuntimeDirectory ("backend-launch\" + $state.instanceId)
                Ensure-SgDirectory $directory
                $payload = Join-Path $directory 'launch.json'
                $ownerSnapshot=Get-SgProcessSnapshot $PID
                if (-not $ownerSnapshot) { throw 'Backend launch owner identity is unavailable.' }
                $owner=[pscustomobject]@{pid=$PID;startTimeUtc=$ownerSnapshot.StartTimeUtc;executablePath=$ownerSnapshot.ExecutablePath;commandSignature=''}
                [IO.File]::WriteAllText($payload,([pscustomobject]@{Config=$Config;ProjectPath=$Plan.ProjectPath;InstanceId=$state.instanceId;Executable=$Plan.Executable;Arguments=$manifest.command.arguments;Readiness=$manifest.readiness;Owner=$owner} | ConvertTo-Json -Depth 20))
                $process = Start-SgDetachedProcess (Resolve-SgPowerShellExecutable) @('-NoProfile','-NonInteractive','-File',('"'+(Join-Path $PSScriptRoot 'ShipGlows.BackendSupervisor.ps1')+'"'),'-PayloadPath',('"'+$payload+'"')) $Plan.ProjectPath (Join-Path $directory 'stdout.log') (Join-Path $directory 'stderr.log') @{}
                $snapshot = Get-SgProcessSnapshot $process.Id
                if (-not $snapshot) { throw 'Backend supervisor exited during startup.' }
                $state.process = [pscustomobject]@{pid=$process.Id;startTimeUtc=$snapshot.StartTimeUtc;executablePath=$snapshot.ExecutablePath;commandSignature=$process.CommandSignature;jobName=$process.JobName}
                $created = $true
            }
        }
        $deadline = [DateTime]::UtcNow.AddSeconds($manifest.readiness.timeoutSeconds)
        do {
            if ($state.process -and -not (Test-SgProcessIdentity $state.process)) { throw 'Backend exited before readiness; application session preserved.' }
            if (Test-SgBackendReady $manifest.readiness) {
                if ($state.process -and -not (Test-SgBackendListenerOwned $state.process ([uri]$manifest.readiness.url).Port)) { throw 'Backend listener ownership is unverified; existing session preserved.' }
                $state.status='ready'; $state.checkedAtUtc=[DateTime]::UtcNow.ToString('o'); return $state
            }
            Start-Sleep -Milliseconds 200
        } while ([DateTime]::UtcNow -lt $deadline)
        throw 'Backend readiness failed; application session preserved.'
    } catch { if ($created) { Stop-SgBackend $state }; throw }
}

function Start-SgProject([object]$Config, [string]$ProjectPath, [int]$RequestedPort=0, [switch]$FlutterVisible, [switch]$RetryingFlutterStartup, [ValidateSet('','windows','android','chrome','web-server')][string]$FlutterDevice='', [string]$FlutterDeviceId='', [ValidateSet('','debug','profile')][string]$FlutterMode='', [ValidateSet('','windows','android')][string]$TauriDevice='', [string]$TauriDeviceId='', [switch]$Restart) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    if (-not (Test-SgProjectPath $path $Config.Workspace)) { throw 'Project must be inside the ShipGlows workspace before backend launch.' }
    $existing = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path }) | Select-Object -First 1
    if (-not $existing) {
        $descriptors=@(Get-SgProjectDescriptors $path)
        $selected=$descriptors | Where-Object { $_.LaunchPath -eq $path } | Select-Object -First 1
        if (-not $selected -and $descriptors.Count -eq 1) { $selected=$descriptors[0] }
        if (-not $selected) { throw 'Multiple runnable surfaces were detected. Choose one surface instead of the monorepo root.' }
        $path=$selected.LaunchPath
    }
    $mutex = New-Object Threading.Mutex($false,('Local\ShipGlowsBackend-' + (Get-SgBackendDigest ($Config.RegistryPath + $path.ToLowerInvariant()))))
    $locked = $false; $backend = $null; $oldBackend = $null; $completed = $false
    try {
        try { $locked=$mutex.WaitOne(30000) } catch [Threading.AbandonedMutexException] { $locked=$true }
        if (-not $locked) { throw 'Project backend launch is already in progress.' }
        $existing = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path }) | Select-Object -First 1
        if ($existing -and -not (Test-SgProjectCatalogEntry $existing)) { throw 'Project surface no longer matches its registered manifest; backend was not launched.' }
        if ($existing -and $existing.PSObject.Properties['backend']) { $oldBackend=$existing.backend }
        $plan = Read-SgBackendManifest $path
        $backend = Initialize-SgBackend $Config $plan $oldBackend
        if ($existing -and (Test-SgProcessIdentity $existing) -and (-not $oldBackend -or $oldBackend.fingerprint -ne $backend.fingerprint)) {
            $Restart=$true
        }
        $result = Start-SgProjectCore $Config $path $RequestedPort -FlutterVisible:$FlutterVisible -RetryingFlutterStartup:$RetryingFlutterStartup -FlutterDevice $FlutterDevice -FlutterDeviceId $FlutterDeviceId -FlutterMode $FlutterMode -TauriDevice $TauriDevice -TauriDeviceId $TauriDeviceId -Restart:$Restart
        if ($result.status -eq 'running') {
            if (($backend.process -and -not (Test-SgProcessIdentity $backend.process)) -or ($backend.mode -ne 'none' -and -not (Test-SgBackendReady $plan.Manifest.readiness))) { [void](Stop-SgProject $Config $path); throw 'Backend lost readiness during application startup.' }
            $result | Add-Member -NotePropertyName backend -NotePropertyValue $backend -Force
            Invoke-SgRegistryMutation $Config { param($data) $item=@($data.projects | Where-Object { $_.path -eq $path })[0]; $item | Add-Member -NotePropertyName backend -NotePropertyValue $backend -Force } | Out-Null
            if ($oldBackend -and $oldBackend.instanceId -ne $backend.instanceId) { Stop-SgBackend $oldBackend }
            $completed=$true
        }
        return $result
    } finally {
        if (-not $completed -and $backend -and (-not $oldBackend -or $backend.instanceId -ne $oldBackend.instanceId)) { Stop-SgBackend $backend }
        if ($locked) { $mutex.ReleaseMutex() }; $mutex.Dispose()
    }
}
