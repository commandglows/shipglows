Set-StrictMode -Version Latest

$script:RegistryVersion = 1
$script:DefaultPortStart = 3000
$script:DefaultPortEnd = 3100
$script:ProjectIndexSchemaVersion = 1
$script:ProjectScannerVersion = '1'
$script:ProjectIndexTtlMinutes = 5
$script:ProjectCatalogMemory = @{}

function Write-SgInfo([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Cyan }
function Write-SgWarn([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Yellow }
function Write-SgError([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Red }

function Get-SgDevConfig {
    $workspace = if ($env:SHIPGLOWS_WINDOWS_WORKSPACE) { $env:SHIPGLOWS_WINDOWS_WORKSPACE } else { Join-Path $env:USERPROFILE 'ShipGlows' }
    $runtime = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'ShipGlows\DevServer' } else { Join-Path $env:USERPROFILE 'AppData\Local\ShipGlows\DevServer' }
    [pscustomobject]@{
        Workspace = [IO.Path]::GetFullPath($workspace)
        RuntimeDirectory = [IO.Path]::GetFullPath($runtime)
        RegistryPath = Join-Path $runtime 'registry.json'
        LockPath = Join-Path $runtime 'registry.lock'
        ProjectIndexPath = Join-Path $runtime 'project-index.json'
        LogDirectory = Join-Path $runtime 'logs'
        PortStart = $script:DefaultPortStart
        PortEnd = $script:DefaultPortEnd
    }
}

function Ensure-SgDirectory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function ConvertTo-SgCanonicalPath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { throw 'Project path is required.' }
    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    $full = [IO.Path]::GetFullPath($expanded)
    if (-not (Test-Path -LiteralPath $full -PathType Container)) { throw "Project path does not exist: $full" }
    return $full.TrimEnd('\','/')
}

function Test-SgProjectPath([string]$Path, [string]$Workspace) {
    try {
        $full = ConvertTo-SgCanonicalPath $Path
        $root = ConvertTo-SgCanonicalPath $Workspace
        $rootPrefix = $root.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
        return $full.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or $full.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)
    } catch { return $false }
}

function Test-SgGitUrl([string]$Url) {
    if ([string]::IsNullOrWhiteSpace($Url)) { return $false }
    if ($Url -match '://[^/]*:') { return $false }
    return $Url -match '^(https://|ssh://|git@)[^\s]+$'
}

function Get-SgRegistryDefault {
    [pscustomobject]@{ schemaVersion = $script:RegistryVersion; projects = @() }
}

function Read-SgRegistry([object]$Config) {
    Ensure-SgDirectory $Config.RuntimeDirectory
    if (-not (Test-Path -LiteralPath $Config.RegistryPath -PathType Leaf)) { return Get-SgRegistryDefault }
    try {
        $raw = Get-Content -LiteralPath $Config.RegistryPath -Raw -ErrorAction Stop
        $data = $raw | ConvertFrom-Json -ErrorAction Stop
        if ($data.schemaVersion -ne $script:RegistryVersion -or $null -eq $data.projects) { throw 'Unsupported registry schema.' }
        return $data
    } catch {
        $backup = "$($Config.RegistryPath).invalid"
        try { Copy-Item -LiteralPath $Config.RegistryPath -Destination $backup -Force } catch { }
        Write-SgWarn "Registry invalid; using an empty recoverable view. Backup: $backup"
        return Get-SgRegistryDefault
    }
}

function Write-SgRegistry([object]$Config, [object]$Registry) {
    Ensure-SgDirectory $Config.RuntimeDirectory
    $temp = "$($Config.RegistryPath).$([guid]::NewGuid().ToString('N')).tmp"
    $json = $Registry | ConvertTo-Json -Depth 10
    try {
        Set-Content -LiteralPath $temp -Value $json -Encoding UTF8 -ErrorAction Stop
        $parsed = (Get-Content -LiteralPath $temp -Raw) | ConvertFrom-Json -ErrorAction Stop
        if ($parsed.schemaVersion -ne $script:RegistryVersion) { throw 'Registry validation failed.' }
        if (Test-Path -LiteralPath $Config.RegistryPath -PathType Leaf) {
            $backup = "$($Config.RegistryPath).bak"
            try { [IO.File]::Replace($temp, $Config.RegistryPath, $backup) }
            finally { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
        } else {
            Move-Item -LiteralPath $temp -Destination $Config.RegistryPath -Force
        }
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

function Invoke-SgRegistryMutation([object]$Config, [scriptblock]$Mutation) {
    Ensure-SgDirectory $Config.RuntimeDirectory
    $lock = $null
    try {
        $deadline = (Get-Date).AddSeconds(15)
        do {
            try {
                $lock = [IO.File]::Open($Config.LockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
            } catch [IO.IOException] {
                if ((Get-Date) -ge $deadline) { throw }
                Start-Sleep -Milliseconds 25
            }
        } while (-not $lock)
        $registry = Read-SgRegistry $Config
        & $Mutation $registry
        Write-SgRegistry $Config $registry
        return $registry
    } finally {
        if ($lock) { $lock.Dispose() }
    }
}

function Get-SgCommandPath([string[]]$Names) {
    foreach ($name in $Names) {
        $command = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) { return $command.Source }
    }
    return $null
}

function Get-SgProjectKind([string]$ProjectPath) {
    $package = Join-Path $ProjectPath 'package.json'
    $pubspec = Join-Path $ProjectPath 'pubspec.yaml'
    if ([IO.File]::Exists($package)) {
        try {
            $packageText = [IO.File]::ReadAllText($package)
            $trimmedPackage = $packageText.Trim()
            if (-not ($trimmedPackage.StartsWith('{') -and $trimmedPackage.EndsWith('}'))) {
                $null = $packageText | ConvertFrom-Json -ErrorAction Stop
            } elseif ($packageText -match '(?s)"scripts"\s*:\s*\{.*?"dev"\s*:') {
                $json = $packageText | ConvertFrom-Json -ErrorAction Stop
                $all = @()
                foreach ($property in @('dependencies','devDependencies','peerDependencies')) {
                    $dependencySection = $json.PSObject.Properties[$property]
                    if ($dependencySection -and $dependencySection.Value) {
                        foreach ($dependency in @($dependencySection.Value.PSObject.Properties)) { $all += [string]$dependency.Name }
                    }
                }
                $scriptsProperty = $json.PSObject.Properties['scripts']
                $hasDevScript = $scriptsProperty -and $scriptsProperty.Value -and $scriptsProperty.Value.PSObject.Properties['dev'] -and $scriptsProperty.Value.dev
                if ($all -contains 'astro' -and $hasDevScript) { return 'astro' }
                if ($all -contains 'vite' -and $hasDevScript) { return 'vite' }
            }
        } catch { throw "Invalid package.json: $($_.Exception.Message)" }
    }
    if ([IO.File]::Exists($pubspec) -and [IO.Directory]::Exists((Join-Path $ProjectPath 'web'))) {
        if ([IO.File]::ReadAllText($pubspec) -match '(?m)^\s*flutter:\s*$') { return 'flutter-web' }
    }
    if ([IO.File]::Exists((Join-Path $ProjectPath 'pyproject.toml'))) {
        if ([IO.File]::Exists((Join-Path $ProjectPath 'uv.lock'))) { return 'python' }
        if ([IO.File]::Exists((Join-Path $ProjectPath 'requirements.txt'))) { return 'python' }
    }
    if ([IO.File]::Exists((Join-Path $ProjectPath 'requirements.txt'))) { return 'python' }
    throw "Unsupported or ambiguous project. Supported kinds: Astro, Vite, Python/FastAPI with uv/requirements, Flutter Web."
}

function Get-SgProjectDescriptors([string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $candidates = @()
    $queue = New-Object System.Collections.Generic.Queue[object]
    [void]$queue.Enqueue([pscustomobject]@{ Path = $root; Depth = 0 })
    $pruneDirs = @('.git', 'node_modules', 'venv', '.venv', '__pycache__', 'target', '.next', '.nuxt', 'dist', '.cache', '.pnpm', '.yarn')
    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue()
        try {
            $kind = Get-SgProjectKind ([string]$item.Path)
            $candidates += [pscustomobject]@{ RootPath = $root; LaunchPath = [string]$item.Path; Kind = $kind; Depth = [int]$item.Depth }
        } catch {
            if ($_.Exception.Message -notlike 'Unsupported or ambiguous project.*') { throw }
        }
        if ([int]$item.Depth -ge 3) { continue }
        foreach ($dir in @(Get-ChildItem -LiteralPath ([string]$item.Path) -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($pruneDirs -contains $dir.Name) { continue }
            if ($dir.Name -match '^\.' ) { continue }
            if ($dir.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            [void]$queue.Enqueue([pscustomobject]@{ Path = $dir.FullName; Depth = ([int]$item.Depth + 1) })
        }
    }
    $selected = @($candidates | Sort-Object -Property Depth,LaunchPath)
    if ($selected.Count -eq 0) { throw "No supported Windows launch target was detected at or below: $root" }
    return $selected
}

function Get-SgProjectDescriptor([string]$ProjectPath) {
    $descriptors = @(Get-SgProjectDescriptors $ProjectPath)
    if ($descriptors.Count -gt 1) { throw "Multiple runnable surfaces were detected. Choose one surface instead of the monorepo root: $ProjectPath" }
    return $descriptors[0]
}

function Get-SgRuntimeSettings([string]$ProjectPath) {
    $settings = [pscustomobject]@{ Port = 0; AutoRepair = $true }
    $file = Join-Path $ProjectPath '.shipglows.env'
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return $settings }
    foreach ($rawLine in @(Get-Content -LiteralPath $file)) {
        $line = ([string]$rawLine).Trim()
        if (-not $line -or $line.StartsWith('#')) { continue }
        if ($line -match '^SHIPGLOWS_ENV_PORT=(.+)$') {
            $value = $Matches[1].Trim()
            if ($value -notmatch '^\d+$' -or [int]$value -lt 1024 -or [int]$value -gt 65535) { throw "Invalid SHIPGLOWS_ENV_PORT in $file; expected a port between 1024 and 65535." }
            $settings.Port = [int]$value
        } elseif ($line -match '^SHIPGLOWS_AUTO_REPAIR=(true|false)$') {
            $settings.AutoRepair = $Matches[1] -eq 'true'
        } else {
            throw "Unsupported line in ${file}: $line. Allowed keys: SHIPGLOWS_ENV_PORT and SHIPGLOWS_AUTO_REPAIR."
        }
    }
    return $settings
}

function Get-SgFreePort([object]$Config, [int]$RequestedPort = 0, [string]$OwnerPath = '') {
    $reserved = @((Read-SgRegistry $Config).projects | Where-Object { $_.port -and (-not $OwnerPath -or $_.path -ne $OwnerPath) } | ForEach-Object { [int]$_.port })
    $candidates = if ($RequestedPort -gt 0) { @($RequestedPort) } else { $Config.PortStart..$Config.PortEnd }
    foreach ($port in $candidates) {
        if ($reserved -contains $port) { continue }
        $listener = $null
        if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
            $listener = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        } else {
            $tcp = New-Object Net.Sockets.TcpClient
            try { $tcp.Connect('127.0.0.1', $port); $listener = $true } catch { $listener = $null } finally { $tcp.Dispose() }
        }
        if (-not $listener) { return $port }
    }
    throw "No free localhost port is available in the requested range."
}

function Test-SgPortAvailable([int]$Port) {
    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
        return -not [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1)
    }
    $tcp = New-Object Net.Sockets.TcpClient
    try {
        $tcp.Connect('127.0.0.1', $Port)
        return $false
    } catch {
        return $true
    } finally {
        $tcp.Dispose()
    }
}

function Reserve-SgProjectPort([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0, [bool]$Explicit = $false) {
    if ($RequestedPort -ne 0 -and ($RequestedPort -lt 1024 -or $RequestedPort -gt 65535)) { throw 'Requested port must be 0 or between 1024 and 65535.' }
    $token = [guid]::NewGuid().ToString('N')
    $result = Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath } | Select-Object -First 1
        if (-not $entry) { throw "Project is not registered: $ProjectPath" }

        $now = (Get-Date).ToUniversalTime()
        foreach ($item in @($data.projects)) {
            $hasReservationTime = $item.PSObject.Properties['reservationTimeUtc'] -and $item.reservationTimeUtc
            if ($item.status -in @('reserved','starting') -and $hasReservationTime) {
                $expired = $true
                try {
                    $expired = ($now - [datetime]::Parse([string]$item.reservationTimeUtc).ToUniversalTime()).TotalMinutes -ge 5
                } catch {
                    # Corrupt reservation metadata cannot retain a port lock.
                    $expired = $true
                }
                if ($expired -and -not (Test-SgProcessIdentity $item)) {
                    $item.status = 'stopped'
                    $item | Add-Member -NotePropertyName reservationToken -NotePropertyValue $null -Force
                    $item | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $null -Force
                }
            }
        }

        $otherPorts = @($data.projects | Where-Object { $_.path -ne $ProjectPath -and [int]$_.port -gt 0 } | ForEach-Object { [int]$_.port })
        $existingPort = if ($entry.PSObject.Properties['port']) { [int]$entry.port } else { 0 }
        $candidates = if ($RequestedPort -gt 0) {
            @($RequestedPort)
        } elseif ($existingPort -gt 0) {
            @($existingPort) + @($Config.PortStart..$Config.PortEnd | Where-Object { $_ -ne $existingPort })
        } else {
            @($Config.PortStart..$Config.PortEnd)
        }

        $selected = 0
        foreach ($candidate in $candidates) {
            if ($otherPorts -contains $candidate -or -not (Test-SgPortAvailable $candidate)) {
                if ($Explicit) { throw "Configured port $candidate is already occupied or reserved." }
                continue
            }
            $selected = $candidate
            break
        }
        if ($selected -le 0) { throw 'No free localhost port is available in the requested range.' }

        $entry.port = $selected
        $entry.status = 'reserved'
        $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $token -Force
        $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $now.ToString('o') -Force
    }
    $reservedEntry = $result.projects | Where-Object { $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $token } | Select-Object -First 1
    if (-not $reservedEntry) { throw "Port reservation could not be persisted for: $ProjectPath" }
    return [pscustomobject]@{ Port = [int]$reservedEntry.port; Token = $token }
}

function Set-SgReservationState([object]$Config, [string]$ProjectPath, [string]$Token, [string]$Status, [object]$EntryData = $null) {
    Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath -and $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $Token } | Select-Object -First 1
        if (-not $entry) { throw "Port reservation was lost for: $ProjectPath" }
        if ($EntryData) {
            foreach ($property in $EntryData.PSObject.Properties) {
                $entry | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value -Force
            }
        }
        $entry.status = $Status
        if ($Status -notin @('reserved','starting')) {
            $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $null -Force
            $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $null -Force
        }
    } | Out-Null
}

