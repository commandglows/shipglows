Set-StrictMode -Version Latest

$script:RegistryVersion = 1
$script:DefaultPortStart = 3000
$script:DefaultPortEnd = 3100

function Write-SgInfo([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Cyan }
function Write-SgWarn([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Yellow }
function Write-SgError([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Red }

function Get-SgDevConfig {
    $workspace = if ($env:SHIPGLOWS_WINDOWS_WORKSPACE) { $env:SHIPGLOWS_WINDOWS_WORKSPACE } else { Join-Path $env:USERPROFILE 'ShipGlows\workspace' }
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
        New-Item -ItemType Directory -LiteralPath $Path -Force | Out-Null
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
            [IO.File]::Replace($temp, $Config.RegistryPath, $null)
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
                if ($json.$property) { $all += $json.$property.PSObject.Properties.Name }
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

function Get-SgFreePort([object]$Config, [int]$RequestedPort = 0) {
    $reserved = @((Read-SgRegistry $Config).projects | Where-Object { $_.port } | ForEach-Object { [int]$_.port })
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
        elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'requirements.txt')) { $args = @('venv',$venv); & $uv @args 2>&1 | Tee-Object -FilePath $LogPath -Append; if ($LASTEXITCODE -ne 0) { throw 'uv venv failed.' }; $python = Join-Path $venv 'Scripts\python.exe'; $args = @('pip','install','--python',$python,'-r',(Join-Path $ProjectPath 'requirements.txt')) }
        else { throw 'Python project requires uv.lock or requirements.txt in V1.' }
    } else {
        $flutter = Get-SgCommandPath @('flutter.cmd','flutter.bat','flutter.exe')
        if (-not $flutter) { throw 'Flutter SDK is not available on PATH.' }
        $pm = $flutter
        $args = @('pub','get')
    }
    Push-Location $ProjectPath
    try { & $pm @args 2>&1 | Tee-Object -FilePath $LogPath -Append; if ($LASTEXITCODE -ne 0) { throw "Dependency setup failed for $Kind." } }
    finally { Pop-Location }
}

function Get-SgLaunchSpec([string]$ProjectPath, [string]$Kind, [int]$Port) {
    if ($Kind -eq 'astro') {
        $pnpm = Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml')
        if ($pnpm) { $file = Get-SgCommandPath @('pnpm.cmd','pnpm.exe'); $args = @('exec','astro','dev','--host','127.0.0.1','--port',"$Port") }
        else { $file = Get-SgCommandPath @('npm.cmd','npm.exe'); $args = @('run','dev','--','--host','127.0.0.1','--port',"$Port") }
    } elseif ($Kind -eq 'python') {
        $uv = Get-SgCommandPath @('uv.exe','uv.cmd','uv'); if (-not $uv) { throw 'uv is required for Python launch.' }
        $target = if (Test-Path -LiteralPath (Join-Path $ProjectPath 'app\main.py')) { 'app.main:app' } elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'main.py')) { 'main:app' } else { throw 'FastAPI entrypoint not found. V1 supports app/main.py or main.py with app.' }
        $file = $uv; $args = @('run','--locked','uvicorn',$target,'--host','127.0.0.1','--port',"$Port")
    } else {
        $file = Get-SgCommandPath @('flutter.cmd','flutter.bat','flutter.exe'); if (-not $file) { throw 'Flutter SDK is not available on PATH.' }
        $args = @('run','-d','web-server','--web-hostname','127.0.0.1','--web-port',"$Port")
    }
    if (-not $file) { throw "Launch tool missing for $Kind." }
    [pscustomobject]@{ FilePath = $file; Arguments = $args; Signature = (Get-SgCommandSignature $ProjectPath $Kind $Port); Interactive = ($Kind -eq 'flutter-web') }
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
    $kind = Get-SgProjectKind $path
    $registry = Invoke-SgRegistryMutation $Config {
        param($data)
        $existing = @($data.projects | Where-Object { $_.path -eq $path })
        if ($existing.Count -eq 0) { $data.projects += [pscustomobject]@{ name = (Split-Path $path -Leaf); path = $path; kind = $kind; port = 0; status = 'stopped'; pid = 0; startTimeUtc = $null; executablePath = $null; commandSignature = $null; logPath = $null; errorLogPath = $null; lastError = $null } }
    }
    return @($registry.projects | Where-Object { $_.path -eq $path })[0]
}

function Start-SgProject([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0) {
    $entry = Register-SgProject $Config $ProjectPath
    if (Test-SgProcessIdentity $entry) { Write-SgInfo "Already running: $($entry.name) on $($entry.port)"; return $entry }
    $port = Get-SgFreePort $Config $RequestedPort
    $logDir = Join-Path $Config.LogDirectory $entry.name
    Ensure-SgDirectory $logDir
    $out = Join-Path $logDir 'stdout.log'; $err = Join-Path $logDir 'stderr.log'
    $setupLog = Join-Path $logDir 'setup.log'
    $kind = Get-SgProjectKind $entry.path
    try { Invoke-SgDependencySetup $entry.path $kind $setupLog; $launch = Get-SgLaunchSpec $entry.path $kind $port }
    catch { $entry.status = 'error'; $entry.lastError = $_.Exception.Message; Invoke-SgRegistryMutation $Config { param($data) $found = @($data.projects | Where-Object { $_.path -eq $entry.path })[0]; if ($found) { $found.status = 'error'; $found.lastError = $entry.lastError } }; throw }
    if ($launch.Interactive) {
        $process = Start-Process -FilePath $launch.FilePath -ArgumentList $launch.Arguments -WorkingDirectory $entry.path -PassThru -WindowStyle Normal
    } else {
        $process = Start-Process -FilePath $launch.FilePath -ArgumentList $launch.Arguments -WorkingDirectory $entry.path -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Normal
    }
    Start-Sleep -Milliseconds 350
    $snapshot = Get-SgProcessSnapshot $process.Id
    if (-not $snapshot) { throw "Process exited before it could be recorded. See $err" }
    $entryData = [pscustomobject]@{ name = $entry.name; path = $entry.path; kind = $kind; port = $port; status = 'starting'; pid = $snapshot.Pid; startTimeUtc = $snapshot.StartTimeUtc; executablePath = $snapshot.ExecutablePath; commandSignature = $launch.Signature; logPath = $out; errorLogPath = $err; lastError = $null }
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

function Show-SgDashboard([object]$Config) {
    $registry = Reconcile-SgRegistry $Config
    Write-Host ''; Write-Host 'ShipGlows DevServer Windows' -ForegroundColor Yellow; Write-Host '============================' -ForegroundColor Yellow
    $items = @($registry.projects)
    if ($items.Count -eq 0) { Write-Host 'No registered projects.'; return }
    $index = 1
    foreach ($entry in $items) { Write-Host ("[{0}] {1}  {2}  {3}  {4}" -f $index,$entry.status,$entry.kind,$entry.port,$entry.path); $index++ }
}

Export-ModuleMember -Function Ensure-SgDirectory,ConvertTo-SgCanonicalPath,Get-SgDevConfig,Get-SgProjectKind,Read-SgRegistry,Reconcile-SgRegistry,Register-SgProject,Start-SgProject,Stop-SgProject,Show-SgDashboard,Test-SgGitUrl,Test-SgProjectPath,Get-SgFreePort
