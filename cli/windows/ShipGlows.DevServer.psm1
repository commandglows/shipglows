Set-StrictMode -Version Latest

$script:RegistryVersion = 1
$script:DefaultPortStart = 3000
$script:DefaultPortEnd = 3100

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
        $lock = [IO.File]::Open($Config.LockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
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
    if (Test-Path -LiteralPath $package -PathType Leaf) {
        try {
            $json = Get-Content -LiteralPath $package -Raw | ConvertFrom-Json -ErrorAction Stop
            $all = @()
            foreach ($property in @('dependencies','devDependencies','peerDependencies')) {
                $dependencySection = $json.PSObject.Properties[$property]
                if ($dependencySection -and $dependencySection.Value) { $all += $dependencySection.Value.PSObject.Properties.Name }
            }
            if ($all -contains 'astro') { return 'astro' }
        } catch { throw "Invalid package.json: $($_.Exception.Message)" }
    }
    if ((Test-Path -LiteralPath $pubspec -PathType Leaf) -and (Test-Path -LiteralPath (Join-Path $ProjectPath 'web') -PathType Container)) {
        if ((Get-Content -LiteralPath $pubspec -Raw) -match '(?m)^\s*flutter:\s*$') { return 'flutter-web' }
    }
    if (Test-Path -LiteralPath (Join-Path $ProjectPath 'pyproject.toml') -PathType Leaf) {
        if (Test-Path -LiteralPath (Join-Path $ProjectPath 'uv.lock') -PathType Leaf) { return 'python' }
        if (Test-Path -LiteralPath (Join-Path $ProjectPath 'requirements.txt') -PathType Leaf) { return 'python' }
    }
    if (Test-Path -LiteralPath (Join-Path $ProjectPath 'requirements.txt') -PathType Leaf) { return 'python' }
    throw "Unsupported or ambiguous project. Supported kinds: Astro, Python/FastAPI with uv/requirements, Flutter Web."
}