function Release-SgProjectPort([object]$Config, [string]$ProjectPath, [string]$Token, [string]$ErrorMessage = '') {
    Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath -and $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $Token } | Select-Object -First 1
        if (-not $entry) { return }
        $entry.status = 'error'
        $entry | Add-Member -NotePropertyName lastError -NotePropertyValue $ErrorMessage -Force
        $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $null -Force
        $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $null -Force
    } | Out-Null
}

function Get-SgProcessSnapshot([int]$Pid) {
    if ($Pid -le 0) { return $null }
    $process = Get-Process -Id $Pid -ErrorAction SilentlyContinue
    if (-not $process) { return $null }
    $cim = Get-CimInstance Win32_Process -Filter "ProcessId = $Pid" -ErrorAction SilentlyContinue
    $start = $null
    try { $start = $process.StartTime.ToUniversalTime().ToString('o') } catch { }
    [pscustomobject]@{
        Pid = $Pid
        StartTimeUtc = $start
        ExecutablePath = if ($cim) { $cim.ExecutablePath } else { $null }
        CommandLine = if ($cim) { $cim.CommandLine } else { $null }
    }
}

function Test-SgProcessIdentity([object]$Entry) {
    $current = Get-SgProcessSnapshot ([int]$Entry.pid)
    if (-not $current) { return $false }
    if ($Entry.startTimeUtc -and $current.StartTimeUtc -ne $Entry.startTimeUtc) { return $false }
    if ($Entry.executablePath -and $current.ExecutablePath -and [IO.Path]::GetFullPath($Entry.executablePath) -ne [IO.Path]::GetFullPath($current.ExecutablePath)) { return $false }
    if ($Entry.commandSignature -and $current.CommandLine -and $current.CommandLine -notlike "*$($Entry.commandSignature)*") { return $false }
    return $true
}

function Get-SgRunnableIdentity([object]$Entry) {
    if (-not $Entry) { return $null }
    $candidate = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } elseif ($Entry.PSObject.Properties['path'] -and $Entry.path) { [string]$Entry.path } else { $null }
    if ([string]::IsNullOrWhiteSpace($candidate)) { return $null }
    return [IO.Path]::GetFullPath($candidate).TrimEnd('\','/').ToLowerInvariant()
}