function Get-SgProjectDescriptor([string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $hasFloxManifest = Test-Path -LiteralPath (Join-Path $root '.flox') -PathType Container
    try {
        return [pscustomobject]@{ RootPath = $root; LaunchPath = $root; Kind = (Get-SgProjectKind $root); UsesFloxManifest = $hasFloxManifest }
    } catch {
        if (-not $hasFloxManifest) { throw }
    }

    # Flox marks the environment root, while a monorepo's runnable application
    # may live below it. Prefer the closest supported application so the same
    # root project remains the operator-facing environment on Windows.
    $candidates = @()
    $queue = New-Object System.Collections.Generic.Queue[object]
    [void]$queue.Enqueue([pscustomobject]@{ Path = $root; Depth = 0 })
    $pruneDirs = @('.flox', '.git', 'node_modules', 'venv', '.venv', '__pycache__', 'target', '.next', '.nuxt', 'dist', '.cache', '.pnpm', '.yarn')
    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue()
        if ([int]$item.Depth -gt 0) {
            try {
                $kind = Get-SgProjectKind ([string]$item.Path)
                $candidates += [pscustomobject]@{ RootPath = $root; LaunchPath = [string]$item.Path; Kind = $kind; UsesFloxManifest = $true; Depth = [int]$item.Depth }
            } catch { }
        }
        if ([int]$item.Depth -ge 3) { continue }
        foreach ($dir in @(Get-ChildItem -LiteralPath ([string]$item.Path) -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($pruneDirs -contains $dir.Name) { continue }
            if ($dir.Name -match '^\.' ) { continue }
            [void]$queue.Enqueue([pscustomobject]@{ Path = $dir.FullName; Depth = ([int]$item.Depth + 1) })
        }
    }
    $selected = @($candidates | Sort-Object -Property Depth,LaunchPath | Select-Object -First 1)[0]
    if (-not $selected) { throw "Flox environment found at $root, but no supported Windows launch target was detected below it." }
    return $selected
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

function Get-SgFloxVariables([string]$ProjectPath) {
    $variables = @{}
    $manifest = Join-Path $ProjectPath '.flox\env\manifest.toml'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) { return $variables }
    $inVars = $false
    foreach ($rawLine in @(Get-Content -LiteralPath $manifest)) {
        $line = ([string]$rawLine).Trim()
        if ($line -match '^\[([^]]+)\]$') { $inVars = $Matches[1] -eq 'vars'; continue }
        if (-not $inVars -or -not $line -or $line.StartsWith('#')) { continue }
        if ($line -notmatch '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+?)\s*$') { throw "Unsupported [vars] entry in ${manifest}: $line" }
        $name = $Matches[1]
        $value = $Matches[2]
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) { $value = $value.Substring(1, $value.Length - 2) }
        $variables[$name] = [string]$value
    }
    return $variables
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

function Get-SgCommandSignature([string]$ProjectPath, [string]$Kind, [int]$Port) {
    return "ShipGlows:${Kind}:${Port}:$([IO.Path]::GetFullPath($ProjectPath))"
}

function Invoke-SgDependencySetup([string]$ProjectPath, [string]$Kind, [string]$LogPath) {
    if ($Kind -eq 'astro') {
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
    [pscustomobject]@{ FilePath = $file; Arguments = $args; Signature = $signature; Interactive = ($Kind -eq 'flutter-web') }
}

function Test-SgHttpReady([int]$Port) {
    try { Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$Port" -TimeoutSec 2 -ErrorAction Stop | Out-Null; return $true } catch { return $false }
}

function Reconcile-SgRegistry([object]$Config) {
    $registry = Read-SgRegistry $Config
    $changed = $false
    foreach ($entry in @($registry.projects)) {
        $live = Test-SgProcessIdentity $entry
        $next = if ($live) { 'running' } else { 'stopped' }
        if ($entry.status -ne $next) { $entry.status = $next; $changed = $true }
    }
    if ($changed) { Write-SgRegistry $Config $registry }
    return $registry
}

function Register-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    if (-not (Test-SgProjectPath $path $Config.Workspace)) { throw "Project must be inside the ShipGlows workspace: $($Config.Workspace)" }
    $descriptor = Get-SgProjectDescriptor $path
    $kind = $descriptor.Kind
    $launchPath = $descriptor.LaunchPath
    $registry = Invoke-SgRegistryMutation $Config {
        param($data)
        $existing = @($data.projects | Where-Object { $_.path -eq $path })
        if ($existing.Count -eq 0) {
            $data.projects += [pscustomobject]@{ name = (Split-Path $path -Leaf); path = $path; launchPath = $launchPath; kind = $kind; port = 0; status = 'stopped'; pid = 0; startTimeUtc = $null; executablePath = $null; commandSignature = $null; logPath = $null; errorLogPath = $null; lastError = $null }
        } else {
            $existing[0] | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
            $existing[0].kind = $kind
        }
    }
    return @($registry.projects | Where-Object { $_.path -eq $path })[0]
}

function Start-SgProject([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0) {
    $entry = Register-SgProject $Config $ProjectPath
    if (Test-SgProcessIdentity $entry) { Write-SgInfo "Already running: $($entry.name) on $($entry.port)"; return $entry }
    $settings = Get-SgRuntimeSettings $entry.path
    $configuredPort = $RequestedPort
    if ($configuredPort -le 0 -and $env:SHIPGLOWS_ENV_PORT) {
        if ($env:SHIPGLOWS_ENV_PORT -notmatch '^\d+$' -or [int]$env:SHIPGLOWS_ENV_PORT -lt 1024 -or [int]$env:SHIPGLOWS_ENV_PORT -gt 65535) { throw 'SHIPGLOWS_ENV_PORT must be a port between 1024 and 65535.' }
        $configuredPort = [int]$env:SHIPGLOWS_ENV_PORT
    }
    if ($configuredPort -le 0 -and $settings.Port -gt 0) { $configuredPort = [int]$settings.Port }
    if ($configuredPort -gt 0) {
        $port = Get-SgFreePort $Config $configuredPort $entry.path
        Write-SgInfo "Using configured port: $port"
    } elseif ([int]$entry.port -gt 0) {
        try {
            $port = Get-SgFreePort $Config ([int]$entry.port) $entry.path
            Write-SgInfo "Reusing persistent port: $port"
        } catch {
            $port = Get-SgFreePort $Config 0 $entry.path
            Write-SgWarn "Persistent port $($entry.port) is unavailable; assigned $port."
        }
    } else {
        $port = Get-SgFreePort $Config 0 $entry.path
        Write-SgInfo "Assigned port: $port"
    }
    $logDir = Join-Path $Config.LogDirectory $entry.name
    Ensure-SgDirectory $logDir
    $out = Join-Path $logDir 'stdout.log'; $err = Join-Path $logDir 'stderr.log'
    $setupLog = Join-Path $logDir 'setup.log'
    foreach ($logPath in @($out,$err,$setupLog)) { Rotate-SgLogFile $logPath }
    $descriptor = Get-SgProjectDescriptor $entry.path
    $launchPath = $descriptor.LaunchPath
    $kind = $descriptor.Kind
    try { Invoke-SgDependencySetup $launchPath $kind $setupLog; $launch = Get-SgLaunchSpec $launchPath $kind $port }
    catch { $entry.status = 'error'; $entry.lastError = $_.Exception.Message; Invoke-SgRegistryMutation $Config { param($data) $found = @($data.projects | Where-Object { $_.path -eq $entry.path })[0]; if ($found) { $found.status = 'error'; $found.lastError = $entry.lastError } }; throw }
    $launchEnvironment = Get-SgFloxVariables $entry.path
    $launchEnvironment['PORT'] = [string]$port
    if ($kind -eq 'astro') { $launchEnvironment['ASTRO_DEV_BACKGROUND'] = '0' }
    $previousEnvironment = @{}
    try {
        foreach ($name in @($launchEnvironment.Keys)) {
            $previousEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
            [Environment]::SetEnvironmentVariable($name, [string]$launchEnvironment[$name], 'Process')
        }
        if ($launch.Interactive) {
            $process = Start-Process -FilePath $launch.FilePath -ArgumentList $launch.Arguments -WorkingDirectory $launchPath -PassThru -WindowStyle Normal
        } else {
            $process = Start-Process -FilePath $launch.FilePath -ArgumentList $launch.Arguments -WorkingDirectory $launchPath -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Hidden
        }
    } finally {
        foreach ($name in @($launchEnvironment.Keys)) { [Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name], 'Process') }
    }
    Start-Sleep -Milliseconds 350
    $snapshot = Get-SgProcessSnapshot $process.Id
    if (-not $snapshot) { throw "Process exited before it could be recorded. See $err" }
    $entryData = [pscustomobject]@{ name = $entry.name; path = $entry.path; launchPath = $launchPath; kind = $kind; port = $port; status = 'starting'; pid = $snapshot.Pid; startTimeUtc = $snapshot.StartTimeUtc; executablePath = $snapshot.ExecutablePath; commandSignature = $launch.Signature; logPath = $out; errorLogPath = $err; lastError = $null }
    Invoke-SgRegistryMutation $Config { param($data) $data.projects = @($data.projects | Where-Object { $_.path -ne $entry.path }); $data.projects += $entryData }
    Start-Sleep -Seconds 1
    if (-not (Test-SgProcessIdentity $entryData)) { Write-SgWarn "Process exited during startup. See $err"; $entryData.status = 'error'; $entryData.lastError = 'Process exited during startup.'; Invoke-SgRegistryMutation $Config { param($data) $found = @($data.projects | Where-Object { $_.path -eq $entry.path })[0]; if ($found) { $found.status = 'error'; $found.lastError = $entryData.lastError } }; return $entryData }
    $entryData.status = if (Test-SgHttpReady $port) { 'running' } elseif ($launch.Interactive) { 'running' } else { 'starting' }
    Invoke-SgRegistryMutation $Config { param($data) $found = @($data.projects | Where-Object { $_.path -eq $entry.path })[0]; if ($found) { $found.status = $entryData.status; $found.lastError = $entryData.lastError } }
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

function Stop-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { return }
    if (Test-SgProcessIdentity $entry) { Stop-SgProcessTree ([int]$entry.pid) }
    else { Write-SgWarn "Stale or unverified process for $($entry.name); no process was terminated." }
    Invoke-SgRegistryMutation $Config { param($data) $found = @($data.projects | Where-Object { $_.path -eq $path })[0]; if ($found) { $found.status = 'stopped'; $found.pid = 0; $found.startTimeUtc = $null; $found.lastError = $null } }
}

function Unregister-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { throw "Project is not registered: $path" }
    if (Test-SgProcessIdentity $entry) { throw "Project is still running: $($entry.name). Stop it before unregistering." }
    Invoke-SgRegistryMutation $Config {
        param($data)
        $data.projects = @($data.projects | Where-Object { $_.path -ne $path })
    } | Out-Null
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

Export-ModuleMember -Function Write-SgInfo,Write-SgWarn,Write-SgError,Ensure-SgDirectory,ConvertTo-SgCanonicalPath,Get-SgDevConfig,Get-SgProjectKind,Get-SgProjectDescriptor,Get-SgRuntimeSettings,Get-SgFloxVariables,Read-SgRegistry,Reconcile-SgRegistry,Register-SgProject,Start-SgProject,Stop-SgProject,Unregister-SgProject,Show-SgDashboard,Test-SgGitUrl,Test-SgProjectPath,Get-SgFreePort,Rotate-SgLogFile