function Get-SgCanonicalSurfaceName([string]$RootPath, [string]$LaunchPath) {
    $root = [IO.Path]::GetFullPath($RootPath).TrimEnd('\','/')
    $launch = [IO.Path]::GetFullPath($LaunchPath).TrimEnd('\','/')
    $rootName = Split-Path $root -Leaf
    if ($launch.Equals($root, [StringComparison]::OrdinalIgnoreCase)) { return $rootName }
    $prefix = $root + [IO.Path]::DirectorySeparatorChar
    if (-not $launch.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Launch path is outside its project root: $launch" }
    return "$rootName-$($launch.Substring($prefix.Length) -replace '[\\/]', '-')"
}

function Get-SgDisplayName([object]$Entry, [string]$Workspace = '') {
    $fallback = if ($Entry.PSObject.Properties['name'] -and $Entry.name) { [string]$Entry.name } else { 'unknown' }
    if ($Workspace) {
        try {
            $workspacePath = [IO.Path]::GetFullPath($Workspace).TrimEnd('\','/')
            $launchPath = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [IO.Path]::GetFullPath([string]$Entry.launchPath).TrimEnd('\','/') } else { [IO.Path]::GetFullPath([string]$Entry.path).TrimEnd('\','/') }
            if ($launchPath.Equals($workspacePath, [StringComparison]::OrdinalIgnoreCase)) { return '.' }
            $workspacePrefix = $workspacePath + [IO.Path]::DirectorySeparatorChar
            if ($launchPath.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) {
                return $launchPath.Substring($workspacePrefix.Length).Replace('\','/')
            }
            return $launchPath
        } catch { return $fallback }
    }
    if (-not ($Entry.PSObject.Properties['rootPath'] -and $Entry.rootPath)) { return $fallback }
    try {
        $root = [IO.Path]::GetFullPath([string]$Entry.rootPath).TrimEnd('\','/')
        $launch = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [IO.Path]::GetFullPath([string]$Entry.launchPath).TrimEnd('\','/') } else { [IO.Path]::GetFullPath([string]$Entry.path).TrimEnd('\','/') }
        return Get-SgCanonicalSurfaceName $root $launch
    } catch {
        return $fallback
    }
}

function Add-SgDiscoveredMetadata([object]$RegisteredEntry, [object]$Candidate) {
    if (-not $RegisteredEntry -or -not $Candidate) { return $RegisteredEntry }
    if ($Candidate.PSObject.Properties['rootPath'] -and $Candidate.rootPath) {
        $RegisteredEntry | Add-Member -NotePropertyName rootPath -NotePropertyValue ([string]$Candidate.rootPath) -Force
    }
    if ($Candidate.PSObject.Properties['launchPath'] -and $Candidate.launchPath) {
        $RegisteredEntry | Add-Member -NotePropertyName launchPath -NotePropertyValue ([string]$Candidate.launchPath) -Force
    }
    return $RegisteredEntry
}

function ConvertTo-SgGitHubRepositoryIdentity([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    $candidate = $Value.Trim()
    $repositoryPath = $null

    if ($candidate -match '^(?<owner>[A-Za-z0-9](?:[A-Za-z0-9-]{0,38}))/(?<repository>[A-Za-z0-9._-]+?)(?:[.]git)?$') {
        $repositoryPath = "$($Matches.owner)/$($Matches.repository)"
    } elseif ($candidate -match '^(?i)git@github[.]com:(?<path>[^?#]+)$') {
        $repositoryPath = [string]$Matches.path
    } else {
        $uri = $null
        if (-not [uri]::TryCreate($candidate, [UriKind]::Absolute, [ref]$uri)) { return $null }
        if (-not $uri.Host.Equals('github.com', [StringComparison]::OrdinalIgnoreCase)) { return $null }
        if ($uri.Scheme -notin @('https','ssh')) { return $null }
        if ($uri.Query -or $uri.Fragment) { return $null }
        $repositoryPath = $uri.AbsolutePath.Trim('/')
    }

    $repositoryPath = $repositoryPath -replace '[.]git$',''
    if ($repositoryPath -notmatch '^(?<owner>[A-Za-z0-9](?:[A-Za-z0-9-]{0,38}))/(?<repository>[A-Za-z0-9._-]+)$') { return $null }
    return "$($Matches.owner)/$($Matches.repository)".ToLowerInvariant()
}

function Get-SgInstalledGitHubRepositoryIdentities([object]$Config, [string]$GitPath = '') {
    $workspace = ConvertTo-SgCanonicalPath ([string]$Config.Workspace)
    if ([string]::IsNullOrWhiteSpace($GitPath)) {
        $gitCommand = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $gitCommand) { return @() }
        $GitPath = [string]$gitCommand.Source
    }
    if (-not (Test-Path -LiteralPath $GitPath -PathType Leaf)) { return @() }

    $candidatePaths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    try {
        foreach ($directory in @(Get-ChildItem -LiteralPath $workspace -Directory -Force -ErrorAction Stop)) {
            if ($directory.Name.StartsWith('.') -or ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
            [void]$candidatePaths.Add([IO.Path]::GetFullPath($directory.FullName).TrimEnd('\','/'))
        }
    } catch [UnauthorizedAccessException] { }
    foreach ($entry in @(Get-SgProjectCatalog $Config)) {
        $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } elseif ($entry.PSObject.Properties['path']) { [string]$entry.path } else { '' }
        if ($rootPath) {
            try { [void]$candidatePaths.Add([IO.Path]::GetFullPath($rootPath).TrimEnd('\','/')) } catch { }
        }
    }

    $workspacePrefix = $workspace.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    $repositoryRoots = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $identities = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        foreach ($candidatePath in $candidatePaths) {
            $repositoryRootOutput = @(& $GitPath -C $candidatePath rev-parse --show-toplevel 2>$null)
            $repositoryRootExitCode = $LASTEXITCODE
            $repositoryRoot = $repositoryRootOutput | Select-Object -First 1
            if ($repositoryRootExitCode -ne 0 -or [string]::IsNullOrWhiteSpace([string]$repositoryRoot)) { continue }
            try { $repositoryRoot = [IO.Path]::GetFullPath([string]$repositoryRoot).TrimEnd('\','/') } catch { continue }
            if (-not ($repositoryRoot.Equals($workspace, [StringComparison]::OrdinalIgnoreCase) -or $repositoryRoot.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase))) { continue }
            if (-not $repositoryRoots.Add($repositoryRoot)) { continue }
            $originOutput = @(& $GitPath -C $repositoryRoot remote get-url origin 2>$null)
            $originExitCode = $LASTEXITCODE
            $origin = $originOutput | Select-Object -First 1
            if ($originExitCode -ne 0) { continue }
            $identity = ConvertTo-SgGitHubRepositoryIdentity ([string]$origin)
            if ($identity) { [void]$identities.Add($identity) }
        }
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    return @($identities | Sort-Object)
}

function Select-SgGitHubCloneCandidates([object[]]$Repositories, [string[]]$InstalledRepositoryIdentities = @()) {
    $installed = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($identity in @($InstalledRepositoryIdentities)) {
        $normalized = ConvertTo-SgGitHubRepositoryIdentity ([string]$identity)
        if ($normalized) { [void]$installed.Add($normalized) }
    }
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $available = New-Object 'System.Collections.Generic.List[object]'
    foreach ($repository in @($Repositories)) {
        if (-not $repository) { continue }
        $value = if ($repository.PSObject.Properties['nameWithOwner']) { [string]$repository.nameWithOwner } elseif ($repository.PSObject.Properties['url']) { [string]$repository.url } else { '' }
        $identity = ConvertTo-SgGitHubRepositoryIdentity $value
        if (-not $identity -or $installed.Contains($identity) -or -not $seen.Add($identity)) { continue }
        [void]$available.Add($repository)
    }
    return @($available.ToArray())
}

function Get-SgProjectIndexPath([object]$Config) {
    if ($Config.PSObject.Properties['ProjectIndexPath'] -and $Config.ProjectIndexPath) {
        return [IO.Path]::GetFullPath([string]$Config.ProjectIndexPath)
    }
    return Join-Path ([IO.Path]::GetFullPath([string]$Config.RuntimeDirectory)) 'project-index.json'
}

function Get-SgProjectCatalogCacheKey([object]$Config) {
    $workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/').ToLowerInvariant()
    return "$workspace|$((Get-SgProjectIndexPath $Config).ToLowerInvariant())"
}

function Test-SgProjectIndex([object]$Config, [object]$Index) {
    if (-not $Index -or $Index.schemaVersion -ne $script:ProjectIndexSchemaVersion -or [string]$Index.scannerVersion -ne $script:ProjectScannerVersion -or $null -eq $Index.projects) { return $false }
    $workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
    $indexedWorkspace = try { [IO.Path]::GetFullPath([string]$Index.workspace).TrimEnd('\','/') } catch { return $false }
    if (-not $workspace.Equals($indexedWorkspace, [StringComparison]::OrdinalIgnoreCase)) { return $false }
    try { $generatedAt = [datetime]::Parse([string]$Index.generatedAt).ToUniversalTime() } catch { return $false }
    $age = ((Get-Date).ToUniversalTime() - $generatedAt).TotalMinutes
    return $age -ge 0 -and $age -lt $script:ProjectIndexTtlMinutes
}

function Read-SgProjectIndex([object]$Config) {
    $path = Get-SgProjectIndexPath $Config
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try {
        $index = (Get-Content -LiteralPath $path -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
        if (Test-SgProjectIndex $Config $index) { return $index }
    } catch { }
    return $null
}

function Write-SgProjectIndex([object]$Config, [object[]]$Projects) {
    $path = Get-SgProjectIndexPath $Config
    $directory = Split-Path -Parent $path
    Ensure-SgDirectory $directory
    $lockPath = "$path.lock"
    $lock = $null
    $temp = "$path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        $deadline = (Get-Date).AddSeconds(15)
        do {
            try { $lock = [IO.File]::Open($lockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
            catch [IO.IOException] {
                if ((Get-Date) -ge $deadline) { throw }
                Start-Sleep -Milliseconds 20
            }
        } while (-not $lock)
        $index = [pscustomobject]@{
            schemaVersion = $script:ProjectIndexSchemaVersion
            workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
            scannerVersion = $script:ProjectScannerVersion
            generatedAt = (Get-Date).ToUniversalTime().ToString('o')
            projects = @($Projects)
        }
        $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $temp -Encoding UTF8 -ErrorAction Stop
        $parsed = (Get-Content -LiteralPath $temp -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
        if (-not (Test-SgProjectIndex $Config $parsed)) { throw 'Project index validation failed.' }
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $backup = "$path.bak"
            try { [IO.File]::Replace($temp, $path, $backup) }
            finally { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
        } else {
            Move-Item -LiteralPath $temp -Destination $path -Force
        }
        return $index
    } finally {
        if ($lock) { $lock.Dispose() }
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

function Clear-SgProjectCatalogCache([object]$Config) {
    $key = Get-SgProjectCatalogCacheKey $Config
    [void]$script:ProjectCatalogMemory.Remove($key)
    $path = Get-SgProjectIndexPath $Config
    $directory = Split-Path -Parent $path
    Ensure-SgDirectory $directory
    $lock = $null
    try {
        $deadline = (Get-Date).AddSeconds(15)
        do {
            try { $lock = [IO.File]::Open("$path.lock", [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
            catch [IO.IOException] {
                if ((Get-Date) -ge $deadline) { throw }
                Start-Sleep -Milliseconds 20
            }
        } while (-not $lock)
        if (Test-Path -LiteralPath $path -PathType Leaf) { Remove-Item -LiteralPath $path -Force -ErrorAction Stop }
    } finally {
        if ($lock) { $lock.Dispose() }
    }
}

function Find-SgWorkspaceProjectCandidates([object]$Config) {
    $workspace = ConvertTo-SgCanonicalPath ([string]$Config.Workspace)
    $manifests = @{'package.json'=$true;'pyproject.toml'=$true;'requirements.txt'=$true;'pubspec.yaml'=$true}
    $pruneDirs = @{'.git'=$true;'node_modules'=$true;'venv'=$true;'.venv'=$true;'__pycache__'=$true;'target'=$true;'.next'=$true;'.nuxt'=$true;'dist'=$true;'.cache'=$true;'.pnpm'=$true;'.yarn'=$true}
    $paths = New-Object 'System.Collections.Generic.Queue[string]'
    $depths = New-Object 'System.Collections.Generic.Queue[int]'
    $roots = New-Object 'System.Collections.Generic.Queue[string]'
    $boundaryDepths = New-Object 'System.Collections.Generic.Queue[int]'
    $paths.Enqueue($workspace); $depths.Enqueue(0); $roots.Enqueue(''); $boundaryDepths.Enqueue(-1)
    $seen = @{}
    $projects = New-Object 'System.Collections.Generic.List[object]'
    while ($paths.Count -gt 0) {
        $path = $paths.Dequeue()
        $depth = $depths.Dequeue()
        $rootPath = $roots.Dequeue()
        $boundaryDepth = $boundaryDepths.Dequeue()
        if (-not [IO.Directory]::Exists($path)) { continue }
        $hasManifest = $false
        try {
            foreach ($filePath in [IO.Directory]::EnumerateFiles($path)) {
                if ($manifests.ContainsKey([IO.Path]::GetFileName($filePath))) { $hasManifest = $true; break }
            }
        } catch [UnauthorizedAccessException] {
            continue
        }
        $isRepositoryRoot = [IO.Directory]::Exists([IO.Path]::Combine($path, '.git'))
        if (-not $rootPath -and ($isRepositoryRoot -or $hasManifest)) { $rootPath = $path; $boundaryDepth = $depth }

        if ($hasManifest) {
            try {
                $kind = Get-SgProjectKind $path
                $identity = $path.ToLowerInvariant()
                if (-not $seen.ContainsKey($identity)) {
                    $seen[$identity] = $true
                    [void]$projects.Add([pscustomobject]@{
                        name = Get-SgCanonicalSurfaceName $(if ($rootPath) { $rootPath } else { $path }) $path
                        path = $path
                        rootPath = $(if ($rootPath) { $rootPath } else { $path })
                        launchPath = $path
                        kind = $kind
                        status = 'discovered'
                        port = 0
                        logPath = $null
                        errorLogPath = $null
                    })
                }
            } catch {
                if ($_.Exception.Message -notlike 'Unsupported or ambiguous project.*') { throw }
            }
        }

        $canDescend = if ($rootPath) { ($depth - $boundaryDepth) -lt 3 } else { $depth -lt 4 }
        if (-not $canDescend) { continue }
        try { $directories = [IO.Directory]::EnumerateDirectories($path) } catch [UnauthorizedAccessException] { continue }
        foreach ($directoryPath in $directories) {
            $directoryName = [IO.Path]::GetFileName($directoryPath)
            if ($directoryName.StartsWith('.') -or $pruneDirs.ContainsKey($directoryName)) { continue }
            try { $attributes = [IO.File]::GetAttributes($directoryPath) } catch { continue }
            if ($attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            $paths.Enqueue($directoryPath); $depths.Enqueue($depth + 1); $roots.Enqueue($rootPath); $boundaryDepths.Enqueue($boundaryDepth)
        }
    }
    return @($projects.ToArray() | Sort-Object -Property path)
}

function Get-SgWorkspaceProjectCandidates([object]$Config, [switch]$ForceRefresh) {
    $key = Get-SgProjectCatalogCacheKey $Config
    if (-not $ForceRefresh -and $script:ProjectCatalogMemory.ContainsKey($key)) {
        $memoryIndex = $script:ProjectCatalogMemory[$key]
        if (Test-SgProjectIndex $Config $memoryIndex) { return @($memoryIndex.projects) }
        [void]$script:ProjectCatalogMemory.Remove($key)
    }
    if (-not $ForceRefresh) {
        $persisted = Read-SgProjectIndex $Config
        if ($persisted) { $script:ProjectCatalogMemory[$key] = $persisted; return @($persisted.projects) }
    }
    $projects = @(Find-SgWorkspaceProjectCandidates $Config)
    $index = Write-SgProjectIndex $Config $projects
    $script:ProjectCatalogMemory[$key] = $index
    return $projects
}

function Get-SgProjectCatalog([object]$Config, [switch]$ForceRefresh) {
    $registry = Reconcile-SgRegistry $Config
    $registeredByIdentity = @{}
    $items = New-Object 'System.Collections.Generic.List[object]'
    foreach ($entry in @($registry.projects)) {
        $identity = Get-SgRunnableIdentity $entry
        if (-not $identity -or $registeredByIdentity.ContainsKey($identity)) { continue }
        $registeredByIdentity[$identity] = $entry
        $entry | Add-Member -NotePropertyName Id -NotePropertyValue $identity -Force
        $entry | Add-Member -NotePropertyName IsRegistered -NotePropertyValue $true -Force
        $entry | Add-Member -NotePropertyName Name -NotePropertyValue (Get-SgDisplayName $entry $Config.Workspace) -Force
        [void]$items.Add($entry)
    }
    foreach ($candidate in @(Get-SgWorkspaceProjectCandidates $Config -ForceRefresh:$ForceRefresh)) {
        $identity = Get-SgRunnableIdentity $candidate
        if (-not $identity) { continue }
        if ($registeredByIdentity.ContainsKey($identity)) {
            Add-SgDiscoveredMetadata $registeredByIdentity[$identity] $candidate | Out-Null
            $registeredByIdentity[$identity] | Add-Member -NotePropertyName Name -NotePropertyValue (Get-SgDisplayName $candidate $Config.Workspace) -Force
            continue
        }
        $candidate | Add-Member -NotePropertyName Id -NotePropertyValue $identity -Force
        $candidate | Add-Member -NotePropertyName IsRegistered -NotePropertyValue $false -Force
        $candidate | Add-Member -NotePropertyName Name -NotePropertyValue (Get-SgDisplayName $candidate $Config.Workspace) -Force
        [void]$items.Add($candidate)
    }
    return @($items.ToArray() | Sort-Object -Property Name,Id)
}

function New-SgProjectChoiceMap([object[]]$Items) {
    $map = @{}
    foreach ($item in @($Items)) {
        $label = [string]$item.Name
        $identity = Get-SgRunnableIdentity $item
        if (-not $label -or -not $identity) { throw 'Every project choice requires a display name and runnable identity.' }
        if ($map.ContainsKey($label)) { throw "Duplicate project choice label: $label" }
        $map[$label] = $identity
    }
    return $map
}

function Test-SgProjectCatalogEntry([object]$Entry) {
    if (-not $Entry) { return $false }
    $path = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { return $false }
    try { return (Get-SgProjectKind $path) -eq [string]$Entry.kind } catch { return $false }
}

function Resolve-SgProjectCatalogEntry([object]$Config, [string]$Identity, [switch]$RequireRegistered) {
    if ([string]::IsNullOrWhiteSpace($Identity)) { throw 'Project identity is required.' }
    $entry = @(Get-SgProjectCatalog $Config | Where-Object { $_.Id -eq $Identity }) | Select-Object -First 1
    if ($entry -and (Test-SgProjectCatalogEntry $entry)) {
        if ($RequireRegistered -and -not $entry.IsRegistered) { throw "Project is not registered: $($entry.path)" }
        return $entry
    }
    Clear-SgProjectCatalogCache $Config
    $entry = @(Get-SgProjectCatalog $Config -ForceRefresh | Where-Object { $_.Id -eq $Identity }) | Select-Object -First 1
    if (-not $entry -or -not (Test-SgProjectCatalogEntry $entry)) { throw "Project surface is no longer available: $Identity" }
    if ($RequireRegistered -and -not $entry.IsRegistered) { throw "Project is not registered: $($entry.path)" }
    return $entry
}

function Sync-SgDiscoveredProjectMetadata([object]$Config, [object]$Candidate) {
    $identity = Get-SgRunnableIdentity $Candidate
    if (-not $identity -or -not ($Candidate.PSObject.Properties['rootPath'] -and $Candidate.rootPath)) { return $null }
    $rootPath = [IO.Path]::GetFullPath([string]$Candidate.rootPath).TrimEnd('\','/')
    $launchPath = [IO.Path]::GetFullPath([string]$Candidate.launchPath).TrimEnd('\','/')
    $name = Get-SgCanonicalSurfaceName $rootPath $launchPath
    $result = Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $identity } | Select-Object -First 1
        if ($entry) {
            $entry | Add-Member -NotePropertyName rootPath -NotePropertyValue $rootPath -Force
            $entry | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
            $entry | Add-Member -NotePropertyName name -NotePropertyValue $name -Force
        }
    }
    return $result.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $identity } | Select-Object -First 1
}

function Get-SgCommandSignature([string]$ProjectPath, [string]$Kind, [int]$Port) {
    return "ShipGlows:${Kind}:${Port}:$([IO.Path]::GetFullPath($ProjectPath))"
}

function Invoke-SgDependencySetup([string]$ProjectPath, [string]$Kind, [string]$LogPath) {
    if ($Kind -in @('astro','vite')) {
        $pm = if (Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml')) { Get-SgCommandPath @('pnpm.cmd','pnpm.exe') } elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'package-lock.json')) { Get-SgCommandPath @('npm.cmd','npm.exe') } else { Get-SgCommandPath @('npm.cmd','npm.exe') }
        if (-not $pm) { throw 'Node package manager not found. Install Node.js and pnpm/npm, then retry.' }
        $args = if ($pm -match 'pnpm') { if (Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml')) { @('install','--frozen-lockfile') } else { @('install') } } elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'package-lock.json')) { @('ci') } else { @('install') }
    } elseif ($Kind -eq 'python') {
        $uv = Get-SgCommandPath @('uv.exe','uv.cmd','uv')
        if (-not $uv) { throw 'uv is required for Python projects. Install uv, then retry.' }
        $pm = $uv
        $venv = Join-Path $ProjectPath '.venv'
        if (Test-Path -LiteralPath (Join-Path $ProjectPath 'uv.lock')) { $args = @('sync','--locked') }
        elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'requirements.txt')) {
            $python = Join-Path $venv 'Scripts\python.exe'
            # uv can write informational output to stderr even on success. Do
            # not let a caller's ErrorActionPreference turn that into a false
            # failure; the native exit code remains the source of truth.
            if (-not (Test-Path -LiteralPath $python -PathType Leaf)) {
                $args = @('venv',$venv)
                $previousErrorActionPreference = $ErrorActionPreference
                try {
                    $ErrorActionPreference = 'Continue'
                    & $uv @args 2>&1 | Tee-Object -FilePath $LogPath -Append
                    if ($LASTEXITCODE -ne 0) { throw 'uv venv failed.' }
                } finally { $ErrorActionPreference = $previousErrorActionPreference }
            }
            $args = @('pip','install','--python',$python,'-r',(Join-Path $ProjectPath 'requirements.txt'))
        }
        else { throw 'Python project requires uv.lock or requirements.txt in V1.' }
    } else {
        $flutter = Get-SgCommandPath @('flutter.cmd','flutter.bat','flutter.exe')
        if (-not $flutter) { throw 'Flutter SDK is not available on PATH.' }
        $pm = $flutter
        $args = @('pub','get')
    }
    Push-Location $ProjectPath
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        # Package managers may report normal progress on stderr; use their
        # exit code so this is stable with $ErrorActionPreference = 'Stop'.
        $ErrorActionPreference = 'Continue'
        & $pm @args 2>&1 | Tee-Object -FilePath $LogPath -Append
        if ($LASTEXITCODE -ne 0) { throw "Dependency setup failed for $Kind." }
    }
    finally { $ErrorActionPreference = $previousErrorActionPreference; Pop-Location }
}

function Rotate-SgLogFile([string]$Path, [long]$MaxBytes = 5242880) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    $file = Get-Item -LiteralPath $Path -ErrorAction Stop
    if ($file.Length -le $MaxBytes) { return }
    $rotated = "$Path.previous"
    Move-Item -LiteralPath $Path -Destination $rotated -Force
}

function Get-SgLaunchSpec([string]$ProjectPath, [string]$Kind, [int]$Port) {
    $signature = Get-SgCommandSignature $ProjectPath $Kind $Port
    if ($Kind -eq 'astro') {
        $pnpm = Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml')
        if ($pnpm) {
            $packageManager = Get-SgCommandPath @('pnpm.cmd','pnpm.exe')
            if (-not $packageManager) { throw 'pnpm is required by pnpm-lock.yaml but is unavailable.' }
            $file = $env:ComSpec
            $command = "call `"$packageManager`" exec astro dev --host 127.0.0.1 --port $Port & rem $signature"
            $args = @('/d','/s','/c',"`"$command`"")
        } else {
            $packageManager = Get-SgCommandPath @('npm.cmd','npm.exe')
            if (-not $packageManager) { throw 'npm is required but is unavailable.' }
            $file = $env:ComSpec
            $command = "call `"$packageManager`" run dev -- --host 127.0.0.1 --port $Port & rem $signature"
            $args = @('/d','/s','/c',"`"$command`"")
        }
    } elseif ($Kind -eq 'vite') {
        $pnpm = Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml')
        $packageManager = if ($pnpm) { Get-SgCommandPath @('pnpm.cmd','pnpm.exe') } else { Get-SgCommandPath @('npm.cmd','npm.exe') }
        if (-not $packageManager) { throw 'A Node package manager is required but unavailable.' }
        $file = $env:ComSpec
        if ($pnpm) {
            $command = "call `"$packageManager`" exec vite --host 127.0.0.1 --port $Port & rem $signature"
        } else {
            $command = "call `"$packageManager`" run dev -- --host 127.0.0.1 --port $Port & rem $signature"
        }
        $args = @('/d','/s','/c',"`"$command`"")
    } elseif ($Kind -eq 'python') {
        $target = if (Test-Path -LiteralPath (Join-Path $ProjectPath 'app\main.py')) { 'app.main:app' } elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'main.py')) { 'main:app' } else { throw 'FastAPI entrypoint not found. V1 supports app/main.py or main.py with app.' }
        $file = $env:ComSpec
        if (Test-Path -LiteralPath (Join-Path $ProjectPath 'uv.lock') -PathType Leaf) {
            $uv = Get-SgCommandPath @('uv.exe','uv.cmd','uv'); if (-not $uv) { throw 'uv is required for Python launch.' }
            $command = "call `"$uv`" run --locked uvicorn $target --host 127.0.0.1 --port $Port & rem $signature"
        } else {
            $python = Join-Path $ProjectPath '.venv\Scripts\python.exe'
            if (-not (Test-Path -LiteralPath $python -PathType Leaf)) { throw 'Python virtual environment not found. Dependency setup must create .venv before launch.' }
            $command = "call `"$python`" -m uvicorn $target --host 127.0.0.1 --port $Port & rem $signature"
        }
        $args = @('/d','/s','/c',"`"$command`"")
    } else {
        $flutter = Get-SgCommandPath @('flutter.cmd','flutter.bat','flutter.exe'); if (-not $flutter) { throw 'Flutter SDK is not available on PATH.' }
        $file = $env:ComSpec
        $command = "call `"$flutter`" run -d web-server --web-hostname 127.0.0.1 --web-port $Port & rem $signature"
        $args = @('/d','/s','/c',"`"$command`"")
    }
    if (-not $file) { throw "Launch tool missing for $Kind." }
    [pscustomobject]@{ FilePath = $file; Arguments = $args; Signature = $signature; Interactive = $false }
}

function Test-SgHttpReady([int]$Port) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$Port" -TimeoutSec 2 -ErrorAction Stop | Out-Null
        return $true
    } catch {
        $tcp = New-Object Net.Sockets.TcpClient
        try {
            $tcp.Connect('127.0.0.1', $Port)
            return $tcp.Connected
        } catch {
            return $false
        } finally {
            $tcp.Dispose()
        }
    }
}

function Wait-SgHttpReady([int]$Port, [int]$TimeoutSeconds = 60) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-SgHttpReady $Port) { return $true }
        Start-Sleep -Milliseconds 500
    }
    return $false
}

function Reconcile-SgRegistry([object]$Config) {
    return Invoke-SgRegistryMutation $Config {
        param($registry)
        $byIdentity = @{}
        $normalized = New-Object 'System.Collections.Generic.List[object]'
        foreach ($entry in @($registry.projects)) {
            $identity = Get-SgRunnableIdentity $entry
            if (-not $identity) { continue }

            $launchPath = [IO.Path]::GetFullPath($(if ($entry.PSObject.Properties['launchPath'] -and $entry.launchPath) { [string]$entry.launchPath } else { [string]$entry.path })).TrimEnd('\','/')
            $oldPath = [IO.Path]::GetFullPath([string]$entry.path).TrimEnd('\','/')
            $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) {
                [IO.Path]::GetFullPath([string]$entry.rootPath).TrimEnd('\','/')
            } elseif (-not $oldPath.Equals($launchPath, [StringComparison]::OrdinalIgnoreCase)) {
                $oldPath
            } else {
                $oldPath
            }
            $entry | Add-Member -NotePropertyName rootPath -NotePropertyValue $rootPath -Force
            $entry | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
            $entry.path = $launchPath

            $live = Test-SgProcessIdentity $entry
            $freshReservation = $false
            if (-not $live -and $entry.status -in @('reserved','starting') -and $entry.PSObject.Properties['reservationTimeUtc'] -and $entry.reservationTimeUtc) {
                try {
                    $freshReservation = (((Get-Date).ToUniversalTime() - [datetime]::Parse([string]$entry.reservationTimeUtc).ToUniversalTime()).TotalMinutes -lt 5)
                } catch {
                    $freshReservation = $false
                }
            }
            if ($live) {
                $entry.status = 'running'
                if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
                if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
            } elseif (-not $freshReservation) {
                $entry.status = 'stopped'
                if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
                if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
            }

            if (-not $byIdentity.ContainsKey($identity)) {
                $byIdentity[$identity] = [pscustomobject]@{ Entry = $entry; Live = $live }
                [void]$normalized.Add($entry)
                continue
            }

            $kept = $byIdentity[$identity]
            $mergeSource = $entry
            if ($live -and -not $kept.Live) {
                $mergeSource = $kept.Entry
                [void]$normalized.Remove($kept.Entry)
                [void]$normalized.Add($entry)
                $byIdentity[$identity] = [pscustomobject]@{ Entry = $entry; Live = $true }
                $kept = $byIdentity[$identity]
            }
            $winner = $kept.Entry
            foreach ($property in @('name','kind','port','pid','startTimeUtc','executablePath','commandSignature','logPath','errorLogPath','lastError','reservationToken','reservationTimeUtc')) {
                $winnerValue = if ($winner.PSObject.Properties[$property]) { $winner.$property } else { $null }
                $candidateValue = if ($mergeSource.PSObject.Properties[$property]) { $mergeSource.$property } else { $null }
                $winnerMissing = $null -eq $winnerValue -or $winnerValue -eq '' -or (($property -in @('port','pid')) -and [int]$winnerValue -eq 0)
                if ($winnerMissing -and $null -ne $candidateValue -and $candidateValue -ne '') {
                    $winner | Add-Member -NotePropertyName $property -NotePropertyValue $candidateValue -Force
                }
            }
        }
        $registry.projects = $normalized.ToArray()
    }
}

function Get-SgProjectEnvironmentPath([string]$ProjectPath) {
    return Join-Path (ConvertTo-SgCanonicalPath $ProjectPath) 'ENVIRONMENT.md'
}

function Remove-SgLegacyProjectServerState([string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $legacyPath = Join-Path (Join-Path $root '.shipglows') 'server.env'
    $legacyFileIsUserOwned = $false
    if (Test-Path -LiteralPath $legacyPath -PathType Leaf) {
        $legacyContent = [IO.File]::ReadAllText($legacyPath)
        if ($legacyContent -match '(?m)^# ShipGlows CLI managed\. Do not edit\.\r?$' -and
            $legacyContent -match '(?m)^SHIPGLOWS_SERVER_MANAGER=shipglows-devserver\r?$') {
            Remove-Item -LiteralPath $legacyPath -Force
            $legacyDirectory = Split-Path -Parent $legacyPath
            if ((Test-Path -LiteralPath $legacyDirectory -PathType Container) -and
                @(Get-ChildItem -LiteralPath $legacyDirectory -Force).Count -eq 0) {
                Remove-Item -LiteralPath $legacyDirectory -Force
            }
        } else {
            $legacyFileIsUserOwned = $true
        }
    }

    if ($legacyFileIsUserOwned) { return }

    $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $git) { return }
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $gitPath = (& $git.Source -C $root rev-parse --git-path info/exclude 2>$null | Select-Object -First 1)
        $repositoryRoot = (& $git.Source -C $root rev-parse --show-toplevel 2>$null | Select-Object -First 1)
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ([string]::IsNullOrWhiteSpace($gitPath) -or [string]::IsNullOrWhiteSpace($repositoryRoot)) { return }
    $excludePath = [string]$gitPath
    if (-not [IO.Path]::IsPathRooted($excludePath)) { $excludePath = Join-Path $root $excludePath }
    if (-not (Test-Path -LiteralPath $excludePath -PathType Leaf)) { return }
    $canonicalRoot = [IO.Path]::GetFullPath($root).TrimEnd('\','/')
    $canonicalRepository = [IO.Path]::GetFullPath([string]$repositoryRoot).TrimEnd('\','/')
    $prefix = if ($canonicalRoot.Length -gt $canonicalRepository.Length) { $canonicalRoot.Substring($canonicalRepository.Length).Trim('\','/').Replace('\','/') + '/' } else { '' }
    $legacyEntry = '/' + $prefix + '.shipglows/server.env'
    $lines = @(Get-Content -LiteralPath $excludePath)
    $next = New-Object System.Collections.Generic.List[string]
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -eq $legacyEntry) {
            if ($next.Count -gt 0 -and $next[$next.Count - 1] -eq '# ShipGlows local runtime') { $next.RemoveAt($next.Count - 1) }
            continue
        }
        $next.Add([string]$lines[$index])
    }
    if (($next -join "`n") -cne ($lines -join "`n")) {
        [IO.File]::WriteAllLines($excludePath, @($next), [Text.UTF8Encoding]::new($false))
    }
}

function Write-SgProjectEnvironment([string]$ProjectPath, [int]$Port = 0) {
    if ($Port -ne 0 -and ($Port -lt 1024 -or $Port -gt 65535)) { throw 'ShipGlows project port must be 0 or between 1024 and 65535.' }
    $path = Get-SgProjectEnvironmentPath $ProjectPath
    $existing = if (Test-Path -LiteralPath $path -PathType Leaf) { [IO.File]::ReadAllText($path) } else { '' }
    $pattern = '(?ms)^<!-- >>> ShipGlows development environment >>> -->\r?\n.*?^<!-- <<< ShipGlows development environment <<< -->\r?\n?'
    $portValue = if ($Port -gt 0) { [string]$Port } else { 'pending first ShipGlows start' }
    $urlValue = if ($Port -gt 0) { "http://127.0.0.1:$Port" } else { 'pending first ShipGlows start' }
    $block = @'
<!-- >>> ShipGlows development environment >>> -->
## ShipGlows development environment

- Server manager: `shipglows-devserver`
- Assigned port: `{0}`
- Canonical local URL: `{1}`
- Live status authority: Windows ShipGlows DevServer registry

Use this assigned URL for local preview, browser, screenshot, and test work. Do not substitute framework defaults such as Astro/Vite `4321` or a port from another project. Read the ShipGlows registry for `running` or `stopped`; this durable document is not rewritten on start or stop.
<!-- <<< ShipGlows development environment <<< -->
'@ -f $portValue,$urlValue
    $remainder = [regex]::Replace($existing, $pattern, '').Trim([char[]]"`r`n")
    $next = if ($remainder) { "$remainder`n`n$($block.Trim())`n" } else { "$($block.Trim())`n" }
    if ($next.Replace("`r`n","`n") -cne $existing.Replace("`r`n","`n")) {
        [IO.File]::WriteAllText($path, $next, [Text.UTF8Encoding]::new($false))
    }
    Remove-SgLegacyProjectServerState $ProjectPath
    return $path
}

function Get-SgProjectEnvironment([string]$ProjectPath) {
    $path = Get-SgProjectEnvironmentPath $ProjectPath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    $content = [IO.File]::ReadAllText($path)
    if ($content -notmatch '(?m)^- Server manager: `shipglows-devserver`\r?$') { return $null }
    $port = 0
    if ($content -match '(?m)^- Assigned port: `(\d+)`\r?$') { $port = [int]$Matches[1] }
    if ($port -ne 0 -and ($port -lt 1024 -or $port -gt 65535)) { throw "Invalid assigned port in $path." }
    $url = if ($port -gt 0) { "http://127.0.0.1:$port" } else { '' }
    [pscustomobject]@{ Path=$path; Port=$port; Url=$url; Manager='shipglows-devserver' }
}

function Register-SgProject([object]$Config, [string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    if (-not (Test-SgProjectPath $root $Config.Workspace)) { throw "Project must be inside the ShipGlows workspace: $($Config.Workspace)" }
    [void](Reconcile-SgRegistry $Config)
    $descriptors = @(Get-SgProjectDescriptors $root)
    $registry = Invoke-SgRegistryMutation $Config {
        param($data)
        foreach ($descriptor in $descriptors) {
            $launchPath = [IO.Path]::GetFullPath([string]$descriptor.LaunchPath).TrimEnd('\','/')
            $existing = @($data.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $launchPath.ToLowerInvariant() })
            $name = Get-SgCanonicalSurfaceName $root $launchPath
            if ($existing.Count -eq 0) {
                $data.projects += [pscustomobject]@{
                    name = $name; path = $launchPath; rootPath = $root; launchPath = $launchPath; kind = $descriptor.Kind
                    port = 0; status = 'stopped'; pid = 0; startTimeUtc = $null; executablePath = $null
                    commandSignature = $null; logPath = $null; errorLogPath = $null; lastError = $null
                    reservationToken = $null; reservationTimeUtc = $null
                }
            } else {
                $existing[0] | Add-Member -NotePropertyName rootPath -NotePropertyValue $root -Force
                $existing[0] | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
                $existing[0] | Add-Member -NotePropertyName name -NotePropertyValue $name -Force
                $existing[0].path = $launchPath
                $existing[0].kind = $descriptor.Kind
            }
        }
    }
    Clear-SgProjectCatalogCache $Config
    $launchPaths = @($descriptors | ForEach-Object { [IO.Path]::GetFullPath([string]$_.LaunchPath).TrimEnd('\','/') })
    $registered = @($registry.projects | Where-Object { $_.path -in $launchPaths })
    foreach ($entry in $registered) { [void](Write-SgProjectEnvironment $entry.path ([int]$entry.port)) }
    return $registered
}

function Start-SgProject([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0) {
    $requestedPath = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Reconcile-SgRegistry $Config).projects | Where-Object { $_.path -eq $requestedPath }) | Select-Object -First 1
    if (-not $entry) {
        $registered = @(Register-SgProject $Config $requestedPath)
        $entry = $registered | Where-Object { $_.path -eq $requestedPath } | Select-Object -First 1
        if (-not $entry -and $registered.Count -gt 1) {
            throw "This monorepo has $($registered.Count) runnable surfaces. Choose a surface from the menu instead of starting its root path."
        }
        if (-not $entry) { $entry = $registered | Select-Object -First 1 }
    }
    if (-not $entry) { throw "No runnable surface could be registered for: $requestedPath" }
    if (-not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $($entry.path)" }
    if (Test-SgProcessIdentity $entry) { Write-SgInfo "Already running: $($entry.name) on $($entry.port)"; return $entry }
    $settings = Get-SgRuntimeSettings $entry.path
    $configuredPort = $RequestedPort
    if ($configuredPort -le 0 -and $env:SHIPGLOWS_ENV_PORT) {
        if ($env:SHIPGLOWS_ENV_PORT -notmatch '^\d+$' -or [int]$env:SHIPGLOWS_ENV_PORT -lt 1024 -or [int]$env:SHIPGLOWS_ENV_PORT -gt 65535) { throw 'SHIPGLOWS_ENV_PORT must be a port between 1024 and 65535.' }
        $configuredPort = [int]$env:SHIPGLOWS_ENV_PORT
    }
    if ($configuredPort -le 0 -and $settings.Port -gt 0) { $configuredPort = [int]$settings.Port }
    $explicitPort = $configuredPort -gt 0
    $previousPort = [int]$entry.port
    $reservation = Reserve-SgProjectPort $Config $entry.path $configuredPort $explicitPort
    $port = $reservation.Port
    $reservationToken = $reservation.Token
    if ($explicitPort) { Write-SgInfo "Using configured port: $port" }
    elseif ($previousPort -gt 0 -and $previousPort -eq $port) { Write-SgInfo "Reusing persistent port: $port" }
    else { Write-SgInfo "Assigned port: $port" }
    $logDir = Join-Path $Config.LogDirectory $entry.name
    Ensure-SgDirectory $logDir
    $out = Join-Path $logDir 'stdout.log'; $err = Join-Path $logDir 'stderr.log'
    $setupLog = Join-Path $logDir 'setup.log'
    foreach ($logPath in @($out,$err,$setupLog)) { Rotate-SgLogFile $logPath }
    $launchPath = if ($entry.PSObject.Properties['launchPath'] -and $entry.launchPath) { [string]$entry.launchPath } else { [string]$entry.path }
    $kind = [string]$entry.kind
    try {
        Invoke-SgDependencySetup $launchPath $kind $setupLog
        $launch = Get-SgLaunchSpec $launchPath $kind $port
    } catch {
        Release-SgProjectPort $Config $entry.path $reservationToken $_.Exception.Message
        throw
    }
    $launchEnvironment = @{}
    $launchEnvironment['PORT'] = [string]$port
    if ($kind -eq 'astro') { $launchEnvironment['ASTRO_DEV_BACKGROUND'] = '0' }
    $previousEnvironment = @{}
    try {
        Set-SgReservationState $Config $entry.path $reservationToken 'starting'
        foreach ($name in @($launchEnvironment.Keys)) {
            $previousEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
            [Environment]::SetEnvironmentVariable($name, [string]$launchEnvironment[$name], 'Process')
        }
        $process = Start-Process -FilePath $launch.FilePath -ArgumentList $launch.Arguments -WorkingDirectory $launchPath -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Hidden
        Start-Sleep -Milliseconds 350
        $snapshot = Get-SgProcessSnapshot $process.Id
        if (-not $snapshot) { throw "Process exited before it could be recorded. See $err" }
    } catch {
        Release-SgProjectPort $Config $entry.path $reservationToken $_.Exception.Message
        throw
    } finally {
        foreach ($name in @($launchEnvironment.Keys)) { [Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name], 'Process') }
    }
    $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } else { [string]$entry.path }
    $entryData = [pscustomobject]@{ name = $entry.name; path = $entry.path; rootPath = $rootPath; launchPath = $launchPath; kind = $kind; port = $port; status = 'starting'; pid = $snapshot.Pid; startTimeUtc = $snapshot.StartTimeUtc; executablePath = $snapshot.ExecutablePath; commandSignature = $launch.Signature; logPath = $out; errorLogPath = $err; lastError = $null }
    Set-SgReservationState $Config $entry.path $reservationToken 'starting' $entryData
    if (-not (Test-SgProcessIdentity $entryData)) {
        Write-SgWarn "Process exited during startup. See $err"
        $entryData.status = 'error'
        $entryData.lastError = 'Process exited during startup.'
        Release-SgProjectPort $Config $entry.path $reservationToken $entryData.lastError
        return $entryData
    }
    [void](Write-SgProjectEnvironment $entry.path $port)
    $entryData.status = if (Wait-SgHttpReady $port) { 'running' } else { 'starting' }
    Set-SgReservationState $Config $entry.path $reservationToken $entryData.status $entryData
    Write-SgInfo "$($entry.name) $($entryData.status): http://127.0.0.1:$port"
    return $entryData
}

function Stop-SgProcessTree([int]$RootPid) {
    $all = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $ids = New-Object System.Collections.Generic.List[int]
    function Add-Descendants([int]$Parent) { foreach ($child in $all | Where-Object { $_.ParentProcessId -eq $Parent }) { if (-not $ids.Contains([int]$child.ProcessId)) { $ids.Add([int]$child.ProcessId); Add-Descendants ([int]$child.ProcessId) } } }
    $ids.Add($RootPid); Add-Descendants $RootPid
    foreach ($pid in @($ids | Sort-Object -Descending)) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
}

function Get-SgOwnedFlutterListenerPids([object]$Entry) {
    if (-not $Entry -or $Entry.kind -ne 'flutter-web' -or [int]$Entry.port -le 0) { return @() }
    $listeners = @(Get-NetTCPConnection -LocalPort ([int]$Entry.port) -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return @() }

    $projectPath = [IO.Path]::GetFullPath($(if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path })).TrimEnd('\','/').ToLowerInvariant()
    $projectPattern = [regex]::Escape($projectPath) + '(?:[\\/"''\s]|$)'
    $signature = if ($Entry.PSObject.Properties['commandSignature']) { ([string]$Entry.commandSignature).ToLowerInvariant() } else { '' }
    $processes = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $byId = @{}
    foreach ($process in $processes) { $byId[[int]$process.ProcessId] = $process }

    $owned = @()
    foreach ($listener in $listeners) {
        $listenerPid = [int]$listener.OwningProcess
        $currentPid = $listenerPid
        $depth = 0
        $flutterEvidence = $false
        $projectEvidence = $false
        while ($currentPid -gt 0 -and $depth -lt 8 -and $byId.ContainsKey($currentPid)) {
            $process = $byId[$currentPid]
            $commandLine = ([string]$process.CommandLine).ToLowerInvariant()
            $executable = ([string]$process.ExecutablePath).ToLowerInvariant()
            if ($commandLine -match 'flutter|dart(vm)?|web-server' -or $executable -match 'dart(vm)?\.exe$|flutter') { $flutterEvidence = $true }
            if (($signature -and $commandLine.Contains($signature)) -or $commandLine -match $projectPattern) { $projectEvidence = $true }
            $currentPid = [int]$process.ParentProcessId
            $depth++
        }
        if ($flutterEvidence -and $projectEvidence) { $owned += $listenerPid }
    }
    return @($owned | Sort-Object -Unique)
}

function Stop-SgOwnedFlutterListener([object]$Entry) {
    $ownedPids = @(Get-SgOwnedFlutterListenerPids $Entry)
    foreach ($ownedPid in $ownedPids) { Stop-SgProcessTree $ownedPid }
    return $ownedPids.Count -gt 0
}

function Stop-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { return $false }
    $alreadyStopped = $entry.status -eq 'stopped' -and [int]$entry.pid -le 0
    $stoppedFlutterListener = Stop-SgOwnedFlutterListener $entry
    if ($alreadyStopped -and -not $stoppedFlutterListener) { return $false }
    if ((Test-Path -LiteralPath $path -PathType Container) -and -not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $path" }
    $stopped = $stoppedFlutterListener
    if (Test-SgProcessIdentity $entry) {
        Stop-SgProcessTree ([int]$entry.pid)
        $stopped = $true
    } elseif (-not $stoppedFlutterListener -and [int]$entry.pid -gt 0) {
        Write-SgWarn "Stale or unverified process for $($entry.name); no process was terminated."
    }
    Invoke-SgRegistryMutation $Config {
        param($data)
        $found = @($data.projects | Where-Object { $_.path -eq $path })[0]
        if ($found) {
            $found.status = 'stopped'; $found.pid = 0; $found.startTimeUtc = $null; $found.lastError = $null
            if ($found.PSObject.Properties['reservationToken']) { $found.reservationToken = $null }
            if ($found.PSObject.Properties['reservationTimeUtc']) { $found.reservationTimeUtc = $null }
        }
    } | Out-Null
    return $stopped
}

function Unregister-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { throw "Project is not registered: $path" }
    if (-not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $path" }
    if (Test-SgProcessIdentity $entry) { throw "Project is still running: $($entry.name). Stop it before unregistering." }
    Invoke-SgRegistryMutation $Config {
        param($data)
        $data.projects = @($data.projects | Where-Object { $_.path -ne $path })
    } | Out-Null
    Clear-SgProjectCatalogCache $Config
    Write-SgInfo "Unregistered project without deleting its files: $path"
}

function Show-SgDashboard([object]$Config) {
    $registry = Reconcile-SgRegistry $Config
    Write-Host ''; Write-Host 'ShipGlows DevServer Windows' -ForegroundColor Yellow; Write-Host '============================' -ForegroundColor Yellow
    $items = @($registry.projects)
    if ($items.Count -eq 0) { Write-Host 'No registered projects.'; return }
    $index = 1
    foreach ($entry in $items) { Write-Host ("[{0}] {1}  {2}  {3}  {4}" -f $index,$entry.status,$entry.kind,$entry.port,$entry.path); $index++ }
}

Export-ModuleMember -Function Write-SgInfo,Write-SgWarn,Write-SgError,Ensure-SgDirectory,ConvertTo-SgCanonicalPath,Get-SgDevConfig,Get-SgProjectKind,Get-SgProjectDescriptor,Get-SgProjectDescriptors,Get-SgRuntimeSettings,Read-SgRegistry,Reconcile-SgRegistry,Register-SgProject,Start-SgProject,Stop-SgProject,Unregister-SgProject,Show-SgDashboard,Test-SgGitUrl,Test-SgProjectPath,ConvertTo-SgGitHubRepositoryIdentity,Get-SgInstalledGitHubRepositoryIdentities,Select-SgGitHubCloneCandidates,Get-SgFreePort,Test-SgPortAvailable,Reserve-SgProjectPort,Set-SgReservationState,Release-SgProjectPort,Get-SgRunnableIdentity,Get-SgCanonicalSurfaceName,Get-SgDisplayName,Add-SgDiscoveredMetadata,Sync-SgDiscoveredProjectMetadata,Get-SgOwnedFlutterListenerPids,Stop-SgOwnedFlutterListener,Rotate-SgLogFile,Get-SgProjectEnvironmentPath,Write-SgProjectEnvironment,Get-SgProjectEnvironment,Remove-SgLegacyProjectServerState,Get-SgWorkspaceProjectCandidates,Get-SgProjectCatalog,Clear-SgProjectCatalogCache,Resolve-SgProjectCatalogEntry,New-SgProjectChoiceMap
