Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'ShipGlows.FlutterConfiguration.ps1')

$script:RegistryVersion = 1
$script:DefaultPortStart = 3000
$script:DefaultPortEnd = 3100
$script:ProjectIndexSchemaVersion = 1
$script:ProjectScannerVersion = '3'
$script:ProjectCatalogMaxWorkspaceDepth = 3
$script:ProjectIndexTtlMinutes = 5
$script:ProjectCatalogMemory = @{}
$script:GitHubRepositoryIdentityMemory = @{}
$script:ProjectEnvironmentSchema = 'shipglows-project-environment/v2'
$script:ProjectEnvironmentBegin = '<!-- >>> ShipGlows development environment >>> -->'
$script:ProjectEnvironmentEnd = '<!-- <<< ShipGlows development environment <<< -->'
$script:CliCapabilitySchema = 'shipglows.cli-capabilities.v1'
$script:CliCapabilityMaxBytes = 65536

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
        CliCapabilitiesPath = if ($env:SHIPGLOWS_CLI_CAPABILITIES_FILE) { [IO.Path]::GetFullPath($env:SHIPGLOWS_CLI_CAPABILITIES_FILE) } else { Join-Path $runtime 'cli-capabilities.v1.json' }
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
        # Keep round-trip timestamps intact on PowerShell 7.5+, as on Windows PowerShell.
        $jsonOptions = @{}
        if ((Get-Command ConvertFrom-Json).Parameters.ContainsKey('DateKind')) { $jsonOptions.DateKind='String' }
        $data = $raw | ConvertFrom-Json @jsonOptions -ErrorAction Stop
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

function Get-SgCliCapabilityRecords {
    $available = @(
        'project.catalog.read','project.runtime.status.read','preview.status.read','workspace.status.read',
        'system.health.read','system.storage.read','system.memory.read','toolchain.status.read','updates.status.read',
        'agents.status.read','mcp.status.read','project.runtime.start','project.runtime.stop','project.runtime.restart','project.runtime.reload',
        'preview.refresh','workspace.open','agent.session.open','system.logs.read','system.cleanup','system.process.stop',
        'system.reboot','system.update','toolchain.install','mcp.configure','credentials.manage','proxy.configure',
        'environment.remove','shipglows.install'
    )
    $unsupported = @('workspace.close','release.publish')
    $records = [Collections.Generic.List[object]]::new()
    foreach ($id in $available) { $records.Add([ordered]@{ id=$id; state='available' }) }
    foreach ($id in $unsupported) { $records.Add([ordered]@{ id=$id; state='unavailable'; reasonCode='unsupportedWindows' }) }
    return @($records)
}

function Test-SgCliCapabilitySnapshot([object]$Snapshot) {
    if (-not $Snapshot -or $Snapshot.schemaVersion -cne $script:CliCapabilitySchema) { return $false }
    try { [void][DateTime]::ParseExact([string]$Snapshot.generatedAt, "yyyy-MM-dd'T'HH:mm:ss.fff'Z'", [Globalization.CultureInfo]::InvariantCulture) } catch { return $false }
    $allowed = @{}; foreach ($record in @(Get-SgCliCapabilityRecords)) { $allowed[[string]$record.id] = $true }
    $seen = @{}
    foreach ($record in @($Snapshot.capabilities)) {
        $properties = @($record.PSObject.Properties.Name)
        if ($properties.Count -lt 2 -or $properties.Count -gt 3 -or 'id' -notin $properties -or 'state' -notin $properties) { return $false }
        if (@($properties | Where-Object { $_ -notin @('id','state','reasonCode') }).Count -gt 0) { return $false }
        $id = [string]$record.id; $state = [string]$record.state
        if (-not $allowed.ContainsKey($id) -or $seen.ContainsKey($id) -or $state -notin @('available','unavailable','degraded','disabled')) { return $false }
        if ('reasonCode' -in $properties -and [string]$record.reasonCode -notmatch '^[a-z][a-zA-Z0-9]{0,63}$') { return $false }
        $seen[$id] = $true
    }
    return $seen.Count -eq 31
}

function ConvertFrom-SgCliCapabilityJson([string]$Json) {
    $convertFromJson = Get-Command ConvertFrom-Json -CommandType Cmdlet
    if ($convertFromJson.Parameters.ContainsKey('DateKind')) {
        return $Json | ConvertFrom-Json -DateKind String -ErrorAction Stop
    }
    return $Json | ConvertFrom-Json -ErrorAction Stop
}

function Write-SgCliCapabilitySnapshot([object]$Config) {
    $path = [IO.Path]::GetFullPath([string]$Config.CliCapabilitiesPath)
    $directory = Split-Path -Parent $path
    Ensure-SgDirectory $directory
    $snapshot = [ordered]@{
        schemaVersion = $script:CliCapabilitySchema
        generatedAt = [DateTime]::UtcNow.ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'", [Globalization.CultureInfo]::InvariantCulture)
        capabilities = @(Get-SgCliCapabilityRecords)
    }
    $json = $snapshot | ConvertTo-Json -Depth 5 -Compress
    $bytes = [Text.Encoding]::UTF8.GetByteCount($json)
    if ($bytes -gt $script:CliCapabilityMaxBytes) { throw 'CLI capability snapshot exceeds its closed size limit.' }
    $temporary = "$path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temporary, $json, [Text.UTF8Encoding]::new($false))
        $verified = ConvertFrom-SgCliCapabilityJson ([IO.File]::ReadAllText($temporary))
        if (-not (Test-SgCliCapabilitySnapshot $verified)) { throw 'CLI capability snapshot validation failed.' }
        Move-Item -LiteralPath $temporary -Destination $path -Force
    } finally {
        Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue
    }
    return $path
}

function Read-SgCliCapabilitySnapshot([object]$Config) {
    $path = [IO.Path]::GetFullPath([string]$Config.CliCapabilitiesPath)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "CLI capability snapshot is missing: $path" }
    if ((Get-Item -LiteralPath $path).Length -gt $script:CliCapabilityMaxBytes) { throw 'CLI capability snapshot exceeds its closed size limit.' }
    $snapshot = ConvertFrom-SgCliCapabilityJson ([IO.File]::ReadAllText($path))
    if (-not (Test-SgCliCapabilitySnapshot $snapshot)) { throw 'CLI capability snapshot is invalid.' }
    return $snapshot
}

function Get-SgFlutterCommandPath {
    $command = Get-SgCommandPath @('flutter.cmd','flutter.bat','flutter.exe')
    if ($command) { return $command }
    $localAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [Environment]::GetFolderPath('LocalApplicationData') }
    if ([string]::IsNullOrWhiteSpace($localAppData)) { return $null }
    $managedRoot = Join-Path $localAppData 'ShipGlows\flutter'
    $flutter = Join-Path $managedRoot 'bin\flutter.bat'
    $dart = Join-Path $managedRoot 'bin\dart.bat'
    foreach ($path in @($managedRoot,$flutter,$dart)) {
        if (-not (Test-Path -LiteralPath $path)) { return $null }
        $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        if (-not $item -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $null }
    }
    return [IO.Path]::GetFullPath($flutter)
}

function Read-SgNodePackage([string]$ProjectPath) {
    $path = Join-Path $ProjectPath 'package.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try { return [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Invalid package.json: $($_.Exception.Message)" }
}

function Get-SgNodeDependencyNames([object]$Package) {
    $names = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    if (-not $Package) { return @() }
    foreach ($sectionName in @('dependencies','devDependencies','peerDependencies')) {
        $section = $Package.PSObject.Properties[$sectionName]
        if (-not $section -or -not $section.Value) { continue }
        foreach ($dependency in @($section.Value.PSObject.Properties)) { [void]$names.Add([string]$dependency.Name) }
    }
    return @($names)
}

function Get-SgNodeScript([object]$Package, [string]$Name) {
    if (-not $Package) { return $null }
    $scripts = $Package.PSObject.Properties['scripts']
    if (-not $scripts -or -not $scripts.Value) { return $null }
    $script = $scripts.Value.PSObject.Properties[$Name]
    if (-not $script -or [string]::IsNullOrWhiteSpace([string]$script.Value)) { return $null }
    return [string]$script.Value
}

function Test-SgBrowserExtensionPackage([object]$Package) {
    $dependencies = @(Get-SgNodeDependencyNames $Package)
    if ($dependencies -contains 'wxt') {
        return [bool]((Get-SgNodeScript $Package 'dev:chrome') -or (Get-SgNodeScript $Package 'dev'))
    }
    return ($dependencies -contains '@crxjs/vite-plugin') -and [bool](Get-SgNodeScript $Package 'dev:chrome')
}

function Get-SgBrowserExtensionFramework([object]$Package) {
    $dependencies = @(Get-SgNodeDependencyNames $Package)
    if ($dependencies -contains 'wxt') { return 'wxt' }
    if ($dependencies -contains '@crxjs/vite-plugin') { return 'crxjs' }
    return $null
}

function Get-SgObsidianDevelopmentScript([object]$Package) {
    foreach ($name in @('dev','watch','start')) {
        $command = Get-SgNodeScript $Package $name
        if ($command) { return [pscustomobject]@{ Name=$name; Command=$command } }
    }
    return $null
}

function Read-SgObsidianPluginManifest([string]$ManifestPath) {
    if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) { return $null }
    $item = Get-Item -LiteralPath $ManifestPath -Force -ErrorAction Stop
    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $item.Length -gt 1048576) { throw "Unsafe Obsidian manifest: $ManifestPath" }
    try { $manifest = [IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Invalid Obsidian manifest '$ManifestPath': $($_.Exception.Message)" }
    if ($manifest.PSObject.Properties['manifest_version']) { return $null }
    $hasObsidianMarker = $manifest.PSObject.Properties['id'] -or $manifest.PSObject.Properties['minAppVersion']
    if (-not $hasObsidianMarker) { return $null }
    foreach ($required in @('id','name','version','minAppVersion')) {
        if (-not $manifest.PSObject.Properties[$required] -or [string]::IsNullOrWhiteSpace([string]$manifest.$required)) {
            throw "Invalid Obsidian manifest '$ManifestPath': id, name, version, and minAppVersion are required."
        }
    }
    if ([string]$manifest.id -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$') { throw "Invalid Obsidian plugin id '$($manifest.id)'." }
    return $manifest
}

function Get-SgObsidianSourceEntrypoint([string]$ProjectPath) {
    foreach ($relative in @('main.ts','src\main.ts','main.js')) {
        $path = Join-Path $ProjectPath $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Unsafe Obsidian entrypoint: $path" }
            return [pscustomobject]@{ Path=$path; RelativePath=$relative.Replace('\','/') }
        }
    }
    return $null
}

function Test-SgObsidianBuildCurrent([string]$ProjectPath, [object]$Entrypoint) {
    $output = Join-Path $ProjectPath 'main.js'
    if (-not (Test-Path -LiteralPath $output -PathType Leaf)) { return $false }
    $outputItem = Get-Item -LiteralPath $output -Force -ErrorAction Stop
    if ($outputItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { return $false }
    $inputs = @($Entrypoint.Path, (Join-Path $ProjectPath 'package.json'), (Join-Path $ProjectPath 'manifest.json'))
    foreach ($candidate in @('vite.config.ts','vite.config.js','esbuild.config.mjs','esbuild.config.js')) {
        $path = Join-Path $ProjectPath $candidate
        if (Test-Path -LiteralPath $path -PathType Leaf) { $inputs += $path }
    }
    $newestInput = @($inputs | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | ForEach-Object { (Get-Item -LiteralPath $_ -Force).LastWriteTimeUtc } | Sort-Object -Descending | Select-Object -First 1)
    return $newestInput.Count -eq 1 -and $outputItem.LastWriteTimeUtc -ge $newestInput[0]
}

function Get-SgObsidianPluginDescriptor([string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $package = Read-SgNodePackage $root
    if (-not $package -or @(Get-SgNodeDependencyNames $package) -notcontains 'obsidian') { return $null }
    $manifest = Read-SgObsidianPluginManifest (Join-Path $root 'manifest.json')
    if (-not $manifest) { return $null }
    $entrypoint = Get-SgObsidianSourceEntrypoint $root
    if (-not $entrypoint) { return $null }
    $development = Get-SgObsidianDevelopmentScript $package
    $build = Get-SgNodeScript $package 'build'
    if (-not $development -and -not $build) { return $null }
    $settings = Get-SgRuntimeSettings $root
    $vaultReady = [bool]$settings.ObsidianVault -and (Test-Path -LiteralPath $settings.ObsidianVault -PathType Container) -and (Test-Path -LiteralPath (Join-Path $settings.ObsidianVault '.obsidian') -PathType Container)
    $state = if (-not $vaultReady) { 'detected' } elseif (-not $development -or -not (Test-SgObsidianBuildCurrent $root $entrypoint)) { 'build-required' } else { 'configured' }
    $artifacts = @('main.js','manifest.json')
    if (Test-Path -LiteralPath (Join-Path $root 'styles.css') -PathType Leaf) { $artifacts += 'styles.css' }
    $evidence = @('manifest.json:id,name,version,minAppVersion','package.json:dependency:obsidian',$entrypoint.RelativePath)
    if ($development) { $evidence += "scripts.$($development.Name)" }
    if ($build) { $evidence += 'scripts.build' }
    return [pscustomobject]@{
        ProjectPath=$root; PluginId=[string]$manifest.id; Name=[string]$manifest.name; Version=[string]$manifest.version
        MinAppVersion=[string]$manifest.minAppVersion; SourceEntrypoint=$entrypoint.RelativePath
        DevelopmentScriptName=$(if($development){[string]$development.Name}else{$null}); DevelopmentScript=$(if($development){[string]$development.Command}else{$null})
        BuildScriptName=$(if($build){'build'}else{$null}); BuildScript=$(if($build){[string]$build}else{$null})
        ArtifactPaths=@($artifacts); Evidence=@($evidence); SurfaceState=$state; VaultPath=$(if($settings.ObsidianVault){$settings.ObsidianVault}else{$null}); InstallPath=$(if($settings.ObsidianVault){Join-Path $settings.ObsidianVault ".obsidian\plugins\$([string]$manifest.id)"}else{$null})
    }
}

function Read-SgBrowserExtensionManifest([string]$ManifestPath) {
    if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) { return $null }
    $item = Get-Item -LiteralPath $ManifestPath -Force -ErrorAction Stop
    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $item.Length -gt 1048576) { throw "Unsafe browser extension manifest: $ManifestPath" }
    try { $manifest = [IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Invalid browser extension manifest '$ManifestPath': $($_.Exception.Message)" }
    # An empty or non-object manifest.json is not a browser extension manifest.
    if ($manifest -isnot [pscustomobject] -or -not $manifest.PSObject.Properties['manifest_version']) { return $null }
    if ([int]$manifest.manifest_version -notin @(2,3) -or [string]::IsNullOrWhiteSpace([string]$manifest.name) -or [string]::IsNullOrWhiteSpace([string]$manifest.version)) { throw "Invalid browser extension manifest '$ManifestPath': name, version, and manifest_version 2 or 3 are required." }
    return $manifest
}

function Get-SgBrowserExtensionDescriptor([string]$ProjectPath, [string]$Browser = 'Chromium') {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $browserName = $Browser.Trim().ToLowerInvariant()
    if ($browserName -notin @('chromium','edge','vivaldi','firefox')) { throw 'Browser must be one of: Chromium, Edge, Vivaldi, Firefox.' }
    $package = Read-SgNodePackage $root
    $framework = Get-SgBrowserExtensionFramework $package
    $wxtCandidates = if ($browserName -eq 'firefox') { @('.output\firefox-mv3\manifest.json','.output\firefox-mv3-dev\manifest.json') } else { @('.output\chrome-mv3\manifest.json','.output\chrome-mv3-dev\manifest.json') }
    if ($framework -eq 'wxt') {
        foreach ($relative in $wxtCandidates) {
            $manifestPath = Join-Path $root $relative
            if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { continue }
            $manifest = Read-SgBrowserExtensionManifest $manifestPath
            if (-not $manifest) { continue }
            return [pscustomobject]@{ProjectPath=$root;ExtensionPath=[IO.Path]::GetFullPath((Split-Path $manifestPath -Parent));ManifestPath=[IO.Path]::GetFullPath($manifestPath);RelativeManifestPath=$relative.Replace('\','/');ManifestVersion=[int]$manifest.manifest_version;Name=[string]$manifest.name;Version=[string]$manifest.version;Mode='built';Framework='wxt'}
        }
    }
    $platformCandidates = if ($browserName -eq 'firefox') { @('dist\firefox\manifest.json','build\firefox\manifest.json','output\firefox\manifest.json') } else { @('dist\chrome\manifest.json','build\chrome\manifest.json','output\chrome\manifest.json') }
    $relativeCandidates = @('manifest.json') + $platformCandidates + @('dist\manifest.json','build\manifest.json','extension\manifest.json')
    $matches = New-Object 'System.Collections.Generic.List[object]'
    foreach ($relative in $relativeCandidates) {
        $manifestPath = Join-Path $root $relative
        if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { continue }
        $manifest = Read-SgBrowserExtensionManifest $manifestPath
        if (-not $manifest) { continue }
        [void]$matches.Add([pscustomobject]@{ProjectPath=$root;ExtensionPath=[IO.Path]::GetFullPath((Split-Path $manifestPath -Parent));ManifestPath=[IO.Path]::GetFullPath($manifestPath);RelativeManifestPath=$relative.Replace('\','/');ManifestVersion=[int]$manifest.manifest_version;Name=[string]$manifest.name;Version=[string]$manifest.version;Mode=$(if($relative -eq 'manifest.json'){'static'}else{'built'});Framework=$framework})
    }
    if ($matches.Count -gt 1) { $paths=($matches|ForEach-Object{$_.RelativeManifestPath})-join', ';throw "Multiple browser extension artifacts were detected ($paths). Remove stale outputs or choose the exact extension directory." }
    if ($matches.Count -eq 1) { return $matches[0] }
    if ($package -and (Test-SgBrowserExtensionPackage $package)) {
        $packageName = if ($package.PSObject.Properties['name'] -and $package.name) { [string]$package.name } else { Split-Path $root -Leaf }
        $packageVersion = if ($package.PSObject.Properties['version'] -and $package.version) { [string]$package.version } else { '' }
        return [pscustomobject]@{ProjectPath=$root;ExtensionPath=$null;ManifestPath=$null;RelativeManifestPath=$null;ManifestVersion=0;Name=$packageName;Version=$packageVersion;Mode='build-required';Framework=$framework}
    }
    return $null
}

function Get-SgManagedPlaywrightModulePath([string]$Browser = 'Chromium') {
    $localAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [Environment]::GetFolderPath('LocalApplicationData') }
    $toolsRoot = Join-Path $localAppData 'ShipGlows\node-tools'
    if (-not (Test-Path -LiteralPath $toolsRoot -PathType Container)) { return $null }
    foreach ($directory in @(Get-ChildItem -LiteralPath $toolsRoot -Directory -Filter 'playwright-*' -ErrorAction SilentlyContinue | Sort-Object LastWriteTimeUtc -Descending)) {
        $modulePath = Join-Path $directory.FullName 'node_modules\playwright'
        if (-not (Test-Path -LiteralPath (Join-Path $modulePath 'package.json') -PathType Leaf)) { continue }
        if ($Browser.Trim().ToLowerInvariant() -eq 'firefox') {
            $browsersPath = Join-Path $directory.FullName 'node_modules\playwright-core\browsers.json'
            if (-not (Test-Path -LiteralPath $browsersPath -PathType Leaf)) { continue }
            try { $firefox = @(([IO.File]::ReadAllText($browsersPath) | ConvertFrom-Json).browsers | Where-Object { $_.name -eq 'firefox' })[0] } catch { continue }
            $managedFirefox = Join-Path $localAppData "ms-playwright\firefox-$([string]$firefox.revision)\firefox\firefox.exe"
            if (-not (Test-Path -LiteralPath $managedFirefox -PathType Leaf)) { continue }
        }
        return $modulePath
    }
    return $null
}

function Get-SgBrowserLabExecutable([string]$Browser, [string]$PlaywrightModule = '') {
    $browserName = $Browser.Trim().ToLowerInvariant()
    if ($browserName -eq 'chromium') { return [pscustomobject]@{ Name='chromium'; Product='Chromium'; Version='managed'; ExecutablePath=$null } }
    $programFilesX86 = ${env:ProgramFiles(x86)}
    $candidates = switch ($browserName) {
        'edge' { @((Join-Path $programFilesX86 'Microsoft\Edge\Application\msedge.exe'),(Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe'),(Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\Application\msedge.exe')) }
        'vivaldi' { @((Join-Path $env:LOCALAPPDATA 'Vivaldi\Application\vivaldi.exe'),(Join-Path $env:ProgramFiles 'Vivaldi\Application\vivaldi.exe'),(Join-Path $programFilesX86 'Vivaldi\Application\vivaldi.exe')) }
        'firefox' {
            if (-not $PlaywrightModule) { @() }
            else {
                $browsersPath = Join-Path (Split-Path $PlaywrightModule -Parent) 'playwright-core\browsers.json'
                try { $firefox = @(([IO.File]::ReadAllText($browsersPath) | ConvertFrom-Json).browsers | Where-Object { $_.name -eq 'firefox' })[0] } catch { $firefox = $null }
                if ($firefox) { @((Join-Path $env:LOCALAPPDATA "ms-playwright\firefox-$([string]$firefox.revision)\firefox\firefox.exe")) } else { @() }
            }
        }
        default { throw 'Browser must be one of: Chromium, Edge, Vivaldi, Firefox.' }
    }
    foreach ($candidate in @($candidates | Where-Object { $_ })) {
        $full = [IO.Path]::GetFullPath([string]$candidate)
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
        $item = Get-Item -LiteralPath $full -Force
        return [pscustomobject]@{ Name=$browserName; Product=[string]$item.VersionInfo.ProductName; Version=[string]$item.VersionInfo.ProductVersion; ExecutablePath=$full }
    }
    throw "$Browser is not installed in a supported machine location. ShipGlows will not target a personal browser profile or silently install it."
}

function Invoke-SgBrowserExtensionLab([string]$ProjectPath, [switch]$Headless, [switch]$Json, [string]$TargetUrl = '', [switch]$Screenshot, [string]$Browser = 'Chromium', [string]$ClickSelector = '', [string]$VisualSelector = '', [object]$Config = $null) {
    $descriptor = Get-SgBrowserExtensionDescriptor $ProjectPath $Browser
    if (-not $descriptor) { throw "No browser extension manifest or supported build contract was detected in: $ProjectPath" }
    if ($descriptor.Mode -eq 'build-required') { throw "Extension build required for $Browser. ShipGlows will not run repository scripts implicitly. Run the reviewed browser-specific build command, then retry the lab." }
    if ($descriptor.ManifestVersion -ne 3) { throw "Manifest V$($descriptor.ManifestVersion) is obsolete for the managed extension lab. Migrate the extension to Manifest V3 before testing." }
    $node = Get-SgCommandPath @('node.exe','node.cmd'); if (-not $node) { throw 'Node.js is required by the browser extension lab but is unavailable.' }
    $playwrightModule = Get-SgManagedPlaywrightModulePath $Browser; if (-not $playwrightModule) { throw "Managed Playwright for $Browser is unavailable. Rerun the ShipGlows full installer before opening the extension lab." }
    $browserInfo = Get-SgBrowserLabExecutable $Browser $playwrightModule
    $runner = Join-Path $PSScriptRoot 'ShipGlows.ExtensionLab.js'; if (-not (Test-Path -LiteralPath $runner -PathType Leaf)) { throw "Browser extension lab runner is missing: $runner" }
    $screenshotPath = ''
    if ($Screenshot) {
        if (-not $Config) { $Config = Get-SgDevConfig }
        Ensure-SgDirectory $Config.RuntimeDirectory
        $evidenceDirectory = Join-Path $Config.RuntimeDirectory 'extension-lab-evidence'
        Ensure-SgDirectory $evidenceDirectory
        $safeName = ([regex]::Replace([string]$descriptor.Name,'[^A-Za-z0-9._-]+','-')).Trim('-')
        if (-not $safeName) { $safeName = 'extension' }
        $screenshotPath = Join-Path $evidenceDirectory ("{0}-{1}.png" -f $safeName,[guid]::NewGuid().ToString('N'))
    }
    $arguments = @($runner,'--extension',$descriptor.ExtensionPath,'--playwright',$playwrightModule,'--browser',$browserInfo.Name,'--browser-product',$browserInfo.Product,'--browser-version',$browserInfo.Version); if ($browserInfo.ExecutablePath) { $arguments += @('--browser-executable',$browserInfo.ExecutablePath) }; if ($Headless) { $arguments += '--headless' }; if ($Json) { $arguments += '--json' }; if ($TargetUrl) { $arguments += @('--target-url',$TargetUrl) }
    if ($screenshotPath) { $arguments += @('--screenshot',$screenshotPath) }
    if ($ClickSelector) { $arguments += @('--click-selector',$ClickSelector) }
    if ($VisualSelector) { $arguments += @('--visual-selector',$VisualSelector) }
    & $node @arguments; if ($LASTEXITCODE -ne 0) { throw "Browser extension lab failed with exit code $LASTEXITCODE." }
}

function Get-SgObsidianExecutablePath {
    $localAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [Environment]::GetFolderPath('LocalApplicationData') }
    $candidates = @((Join-Path $localAppData 'Programs\Obsidian\Obsidian.exe'),(Get-SgCommandPath @('Obsidian.exe'))) | Where-Object { $_ }
    foreach ($candidate in $candidates) {
        $full = [IO.Path]::GetFullPath([string]$candidate)
        if (Test-Path -LiteralPath $full -PathType Leaf) { return $full }
    }
    return $null
}

function Get-SgObsidianBratArtifactReport([string]$ProjectPath) {
    $descriptor = Get-SgObsidianPluginDescriptor $ProjectPath
    if (-not $descriptor) { throw "No valid Obsidian plugin was detected in: $ProjectPath" }
    $root = [IO.Path]::GetFullPath([string]$descriptor.ProjectPath)
    $required = @('main.js','manifest.json')
    $missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_) -PathType Leaf) })
    if ($missing.Count -gt 0) { return [pscustomobject]@{ State='build-required'; PluginId=$descriptor.PluginId; Version=$descriptor.Version; Files=@(); Missing=$missing; Errors=@('Required BRAT artifacts are missing.') } }
    $entrypoint = Get-SgObsidianSourceEntrypoint $root
    if (-not (Test-SgObsidianBuildCurrent $root $entrypoint)) { return [pscustomobject]@{ State='build-required'; PluginId=$descriptor.PluginId; Version=$descriptor.Version; Files=@(); Missing=@(); Errors=@('main.js is older than an Obsidian build input.') } }
    $errors = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath (Join-Path $root 'style.css') -PathType Leaf) { $errors.Add('BRAT and Obsidian require styles.css; rename style.css.') }
    $files = [Collections.Generic.List[object]]::new()
    foreach ($name in @('main.js','manifest.json','styles.css','versions.json')) {
        $file = Join-Path $root $name
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
        $item = Get-Item -LiteralPath $file -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { $errors.Add("Artifact is a reparse point: $name"); continue }
        $rootPrefix = $root.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
        if (-not $item.FullName.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)) { $errors.Add("Artifact escapes the plugin root: $name"); continue }
        $files.Add([pscustomobject]@{ Name=$name; Bytes=[int64]$item.Length; Sha256=(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash })
    }
    $versionsPath = Join-Path $root 'versions.json'
    if (Test-Path -LiteralPath $versionsPath -PathType Leaf) {
        try {
            $versionsItem = Get-Item -LiteralPath $versionsPath -Force
            if (($versionsItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $versionsItem.Length -gt 1048576) { throw 'unsafe versions.json' }
            $versions = Get-Content -LiteralPath $versionsPath -Raw | ConvertFrom-Json -ErrorAction Stop
            if (-not $versions.PSObject.Properties[[string]$descriptor.Version]) { $errors.Add("versions.json has no entry for manifest version $($descriptor.Version).") }
        } catch { $errors.Add('versions.json is invalid JSON.') }
    }
    [pscustomobject]@{ State=$(if($errors.Count){'failed'}else{'passed'}); PluginId=$descriptor.PluginId; Version=$descriptor.Version; Files=@($files); Missing=@(); Errors=@($errors) }
}

function Resolve-SgObsidianVault([string]$VaultPath, [string]$PluginId) {
    if ([string]::IsNullOrWhiteSpace($VaultPath)) { throw 'Obsidian vault is not configured. Add SHIPGLOWS_OBSIDIAN_VAULT=<absolute-vault-path> to the plugin .shipglows.env; ShipGlows will not discover or select a personal vault.' }
    if ($PluginId -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$') { throw 'Obsidian plugin id is not safe for an installation directory.' }
    $vault = [IO.Path]::GetFullPath($VaultPath).TrimEnd('\','/')
    if (-not (Test-Path -LiteralPath $vault -PathType Container)) { throw "Configured Obsidian vault does not exist: $vault" }
    $vaultItem = Get-Item -LiteralPath $vault -Force -ErrorAction Stop
    if ($vaultItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Configured Obsidian vault must not be a reparse point: $vault" }
    $obsidianDirectory = Join-Path $vault '.obsidian'
    if (-not (Test-Path -LiteralPath $obsidianDirectory -PathType Container)) { throw "Configured path is not an initialized Obsidian vault because .obsidian is missing: $vault" }
    $obsidianItem = Get-Item -LiteralPath $obsidianDirectory -Force -ErrorAction Stop
    if ($obsidianItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Obsidian configuration directory must not be a reparse point: $obsidianDirectory" }
    $pluginsDirectory = Join-Path $obsidianDirectory 'plugins'
    $target = [IO.Path]::GetFullPath((Join-Path $pluginsDirectory $PluginId))
    $vaultPrefix = $vault + [IO.Path]::DirectorySeparatorChar
    if (-not $target.StartsWith($vaultPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Obsidian plugin target escapes the configured vault.' }
    return [pscustomobject]@{ VaultPath=$vault; ObsidianPath=$obsidianDirectory; PluginsPath=$pluginsDirectory; TargetPath=$target }
}

function Test-SgObsidianPluginArtifacts([object]$Descriptor, [DateTime]$FreshSinceUtc) {
    if (-not $Descriptor) { return $false }
    $mainPath = Join-Path $Descriptor.ProjectPath 'main.js'
    if (-not (Test-Path -LiteralPath $mainPath -PathType Leaf)) { return $false }
    try {
        $main = Get-Item -LiteralPath $mainPath -Force -ErrorAction Stop
        if (($main.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $main.Length -le 0 -or $main.Length -gt 134217728 -or $main.LastWriteTimeUtc -lt $FreshSinceUtc) { return $false }
        $manifest = Read-SgObsidianPluginManifest (Join-Path $Descriptor.ProjectPath 'manifest.json')
        if (-not $manifest -or [string]$manifest.id -cne [string]$Descriptor.PluginId) { return $false }
        foreach ($artifact in @($Descriptor.ArtifactPaths)) {
            $path = Join-Path $Descriptor.ProjectPath $artifact
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $false }
            $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { return $false }
        }
        return $true
    } catch { return $false }
}

function Wait-SgObsidianPluginReady([string]$ProjectPath, [int]$TimeoutSeconds = 90, [object]$ProcessEntry = $null, [string]$ErrorLogPath = '') {
    $freshSince = [DateTime]::UtcNow.AddSeconds(-2)
    if ($ProcessEntry -and $ProcessEntry.PSObject.Properties['startTimeUtc'] -and $ProcessEntry.startTimeUtc) {
        try { $freshSince = ([DateTimeOffset]::Parse([string]$ProcessEntry.startTimeUtc, [Globalization.CultureInfo]::InvariantCulture)).UtcDateTime.AddSeconds(-2) } catch { }
    }
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    do {
        if ($ProcessEntry -and -not (Test-SgProcessIdentity $ProcessEntry)) {
            return [pscustomobject]@{ Ready=$false; AppId=$null; PluginId=$null; ArtifactPaths=@(); Error=(Get-SgStartupFailure $ErrorLogPath) }
        }
        $descriptor = Get-SgObsidianPluginDescriptor $ProjectPath
        if ($descriptor -and (Test-SgObsidianPluginArtifacts $descriptor $freshSince)) {
            return [pscustomobject]@{ Ready=$true; AppId=$null; PluginId=$descriptor.PluginId; ArtifactPaths=@($descriptor.ArtifactPaths); Error=$null }
        }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; PluginId=$null; ArtifactPaths=@(); Error='Obsidian build readiness timed out before a fresh main.js and valid plugin artifacts were available.' }
}

function Sync-SgObsidianPluginArtifacts([object]$Descriptor, [string]$VaultPath) {
    if (-not $Descriptor) { throw 'Obsidian plugin descriptor is required for synchronization.' }
    $resolved = Resolve-SgObsidianVault $VaultPath ([string]$Descriptor.PluginId)
    if (-not (Test-Path -LiteralPath $resolved.PluginsPath -PathType Container)) { New-Item -ItemType Directory -Path $resolved.PluginsPath -Force | Out-Null }
    $pluginsItem = Get-Item -LiteralPath $resolved.PluginsPath -Force -ErrorAction Stop
    if ($pluginsItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Obsidian plugins directory must not be a reparse point: $($resolved.PluginsPath)" }
    if (Test-Path -LiteralPath $resolved.TargetPath) {
        $targetItem = Get-Item -LiteralPath $resolved.TargetPath -Force -ErrorAction Stop
        if (-not $targetItem.PSIsContainer -or ($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Obsidian plugin target must be a normal directory: $($resolved.TargetPath)" }
    } else {
        New-Item -ItemType Directory -Path $resolved.TargetPath -Force | Out-Null
    }
    $copied = New-Object 'System.Collections.Generic.List[string]'
    foreach ($artifact in @($Descriptor.ArtifactPaths)) {
        $source = Join-Path $Descriptor.ProjectPath $artifact
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Obsidian artifact is missing: $source" }
        $sourceItem = Get-Item -LiteralPath $source -Force -ErrorAction Stop
        if ($sourceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Obsidian artifact must not be a reparse point: $source" }
        $destination = Join-Path $resolved.TargetPath $artifact
        if (Test-Path -LiteralPath $destination) {
            $destinationItem = Get-Item -LiteralPath $destination -Force -ErrorAction Stop
            if ($destinationItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Obsidian target artifact must not be a reparse point: $destination" }
        }
        $temporary = Join-Path $resolved.TargetPath (".$artifact.shipglows-" + [guid]::NewGuid().ToString('N') + '.tmp')
        try {
            [IO.File]::Copy($source, $temporary, $false)
            Move-Item -LiteralPath $temporary -Destination $destination -Force
        } finally { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
        if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash) { throw "Obsidian artifact synchronization verification failed: $artifact" }
        [void]$copied.Add([string]$artifact)
    }
    return [pscustomobject]@{ TargetPath=$resolved.TargetPath; Copied=@($copied) }
}

function Invoke-SgObsidianPluginLab([object]$Config, [string]$ProjectPath, [switch]$Headless, [switch]$Json, [string]$InteractionCommand = '', [switch]$Screenshot, [string]$ClickSelector = '', [string]$VisualSelector = '') {
    $descriptor = Get-SgObsidianPluginDescriptor $ProjectPath
    if (-not $descriptor) { throw "No valid Obsidian plugin was detected in: $ProjectPath" }
    $brat = Get-SgObsidianBratArtifactReport $ProjectPath
    if ($brat.State -eq 'build-required') { throw 'Obsidian plugin build required. ShipGlows will not execute repository scripts implicitly. Run the reviewed build command, then retry the lab.' }
    if ($brat.State -eq 'failed') { throw "Obsidian BRAT artifact inspection failed: $($brat.Errors -join ' ')" }
    $obsidian = Get-SgObsidianExecutablePath; if (-not $obsidian) { throw 'Obsidian Desktop is required by the local lab but is unavailable.' }
    $versionText = [Diagnostics.FileVersionInfo]::GetVersionInfo($obsidian).ProductVersion
    try { $version = [version]([regex]::Match([string]$versionText,'\d+(\.\d+){1,3}').Value) } catch { throw "Obsidian version could not be determined: $versionText" }
    if ($version -lt [version]'1.12.7') { throw "Obsidian 1.12.7 or newer is required; found $version." }
    $node = Get-SgCommandPath @('node.exe','node.cmd'); if (-not $node) { throw 'Node.js is required by the Obsidian lab but is unavailable.' }
    $playwrightModule = Get-SgManagedPlaywrightModulePath; if (-not $playwrightModule) { throw 'Managed Playwright is unavailable. Rerun the ShipGlows full installer before opening the Obsidian lab.' }
    $runner = Join-Path $PSScriptRoot 'ShipGlows.ObsidianLab.js'; if (-not (Test-Path -LiteralPath $runner -PathType Leaf)) { throw "Obsidian lab runner is missing: $runner" }
    Ensure-SgDirectory $Config.RuntimeDirectory
    $labRoot = Join-Path $Config.RuntimeDirectory ("obsidian-labs\{0}" -f [guid]::NewGuid().ToString('N'))
    $profile = Join-Path $labRoot 'profile'; $vault = Join-Path $labRoot 'vault'
    $pluginTarget = Join-Path $vault (".obsidian\plugins\{0}" -f $descriptor.PluginId)
    $evidenceDirectory = Join-Path $Config.RuntimeDirectory 'obsidian-lab-evidence'
    $screenshotPath = if ($Screenshot) { Ensure-SgDirectory $evidenceDirectory; Join-Path $evidenceDirectory ("{0}-{1}.png" -f $descriptor.PluginId,[guid]::NewGuid().ToString('N')) } else { '' }
    $payload = $null
    try {
        foreach ($directory in @($profile,$pluginTarget)) { Ensure-SgDirectory $directory }
        foreach ($artifact in @($brat.Files | Where-Object { $_.Name -in @('main.js','manifest.json','styles.css') })) {
            $source = Join-Path $descriptor.ProjectPath $artifact.Name; $destination = Join-Path $pluginTarget $artifact.Name
            if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne $artifact.Sha256) { throw "Obsidian artifact changed after inspection: $($artifact.Name)" }
            Copy-Item -LiteralPath $source -Destination $destination
            if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -cne $artifact.Sha256) { throw "Obsidian Lab artifact copy verification failed: $($artifact.Name)" }
        }
        [IO.File]::WriteAllText((Join-Path $vault '.obsidian\community-plugins.json'),(@($descriptor.PluginId)|ConvertTo-Json -Compress),[Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText((Join-Path $vault '.obsidian\app.json'),'{}',[Text.UTF8Encoding]::new($false))
        $vaultId=[guid]::NewGuid().ToString('N').Substring(0,16)
        $vaults=[ordered]@{};$vaults[$vaultId]=[ordered]@{path=$vault;ts=[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds();open=$true}
        $profileState=[ordered]@{vaults=$vaults}|ConvertTo-Json -Depth 5 -Compress
        [IO.File]::WriteAllText((Join-Path $profile 'obsidian.json'),$profileState,[Text.UTF8Encoding]::new($false))
        $port = Get-SgFreePort $Config 0 $labRoot
        $arguments=@($runner,'--obsidian',$obsidian,'--playwright',$playwrightModule,'--profile',$profile,'--vault',$vault,'--plugin-id',$descriptor.PluginId,'--port',[string]$port,'--json')
        if($Headless){$arguments+='--headless'};if($InteractionCommand){$arguments+=@('--interaction-command',$InteractionCommand)};if($ClickSelector){$arguments+=@('--click-selector',$ClickSelector)};if($VisualSelector){$arguments+=@('--visual-selector',$VisualSelector)};if($screenshotPath){$arguments+=@('--screenshot',$screenshotPath)}
        $output = & $node @arguments 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Obsidian lab failed: $($output -join ' ')" }
        $payload = ($output | Select-Object -Last 1) | ConvertFrom-Json -ErrorAction Stop
        $payload | Add-Member -NotePropertyName brat -NotePropertyValue $brat -Force
    } finally {
        if (Test-Path -LiteralPath $labRoot) { Assert-SgNoReparseTree $labRoot; Remove-Item -LiteralPath $labRoot -Recurse -Force }
    }
    if (-not $payload -or (Test-Path -LiteralPath $labRoot)) { throw 'Obsidian Lab cleanup could not be proven.' }
    $payload | Add-Member -NotePropertyName profile -NotePropertyValue $profile -Force
    $payload | Add-Member -NotePropertyName vault -NotePropertyValue $vault -Force
    $payload | Add-Member -NotePropertyName cleanup -NotePropertyValue 'passed' -Force
    if($Json){[Console]::Out.WriteLine(($payload|ConvertTo-Json -Depth 8 -Compress))}else{Write-SgInfo "$($payload.name) $($payload.version) | load: $($payload.hostLoad) | interaction: $($payload.interaction.state) | diagnostics: $($payload.diagnostics.state)";if($payload.visual.screenshotStatus -eq 'captured'){Write-SgInfo "Screenshot: $($payload.visual.screenshotPath)"}}
    return $payload
}

function Get-SgNodePackageManager([string]$ProjectPath, [string]$WorkspaceRoot = '') {
    # The install root decides the manager: a pnpm lock selects pnpm, while npm or yarn workspaces install with npm.
    $installRoot = if ($WorkspaceRoot) { $WorkspaceRoot } else { $ProjectPath }
    $installPnpmLock = Test-Path -LiteralPath (Join-Path $installRoot 'pnpm-lock.yaml') -PathType Leaf
    $installNpmLock = (Test-Path -LiteralPath (Join-Path $installRoot 'package-lock.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $installRoot 'npm-shrinkwrap.json') -PathType Leaf)
    $installPackage = Read-SgNodePackage $installRoot
    $installDeclaration = if ($installPackage -and $installPackage.PSObject.Properties['packageManager']) { ([string]$installPackage.packageManager).Trim() } else { '' }
    $installUsesPnpm = $installPnpmLock -or $installDeclaration.StartsWith('pnpm@', [StringComparison]::OrdinalIgnoreCase) -or ($WorkspaceRoot -and (Test-Path -LiteralPath (Join-Path $WorkspaceRoot 'pnpm-workspace.yaml') -PathType Leaf))
    # A pnpm declaration or workspace file cannot be satisfied by an npm lock that has no pnpm lock beside it.
    if ($installUsesPnpm -and $installNpmLock -and -not $installPnpmLock) { throw "packageManager and lockfile conflict at Node dependency root: $installRoot" }
    $pnpmLock = $installPnpmLock
    if (-not $pnpmLock) {
        $npm = Get-SgCommandPath @('npm.cmd','npm.exe')
        if (-not $npm) { throw 'npm is required but unavailable.' }
        return [pscustomobject]@{ Manager=[IO.Path]::GetFullPath($npm); PrefixArguments=@(); Name='npm'; Pinned=$false }
    }

    $package = Read-SgNodePackage $ProjectPath
    $declaration = if ($package -and $package.PSObject.Properties['packageManager']) { ([string]$package.packageManager).Trim() } else { '' }
    # A pnpm workspace pins its manager in the root package.json when the project does not.
    if (-not $declaration -and $WorkspaceRoot) {
        $rootPackage = Read-SgNodePackage $WorkspaceRoot
        $declaration = if ($rootPackage -and $rootPackage.PSObject.Properties['packageManager']) { ([string]$rootPackage.packageManager).Trim() } else { '' }
    }
    if ($declaration) {
        if ($declaration -notmatch '^pnpm@(?<version>[0-9]+[.][0-9]+[.][0-9]+(?:-[0-9A-Za-z.-]+)?)$') {
            throw "Unsupported packageManager declaration '$declaration'; expected an exact pnpm@x.y.z version."
        }
        $corepack = Get-SgCommandPath @('corepack.cmd','corepack.exe')
        if (-not $corepack) { throw "Corepack is required by packageManager '$declaration' but is unavailable." }
        return [pscustomobject]@{ Manager=[IO.Path]::GetFullPath($corepack); PrefixArguments=@($declaration); Name='pnpm'; Pinned=$true }
    }

    $pnpm = Get-SgCommandPath @('pnpm.cmd','pnpm.exe')
    if (-not $pnpm) { throw 'pnpm is required by pnpm-lock.yaml but is unavailable.' }
    return [pscustomobject]@{ Manager=[IO.Path]::GetFullPath($pnpm); PrefixArguments=@(); Name='pnpm'; Pinned=$false }
}

function Get-SgProjectKind([string]$ProjectPath) {
    $selectionPath = Join-Path $ProjectPath '.shipglows.runtime.json'
    if (Test-Path -LiteralPath $selectionPath -PathType Leaf) {
        $selection = Get-Content -LiteralPath $selectionPath -Raw | ConvertFrom-Json
        if ($selection.surface -eq 'tauri') {
            if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath 'src-tauri\tauri.conf.json') -PathType Leaf)) { throw 'The selected Tauri surface has no tauri.conf.json.' }
            return 'tauri'
        }
        if ($selection.surface -ne 'browser-extension') { throw 'Unsupported runtime surface selection. Expected tauri or browser-extension.' }
    }
    if (Get-SgObsidianPluginDescriptor $ProjectPath) { return 'obsidian-plugin' }
    if (Get-SgBrowserExtensionDescriptor $ProjectPath) { return 'browser-extension' }
    $package = Join-Path $ProjectPath 'package.json'
    $pubspec = Join-Path $ProjectPath 'pubspec.yaml'
    if ([IO.File]::Exists($package)) {
        $json = Read-SgNodePackage $ProjectPath
        $all = @(Get-SgNodeDependencyNames $json)
        $hasDevScript = [bool](Get-SgNodeScript $json 'dev')
        if (Test-SgBrowserExtensionPackage $json) { return 'browser-extension' }
        if ($all -contains 'astro' -and $hasDevScript) { return 'astro' }
        if ($all -contains 'vite' -and $hasDevScript) { return 'vite' }
    }
    if ([IO.File]::Exists($pubspec)) {
        if ([IO.File]::ReadAllText($pubspec) -match '(?m)^\s*flutter:\s*$') { return 'flutter-web' }
    }
    if ([IO.File]::Exists((Join-Path $ProjectPath 'pyproject.toml'))) {
        if ([IO.File]::Exists((Join-Path $ProjectPath 'uv.lock'))) { return 'python' }
        if ([IO.File]::Exists((Join-Path $ProjectPath 'requirements.txt'))) { return 'python' }
    }
    if ([IO.File]::Exists((Join-Path $ProjectPath 'requirements.txt'))) { return 'python' }
    throw "Unsupported or ambiguous project. Supported kinds: Obsidian plugins, Astro, Vite, browser extensions, Python/FastAPI with uv/requirements, Flutter."
}

function Get-SgExtensionManagerBrowser {
    # chrome:// has no Windows protocol handler, so ShellExecute falls back to the blocking
    # Open With dialog. Launch an installed Chromium browser with its own extensions URL.
    $programFilesX86 = ${env:ProgramFiles(x86)}
    foreach ($chrome in @((Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),(Join-Path $programFilesX86 'Google\Chrome\Application\chrome.exe'),(Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'))) {
        if ($chrome -and (Test-Path -LiteralPath $chrome -PathType Leaf)) { return [pscustomobject]@{ Product='Chrome'; ExecutablePath=$chrome; ExtensionsUrl='chrome://extensions/' } }
    }
    foreach ($name in @('edge','vivaldi')) {
        try { $browser = Get-SgBrowserLabExecutable $name } catch { continue }
        return [pscustomobject]@{ Product=$browser.Product; ExecutablePath=$browser.ExecutablePath; ExtensionsUrl="$name`://extensions/" }
    }
    return $null
}

function Get-SgBrowserExtensionUnpackedDirectory([string]$ProjectPath) {
    # WXT dev writes its unpacked package to .output; crxjs projects keep dist\chrome.
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
        try { if ((Get-SgBrowserExtensionFramework (Read-SgNodePackage $ProjectPath)) -eq 'wxt') { return '.output\chrome-mv3-dev' } } catch { }
    }
    return 'dist\chrome'
}

function Get-SgProjectExperience([string]$Kind, [int]$Port = 0, [string]$FlutterDevice = '', [string]$FlutterMode = '', [string]$ProjectPath = '') {
    $portValue = if ($Port -gt 0) { ":$Port" } else { 'pending' }
    $modeSuffix = if ($FlutterMode) { " | $FlutterMode" } else { '' }
    switch ($Kind) {
        'tauri' {
            return [pscustomobject]@{
                Label = 'Tauri desktop app'
                PortLabel = "App / HMR $portValue"
                Artifact = 'native development app'
                StartOutcome = 'Tauri development session with shared Vite frontend'
                StartNextAction = 'Follow the build logs until the native application opens.'
                OpenAction = 'Open the frontend preview on the same development port.'
                OpenNextAction = 'The browser preview and native application share the frontend server.'
            }
        }
        'browser-extension' {
            $unpackedDirectory = Get-SgBrowserExtensionUnpackedDirectory $ProjectPath
            return [pscustomobject]@{
                Label = 'Chrome extension'
                PortLabel = "HMR $portValue"
                Artifact = $unpackedDirectory
                StartOutcome = "Manifest V3 build ready in $unpackedDirectory"
                StartNextAction = 'Next: run s open -ProjectPath <path> to open Chrome extension tools.'
                OpenAction = 'Open chrome://extensions and the unpacked directory.'
                OpenNextAction = "In Chrome, enable Developer mode, choose Load unpacked, and select $unpackedDirectory."
            }
        }
        'obsidian-plugin' {
            return [pscustomobject]@{
                Label = 'Obsidian plugin'
                PortLabel = 'Local vault'
                Artifact = 'main.js + manifest.json'
                StartOutcome = 'Obsidian plugin artifacts ready for local validation'
                StartNextAction = 'Run s obsidian-lab -ProjectPath <path> to validate the plugin in a disposable vault.'
                OpenAction = 'Open the disposable Obsidian plugin lab.'
                OpenNextAction = 'Validate the plugin in the disposable vault; the personal Obsidian profile is not modified.'
            }
        }
        { $_ -in @('flutter','flutter-web') } {
            if ($FlutterDevice -eq 'android') {
                return [pscustomobject]@{
                    Label = 'Flutter Android app'
                    PortLabel = "Live session$modeSuffix"
                    Artifact = 'managed Flutter Android session'
                    StartOutcome = 'Managed Flutter Android session ready'
                    StartNextAction = 'Develop with live logs and reload; use the Dev shortcut to reuse this session.'
                    OpenAction = 'Use the managed Flutter Android device or emulator session.'
                    OpenNextAction = 'Validate the app, then run s stop -ProjectPath <path> when finished.'
                }
            }
            if ($FlutterDevice -eq 'windows') {
                return [pscustomobject]@{
                    Label = 'Flutter Windows app'
                    PortLabel = "Live session$modeSuffix"
                    Artifact = 'managed Flutter Windows session'
                    StartOutcome = 'Managed Flutter Windows session ready'
                    StartNextAction = 'Develop with live logs and reload; use the Dev shortcut to reuse this session.'
                    OpenAction = 'Use the managed Flutter Windows app session.'
                    OpenNextAction = 'Validate the app, then run s stop -ProjectPath <path> when finished.'
                }
            }
            return [pscustomobject]@{
                Label = 'Flutter app'
                PortLabel = "App $portValue$modeSuffix"
                Artifact = 'managed Chrome session'
                StartOutcome = 'Managed Flutter app session ready'
                StartNextAction = 'Next: run s open -ProjectPath <path> to open or focus the managed app session.'
                OpenAction = 'Open or focus the managed Chrome app session.'
                OpenNextAction = 'Validate the app, then run s stop -ProjectPath <path> when finished.'
            }
        }
        default {
            return [pscustomobject]@{
                Label = 'Web project'
                PortLabel = "URL $portValue"
                Artifact = $(if ($Port -gt 0) { "http://127.0.0.1:$Port" } else { 'local URL pending' })
                StartOutcome = $(if ($Port -gt 0) { "Local URL ready at http://127.0.0.1:$Port" } else { 'Local URL pending first start' })
                StartNextAction = 'Next: run s open -ProjectPath <path> to open the managed local URL.'
                OpenAction = 'Open the managed local URL.'
                OpenNextAction = 'Use the local project, then run s stop -ProjectPath <path> when finished.'
            }
        }
    }
}

function Format-SgProjectStatus([object]$Entry) {
    if (-not $Entry) { return 'unknown project' }
    $kind = if ($Entry.PSObject.Properties['kind'] -and $Entry.kind) { [string]$Entry.kind } else { 'unknown' }
    $port = if ($Entry.PSObject.Properties['port']) { [int]$Entry.port } else { 0 }
    $status = if ($Entry.PSObject.Properties['status'] -and $Entry.status) { [string]$Entry.status } else { 'discovered' }
    $flutterDevice = if ($Entry.PSObject.Properties['flutterDevice']) { [string]$Entry.flutterDevice } else { '' }
    $flutterMode = if ($kind -in @('flutter','flutter-web') -and $Entry.PSObject.Properties['flutterMode']) { [string]$Entry.flutterMode } else { '' }
    $projectPath = if ($Entry.PSObject.Properties['path'] -and $Entry.path) { [string]$Entry.path } else { '' }
    $experience = Get-SgProjectExperience $kind $port $flutterDevice $flutterMode $projectPath
    if ($kind -eq 'obsidian-plugin') {
        $surfaceState = if ($Entry.PSObject.Properties['surfaceState'] -and $Entry.surfaceState) { [string]$Entry.surfaceState } else { 'detected' }
        $validationState = if ($Entry.PSObject.Properties['validationState'] -and $Entry.validationState) { [string]$Entry.validationState } else { 'validation-unavailable' }
        return "$status | $($experience.Label) | $surfaceState | $validationState | $($experience.Artifact)"
    }
    $artifact = if ($kind -in @('browser-extension','obsidian-plugin')) { " | $($experience.Artifact)" } else { '' }
    return "$status | $($experience.Label) | $($experience.PortLabel)$artifact"
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

# Log folder per project path: display names such as "site" repeat across monorepos.
function Get-SgProjectLogKey([object]$Entry) {
    $name = [string]$Entry.name
    if ([string]::IsNullOrWhiteSpace($name)) { $name = 'project' }
    $safeName = ($name -replace '[^A-Za-z0-9._-]', '-').Trim('-')
    if (-not $safeName) { $safeName = 'project' }
    $normalizedPath = [IO.Path]::GetFullPath([string]$Entry.path).TrimEnd('\','/').ToLowerInvariant()
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $digest = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($normalizedPath)) } finally { $sha.Dispose() }
    $hash = ([BitConverter]::ToString($digest, 0, 4) -replace '-', '').ToLowerInvariant()
    return "$safeName-$hash"
}

function Get-SgRuntimeSettings([string]$ProjectPath) {
    $defaultFlutterDevice = if (Test-Path -LiteralPath (Join-Path $ProjectPath 'windows') -PathType Container) { 'windows' } else { 'chrome' }
    $settings = [pscustomobject]@{ Port = 0; AutoRepair = $true; FlutterDevice = $defaultFlutterDevice; FlutterDeviceId = $null; FlutterMode = 'debug'; DartDefineFile = $null; ObsidianVault = $null; ObsidianSyncMode = 'copy'; ReadyTimeoutSeconds = 0 }
    $file = Join-Path $ProjectPath '.shipglows.env'
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return $settings }
    foreach ($rawLine in @(Get-Content -LiteralPath $file)) {
        $line = ([string]$rawLine).Trim()
        if (-not $line -or $line.StartsWith('#')) { continue }
        if ($line -match '^SHIPGLOWS_ENV_PORT=(.+)$') {
            $value = $Matches[1].Trim()
            if ($value -notmatch '^\d+$' -or [int]$value -lt 1024 -or [int]$value -gt 65535) { throw "Invalid SHIPGLOWS_ENV_PORT in $file; expected a port between 1024 and 65535." }
            $settings.Port = [int]$value
        } elseif ($line -match '^SHIPGLOWS_READY_TIMEOUT_SECONDS=(.+)$') {
            $value = $Matches[1].Trim()
            if ($value -notmatch '^\d+$' -or [int]$value -lt 30 -or [int]$value -gt 1800) { throw "Invalid SHIPGLOWS_READY_TIMEOUT_SECONDS in $file; expected seconds between 30 and 1800." }
            $settings.ReadyTimeoutSeconds = [int]$value
        } elseif ($line -match '^SHIPGLOWS_AUTO_REPAIR=(true|false)$') {
            $settings.AutoRepair = $Matches[1] -eq 'true'
        } elseif ($line -match '^SHIPGLOWS_FLUTTER_DEVICE=(windows|android|chrome|web-server)$') {
            $settings.FlutterDevice = $Matches[1]
        } elseif ($line -match '^SHIPGLOWS_FLUTTER_DEVICE_ID=([A-Za-z0-9._:-]{1,128})$') {
            $settings.FlutterDeviceId = $Matches[1]
        } elseif ($line -match '^SHIPGLOWS_FLUTTER_MODE=(debug|profile)$') {
            $settings.FlutterMode = $Matches[1]
        } elseif ($line -match '^SHIPGLOWS_DART_DEFINE_FILE=(.+)$') {
            # A declared recipe replaces legacy per-checkout generated config.
            if (Test-Path -LiteralPath (Join-Path $ProjectPath '.shipglows.flutter.json') -PathType Leaf) { continue }
            $relative = $Matches[1].Trim()
            if ([IO.Path]::IsPathRooted($relative)) { throw "SHIPGLOWS_DART_DEFINE_FILE in $file must be relative to the project." }
            $resolved = [IO.Path]::GetFullPath((Join-Path $ProjectPath $relative))
            $root = [IO.Path]::GetFullPath($ProjectPath).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
            if (-not $resolved.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolved -PathType Leaf)) { throw "SHIPGLOWS_DART_DEFINE_FILE in $file must resolve to an existing file inside the project." }
            $settings.DartDefineFile = $resolved
        } elseif ($line -match '^SHIPGLOWS_OBSIDIAN_VAULT=(.+)$') {
            $declared = [Environment]::ExpandEnvironmentVariables($Matches[1].Trim())
            if (-not [IO.Path]::IsPathRooted($declared)) { throw "SHIPGLOWS_OBSIDIAN_VAULT in $file must be an absolute path to one explicit vault." }
            $settings.ObsidianVault = [IO.Path]::GetFullPath($declared).TrimEnd('\','/')
        } elseif ($line -eq 'SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy') {
            $settings.ObsidianSyncMode = 'copy'
        } else {
            throw "Unsupported line in ${file}: $line. Allowed keys: SHIPGLOWS_ENV_PORT, SHIPGLOWS_READY_TIMEOUT_SECONDS, SHIPGLOWS_AUTO_REPAIR, SHIPGLOWS_FLUTTER_DEVICE, SHIPGLOWS_FLUTTER_DEVICE_ID, SHIPGLOWS_FLUTTER_MODE, SHIPGLOWS_DART_DEFINE_FILE, SHIPGLOWS_OBSIDIAN_VAULT, and SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy."
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

function Reserve-SgProjectPort([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0, [bool]$Explicit = $false, [switch]$NoPort, [switch]$PreservePort) {
    if ($RequestedPort -ne 0 -and ($RequestedPort -lt 1024 -or $RequestedPort -gt 65535)) { throw 'Requested port must be 0 or between 1024 and 65535.' }
    $token = [guid]::NewGuid().ToString('N')
    if ($NoPort) {
        $result = Invoke-SgRegistryMutation $Config {
            param($data)
            $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath } | Select-Object -First 1
            if (-not $entry) { throw "Project is not registered: $ProjectPath" }
            # Native Flutter targets listen on no HTTP port but keep the surface port for a later Web launch.
            if (-not $PreservePort) { $entry.port = 0 }
            $entry.status = 'reserved'
            $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $token -Force
            $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue ([DateTime]::UtcNow.ToString('o')) -Force
        }
        $reservedEntry = $result.projects | Where-Object { $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $token } | Select-Object -First 1
        if (-not $reservedEntry) { throw "No-port reservation could not be persisted for: $ProjectPath" }
        return [pscustomobject]@{ Port=[int]$reservedEntry.port; Token=$token }
    }
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
        if (-not $entry -and $EntryData -and $EntryData.PSObject.Properties['pid'] -and [int]$EntryData.pid -gt 0 -and $EntryData.PSObject.Properties['startTimeUtc'] -and $EntryData.startTimeUtc) {
            # A concurrent reconciliation may clear the token of a live launch; the exact recorded process identity still proves ownership.
            $launchTicks = ConvertTo-SgUtcStartTicks $EntryData.startTimeUtc
            $entry = $data.projects | Where-Object {
                $sameProcess = $false
                if ($_.path -eq $ProjectPath -and [int]$_.pid -eq [int]$EntryData.pid -and $_.PSObject.Properties['startTimeUtc'] -and $_.startTimeUtc) {
                    try { $sameProcess = (ConvertTo-SgUtcStartTicks $_.startTimeUtc) -eq $launchTicks } catch { $sameProcess = $false }
                }
                $sameProcess
            } | Select-Object -First 1
        }
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
        $entry | Add-Member -NotePropertyName pid -NotePropertyValue 0 -Force
        $entry | Add-Member -NotePropertyName startTimeUtc -NotePropertyValue $null -Force
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

function Get-SgProcessSnapshotMap([int[]]$Pids, [int[]]$CommandLinePids) {
    $result = @{}
    $ids = @($Pids | Where-Object { $_ -gt 0 } | Sort-Object -Unique)
    if ($ids.Count -eq 0) { return $result }
    $processById = @{}
    foreach ($process in @(Get-Process -Id $ids -ErrorAction SilentlyContinue)) { $processById[[int]$process.Id] = $process }
    if ($processById.Count -eq 0) { return $result }
    # Existing callers request full snapshots; reconciliation supplies only the
    # PIDs whose recorded signatures actually require a command line.
    $commandIds = if ($PSBoundParameters.ContainsKey('CommandLinePids')) { @($CommandLinePids) } else { @($processById.Keys) }
    $nativePaths = @{}
    $queryIds = @()
    foreach ($id in @($processById.Keys)) {
        $path = $null
        try { $path = $processById[$id].Path } catch { }
        $nativePaths[$id] = $path
        if (-not $path -or $id -in $commandIds) { $queryIds += $id }
    }
    $cimById = @{}
    if ($queryIds.Count -gt 0) {
        $filter = (@($queryIds | ForEach-Object { "ProcessId = $_" }) -join ' OR ')
        foreach ($cim in @(Get-CimInstance Win32_Process -Filter $filter -Property ProcessId,ExecutablePath,CommandLine -ErrorAction SilentlyContinue)) { $cimById[[int]$cim.ProcessId] = $cim }
    }
    foreach ($id in @($processById.Keys)) {
        $process = $processById[$id]
        $cim = if ($cimById.ContainsKey($id)) { $cimById[$id] } else { $null }
        $start = $null
        try { $start = $process.StartTime.ToUniversalTime().ToString('o') } catch { }
        $result[$id] = [pscustomobject]@{
            Pid = $id
            StartTimeUtc = $start
            ExecutablePath = if ($nativePaths[$id]) { $nativePaths[$id] } elseif ($cim) { $cim.ExecutablePath } else { $null }
            CommandLine = if ($cim) { $cim.CommandLine } else { $null }
        }
    }
    return $result
}

function ConvertTo-SgUtcStartTicks([object]$Value) {
    if ($null -eq $Value) { throw 'Process start time is missing.' }
    if ($Value -is [datetime]) { return ([datetime]$Value).ToUniversalTime().Ticks }
    $parsed = [DateTimeOffset]::MinValue
    if (-not [DateTimeOffset]::TryParse([string]$Value, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind, [ref]$parsed)) {
        throw 'Process start time is invalid.'
    }
    return $parsed.UtcDateTime.Ticks
}

function Test-SgProcessIdentity([object]$Entry, [hashtable]$SnapshotByPid = $null) {
    $pidValue = [int]$Entry.pid
    $current = if ($null -ne $SnapshotByPid) { if ($SnapshotByPid.ContainsKey($pidValue)) { $SnapshotByPid[$pidValue] } else { $null } } else { Get-SgProcessSnapshot $pidValue }
    if (-not $current) { return $false }
    if ($Entry.startTimeUtc) {
        try {
            if ((ConvertTo-SgUtcStartTicks $current.StartTimeUtc) -ne (ConvertTo-SgUtcStartTicks $Entry.startTimeUtc)) { return $false }
        } catch { return $false }
    }
    if ($Entry.executablePath -and (-not $current.ExecutablePath -or [IO.Path]::GetFullPath($Entry.executablePath) -ne [IO.Path]::GetFullPath($current.ExecutablePath))) { return $false }
    if ($Entry.commandSignature -and (-not $current.CommandLine -or $current.CommandLine -notlike "*$($Entry.commandSignature)*")) { return $false }
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

function Get-SgGitHubRepositoryIndexPath([object]$Config) {
    $runtimeDirectory = if ($Config.PSObject.Properties['RuntimeDirectory'] -and $Config.RuntimeDirectory) {
        [IO.Path]::GetFullPath([string]$Config.RuntimeDirectory)
    } else {
        Split-Path -Parent (Get-SgProjectIndexPath $Config)
    }
    return Join-Path $runtimeDirectory 'github-repository-index.json'
}

function Add-SgGitHubRepositoryIndexFileState([System.Collections.Generic.List[object]]$State, [string]$Path) {
    $fullPath = [IO.Path]::GetFullPath($Path)
    $file = Get-Item -LiteralPath $fullPath -Force -ErrorAction SilentlyContinue
    if ($file -and -not $file.PSIsContainer) {
        [void]$State.Add([pscustomobject]@{
            path = $fullPath.ToLowerInvariant()
            exists = $true
            length = [long]$file.Length
            lastWriteUtcTicks = [long]$file.LastWriteTimeUtc.Ticks
        })
    } else {
        [void]$State.Add([pscustomobject]@{ path = $fullPath.ToLowerInvariant(); exists = $false })
    }
}

function Get-SgGitHubRepositoryIndexSignature([string[]]$RepositoryPaths) {
    $state = New-Object 'System.Collections.Generic.List[object]'
    foreach ($repositoryPath in @($RepositoryPaths | Sort-Object -Unique)) {
        $markerPath = Join-Path $repositoryPath '.git'
        $marker = Get-Item -LiteralPath $markerPath -Force -ErrorAction SilentlyContinue
        if (-not $marker) { continue }
        $gitDirectories = New-Object 'System.Collections.Generic.List[string]'
        [void]$state.Add([pscustomobject]@{
            path = [IO.Path]::GetFullPath($markerPath).ToLowerInvariant()
            isDirectory = [bool]$marker.PSIsContainer
            length = if ($marker.PSIsContainer) { 0L } else { [long]$marker.Length }
            lastWriteUtcTicks = [long]$marker.LastWriteTimeUtc.Ticks
        })
        if ($marker.PSIsContainer) {
            [void]$gitDirectories.Add([IO.Path]::GetFullPath($marker.FullName))
        } else {
            $pointer = try { [IO.File]::ReadAllText($marker.FullName).Trim() } catch { '' }
            if ($pointer -match '(?im)^\s*gitdir:\s*(?<path>.+?)\s*$') {
                $gitDirectory = [string]$Matches.path
                if (-not [IO.Path]::IsPathRooted($gitDirectory)) { $gitDirectory = Join-Path $repositoryPath $gitDirectory }
                try { [void]$gitDirectories.Add([IO.Path]::GetFullPath($gitDirectory)) } catch { }
            }
        }
        $commonDirectories = New-Object 'System.Collections.Generic.List[string]'
        foreach ($gitDirectory in $gitDirectories) {
            [void]$commonDirectories.Add($gitDirectory)
            Add-SgGitHubRepositoryIndexFileState $state (Join-Path $gitDirectory 'config')
            Add-SgGitHubRepositoryIndexFileState $state (Join-Path $gitDirectory 'config.worktree')
            $commonDirectoryFile = Join-Path $gitDirectory 'commondir'
            Add-SgGitHubRepositoryIndexFileState $state $commonDirectoryFile
            if (Test-Path -LiteralPath $commonDirectoryFile -PathType Leaf) {
                $commonDirectory = try { [IO.File]::ReadAllText($commonDirectoryFile).Trim() } catch { '' }
                if ($commonDirectory) {
                    if (-not [IO.Path]::IsPathRooted($commonDirectory)) { $commonDirectory = Join-Path $gitDirectory $commonDirectory }
                    try { [void]$commonDirectories.Add([IO.Path]::GetFullPath($commonDirectory)) } catch { }
                }
            }
        }
        foreach ($commonDirectory in @($commonDirectories | Sort-Object -Unique)) {
            Add-SgGitHubRepositoryIndexFileState $state (Join-Path $commonDirectory 'config')
            Add-SgGitHubRepositoryIndexFileState $state (Join-Path $commonDirectory 'config.worktree')
        }
    }
    $serialized = ConvertTo-Json -InputObject @($state.ToArray()) -Depth 5 -Compress
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($serialized))).Replace('-','').ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

function Get-SgGitHubWorkspaceRepositoryList([string]$Workspace) {
    # Cheap fingerprint of the workspace: top-level directories that carry a
    # .git marker. One directory listing, no Git invocation, no .git metadata read.
    $list = New-Object 'System.Collections.Generic.List[string]'
    try {
        foreach ($directory in @(Get-ChildItem -LiteralPath $Workspace -Directory -Force -ErrorAction Stop)) {
            if ($directory.Name.StartsWith('.') -or ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
            $full = [IO.Path]::GetFullPath($directory.FullName).TrimEnd('\','/')
            if (Test-Path -LiteralPath (Join-Path $full '.git')) { [void]$list.Add($full.ToLowerInvariant()) }
        }
    } catch [UnauthorizedAccessException] { }
    return @($list | Sort-Object -Unique)
}

function Test-SgGitHubRepositoryIdentityIndex([object]$Config, [object]$Index, [string]$Signature, [switch]$AllowCachedSignature, [string[]]$WorkspaceRepositories = @()) {
    if (-not $Index -or $Index.schemaVersion -ne 1 -or (-not $AllowCachedSignature -and [string]$Index.signature -ne $Signature) -or $null -eq $Index.repositories) { return $false }
    if ($AllowCachedSignature) {
        # The cached signature is only trusted while the set of workspace
        # repositories is unchanged: a repository cloned outside this module
        # must disappear from the clone picker in the same process.
        if (-not $Index.PSObject.Properties['workspaceRepositories']) { return $false }
        $indexed = @($Index.workspaceRepositories | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        $current = @($WorkspaceRepositories | Sort-Object -Unique)
        if (($indexed -join "`n") -cne ($current -join "`n")) { return $false }
    }
    $workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
    $indexedWorkspace = try { [IO.Path]::GetFullPath([string]$Index.workspace).TrimEnd('\','/') } catch { return $false }
    if (-not $workspace.Equals($indexedWorkspace, [StringComparison]::OrdinalIgnoreCase)) { return $false }
    try { $generatedAt = ConvertFrom-SgRoundTripTimestamp $Index.generatedAt } catch { return $false }
    $age = ([DateTimeOffset]::UtcNow - $generatedAt).TotalMinutes
    if ($age -lt 0 -or $age -ge $script:ProjectIndexTtlMinutes) { return $false }
    foreach ($identity in @($Index.repositories)) {
        $normalized = ConvertTo-SgGitHubRepositoryIdentity ([string]$identity)
        if (-not $normalized -or -not $normalized.Equals([string]$identity, [StringComparison]::Ordinal)) { return $false }
    }
    return $true
}

function Read-SgGitHubRepositoryIdentityIndex([object]$Config, [string]$Signature, [switch]$AllowCachedSignature, [string[]]$WorkspaceRepositories = @()) {
    $path = Get-SgGitHubRepositoryIndexPath $Config
    $key = "$([IO.Path]::GetFullPath([string]$Config.Workspace).ToLowerInvariant())|$($path.ToLowerInvariant())"
    if (Test-Path -LiteralPath "$path.stale" -PathType Leaf) {
        [void]$script:GitHubRepositoryIdentityMemory.Remove($key)
        return $null
    }
    if ($script:GitHubRepositoryIdentityMemory.ContainsKey($key)) {
        $memoryIndex = $script:GitHubRepositoryIdentityMemory[$key]
        if (Test-SgGitHubRepositoryIdentityIndex $Config $memoryIndex $Signature -AllowCachedSignature:$AllowCachedSignature -WorkspaceRepositories $WorkspaceRepositories) { return $memoryIndex }
        [void]$script:GitHubRepositoryIdentityMemory.Remove($key)
    }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try {
        $index = (Get-Content -LiteralPath $path -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
        if (Test-SgGitHubRepositoryIdentityIndex $Config $index $Signature -AllowCachedSignature:$AllowCachedSignature -WorkspaceRepositories $WorkspaceRepositories) {
            $script:GitHubRepositoryIdentityMemory[$key] = $index
            return $index
        }
    } catch { }
    return $null
}

function Write-SgGitHubRepositoryIdentityIndex([object]$Config, [string]$Signature, [string[]]$Repositories, [string[]]$WorkspaceRepositories = @()) {
    $path = Get-SgGitHubRepositoryIndexPath $Config
    $key = "$([IO.Path]::GetFullPath([string]$Config.Workspace).ToLowerInvariant())|$($path.ToLowerInvariant())"
    $index = [pscustomobject]@{
        schemaVersion = 1
        workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
        generatedAt = [DateTimeOffset]::UtcNow.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
        signature = $Signature
        repositories = @($Repositories | Sort-Object -Unique)
        workspaceRepositories = @($WorkspaceRepositories | Sort-Object -Unique)
    }
    $script:GitHubRepositoryIdentityMemory[$key] = $index
    $temp = "$path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        Ensure-SgDirectory (Split-Path -Parent $path)
        $json = ConvertTo-Json -InputObject $index -Depth 5
        [IO.File]::WriteAllText($temp, $json, [Text.UTF8Encoding]::new($false))
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            try { [IO.File]::Replace($temp, $path, $null) }
            catch { Move-Item -LiteralPath $temp -Destination $path -Force -ErrorAction Stop }
        } else {
            [IO.File]::Move($temp, $path)
        }
        Remove-Item -LiteralPath "$path.stale" -Force -ErrorAction SilentlyContinue
    } catch {
        # The index is an optimization; the freshly computed identities remain usable.
    } finally {
        if (Test-Path -LiteralPath $temp -PathType Leaf) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

function Clear-SgGitHubRepositoryIdentityIndex([object]$Config) {
    $path = Get-SgGitHubRepositoryIndexPath $Config
    $key = "$([IO.Path]::GetFullPath([string]$Config.Workspace).ToLowerInvariant())|$($path.ToLowerInvariant())"
    [void]$script:GitHubRepositoryIdentityMemory.Remove($key)
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        try { [IO.File]::WriteAllText("$path.stale", 'stale', [Text.UTF8Encoding]::new($false)) } catch { }
    }
}

function Get-SgInstalledGitHubRepositoryIdentities([object]$Config, [string]$GitPath = '') {
    $workspace = ConvertTo-SgCanonicalPath ([string]$Config.Workspace)
    if ([string]::IsNullOrWhiteSpace($GitPath)) {
        $gitCommand = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $gitCommand) { return @() }
        $GitPath = [string]$gitCommand.Source
    }
    if (-not (Test-Path -LiteralPath $GitPath -PathType Leaf)) { return @() }

    # Prefer the five-minute identity cache before inspecting every repository's
    # .git metadata. Clone and catalog invalidation still marks it stale, and
    # the cheap workspace repository list guards against clones made outside
    # this module (a manual `git clone` into the workspace).
    $workspaceRepositories = Get-SgGitHubWorkspaceRepositoryList $workspace
    $cachedIndex = Read-SgGitHubRepositoryIdentityIndex $Config '' -AllowCachedSignature -WorkspaceRepositories $workspaceRepositories
    if ($cachedIndex) { return @($cachedIndex.repositories) }

    $candidatePaths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    try {
        foreach ($directory in @(Get-ChildItem -LiteralPath $workspace -Directory -Force -ErrorAction Stop)) {
            if ($directory.Name.StartsWith('.') -or ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
            [void]$candidatePaths.Add([IO.Path]::GetFullPath($directory.FullName).TrimEnd('\','/'))
        }
    } catch [UnauthorizedAccessException] { }
    # The clone picker only needs project paths to exclude already installed
    # repositories; reconciling every managed process here delays the picker.
    foreach ($entry in @(Get-SgProjectCatalog $Config -SkipProcessReconciliation)) {
        $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } elseif ($entry.PSObject.Properties['path']) { [string]$entry.path } else { '' }
        if ($rootPath) {
            try { [void]$candidatePaths.Add([IO.Path]::GetFullPath($rootPath).TrimEnd('\','/')) } catch { }
        }
    }

    $workspacePrefix = $workspace.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    $repositoryPaths = @($candidatePaths | Where-Object {
        ($_.Equals($workspace, [StringComparison]::OrdinalIgnoreCase) -or $_.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) -and
        (Test-Path -LiteralPath (Join-Path $_ '.git'))
    } | Sort-Object -Unique)
    $signature = Get-SgGitHubRepositoryIndexSignature $repositoryPaths
    if ($signature) {
        $cachedIndex = Read-SgGitHubRepositoryIdentityIndex $Config $signature
        if ($cachedIndex) { return @($cachedIndex.repositories) }
    }
    $identities = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        foreach ($candidatePath in $repositoryPaths) {
            $originOutput = @(& $GitPath -C $candidatePath remote get-url origin 2>$null)
            $originExitCode = $LASTEXITCODE
            $origin = $originOutput | Select-Object -First 1
            if ($originExitCode -ne 0) { continue }
            $identity = ConvertTo-SgGitHubRepositoryIdentity ([string]$origin)
            if ($identity) { [void]$identities.Add($identity) }
        }
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    $result = @($identities | Sort-Object)
    if ($signature) { Write-SgGitHubRepositoryIdentityIndex $Config $signature $result -WorkspaceRepositories $workspaceRepositories }
    return $result
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

function ConvertFrom-SgRoundTripTimestamp([object]$Value) {
    if ($Value -is [DateTimeOffset]) { return ([DateTimeOffset]$Value).ToUniversalTime() }
    if ($Value -is [DateTime]) { return ([DateTimeOffset]([DateTime]$Value)).ToUniversalTime() }
    $parsed = [DateTimeOffset]::MinValue
    $text = [Convert]::ToString($Value, [Globalization.CultureInfo]::InvariantCulture)
    if (-not [DateTimeOffset]::TryParseExact($text, 'o', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind, [ref]$parsed)) {
        throw 'Timestamp is not an invariant round-trip value.'
    }
    return $parsed.ToUniversalTime()
}

function Test-SgProjectIndex([object]$Config, [object]$Index, [switch]$AllowStale) {
    if (-not $Index -or $Index.schemaVersion -ne $script:ProjectIndexSchemaVersion -or [string]$Index.scannerVersion -ne $script:ProjectScannerVersion -or $null -eq $Index.projects) { return $false }
    $workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
    $indexedWorkspace = try { [IO.Path]::GetFullPath([string]$Index.workspace).TrimEnd('\','/') } catch { return $false }
    if (-not $workspace.Equals($indexedWorkspace, [StringComparison]::OrdinalIgnoreCase)) { return $false }
    try { $generatedAt = ConvertFrom-SgRoundTripTimestamp $Index.generatedAt } catch { return $false }
    $age = ([DateTimeOffset]::UtcNow - $generatedAt).TotalMinutes
    return $age -ge 0 -and ($AllowStale -or $age -lt $script:ProjectIndexTtlMinutes)
}

function Get-SgProjectIndexStalePath([object]$Config) {
    return "$(Get-SgProjectIndexPath $Config).stale"
}

function Read-SgProjectIndex([object]$Config, [switch]$AllowStale) {
    $path = Get-SgProjectIndexPath $Config
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try {
        $index = (Get-Content -LiteralPath $path -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
        if (Test-SgProjectIndex $Config $index -AllowStale:$AllowStale) { return $index }
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
            generatedAt = [DateTimeOffset]::UtcNow.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
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
        Remove-Item -LiteralPath (Get-SgProjectIndexStalePath $Config) -Force -ErrorAction SilentlyContinue
        return $index
    } finally {
        if ($lock) { $lock.Dispose() }
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

function Clear-SgProjectCatalogCache([object]$Config) {
    Clear-SgGitHubRepositoryIdentityIndex $Config
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
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            [IO.File]::WriteAllText((Get-SgProjectIndexStalePath $Config), 'stale', [Text.UTF8Encoding]::new($false))
        }
    } finally {
        if ($lock) { $lock.Dispose() }
    }
}

function Clear-SgProjectCatalogMemoryCache([object]$Config) {
    [void]$script:ProjectCatalogMemory.Remove((Get-SgProjectCatalogCacheKey $Config))
}

function Test-SgProjectCatalogRefreshRequired([object]$Config, [switch]$DiskOnly) {
    if (Test-Path -LiteralPath (Get-SgProjectIndexStalePath $Config) -PathType Leaf) { return $true }
    $key = Get-SgProjectCatalogCacheKey $Config
    if (-not $DiskOnly -and $script:ProjectCatalogMemory.ContainsKey($key)) {
        return -not (Test-SgProjectIndex $Config $script:ProjectCatalogMemory[$key])
    }
    return -not [bool](Read-SgProjectIndex $Config)
}

function Find-SgWorkspaceProjectCandidates([object]$Config) {
    $workspace = ConvertTo-SgCanonicalPath ([string]$Config.Workspace)
    $manifests = @{'package.json'=$true;'pyproject.toml'=$true;'requirements.txt'=$true;'pubspec.yaml'=$true}
    $pruneDirs = @{'.git'=$true;'node_modules'=$true;'venv'=$true;'.venv'=$true;'__pycache__'=$true;'target'=$true;'.next'=$true;'.nuxt'=$true;'dist'=$true;'.cache'=$true;'.pnpm'=$true;'.yarn'=$true}
    # Keep the workspace depth and hidden-directory boundary identical whether
    # ripgrep or the native walker is available.
    $ripgrep = Get-Command rg -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ripgrep) {
        $arguments = @(
            '--files','--no-messages','--no-ignore','--maxdepth',[string]($script:ProjectCatalogMaxWorkspaceDepth + 1),
            '-g','package.json','-g','pyproject.toml','-g','requirements.txt','-g','pubspec.yaml',
            '-g','!**/.*',
            '-g','!**/.git/**','-g','!**/node_modules/**','-g','!**/venv/**','-g','!**/.venv/**',
            '-g','!**/__pycache__/**','-g','!**/target/**','-g','!**/.next/**','-g','!**/.nuxt/**',
            '-g','!**/dist/**','-g','!**/.cache/**','-g','!**/.pnpm/**','-g','!**/.yarn/**',
            $workspace
        )
        $manifestPaths = @(& $ripgrep.Source @arguments)
        if ($LASTEXITCODE -notin @(0,1)) { throw "Project discovery failed with ripgrep exit code $LASTEXITCODE." }
        $seen = @{}
        $projects = New-Object 'System.Collections.Generic.List[object]'
        foreach ($manifestPath in $manifestPaths) {
            $path = ConvertTo-SgCanonicalPath (Split-Path -Parent $manifestPath)
            $relative = $path.Substring($workspace.Length).TrimStart('\','/')
            $segments = @($relative -split '[\\/]' | Where-Object { $_ -and $_ -ne '.' })
            if ($segments.Count -gt $script:ProjectCatalogMaxWorkspaceDepth) { continue }
            $identity = $path.ToLowerInvariant()
            if ($seen.ContainsKey($identity)) { continue }
            $seen[$identity] = $true

            $rootPath = $path
            if ($path.StartsWith($workspace + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
                $path.Equals($workspace, [StringComparison]::OrdinalIgnoreCase)) {
                $cursor = $workspace
                foreach ($segment in $segments) {
                    if ([IO.Directory]::Exists([IO.Path]::Combine($cursor, '.git')) -or
                        ($manifests.Keys | Where-Object { [IO.File]::Exists([IO.Path]::Combine($cursor, $_)) } | Select-Object -First 1)) {
                        $rootPath = $cursor
                        break
                    }
                    $cursor = [IO.Path]::Combine($cursor, $segment)
                }
            }
            try {
                [void]$projects.Add([pscustomobject]@{
                    name = Get-SgCanonicalSurfaceName $rootPath $path
                    path = $path
                    rootPath = $rootPath
                    launchPath = $path
                    kind = Get-SgProjectKind $path
                    status = 'discovered'
                    port = 0
                    logPath = $null
                    errorLogPath = $null
                })
            } catch {
                if ($_.Exception.Message -notlike 'Unsupported or ambiguous project.*') { throw }
            }
        }
        return @($projects.ToArray() | Sort-Object -Property path)
    }

    $paths = New-Object 'System.Collections.Generic.Queue[string]'
    $roots = New-Object 'System.Collections.Generic.Queue[string]'
    $depths = New-Object 'System.Collections.Generic.Queue[int]'
    $paths.Enqueue($workspace); $roots.Enqueue(''); $depths.Enqueue(0)
    $seen = @{}
    $projects = New-Object 'System.Collections.Generic.List[object]'
    while ($paths.Count -gt 0) {
        $path = $paths.Dequeue()
        $rootPath = $roots.Dequeue()
        $depth = $depths.Dequeue()
        if (-not [IO.Directory]::Exists($path)) { continue }
        $hasManifest = $false
        try {
            foreach ($filePath in [IO.Directory]::EnumerateFiles($path)) {
                if ($manifests.ContainsKey([IO.Path]::GetFileName($filePath))) { $hasManifest = $true; break }
            }
        } catch [UnauthorizedAccessException] {
            continue
        } catch [IO.IOException] {
            continue
        }
        $isRepositoryRoot = [IO.Directory]::Exists([IO.Path]::Combine($path, '.git'))
        if (-not $rootPath -and ($isRepositoryRoot -or $hasManifest)) { $rootPath = $path }

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

        try { $directories = [IO.Directory]::EnumerateDirectories($path) }
        catch [UnauthorizedAccessException] { continue }
        catch [IO.IOException] { continue }
        if ($depth -ge $script:ProjectCatalogMaxWorkspaceDepth) { continue }
        foreach ($directoryPath in $directories) {
            $directoryName = [IO.Path]::GetFileName($directoryPath)
            if ($directoryName.StartsWith('.') -or $pruneDirs.ContainsKey($directoryName)) { continue }
            try { $attributes = [IO.File]::GetAttributes($directoryPath) } catch { continue }
            if ($attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            $paths.Enqueue($directoryPath); $roots.Enqueue($rootPath); $depths.Enqueue($depth + 1)
        }
    }
    return @($projects.ToArray() | Sort-Object -Property path)
}

function Get-SgWorkspaceProjectCandidates([object]$Config, [switch]$ForceRefresh) {
    $key = Get-SgProjectCatalogCacheKey $Config
    if (-not $ForceRefresh -and $script:ProjectCatalogMemory.ContainsKey($key)) {
        $memoryIndex = $script:ProjectCatalogMemory[$key]
        if (Test-SgProjectIndex $Config $memoryIndex -AllowStale) { return @($memoryIndex.projects) }
        [void]$script:ProjectCatalogMemory.Remove($key)
    }
    if (-not $ForceRefresh) {
        $persisted = Read-SgProjectIndex $Config -AllowStale
        if ($persisted) { $script:ProjectCatalogMemory[$key] = $persisted; return @($persisted.projects) }
    }
    $projects = @(Find-SgWorkspaceProjectCandidates $Config)
    $index = Write-SgProjectIndex $Config $projects
    $script:ProjectCatalogMemory[$key] = $index
    return $projects
}

function Get-SgProjectCatalog([object]$Config, [switch]$ForceRefresh, [switch]$SkipProcessReconciliation) {
    $registry = if ($SkipProcessReconciliation) { Read-SgRegistry $Config } else { Reconcile-SgRegistry $Config }
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

function Get-SgProjectCatalogForDisplay([object]$Config) {
    # Discovery is refreshed silently while the menu is open. Display calls use
    # that prepared snapshot and only reconcile the inexpensive process state.
    return @(Get-SgProjectCatalog $Config)
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

function Read-SgNodeRecipe([string]$ProjectPath) {
    # Optional launch recipe for Node surfaces: a Doppler development scope and the
    # public keys it may inject. Secret values never enter launch artifacts.
    $path = Join-Path $ProjectPath '.shipglows.node.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    $item = Get-Item -LiteralPath $path -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Node launch recipe cannot be a reparse point.' }
    if ($item.Length -gt 65536) { throw 'Node launch recipe exceeds 64 KiB.' }
    try { $recipe = [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop } catch { throw 'Node launch recipe is not valid JSON.' }
    $keys = @('doppler','publicEnvironment','schemaVersion')
    if ($null -eq $recipe -or $recipe -is [array] -or (@($recipe.PSObject.Properties.Name | Sort-Object) -join ',') -cne ($keys -join ',')) { throw 'Node launch recipe fields are invalid.' }
    if ($recipe.schemaVersion -cne 'shipglows.node-recipe.v1') { throw 'Unsupported Node launch recipe version.' }
    if ($recipe.publicEnvironment -isnot [array]) { throw 'Node recipe publicEnvironment must be an array.' }
    foreach ($key in $recipe.publicEnvironment) {
        if ($key -isnot [string] -or $key -cnotmatch '^[A-Z][A-Z0-9_]{0,95}$' -or $key -match '(SECRET|PASSWORD|TOKEN|PRIVATE_KEY)') { throw 'Node recipe publicEnvironment contains a non-public or invalid key.' }
    }
    if (@($recipe.publicEnvironment | Select-Object -Unique).Count -ne $recipe.publicEnvironment.Count) { throw 'Node recipe publicEnvironment contains duplicate keys.' }
    $dopplerNone = $recipe.doppler -is [string] -and $recipe.doppler -ceq 'NONE'
    # A production scope is accepted only with an explicit productionPublicOnly: true
    # opt-in; the launcher still injects nothing beyond publicEnvironment.
    $productionScope = -not $dopplerNone -and $null -ne $recipe.doppler -and $recipe.doppler -isnot [string] -and @($recipe.doppler.PSObject.Properties.Name) -ccontains 'productionPublicOnly'
    $dopplerFields = if ($productionScope) { 'config,productionPublicOnly,project' } else { 'config,project' }
    $configPattern = if ($productionScope) { '^(prd|prod|production)(_[a-zA-Z0-9_-]+)?$' } else { '^(dev|stg|staging)(_[a-zA-Z0-9_-]+)?$' }
    if (-not $dopplerNone -and ($null -eq $recipe.doppler -or $recipe.doppler -is [string] -or (@($recipe.doppler.PSObject.Properties.Name | Sort-Object) -join ',') -cne $dopplerFields -or $recipe.doppler.project -isnot [string] -or $recipe.doppler.project -cnotmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]{0,95}$' -or $recipe.doppler.config -isnot [string] -or $recipe.doppler.config -cnotmatch $configPattern -or ($productionScope -and ($recipe.doppler.productionPublicOnly -isnot [bool] -or -not $recipe.doppler.productionPublicOnly)))) { throw 'Node recipe must declare Doppler as NONE or provide an exact development/staging project and config (a production config requires productionPublicOnly: true).' }
    if (-not $dopplerNone -and $recipe.publicEnvironment.Count -eq 0) { throw 'Node recipe with Doppler must list the public keys it injects.' }
    return $recipe
}

function Add-SgNodeRecipeLauncher([string]$ProjectPath, [string]$Command) {
    # Wrap the managed `call "<tool>" ...` command so Doppler injects only the declared keys.
    $recipe = Read-SgNodeRecipe $ProjectPath
    if (-not $recipe -or ($recipe.doppler -is [string] -and $recipe.doppler -ceq 'NONE')) { return $Command }
    $doppler = Get-SgCommandPath @('doppler.exe')
    if (-not $doppler) { throw 'The declared Node recipe requires Doppler. No unauthenticated fallback is allowed.' }
    if (-not $Command.StartsWith('call "')) { throw 'Node launch command cannot be wrapped by its Doppler recipe.' }
    $only = @($recipe.publicEnvironment) -join ','
    return "call `"$doppler`" run --project $($recipe.doppler.project) --config $($recipe.doppler.config) --only-secrets $only --no-fallback --no-check-version --silent -- " + $Command.Substring(5)
}

function Get-SgCommandSignature([string]$ProjectPath, [string]$Kind, [int]$Port) {
    return "ShipGlows:${Kind}:${Port}:$([IO.Path]::GetFullPath($ProjectPath))"
}

function Get-SgPnpmWorkspaceRelativePath([string]$RootPath, [string]$ProjectPath) {
    $projectFull = [IO.Path]::GetFullPath($ProjectPath).TrimEnd('\','/')
    return $projectFull.Substring($RootPath.Length).Trim('\','/').Replace('\','/')
}

function Get-SgPnpmWorkspacePatterns([string]$WorkspaceFile) {
    # Reads the top-level packages: list only; anything else is ignored so the caller can decide how to treat an unparsed file.
    $patterns = New-Object Collections.Generic.List[string]
    $inPackages = $false
    foreach ($line in [IO.File]::ReadAllLines($WorkspaceFile)) {
        if ($line -match '^\s*(#|$)') { continue }
        if ($line -match '^packages\s*:\s*(#.*)?$') { $inPackages = $true; continue }
        if ($line -match '^[^\s-]') { $inPackages = $false; continue }
        if ($inPackages -and $line -match '^\s*-\s*(?:"([^"]+)"|''([^'']+)''|([^\s#''"]+))\s*(?:#.*)?$') {
            $value = if ($Matches[1]) { $Matches[1] } elseif ($Matches[2]) { $Matches[2] } else { $Matches[3] }
            $negate = $value.StartsWith('!')
            $body = $value.TrimStart('!').Replace('\','/')
            while ($body.StartsWith('./')) { $body = $body.Substring(2) }
            $patterns.Add(($(if ($negate) { '!' } else { '' }) + $body.TrimEnd('/')))
        }
    }
    return @($patterns)
}

function Test-SgPnpmWorkspaceGlob([string]$Pattern, [string]$RelativePath) {
    # Supports the pnpm subset used for workspace packages: "*" (one segment), "**" (any depth) and literal segments.
    $regex = '(?i)^'
    $index = 0
    while ($index -lt $Pattern.Length) {
        $rest = $Pattern.Substring($index)
        if ($rest.StartsWith('**/')) { $regex += '(?:.*/)?'; $index += 3; continue }
        if ($rest.StartsWith('**')) { $regex += '.*'; $index += 2; continue }
        if ($Pattern[$index] -eq '*') { $regex += '[^/]*'; $index++; continue }
        $regex += [regex]::Escape([string]$Pattern[$index])
        $index++
    }
    return [regex]::IsMatch($RelativePath, $regex + '$')
}

function Get-SgNodePackageWorkspacePatterns([string]$RootPath) {
    # npm and yarn declare workspaces in package.json as an array or as { packages: [...] }; a leading '!' excludes, as in pnpm.
    $patterns = New-Object Collections.Generic.List[string]
    $package = Read-SgNodePackage $RootPath
    if (-not $package -or -not $package.PSObject.Properties['workspaces'] -or -not $package.workspaces) { return @() }
    $value = $package.workspaces
    $entries = if ($value.PSObject.Properties['packages']) { @($value.packages) } else { @($value) }
    foreach ($entry in $entries) {
        $text = ([string]$entry).Trim()
        $body = $text.TrimStart('!').Replace('\','/')
        while ($body.StartsWith('./')) { $body = $body.Substring(2) }
        $body = $body.TrimEnd('/')
        if ($body) { $patterns.Add($(if ($text.StartsWith('!')) { '!' } else { '' }) + $body) }
    }
    return @($patterns)
}

function Test-SgPnpmWorkspaceMembership([string]$RootPath, [string]$ProjectPath) {
    # A pnpm root needs both its lock and its workspace file; an npm or yarn root is any package.json that declares workspaces.
    $pnpmRoot = (Test-Path -LiteralPath (Join-Path $RootPath 'pnpm-lock.yaml') -PathType Leaf) -and (Test-Path -LiteralPath (Join-Path $RootPath 'pnpm-workspace.yaml') -PathType Leaf)
    $packagePatterns = @(Get-SgNodePackageWorkspacePatterns $RootPath)
    if (-not $pnpmRoot -and $packagePatterns.Count -eq 0) { return $false }
    $relative = Get-SgPnpmWorkspaceRelativePath $RootPath $ProjectPath
    if (-not $relative) { return $false }
    $patterns = New-Object Collections.Generic.List[string]
    if ($pnpmRoot) { $patterns.AddRange([string[]]@(Get-SgPnpmWorkspacePatterns (Join-Path $RootPath 'pnpm-workspace.yaml'))) }
    $patterns.AddRange([string[]]$packagePatterns)
    # When the packages list cannot be read, a project inside a root with a pnpm lock is accepted.
    if ($patterns.Count -eq 0) { return $pnpmRoot }
    $included = $false
    foreach ($pattern in $patterns) {
        if ($pattern.StartsWith('!')) {
            if (Test-SgPnpmWorkspaceGlob $pattern.Substring(1) $relative) { return $false }
        } elseif (Test-SgPnpmWorkspaceGlob $pattern $relative) { $included = $true }
    }
    return $included
}

function Get-SgPnpmWorkspaceRoot([string]$ProjectPath) {
    $directory = [IO.Path]::GetFullPath($ProjectPath).TrimEnd('\','/')
    # A repository boundary ends the search so a project never adopts a workspace from outside its repo.
    if (Test-Path -LiteralPath (Join-Path $directory '.git')) { return $null }
    for ($level = 1; $level -le 5; $level++) {
        $parent = [IO.Path]::GetDirectoryName($directory)
        if (-not $parent -or $parent -eq $directory) { return $null }
        $directory = $parent
        if (Test-SgPnpmWorkspaceMembership $directory $ProjectPath) { return $directory }
        if (Test-Path -LiteralPath (Join-Path $directory '.git')) { return $null }
    }
    return $null
}

function Get-SgNodeDependencyWorkspace([string]$ProjectPath) {
    # Only a project without its own pnpm or npm lock is installed from a surrounding pnpm workspace.
    if (Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml') -PathType Leaf) { return $null }
    if ((Test-Path -LiteralPath (Join-Path $ProjectPath 'package-lock.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $ProjectPath 'npm-shrinkwrap.json') -PathType Leaf)) { return $null }
    return Get-SgPnpmWorkspaceRoot $ProjectPath
}

function Get-SgDependencyInputs([string]$ProjectPath, [string]$Kind) {
    $names = if ($Kind -in @('astro','vite','browser-extension','tauri')) {
        @('package.json','pnpm-lock.yaml','package-lock.json','npm-shrinkwrap.json')
    } elseif ($Kind -eq 'python') {
        @('pyproject.toml','uv.lock','requirements.txt')
    } else {
        @('pubspec.yaml','pubspec.lock')
    }
    $inputs = @($names | ForEach-Object { Join-Path $ProjectPath $_ } | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    if ($Kind -in @('astro','vite','browser-extension','tauri')) {
        $workspaceRoot = Get-SgNodeDependencyWorkspace $ProjectPath
        if ($workspaceRoot) {
            foreach ($name in @('package.json','pnpm-lock.yaml','pnpm-workspace.yaml','package-lock.json','npm-shrinkwrap.json')) {
                $path = Join-Path $workspaceRoot $name
                if (Test-Path -LiteralPath $path -PathType Leaf) { $inputs += $path }
            }
        }
    }
    return @($inputs)
}

function New-SgDependencyPlan([string]$ProjectPath, [string]$Kind) {
    if ($Kind -in @('astro','vite','browser-extension','tauri')) {
        $workspaceRoot = Get-SgNodeDependencyWorkspace $ProjectPath
        if ($workspaceRoot) {
            $packageManager=Get-SgNodePackageManager $ProjectPath $workspaceRoot
            if ($packageManager.Name -eq 'npm') {
                # npm and yarn workspaces install every member from the root lockfile; there is no per-member filter.
                $rootNpmLock=(Test-Path -LiteralPath (Join-Path $workspaceRoot 'package-lock.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $workspaceRoot 'npm-shrinkwrap.json') -PathType Leaf)
                [string[]]$npmArguments=if($rootNpmLock){@('ci')}else{@('install')}
                return [pscustomobject]@{Manager=$packageManager.Manager;Arguments=$npmArguments;BootstrapArguments=@();ArtifactStrategy="node-$Kind-npm-workspace";SuppressNpmLock=(-not$rootNpmLock);WorkingDirectory=$workspaceRoot}
            }
            $relative=Get-SgPnpmWorkspaceRelativePath $workspaceRoot $ProjectPath
            [string[]]$arguments=@($packageManager.PrefixArguments)+@('install','--frozen-lockfile','--filter',"./$relative")
            $managerLabel=if($packageManager.Pinned){'corepack-pnpm'}else{$packageManager.Name}
            return [pscustomobject]@{Manager=$packageManager.Manager;Arguments=$arguments;BootstrapArguments=@();ArtifactStrategy="node-$Kind-$managerLabel-workspace";SuppressNpmLock=$false;WorkingDirectory=$workspaceRoot}
        }
        $pnpmLock=Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml') -PathType Leaf
        $npmLock=(Test-Path -LiteralPath (Join-Path $ProjectPath 'package-lock.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $ProjectPath 'npm-shrinkwrap.json') -PathType Leaf)
        $packageManager=Get-SgNodePackageManager $ProjectPath
        [string[]]$arguments=if($pnpmLock){@($packageManager.PrefixArguments)+@('install','--frozen-lockfile')}elseif($npmLock){@('ci')}else{@('install')}
        $managerLabel=if($packageManager.Pinned){'corepack-pnpm'}else{$packageManager.Name}
        return [pscustomobject]@{Manager=$packageManager.Manager;Arguments=$arguments;BootstrapArguments=@();ArtifactStrategy="node-$Kind-$managerLabel";SuppressNpmLock=(-not$pnpmLock-and-not$npmLock);WorkingDirectory=$ProjectPath}
    }
    if($Kind-eq'python'){
        $manager=Get-SgCommandPath @('uv.exe','uv.cmd','uv');if(-not$manager){throw 'uv is required for Python projects. Install uv, then retry.'}
        $venv=Join-Path $ProjectPath '.venv';$python=Join-Path $venv 'Scripts\python.exe'
        if(Test-Path -LiteralPath (Join-Path $ProjectPath 'uv.lock') -PathType Leaf){$arguments=@('sync','--locked');$bootstrap=@();$artifact='python-uv-lock'}
        elseif(Test-Path -LiteralPath (Join-Path $ProjectPath 'requirements.txt') -PathType Leaf){$arguments=@('pip','install','--python',$python,'-r',(Join-Path $ProjectPath 'requirements.txt'));$bootstrap=@('venv',$venv);$artifact='python-requirements-venv'}
        else{throw 'Python project requires uv.lock or requirements.txt in V1.'}
        return [pscustomobject]@{Manager=[IO.Path]::GetFullPath($manager);Arguments=[string[]]$arguments;BootstrapArguments=[string[]]$bootstrap;ArtifactStrategy=$artifact;SuppressNpmLock=$false;WorkingDirectory=$ProjectPath}
    }
    $manager=Get-SgFlutterCommandPath;if(-not$manager){throw 'Flutter SDK is not available on PATH.'}
    return [pscustomobject]@{Manager=[IO.Path]::GetFullPath($manager);Arguments=[string[]]@('pub','get');BootstrapArguments=@();ArtifactStrategy='flutter-package-config';SuppressNpmLock=$false;WorkingDirectory=$ProjectPath}
}

function Get-SgDependencyDigest([string]$ProjectPath, [string]$Kind, [object]$Plan) {
    $inputs = @(Get-SgDependencyInputs $ProjectPath $Kind)
    if ($inputs.Count -eq 0) { throw "No dependency manifest found for $Kind." }
    $projectBase = $ProjectPath.TrimEnd('\','/')
    $builder = New-Object Text.StringBuilder
    [void]$builder.AppendLine('schemaVersion=2')
    [void]$builder.AppendLine("kind=$Kind")
    [void]$builder.AppendLine("manager=$([string]$Plan.Manager)")
    [void]$builder.AppendLine("arguments=$(@($Plan.Arguments)|ConvertTo-Json -Compress)")
    [void]$builder.AppendLine("bootstrapArguments=$(@($Plan.BootstrapArguments)|ConvertTo-Json -Compress)")
    [void]$builder.AppendLine("artifactStrategy=$([string]$Plan.ArtifactStrategy)")
    $workingDirectory = if ($Plan.PSObject.Properties['WorkingDirectory']) { [string]$Plan.WorkingDirectory } else { '' }
    if ($workingDirectory -and $workingDirectory.TrimEnd('\','/') -ne $projectBase) { [void]$builder.AppendLine("workingDirectory=$($workingDirectory.TrimEnd('\','/').ToLowerInvariant())") }
    foreach ($path in @($inputs | Sort-Object)) {
        # Workspace-root inputs live outside the project; label them by their own path so they cannot collide with project files.
        $relative = if ($path.StartsWith("$projectBase\", [StringComparison]::OrdinalIgnoreCase)) { $path.Substring($projectBase.Length).TrimStart('\','/').ToLowerInvariant() } else { 'workspace-root/' + (Split-Path -Leaf $path).ToLowerInvariant() }
        $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256 -ErrorAction Stop).Hash.ToLowerInvariant()
        [void]$builder.AppendLine("$relative=$hash")
    }
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($builder.ToString())))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Test-SgDependencyArtifacts([string]$ProjectPath, [string]$Kind) {
    if ($Kind -in @('astro','vite','browser-extension','tauri')) {
        # Workspace members may own no node_modules; an npm workspace hoists every package to the root, and a pnpm workspace root holds .modules.yaml.
        $nodeModules = Join-Path $ProjectPath 'node_modules'
        $workspaceRoot=Get-SgNodeDependencyWorkspace $ProjectPath
        $installModules=if($workspaceRoot){Join-Path $workspaceRoot 'node_modules'}else{$nodeModules}
        if (-not (Test-Path -LiteralPath $installModules -PathType Container)) { return $false }
        # pnpm workspaces write .modules.yaml to the root node_modules; the project keeps its own symlinked node_modules.
        if($workspaceRoot -and -not (Test-Path -LiteralPath (Join-Path $workspaceRoot 'pnpm-lock.yaml') -PathType Leaf)){$managerArtifact=Test-Path -LiteralPath (Join-Path $installModules '.package-lock.json') -PathType Leaf}
        elseif($workspaceRoot){$managerArtifact=(Test-Path -LiteralPath (Join-Path $installModules '.modules.yaml') -PathType Leaf)-or(Test-Path -LiteralPath (Join-Path $nodeModules '.modules.yaml') -PathType Leaf)}
        elseif(Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml') -PathType Leaf){$managerArtifact=Test-Path -LiteralPath (Join-Path $nodeModules '.modules.yaml') -PathType Leaf}
        else{$managerArtifact=Test-Path -LiteralPath (Join-Path $nodeModules '.package-lock.json') -PathType Leaf}
        $frameworkExists={ param([string]$Relative) (Test-Path -LiteralPath (Join-Path $nodeModules $Relative) -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $installModules $Relative) -PathType Leaf) }
        if($Kind-eq'browser-extension'){
            # WXT projects install wxt; only crxjs projects carry @crxjs/vite-plugin.
            $frameworkPackage=if((Get-SgBrowserExtensionFramework (Read-SgNodePackage $ProjectPath))-eq'wxt'){'wxt'}else{'@crxjs\vite-plugin'}
            $frameworkArtifact=& $frameworkExists (Join-Path $frameworkPackage 'package.json')
        }elseif($Kind-eq'tauri'){$frameworkArtifact=& $frameworkExists '@tauri-apps\cli\package.json'}else{$frameworkArtifact=& $frameworkExists (Join-Path $Kind 'package.json')}
        return $managerArtifact -and $frameworkArtifact
    }
    if ($Kind -eq 'python') { return Test-Path -LiteralPath (Join-Path $ProjectPath '.venv\Scripts\python.exe') -PathType Leaf }
    return Test-Path -LiteralPath (Join-Path $ProjectPath '.dart_tool\package_config.json') -PathType Leaf
}

function Get-SgDependencyStatePath([object]$Config, [string]$ProjectPath) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $identity = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(([IO.Path]::GetFullPath($ProjectPath).ToLowerInvariant()))))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
    return Join-Path (Join-Path ([IO.Path]::GetFullPath([string]$Config.RuntimeDirectory)) 'dependency-state') "$identity.json"
}

function Test-SgDependencyState([string]$StatePath, [string]$Digest, [string]$ProjectPath, [string]$Kind) {
    if (-not (Test-SgDependencyArtifacts $ProjectPath $Kind) -or -not (Test-Path -LiteralPath $StatePath -PathType Leaf)) { return $false }
    try {
        $state = Get-Content -LiteralPath $StatePath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        return [int]$state.schemaVersion -eq 2 -and [string]$state.digest -ceq $Digest -and [string]$state.kind -ceq $Kind -and [string]$state.projectPath -ceq ([IO.Path]::GetFullPath($ProjectPath))
    } catch { return $false }
}

function Write-SgDependencyState([string]$StatePath, [string]$Digest, [string]$ProjectPath, [string]$Kind) {
    $temp = "$StatePath.$([guid]::NewGuid().ToString('N')).tmp"
    $state = [ordered]@{ schemaVersion=2; projectPath=[IO.Path]::GetFullPath($ProjectPath); kind=$Kind; digest=$Digest; completedAt=[DateTimeOffset]::UtcNow.ToString('o',[Globalization.CultureInfo]::InvariantCulture) }
    try {
        [IO.File]::WriteAllText($temp, ($state | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $StatePath -PathType Leaf) {
            $backup = "$StatePath.bak"
            try { [IO.File]::Replace($temp, $StatePath, $backup) } finally { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
        } else { Move-Item -LiteralPath $temp -Destination $StatePath -Force }
    } finally { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
}

function Write-SgDependencyLogRecord([IO.TextWriter]$Writer, [object]$Record) {
    $Writer.WriteLine([string]$Record)
    Write-Output $Record
}

# pnpm refuses to reuse a node_modules created by another pnpm version or
# layout setting (for example a global pnpm versus the corepack-pinned one).
# Name that case and its remedy instead of a bare failure; deleting
# node_modules stays the operator's decision.
$script:SgPnpmLayoutMismatchCodes = @('ERR_PNPM_VIRTUAL_STORE_DIR_MAX_LENGTH_DIFF','ERR_PNPM_UNEXPECTED_STORE','ERR_PNPM_UNEXPECTED_VIRTUAL_STORE')

function Get-SgDependencyFailureMessage([string]$Kind, [string]$WorkingDirectory, [string]$LogPath, [string[]]$Output) {
    $code = $script:SgPnpmLayoutMismatchCodes | Where-Object { $mismatch = $_; @($Output | Where-Object { $_ -like "*$mismatch*" }).Count -gt 0 } | Select-Object -First 1
    if (-not $code) { return "Dependency setup failed for $Kind. See $LogPath." }
    $nodeModules = Join-Path $WorkingDirectory 'node_modules'
    return "Dependency setup failed for ${Kind}: $nodeModules was created by a different pnpm version or configuration ($code). Delete that node_modules directory, then retry. See $LogPath."
}

function Invoke-SgDependencySetup([object]$Config, [string]$ProjectPath, [string]$Kind, [string]$LogPath) {
    $statePath = Get-SgDependencyStatePath $Config $ProjectPath
    Ensure-SgDirectory (Split-Path -Parent $statePath)
    $lock = $null
    $logWriter = $null
    $suppressNpmLock = $false
    try {
        $deadline = (Get-Date).AddSeconds(30)
        do {
            try { $lock = [IO.File]::Open("$statePath.lock", [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
            catch [IO.IOException] { if ((Get-Date) -ge $deadline) { throw 'Dependency setup lock timed out.' }; Start-Sleep -Milliseconds 50 }
        } while (-not $lock)
        $plan = New-SgDependencyPlan $ProjectPath $Kind
        $digest = Get-SgDependencyDigest $ProjectPath $Kind $plan
        if (Test-SgDependencyState $statePath $digest $ProjectPath $Kind) { Write-SgInfo "Dependencies unchanged: $ProjectPath"; return $false }
        # From this point onward the previous success record no longer
        # describes a safely reusable installation. Keep failures fail-closed.
        Remove-Item -LiteralPath $statePath -Force -ErrorAction SilentlyContinue
        Ensure-SgDirectory (Split-Path -Parent $LogPath)
        # setup.log describes the current dependency attempt. Start it with one
        # deterministic encoding instead of appending PS 5.1 UTF-16 to history.
        $logWriter = New-Object IO.StreamWriter($LogPath, $false, (New-Object Text.UTF8Encoding($false)))
        $logWriter.AutoFlush = $true
        $pm=[string]$plan.Manager
        [string[]]$setupArguments=@($plan.Arguments)
        $suppressNpmLock=[bool]$plan.SuppressNpmLock
        if(@($plan.BootstrapArguments).Count-gt0-and-not(Test-Path -LiteralPath (Join-Path $ProjectPath '.venv\Scripts\python.exe') -PathType Leaf)){
            $previousErrorActionPreference=$ErrorActionPreference
            try{$ErrorActionPreference='Continue';& $pm @($plan.BootstrapArguments) 2>&1|ForEach-Object{Write-SgDependencyLogRecord $logWriter $_};if($LASTEXITCODE-ne0){throw 'uv venv failed.'}}
            finally{$ErrorActionPreference=$previousErrorActionPreference}
        }
        # A pnpm workspace filter is relative to the workspace root, so the install must run there.
        Push-Location ([string]$plan.WorkingDirectory)
        $previousErrorActionPreference = $ErrorActionPreference
        $previousNpmPackageLock = $env:npm_config_package_lock
        try {
            # Package managers may report normal progress on stderr; use their
            # exit code so this is stable with $ErrorActionPreference = 'Stop'.
            $ErrorActionPreference = 'Continue'
            if ($suppressNpmLock) { $env:npm_config_package_lock = 'false' }
            $setupOutput = New-Object Collections.Generic.List[string]
            & $pm @setupArguments 2>&1 | ForEach-Object { $setupOutput.Add([string]$_); Write-SgDependencyLogRecord $logWriter $_ }
            if ($LASTEXITCODE -ne 0) { throw (Get-SgDependencyFailureMessage $Kind ([string]$plan.WorkingDirectory) $LogPath $setupOutput) }
        }
        finally { $env:npm_config_package_lock = $previousNpmPackageLock; $ErrorActionPreference = $previousErrorActionPreference; Pop-Location }
        if (-not (Test-SgDependencyArtifacts $ProjectPath $Kind)) { throw "Dependency setup completed without the expected $Kind artifacts." }
        $completedPlan = New-SgDependencyPlan $ProjectPath $Kind
        $completedDigest = Get-SgDependencyDigest $ProjectPath $Kind $completedPlan
        if ($completedDigest -cne $digest) { throw 'Dependency inputs changed during setup; durable state was not recorded. Retry with stable manifests and lockfiles.' }
        Write-SgDependencyState $statePath $completedDigest $ProjectPath $Kind
        return $true
    } finally { if ($logWriter) { $logWriter.Dispose() }; if ($lock) { $lock.Dispose() } }
}

function Repair-SgStaleAstroDevLock([string]$ProjectPath, [scriptblock]$SnapshotResolver = $null) {
    $lockPath = Join-Path $ProjectPath '.astro\dev.json'
    if (-not (Test-Path -LiteralPath $lockPath -PathType Leaf)) { return $false }
    try {
        $raw = [IO.File]::ReadAllText($lockPath)
        if ($raw.Length -gt 4096) { return $false }
        $lock = $raw | ConvertFrom-Json -ErrorAction Stop
        if (-not $lock.PSObject.Properties['pid'] -or [int]$lock.pid -le 0) { return $false }
        $snapshot = if ($SnapshotResolver) { & $SnapshotResolver ([int]$lock.pid) } else { Get-SgProcessSnapshot ([int]$lock.pid) }
        if (-not $snapshot) { return $false }
        $executable = [IO.Path]::GetFileName([string]$snapshot.ExecutablePath)
        $commandLine = [string]$snapshot.CommandLine
        $isAstroNode = $executable -ieq 'node.exe' -and $commandLine -match '(?i)(?:^|[\\/])astro(?:[\\/]|[.](?:m?js)\b)'
        if ($isAstroNode) { return $false }
        [IO.File]::Delete($lockPath)
        Write-SgInfo "Removed stale Astro lock whose PID now belongs to another process: $($lock.pid)"
        return $true
    } catch {
        Write-SgWarn "Astro lock inspection was inconclusive: $($_.Exception.Message)"
        return $false
    }
}

function Rotate-SgLogFile([string]$Path, [long]$MaxBytes = 5242880) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    $file = Get-Item -LiteralPath $Path -ErrorAction Stop
    if ($file.Length -le $MaxBytes) { return }
    $rotated = "$Path.previous"
    Move-Item -LiteralPath $Path -Destination $rotated -Force
}

function Get-SgLaunchSpec([string]$ProjectPath, [string]$Kind, [int]$Port, [bool]$FlutterVisible = $false, [string]$FlutterProfilePath = '', [string]$FlutterDevice = 'chrome', [string]$DartDefineFile = '', [string]$FlutterLaunchDirectory = '', [string]$FlutterLaunchIdentity = '', [string]$FlutterMode = 'debug') {
    if ($Kind -eq 'tauri') {
        $tauri = Get-Content -LiteralPath (Join-Path $ProjectPath 'src-tauri\tauri.conf.json') -Raw | ConvertFrom-Json
        $devUrl = [uri]$tauri.build.devUrl
        if ($devUrl.Host -notin @('127.0.0.1','localhost') -or $devUrl.Port -ne $Port) { throw "Tauri devUrl must use the assigned local port $Port." }
        if (-not $tauri.build.beforeDevCommand) { throw 'Tauri must declare beforeDevCommand to own its frontend server.' }
        $manager = Get-SgNodePackageManager $ProjectPath
        $prefix = if (@($manager.PrefixArguments).Count) { ' ' + (@($manager.PrefixArguments) -join ' ') } else { '' }
        $cargo = Get-SgCommandPath @('cargo.exe')
        if (-not $cargo) {
            $candidate = Join-Path $env:USERPROFILE '.cargo\bin\cargo.exe'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $cargo = $candidate }
        }
        if (-not $cargo) { throw 'Tauri requires native cargo.exe; a cargo.cmd wrapper is not sufficient.' }
        $cargoDirectory = Split-Path $cargo -Parent
        $toolchainConfig = Join-Path $env:LOCALAPPDATA 'ShipGlows\Toolchains\tauri-windows\mise.toml'
        $toolchainPrefix = ''
        if ((Test-Path -LiteralPath $toolchainConfig) -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath 'rust-toolchain.toml')) -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath 'rust-toolchain'))) {
            $toolchainText = Get-Content -LiteralPath $toolchainConfig -Raw
            if ($toolchainText -match 'rust\s*=\s*\{\s*version\s*=\s*"([0-9.]+)"') { $toolchainPrefix = "set `"RUSTUP_TOOLCHAIN=$($Matches[1])`" && " }
        }
        $devConfig = Join-Path $ProjectPath 'src-tauri\tauri.dev.conf.json'
        $devConfigArgument = if (Test-Path -LiteralPath $devConfig -PathType Leaf) { ' --config "src-tauri\tauri.dev.conf.json"' } else { '' }
        $command = "set `"PATH=$cargoDirectory;%PATH%`" && ${toolchainPrefix}call `"$($manager.Manager)`"$prefix exec tauri dev$devConfigArgument"
        return [pscustomobject]@{ FilePath=$env:ComSpec; Arguments=@('/d','/s','/c',"`"$command`""); Signature='tauri dev'; Interactive=$false; FlutterSdkRoot=$null }
    }
    $signature = Get-SgCommandSignature $ProjectPath $Kind $Port
    if ($Kind -eq 'obsidian-plugin') {
        $descriptor = Get-SgObsidianPluginDescriptor $ProjectPath
        if (-not $descriptor) { throw 'Obsidian plugin metadata is no longer valid.' }
        if (-not $descriptor.DevelopmentScriptName) {
            $suggestion = if ($descriptor.BuildScriptName) { "The project only declares '$($descriptor.BuildScriptName)'; add or declare a reviewed watch script before using s start." } else { 'Declare a reviewed dev, watch, or start script before using s start.' }
            throw "Obsidian plugin watch workflow unavailable. $suggestion"
        }
        $packageManager = Get-SgNodePackageManager $ProjectPath
        $file = $env:ComSpec
        $prefix = if (@($packageManager.PrefixArguments).Count -gt 0) { ' ' + (@($packageManager.PrefixArguments) -join ' ') } else { '' }
        $command = "call `"$($packageManager.Manager)`"$prefix run $($descriptor.DevelopmentScriptName) & rem $signature"
        $args = @('/d','/s','/c',"`"$command`"")
        return [pscustomobject]@{ FilePath=$file; Arguments=$args; Signature=$signature; Interactive=$false; FlutterSdkRoot=$null }
    }
    if ($Kind -eq 'astro') {
        $pnpm = [bool](Get-SgNodeDependencyWorkspace $ProjectPath) -or [bool](Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml'))
        if ($pnpm) {
            $packageManager = Get-SgCommandPath @('pnpm.cmd','pnpm.exe')
            if (-not $packageManager) { throw 'pnpm is required by pnpm-lock.yaml but is unavailable.' }
            $file = $env:ComSpec
            $command = "call `"$packageManager`" exec astro dev --host 127.0.0.1 --port $Port & rem $signature"
            $command = Add-SgNodeRecipeLauncher $ProjectPath $command
            $args = @('/d','/s','/c',"`"$command`"")
        } else {
            $packageManager = Get-SgCommandPath @('npm.cmd','npm.exe')
            if (-not $packageManager) { throw 'npm is required but is unavailable.' }
            $file = $env:ComSpec
            $command = "call `"$packageManager`" run dev -- --host 127.0.0.1 --port $Port & rem $signature"
            $command = Add-SgNodeRecipeLauncher $ProjectPath $command
            $args = @('/d','/s','/c',"`"$command`"")
        }
    } elseif ($Kind -in @('vite','browser-extension')) {
        $packageManager = Get-SgNodePackageManager $ProjectPath (Get-SgNodeDependencyWorkspace $ProjectPath)
        $file = $env:ComSpec
        $prefix = if (@($packageManager.PrefixArguments).Count -gt 0) { ' ' + (@($packageManager.PrefixArguments) -join ' ') } else { '' }
        if ($Kind -eq 'browser-extension') {
            $extensionPackage = Read-SgNodePackage $ProjectPath
            $extensionFramework = Get-SgBrowserExtensionFramework $extensionPackage
            $developmentScript = if (Get-SgNodeScript $extensionPackage 'dev:chrome') { 'dev:chrome' } elseif ($extensionFramework -eq 'wxt' -and (Get-SgNodeScript $extensionPackage 'dev')) { 'dev' } else { throw 'Browser extension development script is unavailable. Declare a reviewed dev:chrome script, or a WXT dev script.' }
            $optionSeparator = if ($packageManager.Name -eq 'pnpm') { '' } else { ' --' }
            $browserArguments = if ($extensionFramework -eq 'wxt') { ' --browser chrome --mv3' } else { '' }
            $command = "call `"$($packageManager.Manager)`"$prefix run $developmentScript$optionSeparator$browserArguments --host 127.0.0.1 --port $Port & rem $signature"
        } elseif ($packageManager.Name -eq 'pnpm') {
            $command = "call `"$($packageManager.Manager)`"$prefix exec vite --host 127.0.0.1 --port $Port & rem $signature"
        } else {
            $command = "call `"$($packageManager.Manager)`" run dev -- --host 127.0.0.1 --port $Port & rem $signature"
        }
        $command = Add-SgNodeRecipeLauncher $ProjectPath $command
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
        $flutter = Get-SgFlutterCommandPath; if (-not $flutter) { throw 'Flutter SDK is unavailable on PATH and at the ShipGlows-managed location.' }
        $supervisor = Join-Path $PSScriptRoot 'ShipGlows.FlutterSupervisor.ps1'
        if (-not (Test-Path -LiteralPath $supervisor -PathType Leaf)) { throw 'ShipGlows Flutter supervisor is missing.' }
        if ([string]::IsNullOrWhiteSpace($FlutterLaunchDirectory) -or [string]::IsNullOrWhiteSpace($FlutterLaunchIdentity)) { throw 'Managed Flutter launch identity is required.' }
        $file = Resolve-SgPowerShellExecutable
        $args = @('-NoLogo','-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',"`"$supervisor`"",'-LaunchDirectory',"`"$FlutterLaunchDirectory`"",'-ProjectPath',"`"$ProjectPath`"",'-FlutterPath',"`"$flutter`"")
        if ($FlutterDevice -in @('chrome','web-server')) { $args += @('-Port',[string]$Port) }
        if ($FlutterMode -notin @('debug','profile')) { throw 'Managed Flutter sessions support only debug or profile mode; release builds use the artifact publisher.' }
        $args += @('-Device',$FlutterDevice,'-LaunchIdentity',$FlutterLaunchIdentity,'-Mode',$FlutterMode)
        if ($FlutterDevice -eq 'chrome') { $args += @('-ProfilePath',"`"$FlutterProfilePath`""); if ($FlutterVisible) { $args += '-Visible' } }
        if ($DartDefineFile) { $args += @('-DartDefineFile',"`"$DartDefineFile`"") }
        $signature = $FlutterLaunchIdentity
    }
    if (-not $file) { throw "Launch tool missing for $Kind." }
    [pscustomobject]@{ FilePath = $file; Arguments = $args; Signature = $signature; Interactive = $false; FlutterSdkRoot=$(if($Kind-eq'flutter-web'){Split-Path (Split-Path $flutter -Parent) -Parent}else{$null}) }
}

function ConvertTo-SgPowerShellLiteral([string]$Value) {
    return "'$(if($null-eq$Value){''}else{$Value.Replace("'","''")})'"
}

function Resolve-SgPowerShellExecutable([string[]]$KnownCandidates=@()) {
    $candidates=New-Object 'System.Collections.Generic.List[string]'
    if(@($KnownCandidates).Count-gt0){foreach($candidate in @($KnownCandidates)){if($candidate){[void]$candidates.Add([string]$candidate)}}}
    elseif($env:SHIPGLOWS_MANAGED_PWSH){[void]$candidates.Add($env:SHIPGLOWS_MANAGED_PWSH)}
    foreach($candidate in $candidates){
        if([string]::IsNullOrWhiteSpace($candidate)-or-not[IO.Path]::IsPathRooted($candidate)){continue}
        try{$resolved=[IO.Path]::GetFullPath($candidate)}catch{continue}
        if([IO.Path]::GetFileName($resolved)-ne'pwsh.exe'){continue}
        if(-not $env:SHIPGLOWS_MANAGED_PWSH -or $resolved-ne[IO.Path]::GetFullPath($env:SHIPGLOWS_MANAGED_PWSH)){continue}
        if(Test-Path -LiteralPath $resolved -PathType Leaf){return $resolved}
    }
    throw 'The ShipGlows-managed PowerShell runtime could not be resolved for detached process launch.'
}

function Get-SgJobNativeSource {
    return @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class ShipGlowsJobNative {
    [StructLayout(LayoutKind.Sequential)] public struct BasicAccounting { public long TotalUserTime; public long TotalKernelTime; public long ThisPeriodTotalUserTime; public long ThisPeriodTotalKernelTime; public uint TotalPageFaultCount; public uint TotalProcesses; public uint ActiveProcesses; public uint TotalTerminatedProcesses; }
    [StructLayout(LayoutKind.Sequential)] public struct BasicLimits { public long PerProcessUserTimeLimit; public long PerJobUserTimeLimit; public uint LimitFlags; public UIntPtr MinimumWorkingSetSize; public UIntPtr MaximumWorkingSetSize; public uint ActiveProcessLimit; public UIntPtr Affinity; public uint PriorityClass; public uint SchedulingClass; }
    [StructLayout(LayoutKind.Sequential)] public struct IoCounters { public ulong ReadOperationCount; public ulong WriteOperationCount; public ulong OtherOperationCount; public ulong ReadTransferCount; public ulong WriteTransferCount; public ulong OtherTransferCount; }
    [StructLayout(LayoutKind.Sequential)] public struct ExtendedLimits { public BasicLimits BasicLimitInformation; public IoCounters IoInfo; public UIntPtr ProcessMemoryLimit; public UIntPtr JobMemoryLimit; public UIntPtr PeakProcessMemoryUsed; public UIntPtr PeakJobMemoryUsed; }
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateJobObject(IntPtr attributes, string name);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetInformationJobObject(IntPtr job, int infoClass, ref ExtendedLimits info, uint length);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool QueryInformationJobObject(IntPtr job, int infoClass, ref BasicAccounting info, uint length, IntPtr returnLength);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);
    [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr OpenJobObject(uint access, bool inherit, string name);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool TerminateJobObject(IntPtr job, uint exitCode);
    [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr handle);
    public static IntPtr CreateKillOnClose(string name) {
        IntPtr job=CreateJobObject(IntPtr.Zero,name); if(job==IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(),"CreateJobObject failed");
        ExtendedLimits info=new ExtendedLimits(); info.BasicLimitInformation.LimitFlags=0x00002000;
        if(!SetInformationJobObject(job,9,ref info,(uint)Marshal.SizeOf(typeof(ExtendedLimits)))) { int error=Marshal.GetLastWin32Error(); CloseHandle(job); throw new Win32Exception(error,"SetInformationJobObject failed"); }
        return job;
    }
    public static void AssignCurrent(IntPtr job) { if(!AssignProcessToJobObject(job,GetCurrentProcess())) throw new Win32Exception(Marshal.GetLastWin32Error(),"AssignProcessToJobObject failed"); }
    public static uint ActiveProcessCount(IntPtr job) { BasicAccounting info=new BasicAccounting(); if(!QueryInformationJobObject(job,1,ref info,(uint)Marshal.SizeOf(typeof(BasicAccounting)),IntPtr.Zero)) throw new Win32Exception(Marshal.GetLastWin32Error(),"QueryInformationJobObject failed"); return info.ActiveProcesses; }
    public static bool Terminate(string name) { IntPtr job=OpenJobObject(0x0008,false,name); if(job==IntPtr.Zero) return false; try { if(!TerminateJobObject(job,1)) throw new Win32Exception(Marshal.GetLastWin32Error(),"TerminateJobObject failed"); return true; } finally { CloseHandle(job); } }
}
'@
}

function Initialize-SgJobNativeApi {
    if (-not ('ShipGlowsJobNative' -as [type])) { Add-Type -TypeDefinition (Get-SgJobNativeSource) -Language CSharp -ErrorAction Stop }
}

function Stop-SgManagedJob([object]$Entry) {
    if (-not $Entry.PSObject.Properties['jobName'] -or [string]::IsNullOrWhiteSpace([string]$Entry.jobName)) { return $false }
    if ([string]$Entry.jobName -notmatch '^Local\\ShipGlows-[a-f0-9]{32}$') { throw 'Managed job identity is invalid.' }
    Initialize-SgJobNativeApi
    return [ShipGlowsJobNative]::Terminate([string]$Entry.jobName)
}

function Start-SgDetachedProcess([string]$FilePath,[string[]]$ArgumentList,[string]$WorkingDirectory,[string]$RedirectStandardOutput,[string]$RedirectStandardError,[hashtable]$EnvironmentVariables,[string]$SecretTokenPath='') {
    $argumentLiterals=@($ArgumentList|ForEach-Object{ConvertTo-SgPowerShellLiteral ([string]$_)})-join','
    $lines=New-Object 'System.Collections.Generic.List[string]'
    [void]$lines.Add("`$ErrorActionPreference='Stop'")
    $jobName = "Local\ShipGlows-$([guid]::NewGuid().ToString('N'))"
    [void]$lines.Add("if(-not('ShipGlowsJobNative' -as [type])){Add-Type -TypeDefinition $(ConvertTo-SgPowerShellLiteral (Get-SgJobNativeSource)) -Language CSharp -ErrorAction Stop}")
    [void]$lines.Add("`$job=[ShipGlowsJobNative]::CreateKillOnClose($(ConvertTo-SgPowerShellLiteral $jobName))")
    [void]$lines.Add('try {')
    [void]$lines.Add('[ShipGlowsJobNative]::AssignCurrent($job)')
    [void]$lines.Add("Set-Location -LiteralPath $(ConvertTo-SgPowerShellLiteral $WorkingDirectory)")
    foreach($name in @($EnvironmentVariables.Keys|Sort-Object)){
        if($name-eq'SHIPGLOWS_SUPERVISOR_TOKEN'){
            if([string]::IsNullOrWhiteSpace($SecretTokenPath)){throw 'Detached Flutter launch requires its protected token path.'}
            [void]$lines.Add("[Environment]::SetEnvironmentVariable('SHIPGLOWS_SUPERVISOR_TOKEN',[IO.File]::ReadAllText($(ConvertTo-SgPowerShellLiteral $SecretTokenPath)),'Process')")
        }else{
            [void]$lines.Add("[Environment]::SetEnvironmentVariable($(ConvertTo-SgPowerShellLiteral $name),$(ConvertTo-SgPowerShellLiteral ([string]$EnvironmentVariables[$name])),'Process')")
        }
    }
    [void]$lines.Add("[string[]]`$launchArguments=@($argumentLiterals)")
    [void]$lines.Add("`$managedProcess=Start-Process -FilePath $(ConvertTo-SgPowerShellLiteral $FilePath) -ArgumentList `$launchArguments -WorkingDirectory $(ConvertTo-SgPowerShellLiteral $WorkingDirectory) -RedirectStandardOutput $(ConvertTo-SgPowerShellLiteral $RedirectStandardOutput) -RedirectStandardError $(ConvertTo-SgPowerShellLiteral $RedirectStandardError) -PassThru -Wait -WindowStyle Hidden")
    [void]$lines.Add("`$managedExitCode=`$managedProcess.ExitCode;`$managedProcess.Dispose();while([ShipGlowsJobNative]::ActiveProcessCount(`$job)-gt1){Start-Sleep -Milliseconds 200};exit `$managedExitCode")
    [void]$lines.Add("} catch { [IO.File]::AppendAllText($(ConvertTo-SgPowerShellLiteral $RedirectStandardError),(`$_.Exception.Message+[Environment]::NewLine)); exit 1 } finally { if(`$job-ne[IntPtr]::Zero){[void][ShipGlowsJobNative]::CloseHandle(`$job)} }")
    $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(($lines-join[Environment]::NewLine)))
    $powershell=Resolve-SgPowerShellExecutable
    $commandLine="`"$powershell`" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encoded"
    $startup=New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{ShowWindow=[uint16]0}
    $creation=Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine=$commandLine;CurrentDirectory=$WorkingDirectory;ProcessStartupInformation=$startup}
    if(-not$creation-or[int]$creation.ReturnValue-ne0-or[int]$creation.ProcessId-le0){$code=if($creation){[int]$creation.ReturnValue}else{-1};throw "Detached process creation failed with Win32 code $code."}
    $identityLength=[Math]::Min(96,$encoded.Length)
    return [pscustomobject]@{Id=[int]$creation.ProcessId;CommandSignature=$encoded.Substring($encoded.Length-$identityLength);JobName=$jobName}
}

function Complete-SgManagedProcessExit([object]$Config, [string]$ProjectPath, [int]$Pid, [string]$StartTimeUtc) {
    if ([string]::IsNullOrWhiteSpace($ProjectPath) -or $Pid -le 0 -or [string]::IsNullOrWhiteSpace($StartTimeUtc)) { return }
    Invoke-SgRegistryMutation $Config {
        param($registry)
        $entry = @($registry.projects | Where-Object { $_.path -eq $ProjectPath })[0]
        if (-not $entry -or [int]$entry.pid -ne $Pid -or [string]$entry.startTimeUtc -ne $StartTimeUtc) { return }
        # An explicit stop clears the PID first. This watcher therefore only
        # records an unrequested exit of the exact process it was assigned to.
        if ($entry.status -in @('starting', 'running')) {
            $entry.status = 'error'
            $entry.pid = 0
            $entry.startTimeUtc = $null
            $entry | Add-Member -NotePropertyName lastError -NotePropertyValue 'Managed application process exited unexpectedly. Inspect the project logs before restarting.' -Force
            if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
            if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
        }
    } | Out-Null
}

function Start-SgManagedProcessExitMonitor([object]$Config, [string]$ProjectPath, [int]$Pid, [string]$StartTimeUtc) {
    if ($Pid -le 0 -or [string]::IsNullOrWhiteSpace($StartTimeUtc)) { throw 'A managed process exit monitor requires a verified process identity.' }
    $modulePath = $MyInvocation.MyCommand.Module.Path
    $configLiteral = ConvertTo-SgPowerShellLiteral $Config.RuntimeDirectory
    $projectLiteral = ConvertTo-SgPowerShellLiteral $ProjectPath
    $startLiteral = ConvertTo-SgPowerShellLiteral $StartTimeUtc
    $moduleLiteral = ConvertTo-SgPowerShellLiteral $modulePath
    $script = @(
        "`$ErrorActionPreference='Stop'",
        "Wait-Process -Id $Pid -ErrorAction SilentlyContinue",
        "Import-Module $moduleLiteral -Force -DisableNameChecking",
        "`$config=Get-SgDevConfig; if([IO.Path]::GetFullPath(`$config.RuntimeDirectory)-ine[IO.Path]::GetFullPath($configLiteral)){exit 0}",
        "Complete-SgManagedProcessExit `$config $projectLiteral $Pid $startLiteral"
    ) -join '; '
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))
    $powershell = Resolve-SgPowerShellExecutable
    $creation = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
        CommandLine = "`"$powershell`" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encoded"
        CurrentDirectory = $Config.RuntimeDirectory
        ProcessStartupInformation = (New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{ ShowWindow = [uint16]0 })
    }
    if (-not $creation -or [int]$creation.ReturnValue -ne 0 -or [int]$creation.ProcessId -le 0) { throw 'Managed process exit monitor could not be created.' }
}

# A live web process launched by Start-SgProjectCore stays 'starting' while that start
# still owns its readiness wait (bounded by Wait-SgProjectReady's 1800 s cap), so a
# concurrent status read does not report a slow dev-server boot as an error.
function Test-SgStartupGraceActive([object]$Entry, [int]$GraceSeconds = 1800) {
    if (-not $Entry -or [string]$Entry.status -ne 'starting') { return $false }
    if (-not $Entry.PSObject.Properties['startTimeUtc'] -or -not $Entry.startTimeUtc) { return $false }
    try { $started = ([DateTimeOffset]::Parse([string]$Entry.startTimeUtc, [Globalization.CultureInfo]::InvariantCulture)).UtcDateTime } catch { return $false }
    return (([datetime]::UtcNow - $started).TotalSeconds -lt $GraceSeconds)
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

function Protect-SgOwnerOnlyPath([string]$Path) {
    $item=Get-Item -LiteralPath $Path -Force -ErrorAction Stop;if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){throw "Managed runtime path must not be a reparse point: $Path"}
    $sid=[Security.Principal.WindowsIdentity]::GetCurrent().User;$acl=Get-Acl -LiteralPath $Path;$acl.SetAccessRuleProtection($true,$false);foreach($rule in @($acl.Access)){$acl.RemoveAccessRuleAll($rule)}
    $inheritance=if($item.PSIsContainer){[Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'}else{[Security.AccessControl.InheritanceFlags]::None};$access=New-Object Security.AccessControl.FileSystemAccessRule($sid,[Security.AccessControl.FileSystemRights]::FullControl,$inheritance,[Security.AccessControl.PropagationFlags]::None,[Security.AccessControl.AccessControlType]::Allow);$acl.AddAccessRule($access);Set-Acl -LiteralPath $Path -AclObject $acl
}
function Test-SgOwnerOnlyPath([string]$Path) { try{$acl=Get-Acl -LiteralPath $Path;$sid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value;$allowed=@($acl.Access|Where-Object{$_.AccessControlType -eq 'Allow'});return [bool]($acl.AreAccessRulesProtected -and $allowed.Count -eq 1 -and $allowed[0].IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value -eq $sid)}catch{return $false} }
function Assert-SgNoReparseTree([string]$Path) { $root=Get-Item -LiteralPath $Path -Force -ErrorAction Stop;if($root.Attributes-band[IO.FileAttributes]::ReparsePoint){throw 'Managed Flutter IPC path is a reparse point.'};foreach($item in @(Get-ChildItem -LiteralPath $Path -Force -Recurse -ErrorAction Stop)){if($item.Attributes-band[IO.FileAttributes]::ReparsePoint){throw 'Managed Flutter IPC tree contains a reparse point.'}} }

function Get-SgFlutterMachineState([string]$LogPath) {
    $appIds = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::Ordinal)
    $started = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::Ordinal)
    $stopped = @{}
    if (Test-Path -LiteralPath $LogPath -PathType Leaf) {
        foreach ($line in @(Get-Content -LiteralPath $LogPath -ErrorAction SilentlyContinue)) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try { $messages = @(([string]$line | ConvertFrom-Json -ErrorAction Stop)) } catch { continue }
            foreach ($message in $messages) {
                if (-not $message -or -not $message.event -or -not $message.params) { continue }
                $appId = [string]$message.params.appId
                if ([string]::IsNullOrWhiteSpace($appId)) { continue }
                switch ([string]$message.event) {
                    'app.start' { [void]$appIds.Add($appId) }
                    'app.started' { [void]$started.Add($appId) }
                    'app.stop' { $stopped[$appId] = if ($message.params.error) { [string]$message.params.error } else { 'Flutter stopped before startup completed.' } }
                }
            }
        }
    }
    foreach ($appId in $appIds) {
        if ($stopped.ContainsKey($appId)) { return [pscustomobject]@{ Ready=$false; AppId=$appId; Error=[string]$stopped[$appId] } }
        if ($started.Contains($appId)) { return [pscustomobject]@{ Ready=$true; AppId=$appId; Error=$null } }
    }
    return [pscustomobject]@{ Ready=$false; AppId=$null; Error=$null }
}

function Wait-SgFlutterReady([string]$LogPath, [int]$TimeoutSeconds = 90) {
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    do {
        $state = Get-SgFlutterMachineState $LogPath
        if ($state.Ready -or $state.Error) { return $state }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; Error='Flutter application startup timed out before app.started.' }
}

function Protect-SgDiagnosticText([string]$Text) {
    if ($null -eq $Text) { return '' }
    $result = [string]$Text
    $quotedOrAtom = '(?:"[^"\r\n]*"|''[^''\r\n]*''|[^\s,;]+)'
    $result = [regex]::Replace($result, '(?i)\b(authorization)(\s*(?::|=)?\s*)(bearer|basic)(\s+)'+$quotedOrAtom, '$1$2$3$4[REDACTED]')
    $result = [regex]::Replace($result, '(?i)\b(bearer)(\s+)'+$quotedOrAtom, '$1$2[REDACTED]')
    $key = '(?i)\b(token|secret|password|api[-_]?key|dart-define)\b'
    $result = [regex]::Replace($result, $key+'(\s*(?::|=)\s*)'+$quotedOrAtom, '$1$2[REDACTED]')
    $result = [regex]::Replace($result, $key+'(\s+)(?:"[^"\r\n]*"|''[^''\r\n]*'')', '$1$2[REDACTED]')
    $result = [regex]::Replace($result, $key+'(\s+)(?!(?:is|was|missing|invalid|validation|required|failed|not|unset|empty)\b)[^\s,;]+', '$1$2[REDACTED]')
    return $result
}

function Get-SgStartupFailure([string]$ErrorLogPath, [string]$Fallback = 'Process exited during startup.') {
    if ([string]::IsNullOrWhiteSpace($ErrorLogPath) -or -not (Test-Path -LiteralPath $ErrorLogPath -PathType Leaf)) { return $Fallback }
    try {
        $tail = (Get-SgBoundedFileTail $ErrorLogPath 8192).Trim()
        $tail = Protect-SgDiagnosticText $tail
        if ($tail.Length -gt 1200) { $tail = $tail.Substring($tail.Length - 1200) }
        if ($tail) { return "Process exited during startup: $tail" }
    } catch { }
    return $Fallback
}

function Wait-SgProjectReady([string]$Kind, [int]$Port, [string]$LogPath, [int]$TimeoutSeconds = 90, [object]$ProcessEntry = $null, [string]$ErrorLogPath = '') {
    if ($Kind -eq 'flutter-web') { return Wait-SgFlutterReady $LogPath $TimeoutSeconds }
    $deadline = (Get-Date).AddSeconds([Math]::Min([Math]::Max(0, $TimeoutSeconds), 1800))
    do {
        if ($ProcessEntry -and -not (Test-SgProcessIdentity $ProcessEntry)) {
            return [pscustomobject]@{ Ready=$false; AppId=$null; Error=(Get-SgStartupFailure $ErrorLogPath) }
        }
        if ((Test-SgHttpReady $Port) -and (-not $ProcessEntry -or (Test-SgProcessIdentity $ProcessEntry))) {
            if ($Kind -eq 'tauri') {
                Start-Sleep -Milliseconds 1200
                if ($ProcessEntry -and -not (Test-SgProcessIdentity $ProcessEntry)) {
                    return [pscustomobject]@{ Ready=$false; AppId=$null; Error=(Get-SgStartupFailure $ErrorLogPath) }
                }
                if (-not (Test-SgHttpReady $Port)) {
                    return [pscustomobject]@{ Ready=$false; AppId=$null; Error=(Get-SgStartupFailure $ErrorLogPath 'Tauri dev server stopped during startup.') }
                }
            }
            return [pscustomobject]@{ Ready=$true; AppId=$null; Error=$null }
        }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; Error='Application readiness timed out.' }
}

function Get-SgBrowserExtensionManifestPaths([string]$ProjectPath) {
    $descriptor = Get-SgBrowserExtensionDescriptor $ProjectPath 'Chromium'
    if ($descriptor -and $descriptor.ManifestPath) { return @([string]$descriptor.ManifestPath) }
    return @()
}

function Test-SgBrowserExtensionManifest([string]$Path, [DateTime]$FreshSinceUtc) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    try {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $item.Length -gt 1048576 -or $item.LastWriteTimeUtc -lt $FreshSinceUtc) { return $false }
        $manifest = [IO.File]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop
        foreach ($requiredProperty in @('manifest_version','name','version')) {
            if (-not $manifest.PSObject.Properties[$requiredProperty]) { return $false }
        }
        return [int]$manifest.manifest_version -eq 3 -and -not [string]::IsNullOrWhiteSpace([string]$manifest.name) -and -not [string]::IsNullOrWhiteSpace([string]$manifest.version)
    } catch { return $false }
}

function Wait-SgBrowserExtensionReady([string]$ProjectPath, [int]$Port, [int]$TimeoutSeconds = 90, [object]$ProcessEntry = $null, [string]$ErrorLogPath = '') {
    $freshSince = [DateTime]::UtcNow.AddSeconds(-2)
    if ($ProcessEntry -and $ProcessEntry.PSObject.Properties['startTimeUtc'] -and $ProcessEntry.startTimeUtc) {
        try { $freshSince = ([DateTimeOffset]::Parse([string]$ProcessEntry.startTimeUtc, [Globalization.CultureInfo]::InvariantCulture)).UtcDateTime.AddSeconds(-2) } catch { }
    }
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    do {
        if ($ProcessEntry -and -not (Test-SgProcessIdentity $ProcessEntry)) {
            return [pscustomobject]@{ Ready=$false; AppId=$null; ManifestPath=$null; Error=(Get-SgStartupFailure $ErrorLogPath) }
        }
        if (-not (Test-SgPortAvailable $Port)) {
            foreach ($manifestPath in @(Get-SgBrowserExtensionManifestPaths $ProjectPath)) {
                if (Test-SgBrowserExtensionManifest $manifestPath $freshSince) {
                    return [pscustomobject]@{ Ready=$true; AppId=$null; ManifestPath=$manifestPath; Error=$null }
                }
            }
        }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; ManifestPath=$null; Error='Browser extension readiness timed out before a fresh Manifest V3 package and HMR listener were available.' }
}

function Update-SgFlutterReadinessWindow([bool]$WasActiveProgress,[bool]$IsActiveProgress,[datetime]$Deadline,[int]$TimeoutSeconds,[datetime]$Now=(Get-Date)) {
    if($WasActiveProgress-and-not$IsActiveProgress){$Deadline=$Now.AddSeconds([Math]::Max(0,$TimeoutSeconds))}
    [pscustomobject]@{ActiveProgress=$IsActiveProgress;Deadline=$Deadline}
}

# Latest file write under any of the given directories (missing ones are skipped).
function Get-SgLatestWriteUtc([string[]]$Path) {
    $latest=[datetime]::MinValue
    foreach($root in @($Path)){
        if(-not$root-or-not[IO.Directory]::Exists($root)){continue}
        try{foreach($file in ([IO.DirectoryInfo]$root).EnumerateFiles('*',[IO.SearchOption]::AllDirectories)){if($file.LastWriteTimeUtc-gt$latest){$latest=$file.LastWriteTimeUtc}}}catch{}
    }
    $latest
}

function Update-SgFlutterBuildStallDeadline([datetime]$StallDeadline,[datetime]$LastActivityUtc,[datetime]$LatestWriteUtc,[int]$StallTimeoutSeconds,[datetime]$Now=(Get-Date)) {
    if($LatestWriteUtc-gt$LastActivityUtc){$LastActivityUtc=$LatestWriteUtc;$StallDeadline=$Now.AddSeconds([Math]::Max(0,$StallTimeoutSeconds))}
    [pscustomobject]@{LastActivityUtc=$LastActivityUtc;StallDeadline=$StallDeadline}
}

# With BuildActivityPath, an active build is only cut after BuildStallTimeoutSeconds without
# any file write under those paths, or when ActiveProgressTimeoutSeconds (hard cap) is reached.
# Windows passes build\windows (native MSBuild) and .dart_tool\flutter_build (Dart kernel
# compile): a large Dart compile writes nothing under build\windows for minutes.
function Wait-SgFlutterSupervisorReady([string]$StatePath, [int]$TimeoutSeconds = 90, [object]$ProcessEntry = $null, [int]$ActiveProgressTimeoutSeconds = 600, [string[]]$BuildActivityPath = @(), [int]$BuildStallTimeoutSeconds = 300) {
    $deadline=(Get-Date).AddSeconds([Math]::Max(0,$TimeoutSeconds))
    $progressDeadline=(Get-Date).AddSeconds([Math]::Max($TimeoutSeconds,$ActiveProgressTimeoutSeconds))
    $activeProgress=$false;$stalled=$false
    $stallDeadline=(Get-Date).AddSeconds([Math]::Max(0,$BuildStallTimeoutSeconds));$lastActivityUtc=Get-SgLatestWriteUtc $BuildActivityPath;$nextActivityScan=Get-Date
    $hasActivityPath=@($BuildActivityPath|Where-Object{$_}).Count-gt0
    do {
        if(Test-Path -LiteralPath $StatePath -PathType Leaf){try{$state=Get-SgBoundedFileTail $StatePath 262144|ConvertFrom-Json -ErrorAction Stop;if($state.status -eq 'running' -and $state.appId){return [pscustomobject]@{Ready=$true;AppId=[string]$state.appId;Error=$null;DaemonPid=[int]$state.daemonPid}};if($state.status -eq 'error'){return [pscustomobject]@{Ready=$false;AppId=$null;Error=$(if($state.lastError){Protect-SgDiagnosticText ([string]$state.lastError)}else{'Flutter supervisor failed.'});DaemonPid=[int]$state.daemonPid}};$currentProgress=[bool](($state.PSObject.Properties['progressActive']-and[bool]$state.progressActive)-or[string]$state.status-eq'building');$timing=Update-SgFlutterReadinessWindow $activeProgress $currentProgress $deadline $TimeoutSeconds;$deadline=$timing.Deadline;$activeProgress=$timing.ActiveProgress}catch{}}
        if($ProcessEntry-and-not(Test-SgProcessIdentity $ProcessEntry)){return [pscustomobject]@{Ready=$false;AppId=$null;Error='Flutter supervisor exited during startup.';DaemonPid=0}}
        $now=Get-Date
        if($hasActivityPath-and$now-ge$nextActivityScan){$nextActivityScan=$now.AddSeconds(5);$activity=Update-SgFlutterBuildStallDeadline $stallDeadline $lastActivityUtc (Get-SgLatestWriteUtc $BuildActivityPath) $BuildStallTimeoutSeconds $now;$stallDeadline=$activity.StallDeadline;$lastActivityUtc=$activity.LastActivityUtc}
        if($activeProgress-and$hasActivityPath-and$now-ge$stallDeadline){$stalled=$true;break}
        if(((-not$activeProgress)-and$now-ge$deadline)-or($activeProgress-and$now-ge$progressDeadline)){break};Start-Sleep -Milliseconds 250
    }while($true)
    [pscustomobject]@{Ready=$false;AppId=$null;Error=$(if($stalled){"Flutter Windows build stalled: no build output for $BuildStallTimeoutSeconds seconds before app.started."}elseif($activeProgress){'Flutter Windows build timed out before app.started.'}else{'Flutter supervisor timed out before app.started.'});DaemonPid=0}
}

function Invoke-SgFlutterSupervisorCommand([object]$Entry,[ValidateSet('reload','stop','open')][string]$Method,[int]$TimeoutSeconds=10) {
    # The supervisor can spend 10 seconds awaiting app.stop before publishing
    # its response. Do not enter forced cleanup while that request is pending.
    if($Method -in @('stop','open')){$TimeoutSeconds=[Math]::Max($TimeoutSeconds,12)}
    if(-not $Entry.PSObject.Properties['flutterLaunchDirectory'] -or -not $Entry.PSObject.Properties['flutterTokenPath']){throw 'Flutter supervisor identity is unavailable.'}
    $launch=[IO.Path]::GetFullPath([string]$Entry.flutterLaunchDirectory);$tokenPath=[IO.Path]::GetFullPath([string]$Entry.flutterTokenPath)
    if(-not $tokenPath.StartsWith($launch.TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or -not(Test-Path -LiteralPath $tokenPath -PathType Leaf)){throw 'Flutter supervisor token identity is invalid.'};Assert-SgNoReparseTree $launch;if(-not(Test-SgOwnerOnlyPath $launch)-or-not(Test-SgOwnerOnlyPath $tokenPath)){throw 'Flutter supervisor IPC ACL is not owner-only.'}
    $token=[IO.File]::ReadAllText($tokenPath).Trim();if($token -notmatch '^[a-f0-9]{64}$'){throw 'Flutter supervisor token is invalid.'}
    $id=[guid]::NewGuid().ToString('N');$commandDir=Join-Path $launch 'commands';$response=Join-Path (Join-Path $launch 'responses') "$id.json";Ensure-SgDirectory $commandDir
    $target=Join-Path $commandDir "$id.json";$temp="$target.tmp";$json=[ordered]@{token=$token;id=$id;method=$Method}|ConvertTo-Json -Compress;[IO.File]::WriteAllText($temp,$json,(New-Object Text.UTF8Encoding($false)));Move-Item -LiteralPath $temp -Destination $target -Force
    try{$deadline=(Get-Date).AddSeconds($TimeoutSeconds);while((Get-Date)-lt $deadline){if(Test-Path -LiteralPath $response -PathType Leaf){$info=Get-Item -LiteralPath $response;if($info.Length-gt65536){throw 'Flutter supervisor response exceeds 64 KiB.'};try{$result=Get-Content -LiteralPath $response -Raw|ConvertFrom-Json -ErrorAction Stop}finally{Remove-Item -LiteralPath $response -Force -ErrorAction SilentlyContinue};$names=@($result.PSObject.Properties.Name);if($result -is[array]-or-not($result.PSObject.Properties['ok'])-or$result.ok-isnot[bool]){throw 'Malformed Flutter supervisor response.'};if($result.ok){if(($names|Sort-Object)-join',' -ne 'method,ok'-or[string]$result.method-cne$Method){throw 'Mismatched Flutter supervisor response.'};return $result}else{if(($names|Sort-Object)-join',' -ne 'error,ok'){throw 'Malformed Flutter supervisor response.'};throw 'Flutter supervisor command failed.'}};Start-Sleep -Milliseconds 100};throw "Flutter supervisor $Method command timed out."}finally{if(Test-Path -LiteralPath $target -PathType Leaf){Remove-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue};if(Test-Path -LiteralPath $temp -PathType Leaf){Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue}}
}

function Invoke-SgFlutterProjectReload([object]$Config,[string]$ProjectPath,[int]$TimeoutSeconds=10) {
    # Hot reload is identity-bound: the registered process, supervisor state, daemon and app must all
    # match before the existing authenticated reload IPC is used. It never stops, starts or rebuilds.
    $result={ param([string]$Status,[string]$Reason,[string]$Name=$null); [pscustomobject]@{Status=$Status;Reason=$Reason;Name=$Name} }
    if([string]::IsNullOrWhiteSpace($ProjectPath)){return (& $result 'unavailable' 'ProjectPath is required.')}
    try{$path=ConvertTo-SgCanonicalPath $ProjectPath}catch{return (& $result 'unavailable' 'The project path is invalid.')}
    $entry=@((Reconcile-SgRegistry $Config).projects|Where-Object{$_.path -eq $path})|Select-Object -First 1
    if(-not $entry){return (& $result 'unavailable' 'The project is not registered.')}
    if($entry.kind -ne 'flutter-web'){return (& $result 'unavailable' 'The registered project is not a managed Flutter session.')}
    if($entry.status -ne 'running'){return (& $result 'unavailable' "The Flutter session is not ready (status=$($entry.status)).")}
    if($entry.PSObject.Properties['flutterMode'] -and [string]$entry.flutterMode -eq 'profile'){return (& $result 'unavailable' "Flutter profile sessions support neither hot reload nor hot restart (Flutter: 'Restart is not supported in profile mode'). Rebuild with s restart -ProjectPath <path> -FlutterMode profile, or start a debug session for iterative work.")}
    if(-not $entry.PSObject.Properties['flutterAppId'] -or [string]::IsNullOrWhiteSpace([string]$entry.flutterAppId)){return (& $result 'unavailable' 'The Flutter application identity is unavailable.')}
    if(-not (Test-SgProcessIdentity $entry)){return (& $result 'unavailable' 'The managed Flutter supervisor is not running.')}
    if(-not $entry.PSObject.Properties['flutterLaunchDirectory'] -or -not $entry.flutterLaunchDirectory){return (& $result 'unavailable' 'The Flutter supervisor identity is unavailable.')}
    try{Assert-SgNoReparseTree ([string]$entry.flutterLaunchDirectory)}catch{return (& $result 'unavailable' 'The Flutter supervisor identity is invalid.')}
    $state=Get-SgFlutterSupervisorState $entry
    if(-not $state){return (& $result 'unavailable' 'The Flutter supervisor readiness state is unavailable.')}
    if(-not $state.PSObject.Properties['status'] -or [string]$state.status -ne 'running' -or -not $state.PSObject.Properties['ready'] -or $state.ready -isnot [bool] -or -not $state.ready){return (& $result 'unavailable' 'The Flutter application is not ready.')}
    if(-not $state.PSObject.Properties['appId'] -or [string]$state.appId -cne [string]$entry.flutterAppId){return (& $result 'unavailable' 'The Flutter application identity is stale.')}
    if($entry.PSObject.Properties['flutterDaemonPid'] -and [int]$entry.flutterDaemonPid -gt 0 -and $state.PSObject.Properties['daemonPid'] -and [int]$state.daemonPid -ne [int]$entry.flutterDaemonPid){return (& $result 'unavailable' 'The Flutter daemon identity is stale.')}
    try{[void](Invoke-SgFlutterSupervisorCommand $entry 'reload' $TimeoutSeconds);return (& $result 'succeeded' $null ([string]$entry.name))}
    catch{return (& $result 'failed' (Protect-SgDiagnosticText $_.Exception.Message))}
}

function Get-SgBoundedFileTail([string]$Path,[int]$MaxBytes=262144) {
    $share=[IO.FileShare]::ReadWrite-bor[IO.FileShare]::Delete;$stream=[IO.File]::Open($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,$share);try{$count=[int][Math]::Min([int64][Math]::Max(0,$MaxBytes),$stream.Length);[void]$stream.Seek(-$count,[IO.SeekOrigin]::End);$buffer=New-Object byte[] $count;$read=0;while($read-lt$count){$n=$stream.Read($buffer,$read,$count-$read);if($n-le0){break};$read+=$n};[Text.Encoding]::UTF8.GetString($buffer,0,$read)}finally{$stream.Dispose()}
}

function Copy-SgFlutterDiagnostics([object]$Entry,[string]$DurableOut,[string]$DurableErr) {
    if(-not$Entry-or-not$Entry.PSObject.Properties['flutterLaunchDirectory']){return}
    $launch=[string]$Entry.flutterLaunchDirectory;if(-not(Test-Path -LiteralPath $launch -PathType Container)){return};Assert-SgNoReparseTree $launch
    foreach($pair in @(@('flutter.stdout.log',$DurableOut),@('flutter.stderr.log',$DurableErr))){$source=Join-Path $launch $pair[0];if(Test-Path -LiteralPath $source -PathType Leaf){$text=Protect-SgDiagnosticText (Get-SgBoundedFileTail $source 262144);Add-Content -LiteralPath $pair[1] -Value $text}}
    $statePath=Join-Path $launch 'state.json';if(Test-Path -LiteralPath $statePath -PathType Leaf){try{if((Get-Item -LiteralPath $statePath).Length-gt262144){throw 'Oversized Flutter supervisor state.'};$state=(Get-SgBoundedFileTail $statePath 262144)|ConvertFrom-Json -ErrorAction Stop;$lastError=Protect-SgDiagnosticText ([string]$state.lastError);$protocolError=Protect-SgDiagnosticText ([string]$state.lastProtocolError);$summary=[ordered]@{status=[string]$state.status;lastError=$lastError;lastEvent=[string]$state.lastEvent;lastProtocolError=$protocolError;flutterExitCode=$(if($null-ne$state.flutterExitCode){[int]$state.flutterExitCode}else{$null});exitReason=[string]$state.exitReason;appId=[string]$state.appId;daemonPid=[int]$state.daemonPid}|ConvertTo-Json -Compress;Add-Content -LiteralPath $DurableOut -Value $summary}catch{Add-Content -LiteralPath $DurableErr -Value 'Flutter supervisor state could not be preserved.'}}
}

function Test-SgFlutterStartupRetryable([string]$Message) {return [bool](-not[string]::IsNullOrWhiteSpace($Message)-and$Message-match'(?i)(error waiting for a debug connection|log reader stopped unexpectedly|application stopped before app\.started)')}
function Move-SgFlutterRetryDiagnostics([string]$OutPath,[string]$ErrorPath) {foreach($path in @($OutPath,$ErrorPath)){if(Test-Path -LiteralPath $path -PathType Leaf){Move-Item -LiteralPath $path -Destination ($path+'.startup-previous') -Force}}}

function Get-SgFlutterSupervisorState([object]$Entry) {
    if(-not$Entry-or-not$Entry.PSObject.Properties['flutterLaunchDirectory']-or-not$Entry.flutterLaunchDirectory){return $null}
    $statePath=Join-Path ([string]$Entry.flutterLaunchDirectory) 'state.json'
    try{if(-not(Test-Path -LiteralPath $statePath -PathType Leaf)-or(Get-Item -LiteralPath $statePath).Length-gt262144){return $null};$state=Get-SgBoundedFileTail $statePath 262144|ConvertFrom-Json -ErrorAction Stop;if($state-is[array]){return $null};return $state}catch{return $null}
}

function Get-SgOwnedFlutterNativePids([object]$Entry) {
    if(-not$Entry-or$Entry.kind-ne'flutter-web'){return @()};$device=if($Entry.PSObject.Properties['flutterDeviceId']){[string]$Entry.flutterDeviceId}elseif($Entry.PSObject.Properties['flutterDevice']){[string]$Entry.flutterDevice}else{''};if($device-ne'windows'){return @()}
    $projectValue=if($Entry.PSObject.Properties['launchPath']-and$Entry.launchPath){[string]$Entry.launchPath}elseif($Entry.PSObject.Properties['path']-and$Entry.path){[string]$Entry.path}else{return @()}
    $project=[IO.Path]::GetFullPath($projectValue).TrimEnd('\','/')
    $cmake=Join-Path $project 'windows\CMakeLists.txt';if(-not(Test-Path -LiteralPath $cmake -PathType Leaf)){return @()}
    try{$cmakeText=[IO.File]::ReadAllText($cmake);$match=[regex]::Match($cmakeText,'(?im)^\s*set\s*\(\s*BINARY_NAME\s+"([A-Za-z0-9._-]+)"\s*\)\s*$');if(-not$match.Success){return @()};$expectedLeaf=$match.Groups[1].Value+'.exe'}catch{return @()}
    $runnerRoot=[IO.Path]::GetFullPath((Join-Path $project 'build\windows')).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
    # The managed session owns only the runner of its own build mode: Debug by default, Profile for a profile session; a Release runner is never a managed process.
    $runnerDirectory=if($Entry.PSObject.Properties['flutterMode']-and[string]$Entry.flutterMode-eq'profile'){'Profile'}else{'Debug'}
    $runnerPattern='(?i)[\\/]runner[\\/]'+$runnerDirectory+'[\\/][^\\/]+\.exe$'
    $started=$null;if($Entry.PSObject.Properties['startTimeUtc']-and$Entry.startTimeUtc){try{$started=([DateTimeOffset]::Parse([string]$Entry.startTimeUtc,[Globalization.CultureInfo]::InvariantCulture)).UtcDateTime.AddSeconds(-5)}catch{}}
    $owned=@()
    foreach($process in @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)){
        try{$executable=[IO.Path]::GetFullPath([string]$process.ExecutablePath)}catch{continue}
        if(-not$executable.StartsWith($runnerRoot,[StringComparison]::OrdinalIgnoreCase)-or$executable-notmatch$runnerPattern-or-not([IO.Path]::GetFileName($executable).Equals($expectedLeaf,[StringComparison]::OrdinalIgnoreCase))){continue}
        if($started-and$process.PSObject.Properties['CreationDate']-and$process.CreationDate){try{if(([datetime]$process.CreationDate).ToUniversalTime()-lt$started){continue}}catch{continue}}
        $owned+=[int]$process.ProcessId
    }
    return @($owned|Sort-Object -Unique)
}

function Stop-SgOwnedFlutterNative([object]$Entry) {$owned=@(Get-SgOwnedFlutterNativePids $Entry);foreach($ownedPid in $owned){Stop-SgProcessTree $ownedPid};return $owned.Count-gt0}

function Wait-SgFlutterOwnedExtinction([object]$Entry,[int]$TimeoutSeconds=8,[int]$QuietMilliseconds=1000) {
    $deadline=(Get-Date).AddSeconds([Math]::Max(0,$TimeoutSeconds));$quietSince=$null
    do{
        $identityLive=Test-SgProcessIdentity $Entry;$browser=@(Get-SgOwnedFlutterBrowserPids $Entry);$listener=@(Get-SgOwnedFlutterListenerPids $Entry);$native=@(Get-SgOwnedFlutterNativePids $Entry)
        if(-not$identityLive){if($browser.Count-gt0){[void](Stop-SgOwnedFlutterBrowser $Entry)};if($listener.Count-gt0){[void](Stop-SgOwnedFlutterListener $Entry)};if($native.Count-gt0){[void](Stop-SgOwnedFlutterNative $Entry)}}
        if(-not$identityLive-and$browser.Count-eq0-and$listener.Count-eq0-and$native.Count-eq0){if(-not$quietSince){$quietSince=Get-Date}elseif(((Get-Date)-$quietSince).TotalMilliseconds-ge[Math]::Max(0,$QuietMilliseconds)){return $true}}else{$quietSince=$null}
        if((Get-Date)-ge$deadline){return $false};Start-Sleep -Milliseconds 100
    }while($true)
}

function Remove-SgFlutterLaunchArtifacts([object]$Config,[object]$Entry) {
    if(-not$Entry-or-not$Entry.PSObject.Properties['flutterLaunchDirectory']-or-not$Entry.flutterLaunchDirectory){return $true};$launch=[IO.Path]::GetFullPath([string]$Entry.flutterLaunchDirectory);$base=[IO.Path]::GetFullPath((Join-Path $Config.RuntimeDirectory 'flutter-launch')).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
    if(-not$launch.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)-or(Split-Path $launch -Leaf)-notmatch'^[a-f0-9]{32}$'){throw 'Refusing Flutter launch cleanup outside the managed runtime identity.'};if(-not(Test-Path -LiteralPath $launch)){return $true};Assert-SgNoReparseTree $launch
    if(Test-SgProcessIdentity $Entry -or @(Get-SgOwnedFlutterBrowserPids $Entry).Count -gt 0 -or @(Get-SgOwnedFlutterListenerPids $Entry).Count -gt 0 -or @(Get-SgOwnedFlutterNativePids $Entry).Count -gt 0){throw 'Refusing Flutter launch cleanup while owned processes remain.'};Remove-Item -LiteralPath $launch -Recurse -Force;return -not(Test-Path -LiteralPath $launch)
}

function Get-SgListeningTcpPortSet {
    $ports = @{}
    try { foreach ($endpoint in [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()) { $ports[[int]$endpoint.Port] = $true } } catch { return $null }
    return $ports
}

function Test-SgTcpPortListening([int]$Port) {
    try { foreach ($endpoint in [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()) { if ($endpoint.Port -eq $Port) { return $true } }; return $false } catch { return $true }
}

function Reconcile-SgRegistry([object]$Config) {
    return Invoke-SgRegistryMutation $Config {
        param($registry)
        $signaturePids = @($registry.projects | Where-Object { $_.PSObject.Properties['commandSignature'] -and $_.commandSignature } | ForEach-Object { [int]$_.pid })
        $processSnapshots = Get-SgProcessSnapshotMap @($registry.projects | ForEach-Object { [int]$_.pid }) -CommandLinePids $signaturePids
        $listeningPorts = Get-SgListeningTcpPortSet
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

            $live = Test-SgProcessIdentity $entry $processSnapshots
            $freshReservation = $false
            if (-not $live -and $entry.status -in @('reserved','starting') -and $entry.PSObject.Properties['reservationTimeUtc'] -and $entry.reservationTimeUtc) {
                try {
                    $freshReservation = (((Get-Date).ToUniversalTime() - [datetime]::Parse([string]$entry.reservationTimeUtc).ToUniversalTime()).TotalMinutes -lt 5)
                } catch {
                    $freshReservation = $false
                }
            }
            if ($live) {
                if($entry.kind-eq'flutter-web'){$flutterState=Get-SgFlutterSupervisorState $entry;$nativeRequired=($entry.PSObject.Properties['flutterDeviceId']-and[string]$entry.flutterDeviceId-eq'windows');if($flutterState-and$flutterState.status-eq'running'-and$flutterState.appId-and(-not$nativeRequired-or@(Get-SgOwnedFlutterNativePids $entry).Count-gt0)){$entry.status='running';$entry|Add-Member -NotePropertyName flutterStartupState -NotePropertyValue 'running' -Force;$entry|Add-Member -NotePropertyName flutterAppId -NotePropertyValue ([string]$flutterState.appId) -Force;$entry|Add-Member -NotePropertyName flutterDaemonPid -NotePropertyValue ([int]$flutterState.daemonPid) -Force;$entry|Add-Member -NotePropertyName lastError -NotePropertyValue $null -Force}elseif($flutterState-and$flutterState.status-in@('error','stopped')){$entry.status=[string]$flutterState.status;$entry|Add-Member -NotePropertyName flutterStartupState -NotePropertyValue ([string]$flutterState.status) -Force;if($flutterState.lastError){$entry|Add-Member -NotePropertyName lastError -NotePropertyValue (Protect-SgDiagnosticText ([string]$flutterState.lastError)) -Force}}elseif($flutterState-and$flutterState.status-eq'running'-and$nativeRequired){$entry.status='error';$entry|Add-Member -NotePropertyName flutterStartupState -NotePropertyValue 'error' -Force;$entry|Add-Member -NotePropertyName lastError -NotePropertyValue 'Flutter Windows runner is no longer active.' -Force}else{$entry.status='starting';$entry|Add-Member -NotePropertyName flutterStartupState -NotePropertyValue 'starting' -Force}}elseif($entry.kind-in@('astro','vite','browser-extension','tauri')-and[int]$entry.port-gt0){if(($null -eq $listeningPorts -or $listeningPorts.ContainsKey([int]$entry.port)) -and (Test-SgHttpReady ([int]$entry.port))){$entry.status='running';$entry|Add-Member -NotePropertyName lastError -NotePropertyValue $null -Force}elseif(Test-SgStartupGraceActive $entry){$entry.status='starting';$entry|Add-Member -NotePropertyName lastError -NotePropertyValue $null -Force}else{$entry.status='error';$entry|Add-Member -NotePropertyName lastError -NotePropertyValue 'Managed process is alive, but its local service port is not responding.' -Force}}else{$entry.status = 'running'}
                # A live launch that is still starting owns its reservation until Start-SgProjectCore commits it.
                if ($entry.status -ne 'starting') {
                    if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
                    if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
                }
            } elseif (-not $freshReservation) {
                $flutterResidual=$entry.kind-eq'flutter-web'-and(@(Get-SgOwnedFlutterNativePids $entry).Count-gt0-or@(Get-SgOwnedFlutterListenerPids $entry).Count-gt0-or@(Get-SgOwnedFlutterBrowserPids $entry).Count-gt0)
                if($flutterResidual){$entry.status='error';$entry|Add-Member -NotePropertyName lastError -NotePropertyValue 'Owned Flutter process remains after supervisor exit.' -Force}elseif($entry.status-ne'error'){$entry.status = 'stopped'}
                if($entry.kind-eq'flutter-web'){$entry|Add-Member -NotePropertyName flutterStartupState -NotePropertyValue ([string]$entry.status) -Force}
                if(-not$flutterResidual){$entry.pid=0;$entry|Add-Member -NotePropertyName startTimeUtc -NotePropertyValue $null -Force}
                if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
                if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
            }

            if ($entry.PSObject.Properties['backend'] -and $entry.backend -and $entry.backend.mode -eq 'local' -and ($entry.backend.status -eq 'error' -or ($entry.backend.status -eq 'ready' -and -not (Test-SgProcessIdentity $entry.backend.process)))) {
                $entry.backend.status = if ($entry.status -eq 'stopped') { 'stopped' } else { 'error' }
                if ($live) { $entry.status='error'; $entry.lastError='Required backend supervisor is no longer active.' }
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
            foreach ($property in @('name','kind','port','pid','startTimeUtc','executablePath','commandSignature','jobName','logPath','errorLogPath','lastError','reservationToken','reservationTimeUtc')) {
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

function Get-SgProjectEnvironmentBlock([string]$Content) {
    $text = if ($null -eq $Content) { '' } else { [string]$Content }
    $beginCount = [regex]::Matches($text, [regex]::Escape($script:ProjectEnvironmentBegin)).Count
    $endCount = [regex]::Matches($text, [regex]::Escape($script:ProjectEnvironmentEnd)).Count
    if ($beginCount -eq 0 -and $endCount -eq 0) { return [pscustomobject]@{ Exists=$false; Schema=$null; Match=$null } }
    if ($beginCount -ne 1 -or $endCount -ne 1) { throw 'ShipGlows project environment markers are incomplete or duplicated; the file was preserved.' }
    $pattern = '(?ms)^' + [regex]::Escape($script:ProjectEnvironmentBegin) + '\r?\n.*?^' + [regex]::Escape($script:ProjectEnvironmentEnd) + '\r?\n?'
    $blocks = [regex]::Matches($text, $pattern)
    if ($blocks.Count -ne 1) { throw 'ShipGlows project environment markers are incomplete or duplicated; the file was preserved.' }
    $schemaPattern = '(?m)^- Environment schema: `([^`]+)`\r?$'
    $schemas = [regex]::Matches($blocks[0].Value, $schemaPattern)
    if ($schemas.Count -gt 1) { throw 'ShipGlows project environment schema is duplicated; the file was preserved.' }
    $schema = if ($schemas.Count -eq 0) { 'legacy/v0' } else { [string]$schemas[0].Groups[1].Value }
    if ($schema -notin @('legacy/v0','shipglows-project-environment/v1',$script:ProjectEnvironmentSchema)) { throw "Unsupported ShipGlows project environment schema '$schema'; the file was preserved." }
    return [pscustomobject]@{ Exists=$true; Schema=$schema; Match=$blocks[0] }
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

function Write-SgProjectEnvironment([string]$ProjectPath, [int]$Port = 0, [string]$Kind = '', [switch]$ReplaceDurablePort) {
    if ($Port -ne 0 -and ($Port -lt 1024 -or $Port -gt 65535)) { throw 'ShipGlows project port must be 0 or between 1024 and 65535.' }
    $path = Get-SgProjectEnvironmentPath $ProjectPath
    $existing = if (Test-Path -LiteralPath $path -PathType Leaf) { [IO.File]::ReadAllText($path) } else { '' }
    $managed = Get-SgProjectEnvironmentBlock $existing
    $effectivePort = $Port
    if (-not $ReplaceDurablePort -and $effectivePort -eq 0 -and $managed.Exists -and $managed.Match.Value -match '(?m)^- Assigned port: `(\d+)`\r?$') {
        $durablePort = [int]$Matches[1]
        if ($durablePort -lt 1024 -or $durablePort -gt 65535) { throw "Invalid assigned port in $path." }
        $effectivePort = $durablePort
    }
    $portValue = if ($Kind -eq 'obsidian-plugin') { 'not applicable (Obsidian plugin)' } elseif ($effectivePort -gt 0) { [string]$effectivePort } else { 'pending first ShipGlows start' }
    if ([string]::IsNullOrWhiteSpace($Kind)) { try { $Kind = Get-SgProjectKind $ProjectPath } catch { $Kind = 'unknown' } }
    $urlValue = if ($Kind -eq 'browser-extension') { 'not applicable (browser extension)' } elseif ($Kind -eq 'obsidian-plugin') { 'not applicable (Obsidian plugin)' } elseif ($effectivePort -gt 0) { "http://127.0.0.1:$effectivePort" } else { 'pending first ShipGlows start' }
    $extensionGuidance = if ($Kind -eq 'browser-extension') {
        $unpackedDirectory = (Get-SgBrowserExtensionUnpackedDirectory $ProjectPath).Replace('\','/')
(@"
- Browser target: ``Chrome``
- Unpacked Chrome directory: ``$unpackedDirectory``
- Extension workflow: ``s start -ProjectPath .`` -> ``s open -ProjectPath .`` -> Chrome Developer mode -> Load unpacked -> ``$($unpackedDirectory.Replace('/','\'))`` -> ``s stop -ProjectPath .``
- Chrome profile boundary: ShipGlows opens the extension manager and generated directory but never installs the extension automatically in a personal profile.
"@).TrimEnd() + "`n"
    } else { '' }
    $obsidianGuidance = if ($Kind -eq 'obsidian-plugin') {
(@"
- Obsidian vault: declare one absolute path with ``SHIPGLOWS_OBSIDIAN_VAULT`` in ``.shipglows.env``.
- Artifact sync: ``SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy``; ShipGlows never creates links or selects a personal vault.
- Plugin workflow: ``s start -ProjectPath .`` -> ``s open -ProjectPath .`` or ``s obsidian-lab -ProjectPath .``.
- Load validation: watcher/build and exact artifact copy are reported separately from Obsidian's actual plugin load state.
"@).TrimEnd() + "`n"
    } else { '' }
    $block = @'
<!-- >>> ShipGlows development environment >>> -->
## ShipGlows development environment

- Environment schema: `{2}`
- Server manager: `shipglows-devserver`
- Project kind: `{3}`
- Assigned port: `{0}`
- Canonical local URL: `{1}`
{4}{5}- Live status authority: Windows ShipGlows DevServer registry

Use the assigned URL for ordinary web projects. Browser extensions use their generated unpacked directory and browser extension manager instead of a normal page URL. Do not substitute framework defaults such as Astro/Vite `4321` or a port from another project. Read the ShipGlows registry for `running` or `stopped`; this durable document is not rewritten on start or stop.
<!-- <<< ShipGlows development environment <<< -->
'@ -f $portValue,$urlValue,$script:ProjectEnvironmentSchema,$Kind,$extensionGuidance,$obsidianGuidance
    $remainderText = if ($managed.Exists) { $existing.Remove($managed.Match.Index, $managed.Match.Length) } else { $existing }
    $remainder = $remainderText.Trim([char[]]"`r`n")
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
    $managed = Get-SgProjectEnvironmentBlock $content
    if (-not $managed.Exists -or $managed.Match.Value -notmatch '(?m)^- Server manager: `shipglows-devserver`\r?$') { return $null }
    $port = 0
    if ($managed.Match.Value -match '(?m)^- Assigned port: `(\d+)`\r?$') { $port = [int]$Matches[1] }
    if ($port -ne 0 -and ($port -lt 1024 -or $port -gt 65535)) { throw "Invalid assigned port in $path." }
    $kind = if ($managed.Match.Value -match '(?m)^- Project kind: `([^`]+)`\r?$') { [string]$Matches[1] } else { '' }
    $url = if ($kind -notin @('browser-extension','obsidian-plugin') -and $port -gt 0) { "http://127.0.0.1:$port" } else { '' }
    [pscustomobject]@{ Path=$path; Port=$port; Url=$url; Kind=$kind; Manager='shipglows-devserver'; Schema=$managed.Schema }
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
            $durableEnvironment = Get-SgProjectEnvironment $launchPath
            $durablePort = if ($durableEnvironment -and $durableEnvironment.Port -gt 0) { [int]$durableEnvironment.Port } else { 0 }
            $existing = @($data.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $launchPath.ToLowerInvariant() })
            $portInUse = $durablePort -gt 0 -and @($data.projects | Where-Object { (Get-SgRunnableIdentity $_) -ne $launchPath.ToLowerInvariant() -and [int]$_.port -eq $durablePort }).Count -gt 0
            $initialPort = if ($portInUse) { 0 } else { $durablePort }
            $name = Get-SgCanonicalSurfaceName $root $launchPath
            if ($existing.Count -eq 0) {
                $newEntry = [pscustomobject]@{
                    name = $name; path = $launchPath; rootPath = $root; launchPath = $launchPath; kind = $descriptor.Kind
                    port = $initialPort; status = 'stopped'; pid = 0; startTimeUtc = $null; executablePath = $null
                    commandSignature = $null; logPath = $null; errorLogPath = $null; lastError = $null
                    reservationToken = $null; reservationTimeUtc = $null
                }
                if ($descriptor.Kind -eq 'obsidian-plugin') {
                    $plugin = Get-SgObsidianPluginDescriptor $launchPath
                    $newEntry | Add-Member -NotePropertyName surfaceState -NotePropertyValue ([string]$plugin.SurfaceState) -Force
                    $newEntry | Add-Member -NotePropertyName pluginId -NotePropertyValue ([string]$plugin.PluginId) -Force
                }
                $data.projects += $newEntry
            } else {
                $existing[0] | Add-Member -NotePropertyName rootPath -NotePropertyValue $root -Force
                $existing[0] | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
                $existing[0] | Add-Member -NotePropertyName name -NotePropertyValue $name -Force
                $existing[0].path = $launchPath
                $existing[0].kind = $descriptor.Kind
                if ($descriptor.Kind -eq 'obsidian-plugin') {
                    $plugin = Get-SgObsidianPluginDescriptor $launchPath
                    $existing[0] | Add-Member -NotePropertyName surfaceState -NotePropertyValue ([string]$plugin.SurfaceState) -Force
                    $existing[0] | Add-Member -NotePropertyName pluginId -NotePropertyValue ([string]$plugin.PluginId) -Force
                }
                if ([int]$existing[0].port -le 0 -and $initialPort -gt 0) { $existing[0].port = $initialPort }
            }
        }
    }
    Clear-SgProjectCatalogCache $Config
    $launchPaths = @($descriptors | ForEach-Object { [IO.Path]::GetFullPath([string]$_.LaunchPath).TrimEnd('\','/') })
    $registered = @($registry.projects | Where-Object { $_.path -in $launchPaths })
    foreach ($entry in $registered) {
        $durable = Get-SgProjectEnvironment $entry.path
        $durableCollision = [int]$entry.port -le 0 -and $durable -and $durable.Port -gt 0 -and @($registry.projects | Where-Object { $_.path -ne $entry.path -and [int]$_.port -eq [int]$durable.Port }).Count -gt 0
        [void](Write-SgProjectEnvironment $entry.path ([int]$entry.port) ([string]$entry.kind) -ReplaceDurablePort:$durableCollision)
    }
    return $registered
}

function Sync-SgRegisteredProjectEnvironments([object]$Config) {
    $roots = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $paths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @((Read-SgRegistry $Config).projects)) {
        $candidate = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } else { [string]$entry.path }
        if ([string]::IsNullOrWhiteSpace($candidate) -or -not (Test-Path -LiteralPath $candidate -PathType Container)) { continue }
        $root = [IO.Path]::GetFullPath($candidate).TrimEnd('\','/')
        if (-not $roots.Add($root)) { continue }
        try {
            foreach ($registered in @(Register-SgProject $Config $root)) { [void]$paths.Add([IO.Path]::GetFullPath([string]$registered.path)) }
        } catch {
            if ($_.Exception.Message -notlike 'No supported Windows launch target was detected at or below:*') { throw }
            Write-SgWarn "Skipping stale registered project root with no supported launch target: $root"
        }
    }
    return @($paths)
}

function Invoke-SgFlutterAndroidTool([string]$File, [string[]]$Arguments, [int]$TimeoutSeconds = 30) {
    $modulePath=Join-Path $PSScriptRoot 'ShipGlows.MobileToolchain.psm1'
    if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) { throw 'ShipGlows mobile toolchain transport is unavailable.' }
    Import-Module $modulePath -Force -DisableNameChecking
    return ShipGlows.MobileToolchain\Invoke-SgBoundedProcess -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds
}

function Get-SgFlutterAndroidDevices([string]$FlutterPath, [scriptblock]$Runner = $null) {
    if (-not $Runner) { $Runner = { param($File,$Arguments) Invoke-SgFlutterAndroidTool $File $Arguments 30 } }
    $result=& $Runner $FlutterPath @('devices','--machine')
    if (-not $result -or [int]$result.ExitCode -ne 0) { throw 'Flutter could not enumerate Android devices.' }
    try { $devices=@(([string]$result.Output | ConvertFrom-Json -ErrorAction Stop)) } catch { throw 'Flutter returned invalid device inventory JSON.' }
    return @($devices | Where-Object { $_.targetPlatform -match '^android-' -and [string]$_.id -match '^[A-Za-z0-9._:-]{1,128}$' })
}

function Resolve-SgFlutterAndroidDevice([string]$FlutterPath, [string]$RequestedDeviceId = '', [string]$AvdName = 'ShipGlows_API_36', [scriptblock]$Runner = $null, [scriptblock]$Waiter = $null, [int]$TimeoutSeconds = 180) {
    if ($RequestedDeviceId -and $RequestedDeviceId -notmatch '^[A-Za-z0-9._:-]{1,128}$') { throw 'Invalid requested Flutter Android device identifier.' }
    if ($AvdName -notmatch '^[A-Za-z0-9._-]{1,64}$') { throw 'Invalid Android emulator name.' }
    if (-not $Runner) { $Runner = { param($File,$Arguments) Invoke-SgFlutterAndroidTool $File $Arguments 30 } }
    if (-not $Waiter) { $Waiter = { param($Milliseconds) Start-Sleep -Milliseconds $Milliseconds } }
    $devices=@(Get-SgFlutterAndroidDevices $FlutterPath $Runner)
    if ($RequestedDeviceId) {
        $requested=@($devices | Where-Object { [string]$_.id -ceq $RequestedDeviceId }) | Select-Object -First 1
        if (-not $requested) { throw "Requested Android device is not connected: $RequestedDeviceId" }
        return [string]$requested.id
    }
    if ($devices.Count -gt 0) {
        $preferred=@($devices | Where-Object { $_.emulator -eq $true } | Sort-Object name,id | Select-Object -First 1)
        if ($preferred.Count -eq 0) { $preferred=@($devices | Sort-Object name,id | Select-Object -First 1) }
        return [string]$preferred[0].id
    }
    $launch=& $Runner $FlutterPath @('emulators','--launch',$AvdName)
    if (-not $launch -or [int]$launch.ExitCode -ne 0) { throw "Android emulator could not start: $AvdName" }
    $deadline=[datetime]::UtcNow.AddSeconds([Math]::Max(1,$TimeoutSeconds))
    do {
        & $Waiter 1000
        $devices=@(Get-SgFlutterAndroidDevices $FlutterPath $Runner)
        if ($devices.Count -gt 0) { $first=@($devices | Sort-Object name,id)[0]; return [string]$first.id }
    } while ([datetime]::UtcNow -lt $deadline)
    throw "Android emulator did not become ready within $TimeoutSeconds seconds: $AvdName"
}

# Git checkout facts read from .git without a subprocess. RepositoryRoot is the main
# checkout (null outside Git); IsLinkedWorktree marks `git worktree add` checkouts.
function Get-SgGitCheckoutInfo([string]$Path) {
    $current = [IO.Path]::GetFullPath($Path).TrimEnd('\','/')
    while ($current) {
        $dotGit = Join-Path $current '.git'
        if ([IO.Directory]::Exists($dotGit)) { return [pscustomobject]@{RepositoryRoot=$current;IsLinkedWorktree=$false} }
        if ([IO.File]::Exists($dotGit)) {
            $gitDir = ([IO.File]::ReadAllText($dotGit) -replace '^\s*gitdir:\s*','').Trim()
            if (-not [IO.Path]::IsPathRooted($gitDir)) { $gitDir = Join-Path $current $gitDir }
            $gitDir = [IO.Path]::GetFullPath($gitDir).TrimEnd('\','/')
            if ($gitDir -match '^(?<common>.+)[\\/]worktrees[\\/][^\\/]+$') { return [pscustomobject]@{RepositoryRoot=(Split-Path $Matches['common'] -Parent);IsLinkedWorktree=$true} }
            return [pscustomobject]@{RepositoryRoot=$current;IsLinkedWorktree=$false}
        }
        $parent = Split-Path $current -Parent
        if (-not $parent -or $parent -eq $current) { break }
        $current = $parent
    }
    [pscustomobject]@{RepositoryRoot=$null;IsLinkedWorktree=$false}
}

$script:SgDevShortcutMarkerPrefixes = @('ShipGlows managed Dev shortcut v2 | ','ShipGlows managed Flutter Dev shortcut v1 | ')

# Project path recorded by a ShipGlows Dev shortcut description, or $null for a foreign shortcut.
function Get-SgDevShortcutOwner([string]$Description) {
    foreach ($prefix in $script:SgDevShortcutMarkerPrefixes) {
        if ($Description.StartsWith($prefix, [StringComparison]::Ordinal)) { return $Description.Substring($prefix.Length).Trim() }
    }
    $null
}

# The Desktop holds one `<repository>-<surface> - Dev` shortcut per live dev server (Tauri,
# Astro, Vite, Flutter) of a main checkout. Builds and linked worktrees never get one.
function Install-SgDevShortcut([object]$Entry, [string]$DesktopPath = '', [string]$LauncherPath = '') {
    if (-not $Entry -or [string]$Entry.kind -notin @('tauri','astro','vite','flutter-web')) { return $null }
    $projectPath = [IO.Path]::GetFullPath([string]$Entry.path).TrimEnd('\','/')
    $checkout = Get-SgGitCheckoutInfo $projectPath
    if ($checkout.IsLinkedWorktree) { Write-SgInfo 'Dev shortcut skipped: Git worktrees never get a Desktop shortcut.'; return $null }
    $desktop = if ($DesktopPath) { [IO.Path]::GetFullPath($DesktopPath) } else { [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop) }
    if ([string]::IsNullOrWhiteSpace($desktop) -or -not (Test-Path -LiteralPath $desktop -PathType Container)) { throw 'The Windows Desktop directory is unavailable.' }
    $launcher = if ($LauncherPath) { [IO.Path]::GetFullPath($LauncherPath) } else { Join-Path $PSScriptRoot 'shipglows-dev.cmd' }
    if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) { throw 'The managed ShipGlows DevServer launcher is unavailable.' }
    $displayName = if ($checkout.RepositoryRoot) { Get-SgCanonicalSurfaceName $checkout.RepositoryRoot $projectPath } else { [string]$Entry.name }
    if ([string]::IsNullOrWhiteSpace($displayName) -or $displayName.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) { throw 'The project name cannot be used for a Windows Dev shortcut.' }
    $path = Join-Path $desktop ("$displayName - Dev.lnk")
    $shell = New-Object -ComObject WScript.Shell
    if ((Test-Path -LiteralPath $path -PathType Leaf) -and $null -eq (Get-SgDevShortcutOwner ([string]$shell.CreateShortcut($path).Description))) {
        Write-SgWarn "Dev shortcut skipped: $path is not owned by ShipGlows."
        return $null
    }
    $device = if ($Entry.PSObject.Properties['flutterDevice']) { [string]$Entry.flutterDevice } else { '' }
    $opensBrowser = $Entry.kind -in @('astro','vite') -or ($Entry.kind -eq 'flutter-web' -and $device -notin @('windows','android'))
    $temporary = Join-Path $desktop ('.shipglows-dev-shortcut-' + [guid]::NewGuid().ToString('N') + '.lnk')
    try {
        $shortcut = $shell.CreateShortcut($temporary)
        $shortcut.TargetPath = $launcher
        $shortcut.Arguments = "start -ProjectPath `"$projectPath`"" + $(if ($opensBrowser) { ' -Open' } else { '' })
        $shortcut.WorkingDirectory = $projectPath
        $shortcut.Description = "$($script:SgDevShortcutMarkerPrefixes[0])$projectPath"
        $shortcut.Save()
        Move-Item -LiteralPath $temporary -Destination $path -Force
    } finally { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
    # Retire this project's managed shortcuts under older names and those left by deleted or worktree checkouts.
    foreach ($candidate in @(Get-ChildItem -LiteralPath $desktop -Filter '*.lnk' -File)) {
        if ($candidate.FullName -eq $path) { continue }
        try {
            $owner = Get-SgDevShortcutOwner ([string]$shell.CreateShortcut($candidate.FullName).Description)
            if ($null -eq $owner) { continue }
            $ownerPath = [IO.Path]::GetFullPath($owner).TrimEnd('\','/')
            if ($ownerPath -eq $projectPath -or -not (Test-Path -LiteralPath $ownerPath -PathType Container) -or (Get-SgGitCheckoutInfo $ownerPath).IsLinkedWorktree) { Remove-Item -LiteralPath $candidate.FullName -Force }
        } catch { Write-SgWarn "Stale Dev shortcut left in place: $($candidate.Name)" }
    }
    Write-SgInfo "Dev shortcut ready: $displayName - Dev"
    return $path
}

function Start-SgProjectCore([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0, [switch]$FlutterVisible, [switch]$RetryingFlutterStartup, [ValidateSet('','windows','android','chrome','web-server')][string]$FlutterDevice = '', [string]$FlutterDeviceId = '', [ValidateSet('','debug','profile')][string]$FlutterMode = '', [switch]$Restart) {
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
    $alreadyRunning = Test-SgProcessIdentity $entry
    if ($alreadyRunning -and -not $Restart -and [string]$entry.kind -ne 'flutter-web') { Write-SgInfo "Already running: $($entry.name) on $($entry.port)"; return $entry }
    $settings = Get-SgRuntimeSettings $entry.path
    $obsidianDescriptor = $null
    $obsidianVault = $null
    if ([string]$entry.kind -eq 'obsidian-plugin') {
        $obsidianDescriptor = Get-SgObsidianPluginDescriptor $entry.path
        if (-not $obsidianDescriptor) { throw 'Obsidian plugin metadata is no longer valid.' }
        $obsidianVault = Resolve-SgObsidianVault ([string]$settings.ObsidianVault) ([string]$obsidianDescriptor.PluginId)
        if ([string]$settings.ObsidianSyncMode -ne 'copy') { throw 'Only SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy is supported; links are never invented.' }
    }
    if ($FlutterDevice) {
        if ([string]$entry.kind -ne 'flutter-web') { throw 'Flutter target selection requires a Flutter project.' }
        $settings.FlutterDevice=$FlutterDevice
        $settings.FlutterDeviceId=if($FlutterDevice -eq 'android'){$FlutterDeviceId}else{$FlutterDevice}
    } elseif ($FlutterDeviceId) { throw 'FlutterDeviceId requires an explicit Android FlutterDevice.' }
    if ($FlutterMode) {
        if ([string]$entry.kind -ne 'flutter-web') { throw 'Flutter mode selection requires a Flutter project.' }
        $settings.FlutterMode=$FlutterMode
    }
    $resolvedFlutterDevice = [string]$settings.FlutterDevice
    $resolvedFlutterMode = if ([string]$settings.FlutterMode) { [string]$settings.FlutterMode } else { 'debug' }
    if ([string]$entry.kind -eq 'flutter-web' -and $settings.FlutterDevice -eq 'android') {
        $flutterPath=Get-SgFlutterCommandPath
        if (-not $flutterPath) { throw 'Flutter SDK is unavailable for Android device discovery.' }
        $resolvedFlutterDevice=Resolve-SgFlutterAndroidDevice $flutterPath ([string]$settings.FlutterDeviceId)
        $settings.FlutterDeviceId=$resolvedFlutterDevice
    }
    $configuredPort = $RequestedPort
    if ($configuredPort -le 0 -and $env:SHIPGLOWS_ENV_PORT) {
        if ($env:SHIPGLOWS_ENV_PORT -notmatch '^\d+$' -or [int]$env:SHIPGLOWS_ENV_PORT -lt 1024 -or [int]$env:SHIPGLOWS_ENV_PORT -gt 65535) { throw 'SHIPGLOWS_ENV_PORT must be a port between 1024 and 65535.' }
        $configuredPort = [int]$env:SHIPGLOWS_ENV_PORT
    }
    if ($configuredPort -le 0 -and $settings.Port -gt 0) { $configuredPort = [int]$settings.Port }
    if ($configuredPort -le 0) {
        $projectEnvironment = Get-SgProjectEnvironment $entry.path
        if ($projectEnvironment -and $projectEnvironment.Port -gt 0) { $configuredPort = [int]$projectEnvironment.Port }
    }
    $flutterConfiguration = $null
    if ([string]$entry.kind -eq 'flutter-web') {
        $configurationPort = if ($configuredPort -gt 0) { $configuredPort } else { [int]$entry.port }
        if ($configuredPort -le 0 -and $settings.FlutterDevice -in @('chrome','web-server')) {
            if (-not $alreadyRunning -or $configurationPort -le 0) { $configurationPort = Get-SgFreePort $Config 0 $entry.path }
            $configuredPort = $configurationPort
        }
        $flutterConfiguration = Get-SgFlutterConfiguration $entry.path $settings $configurationPort
        if ($alreadyRunning) {
            if (-not $Restart -and (Test-SgFlutterSessionConfiguration $entry $flutterConfiguration)) {
                Write-SgInfo "Already running with verified Flutter configuration: $($entry.name)"
                return $entry
            }
            [void](Resolve-SgPowerShellExecutable)
            if (-not (Get-SgFlutterCommandPath)) { throw 'Flutter SDK is unavailable; the existing session was preserved.' }
            Write-SgInfo 'Flutter target or configuration changed; restarting the managed session.'
            [void](Stop-SgProject $Config $entry.path -PreserveBackend)
            if (Test-SgProcessIdentity $entry) { throw 'Cannot replace Flutter configuration while the previous session is still active.' }
        }
    }
    if ($alreadyRunning -and $Restart -and [string]$entry.kind -ne 'flutter-web') { [void](Stop-SgProject $Config $entry.path -PreserveBackend) }
    $explicitPort = $configuredPort -gt 0
    $previousPort = [int]$entry.port
    $flutterNative = [string]$entry.kind -eq 'flutter-web' -and $settings.FlutterDevice -in @('windows','android')
    $reservation = Reserve-SgProjectPort $Config $entry.path $configuredPort $explicitPort -NoPort:([string]$entry.kind -eq 'obsidian-plugin' -or $flutterNative) -PreservePort:$flutterNative
    $port = $reservation.Port
    $reservationToken = $reservation.Token
    if ([string]$entry.kind -eq 'obsidian-plugin') { Write-SgInfo 'Obsidian plugin watch has no HTTP port.' }
    elseif ($flutterNative) { Write-SgInfo "Flutter $($settings.FlutterDevice) target needs no HTTP port reservation." }
    elseif ($explicitPort) { Write-SgInfo "Using configured port: $port" }
    elseif ($previousPort -gt 0 -and $previousPort -eq $port) { Write-SgInfo "Reusing persistent port: $port" }
    else { Write-SgInfo "Assigned port: $port" }
    $logDir = Join-Path $Config.LogDirectory (Get-SgProjectLogKey $entry)
    Ensure-SgDirectory $logDir
    $out = Join-Path $logDir 'stdout.log'; $err = Join-Path $logDir 'stderr.log'
    $setupLog = Join-Path $logDir 'setup.log'
    foreach ($logPath in @($out,$err,$setupLog)) { Rotate-SgLogFile $logPath }
    $launchPath = if ($entry.PSObject.Properties['launchPath'] -and $entry.launchPath) { [string]$entry.launchPath } else { [string]$entry.path }
    $kind = [string]$entry.kind
    $flutterProfilePath = $null
    $flutterLaunchDirectory = $null
    $flutterTokenPath = $null
    $flutterLaunchIdentity = $null
    if ($kind -eq 'flutter-web' -and $settings.FlutterDevice -eq 'chrome') {
        $flutterLaunchDirectory = Join-Path $Config.RuntimeDirectory ("flutter-launch\{0}" -f $reservationToken)
        $flutterProfilePath = Join-Path $flutterLaunchDirectory 'chrome-profile'
        Ensure-SgDirectory $flutterProfilePath
    } elseif ($kind -eq 'flutter-web') {
        $flutterLaunchDirectory = Join-Path $Config.RuntimeDirectory ("flutter-launch\{0}" -f $reservationToken)
        Ensure-SgDirectory $flutterLaunchDirectory
    }
    if ($kind -eq 'flutter-web') {
        Protect-SgOwnerOnlyPath $flutterLaunchDirectory
        $bytes=New-Object byte[] 32;[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes);$flutterToken=([BitConverter]::ToString($bytes)).Replace('-','').ToLowerInvariant()
        $flutterTokenPath=Join-Path $flutterLaunchDirectory 'token';[IO.File]::WriteAllText($flutterTokenPath,$flutterToken,(New-Object Text.UTF8Encoding($false)));Protect-SgOwnerOnlyPath $flutterTokenPath
        $flutterLaunchIdentity="ShipGlowsFlutter-$reservationToken"
        if ($flutterConfiguration -and $flutterConfiguration.HasRecipe) {
            $settings.DartDefineFile = Join-Path $flutterLaunchDirectory 'public-defines.json'
            [IO.File]::WriteAllText($settings.DartDefineFile,($flutterConfiguration.Defines | ConvertTo-Json -Compress),(New-Object Text.UTF8Encoding($false)))
            Protect-SgOwnerOnlyPath $settings.DartDefineFile
        }
    }
    try {
        Invoke-SgDependencySetup $Config $launchPath $kind $setupLog | Out-Null
        if ($kind -eq 'astro') { [void](Repair-SgStaleAstroDevLock $launchPath) }
        $launch = Get-SgLaunchSpec $launchPath $kind $port ([bool]$FlutterVisible) $flutterProfilePath $resolvedFlutterDevice $settings.DartDefineFile $flutterLaunchDirectory $flutterLaunchIdentity $resolvedFlutterMode
    } catch {
        Release-SgProjectPort $Config $entry.path $reservationToken $_.Exception.Message
        throw
    }
    $launchEnvironment = @{}
    $launchEnvironment['PORT'] = [string]$port
    if ($kind -eq 'flutter-web') { $launchEnvironment['SHIPGLOWS_SUPERVISOR_TOKEN'] = $flutterToken }
    if ($flutterConfiguration) { foreach ($key in $flutterConfiguration.Environment.Keys) { $launchEnvironment[$key] = [string]$flutterConfiguration.Environment[$key] } }
    if ($kind -eq 'astro') { $launchEnvironment['ASTRO_DEV_BACKGROUND'] = '0' }
    try {
        Set-SgReservationState $Config $entry.path $reservationToken 'starting'
        $process = Start-SgDetachedProcess $launch.FilePath $launch.Arguments $launchPath $out $err $launchEnvironment $flutterTokenPath
        Start-Sleep -Milliseconds 350
        $snapshot = Get-SgProcessSnapshot $process.Id
        if (-not $snapshot) { throw "Process exited before it could be recorded. See $err" }
    } catch {
        Release-SgProjectPort $Config $entry.path $reservationToken $_.Exception.Message
        throw
    }
    $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } else { [string]$entry.path }
    $entryData = [pscustomobject]@{ name = $entry.name; path = $entry.path; rootPath = $rootPath; launchPath = $launchPath; kind = $kind; port = $port; status = 'starting'; pid = $snapshot.Pid; startTimeUtc = $snapshot.StartTimeUtc; executablePath = $snapshot.ExecutablePath; commandSignature = $process.CommandSignature; jobName = $(if ($process.PSObject.Properties['JobName']) { $process.JobName } else { $null }); logPath = $out; errorLogPath = $err; lastError = $null; surfaceState = $(if($kind-eq'obsidian-plugin'){'starting'}else{$null}); pluginId = $(if($obsidianDescriptor){[string]$obsidianDescriptor.PluginId}else{$null}); validationState = $(if($kind-eq'obsidian-plugin'){'validation-unavailable'}else{$null}); flutterStartupState = $(if($kind-eq'flutter-web'){'starting'}else{$null}); flutterAppId = $null; flutterDaemonPid = 0; flutterHeadless = ($kind -eq 'flutter-web' -and $settings.FlutterDevice -eq 'chrome' -and -not [bool]$FlutterVisible); flutterDevice = $(if ($kind -eq 'flutter-web') { $settings.FlutterDevice } else { $null }); flutterDeviceId = $(if ($kind -eq 'flutter-web') { $resolvedFlutterDevice } else { $null }); flutterMode = $(if ($kind -eq 'flutter-web') { $resolvedFlutterMode } else { $null }); browserProfilePath = $flutterProfilePath; flutterLaunchDirectory=$flutterLaunchDirectory; flutterTokenPath=$flutterTokenPath }
    if($kind-eq'flutter-web'){$sdkRoot=if($launch.PSObject.Properties['FlutterSdkRoot']){$launch.FlutterSdkRoot}else{$null};$entryData|Add-Member -NotePropertyName flutterSdkRoot -NotePropertyValue $sdkRoot -Force;$entryData|Add-Member -NotePropertyName flutterConfigurationFingerprint -NotePropertyValue $flutterConfiguration.Fingerprint -Force}
    Set-SgReservationState $Config $entry.path $reservationToken 'starting' $entryData
    if (-not (Test-SgProcessIdentity $entryData)) {
        if($kind-eq'flutter-web'){
            Copy-SgFlutterDiagnostics $entryData $out $err
            [void](Stop-SgOwnedFlutterNative $entryData)
            if(Wait-SgFlutterOwnedExtinction $entryData 2){try{[void](Remove-SgFlutterLaunchArtifacts $Config $entryData)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}else{$entryData.status='error';$entryData.flutterStartupState='error';$entryData.lastError=Get-SgStartupFailure $err;Set-SgReservationState $Config $entry.path $reservationToken 'error' $entryData;throw 'Flutter supervisor exited during startup and owned process extinction could not be proved.'}
        }
        Write-SgWarn "Process exited during startup. See $err"
        $entryData.status = 'error'
        $entryData.lastError = Get-SgStartupFailure $err
        $entryData.pid = 0
        $entryData.startTimeUtc = $null
        Release-SgProjectPort $Config $entry.path $reservationToken $entryData.lastError
        if(-not$RetryingFlutterStartup-and$resolvedFlutterDevice-eq'windows'-and(Test-SgFlutterStartupRetryable $entryData.lastError)){Move-SgFlutterRetryDiagnostics $out $err;Write-SgWarn 'Flutter debug connection failed during startup; retrying once after verified cleanup.';return Start-SgProjectCore $Config $ProjectPath $RequestedPort -FlutterVisible:$FlutterVisible -RetryingFlutterStartup -FlutterDevice $FlutterDevice -FlutterDeviceId $FlutterDeviceId -FlutterMode $FlutterMode}
        return $entryData
    }
    [void](Write-SgProjectEnvironment $entry.path $port $kind)
    $readyTimeout = if ([int]$settings.ReadyTimeoutSeconds -gt 0) { [int]$settings.ReadyTimeoutSeconds } else { 0 }
    $readiness = if($kind -eq 'flutter-web'){$(if($resolvedFlutterDevice-eq'windows'){Wait-SgFlutterSupervisorReady (Join-Path $flutterLaunchDirectory 'state.json') 90 $entryData 1800 @((Join-Path $launchPath 'build\windows'),(Join-Path $launchPath '.dart_tool\flutter_build')) 300}else{Wait-SgFlutterSupervisorReady (Join-Path $flutterLaunchDirectory 'state.json') 90 $entryData 600})}elseif($kind-eq'browser-extension'){Wait-SgBrowserExtensionReady $launchPath $port $(if($readyTimeout){$readyTimeout}else{90}) $entryData $err}elseif($kind-eq'obsidian-plugin'){Wait-SgObsidianPluginReady $launchPath $(if($readyTimeout){$readyTimeout}else{90}) $entryData $err}else{Wait-SgProjectReady $kind $port $out $(if($readyTimeout){$readyTimeout}else{300}) $entryData $err}
    if ($readiness.Ready) {
        $entryData.status = 'running'
        if ($kind -eq 'obsidian-plugin') {
            $sync = Sync-SgObsidianPluginArtifacts $obsidianDescriptor $obsidianVault.VaultPath
            $entryData.surfaceState = 'ready'
            $entryData.validationState = 'validation-unavailable'
            $entryData | Add-Member -NotePropertyName obsidianPluginPath -NotePropertyValue ([string]$sync.TargetPath) -Force
            $entryData | Add-Member -NotePropertyName obsidianArtifactPaths -NotePropertyValue @($readiness.ArtifactPaths) -Force
        }
        if($kind-eq'flutter-web'){$entryData.flutterStartupState='running'}
        $entryData.flutterAppId = $readiness.AppId
        if($readiness.PSObject.Properties['DaemonPid']){$entryData.flutterDaemonPid=[int]$readiness.DaemonPid}
        Set-SgReservationState $Config $entry.path $reservationToken 'running' $entryData
        try { Start-SgManagedProcessExitMonitor $Config $entry.path ([int]$snapshot.Pid) ([string]$snapshot.StartTimeUtc) } catch { Write-SgWarn "Process exit monitoring could not start: $($_.Exception.Message)" }
        try { [void](Install-SgDevShortcut $entryData) } catch { Write-SgWarn "Dev shortcut skipped: $($_.Exception.Message)" }
    } else {
        $entryData.status = 'error'
        if($kind-eq'flutter-web'){$entryData.flutterStartupState='error'}
        if($kind-eq'flutter-web'){$entryData.flutterStartupState='error'}
        $entryData.lastError = if ($readiness.Error) { [string]$readiness.Error } else { 'Application readiness failed.' }
        $jobStopped=$false;if ($entryData.jobName) { $jobStopped=[bool](Stop-SgManagedJob $entryData) }
        if(-not$jobStopped-and(Test-SgProcessIdentity $entryData)){Stop-SgProcessTree ([int]$entryData.pid)}
        if($kind-eq'flutter-web'){
            [void](Stop-SgOwnedFlutterBrowser $entryData)
            [void](Stop-SgOwnedFlutterListener $entryData)
            [void](Stop-SgOwnedFlutterNative $entryData)
            Copy-SgFlutterDiagnostics $entryData $out $err
            if(Wait-SgFlutterOwnedExtinction $entryData 8){try{[void](Remove-SgFlutterLaunchArtifacts $Config $entryData)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}else{Write-SgWarn 'Flutter processes did not prove extinction; launch diagnostics were preserved.'}
        }
        if (-not (Wait-SgManagedExtinction $entryData 8)) {$entryData.status='error';Set-SgReservationState $Config $entry.path $reservationToken 'error' $entryData;throw 'Application readiness failed and managed process extinction could not be proved.' }
        $entryData.pid = 0
        $entryData.startTimeUtc = $null
        Release-SgProjectPort $Config $entry.path $reservationToken $entryData.lastError
        $diagnosticFailure=Get-SgStartupFailure $err $entryData.lastError
        if(-not$RetryingFlutterStartup-and$resolvedFlutterDevice-eq'windows'-and(Test-SgFlutterStartupRetryable $diagnosticFailure)){Move-SgFlutterRetryDiagnostics $out $err;Write-SgWarn 'Flutter debug connection failed during startup; retrying once after verified cleanup.';return Start-SgProjectCore $Config $ProjectPath $RequestedPort -FlutterVisible:$FlutterVisible -RetryingFlutterStartup -FlutterDevice $FlutterDevice -FlutterDeviceId $FlutterDeviceId -FlutterMode $FlutterMode}
    }
    if($kind-eq'obsidian-plugin'){
        Write-SgInfo "$($entry.name) running: artifacts copied to $($entryData.obsidianPluginPath); Obsidian load validation is unavailable."
    }elseif($kind-eq'browser-extension'){
        Write-SgInfo "$($entry.name) $($entryData.status): Manifest V3 build ready in $(Get-SgBrowserExtensionUnpackedDirectory $entry.path)"
        Write-SgInfo "Next: run s open -ProjectPath `"$($entry.path)`" to open Chrome extension tools."
    }elseif($kind-eq'flutter-web' -and $settings.FlutterDevice -in @('windows','android')){
        Write-SgInfo "$($entry.name) $($entryData.status): managed Flutter $($settings.FlutterDevice) app ($resolvedFlutterMode mode)"
    }else{Write-SgInfo "$($entry.name) $($entryData.status): http://127.0.0.1:$port"}
    return $entryData
}

function Stop-SgProcessTree([int]$RootPid) {
    $all = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $ids = New-Object System.Collections.Generic.List[int]
    $visited = New-Object 'System.Collections.Generic.HashSet[int]'
    function Add-ProcessPostOrder([int]$Parent) {
        if(-not$visited.Add($Parent)){return}
        foreach($child in @($all|Where-Object{$_.ParentProcessId-eq$Parent})){Add-ProcessPostOrder ([int]$child.ProcessId)}
        [void]$ids.Add($Parent)
    }
    Add-ProcessPostOrder $RootPid
    foreach ($pid in @($ids)) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
}

function Get-SgOwnedFlutterListenerPids([object]$Entry) {
    if (-not $Entry -or $Entry.kind -ne 'flutter-web' -or [int]$Entry.port -le 0) { return @() }
    if (-not (Test-SgTcpPortListening ([int]$Entry.port))) { return @() }
    $listeners = @(Get-NetTCPConnection -LocalPort ([int]$Entry.port) -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return @() }

    $projectPath = [IO.Path]::GetFullPath($(if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path })).TrimEnd('\','/').ToLowerInvariant()
    $projectPattern = [regex]::Escape($projectPath) + '(?:[\\/"''\s]|$)'
    $signature = if ($Entry.PSObject.Properties['commandSignature']) { ([string]$Entry.commandSignature).ToLowerInvariant() } else { '' }
    $managedPaths=@();foreach($property in @('browserProfilePath','flutterLaunchDirectory')){if($Entry.PSObject.Properties[$property]-and$Entry.$property){$managedPaths+=[IO.Path]::GetFullPath([string]$Entry.$property).TrimEnd('\','/').ToLowerInvariant()}}
    $managedPatterns=@($managedPaths|ForEach-Object{'(?i)(?:^|[\s"''])'+[regex]::Escape($_)+'(?:[\s"'']|$)'})
    $processes = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $byId = @{}
    foreach ($process in $processes) { $byId[[int]$process.ProcessId] = $process }

    $owned = @()
    foreach ($listener in $listeners) {
        $listenerPid = [int]$listener.OwningProcess
        if(-not$byId.ContainsKey($listenerPid)-or-not$Entry.PSObject.Properties['flutterSdkRoot']-or-not$Entry.flutterSdkRoot-or$managedPatterns.Count-eq0){continue}
        $process=$byId[$listenerPid]
        try{$executable=[IO.Path]::GetFullPath([string]$process.ExecutablePath);$sdkDartRoot=[IO.Path]::GetFullPath((Join-Path ([string]$Entry.flutterSdkRoot) 'bin\cache\dart-sdk\bin'));$allowedExecutables=@([IO.Path]::GetFullPath((Join-Path $sdkDartRoot 'dart.exe')),[IO.Path]::GetFullPath((Join-Path $sdkDartRoot 'dartvm.exe')))}catch{continue}
        $executableAllowed=@($allowedExecutables|Where-Object{$executable.Equals($_,[StringComparison]::OrdinalIgnoreCase)}).Count-eq 1
        if(-not$executableAllowed){continue}
        $commandLine=[string]$process.CommandLine;$managedEvidence=$false;foreach($managedPattern in $managedPatterns){if($commandLine-match$managedPattern){$managedEvidence=$true;break}}
        if($managedEvidence){$owned+=$listenerPid}
    }
    return @($owned | Sort-Object -Unique)
}

function Stop-SgOwnedFlutterListener([object]$Entry) {
    $ownedPids = @(Get-SgOwnedFlutterListenerPids $Entry)
    foreach ($ownedPid in $ownedPids) { Stop-SgProcessTree $ownedPid }
    return $ownedPids.Count -gt 0
}

function Get-SgOwnedFlutterBrowserPids([object]$Entry) {
    if (-not $Entry -or $Entry.kind -ne 'flutter-web' -or -not $Entry.PSObject.Properties['browserProfilePath'] -or [string]::IsNullOrWhiteSpace([string]$Entry.browserProfilePath)) { return @() }
    $profile = [IO.Path]::GetFullPath([string]$Entry.browserProfilePath).TrimEnd('\','/')
    $profilePattern = '(?i)(?:^|\s)--user-data-dir=(?:"' + [regex]::Escape($profile) + '"|' + [regex]::Escape($profile) + ')(?:\s|$)'
    $owned = @()
    foreach ($process in @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)) {
        $executable = [string]$process.ExecutablePath
        $commandLine = [string]$process.CommandLine
        if ($executable -notmatch '(?i)(?:chrome|msedge)\.exe$') { continue }
        if ($commandLine -match $profilePattern) { $owned += [int]$process.ProcessId }
    }
    return @($owned | Sort-Object -Unique)
}

function Stop-SgOwnedFlutterBrowser([object]$Entry) {
    $ownedPids = @(Get-SgOwnedFlutterBrowserPids $Entry)
    foreach ($ownedPid in $ownedPids) { Stop-SgProcessTree $ownedPid }
    return $ownedPids.Count -gt 0
}

function Wait-SgManagedExtinction([object]$Entry, [int]$TimeoutSeconds = 8) {
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    $entryPort = if ($Entry.PSObject.Properties['port']) { [int]$Entry.port } else { 0 }
    do {
        $identityGone = -not (Test-SgProcessIdentity $Entry)
        $serviceGone = $entryPort -le 0 -or (Test-SgPortAvailable $entryPort)
        $nativeGone=$Entry.kind-ne'flutter-web'-or@(Get-SgOwnedFlutterNativePids $Entry).Count-eq0
        if ($identityGone -and $serviceGone -and $nativeGone) { return $true }
        if ((Get-Date) -ge $deadline) { return $false }
        Start-Sleep -Milliseconds 100
    } while ($true)
}

function Stop-SgProjectCore([object]$Config, [string]$ProjectPath, [switch]$PreserveBackend) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { return $false }
    $entryPort = if ($entry.PSObject.Properties['port']) { [int]$entry.port } else { 0 }
    $alreadyStopped = $entry.status -eq 'stopped' -and [int]$entry.pid -le 0
    $cleanedFlutterArtifacts=$false
    if($entry.kind -eq 'flutter-web' -and $alreadyStopped){try{$cleanedFlutterArtifacts=[bool](Remove-SgFlutterLaunchArtifacts $Config $entry)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}
    $stoppedBySupervisor=$false
    if($entry.kind -eq 'flutter-web' -and $entry.PSObject.Properties['flutterLaunchDirectory'] -and (Test-SgProcessIdentity $entry)){try{[void](Invoke-SgFlutterSupervisorCommand $entry 'stop' 8);$stoppedBySupervisor=$true}catch{Write-SgWarn "Flutter supervisor stop fallback: $($_.Exception.Message)"}}
    $stoppedFlutterListener = Stop-SgOwnedFlutterListener $entry
    $stoppedFlutterBrowser = Stop-SgOwnedFlutterBrowser $entry
    $stoppedFlutterNative = Stop-SgOwnedFlutterNative $entry
    $noRuntimeWork = $alreadyStopped -and -not $cleanedFlutterArtifacts -and -not $stoppedBySupervisor -and -not $stoppedFlutterListener -and -not $stoppedFlutterBrowser -and -not $stoppedFlutterNative
    if ((Test-Path -LiteralPath $path -PathType Container) -and -not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $path" }
    $stopped = $cleanedFlutterArtifacts -or $stoppedBySupervisor -or $stoppedFlutterListener -or $stoppedFlutterBrowser -or $stoppedFlutterNative
    $identityLive = Test-SgProcessIdentity $entry
    $serviceLive = $entryPort -gt 0 -and -not (Test-SgPortAvailable $entryPort)
    if (($identityLive -or $serviceLive) -and $entry.PSObject.Properties['jobName'] -and $entry.jobName) {
        if (-not (Stop-SgManagedJob $entry)) { throw "Managed process job is unavailable for $($entry.name); refusing an unverified stop." }
        $stopped = $true
    } elseif ($identityLive) {
        Stop-SgProcessTree ([int]$entry.pid)
        $stopped = $true
    } elseif (-not $stoppedBySupervisor -and -not $stoppedFlutterListener -and -not $stoppedFlutterBrowser -and -not $stoppedFlutterNative -and [int]$entry.pid -gt 0) {
        Write-SgWarn "Stale or unverified process for $($entry.name); no process was terminated."
    }
    if (-not (Wait-SgManagedExtinction $entry 8)) { throw "Could not prove process and service extinction for $($entry.name); registry state was preserved." }
    if (-not $PreserveBackend -and $entry.PSObject.Properties['backend']) { Stop-SgBackend $entry.backend }
    Invoke-SgRegistryMutation $Config {
        param($data)
        $found = @($data.projects | Where-Object { $_.path -eq $path })[0]
        if ($found) {
            if (-not $PreserveBackend -and $found.PSObject.Properties['backend']) { $found.backend.status='stopped' }
            $found.status = 'stopped'; $found.pid = 0; $found.startTimeUtc = $null; $found.lastError = $null;if($found.kind-eq'flutter-web'){$found|Add-Member -NotePropertyName flutterStartupState -NotePropertyValue 'stopped' -Force}
            if ($found.PSObject.Properties['reservationToken']) { $found.reservationToken = $null }
            if ($found.PSObject.Properties['reservationTimeUtc']) { $found.reservationTimeUtc = $null }
        }
    } | Out-Null
    if ($noRuntimeWork) { return $false }
    if($entry.kind -eq 'flutter-web'){try{[void](Remove-SgFlutterLaunchArtifacts $Config $entry)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}
    return $stopped
}

function Open-SgProject([object]$Config, [object]$Entry) {
    if (-not $Entry) { throw 'No registered project was selected.' }
    if ([string]$Entry.kind -eq 'obsidian-plugin') {
        $state = if ($Entry.PSObject.Properties['surfaceState'] -and $Entry.surfaceState) { [string]$Entry.surfaceState } else { 'detected' }
        $validation = if ($Entry.PSObject.Properties['validationState'] -and $Entry.validationState) { [string]$Entry.validationState } else { 'validation-unavailable' }
        Write-SgInfo "Obsidian plugin $state | $validation. Use s obsidian-lab -ProjectPath `"$([string]$Entry.path)`" for isolated load validation."
        return $Entry
    }
    if ($Entry.status -notin @('starting','running') -or [int]$Entry.port -le 0) {
        $name = if ($Entry.PSObject.Properties['name'] -and $Entry.name) { [string]$Entry.name } else { 'This project' }
        $path = if ($Entry.PSObject.Properties['path'] -and $Entry.path) { [string]$Entry.path } else { '<path>' }
        $flutterDevice = if ($Entry.PSObject.Properties['flutterDevice']) { [string]$Entry.flutterDevice } else { '' }
        $experience = Get-SgProjectExperience ([string]$Entry.kind) ([int]$Entry.port) $flutterDevice
        throw "$name is $($Entry.status) ($($experience.Label)). Run s start -ProjectPath `"$path`" before Open / load project."
    }
    if ($Entry.kind -eq 'browser-extension') {
        $projectPath = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path }
        $output = @(Get-SgBrowserExtensionManifestPaths $projectPath | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | ForEach-Object { Split-Path -Parent $_ }) | Select-Object -First 1
        if (-not $output) { throw 'The browser extension has no generated unpacked directory. Wait for the Chrome development build to finish.' }
        $browser = Get-SgExtensionManagerBrowser
        if ($browser) { Start-Process -FilePath $browser.ExecutablePath -ArgumentList $browser.ExtensionsUrl }
        else { Write-SgWarn 'No Chrome, Edge or Vivaldi installation was found; open the browser extensions page yourself.' }
        Start-Process $output
        $managerUrl = if ($browser) { $browser.ExtensionsUrl } else { 'chrome://extensions' }
        Write-SgInfo "Extension tools opened: $managerUrl and $output"
        Write-SgInfo '1. Enable Developer mode in the browser.'
        Write-SgInfo '2. Choose Load unpacked.'
        Write-SgInfo "3. Select $output. ShipGlows never installs the extension automatically in your personal Chrome profile."
        return $Entry
    }
    if ($Entry.kind -eq 'flutter-web' -and $Entry.PSObject.Properties['flutterHeadless'] -and [bool]$Entry.flutterHeadless) {
        $port = [int]$Entry.port
        [void](Invoke-SgFlutterSupervisorCommand $Entry 'open' 8)
        $deadline=(Get-Date).AddSeconds(8);while((Get-Date)-lt $deadline -and (Test-SgProcessIdentity $Entry)){Start-Sleep -Milliseconds 200}
        if(Test-SgProcessIdentity $Entry){throw 'Flutter supervisor did not stop after open; visible relaunch was refused.'}
        [void](Stop-SgOwnedFlutterListener $Entry);[void](Stop-SgOwnedFlutterBrowser $Entry)
        if(-not(Wait-SgFlutterOwnedExtinction $Entry 8)){throw 'Owned Flutter processes remain after open; visible relaunch was refused.'}
        [void](Remove-SgFlutterLaunchArtifacts $Config $Entry)
        return Start-SgProject $Config ([string]$Entry.path) $port -FlutterVisible
    }
    if ($Entry.kind -eq 'flutter-web' -and $Entry.PSObject.Properties['flutterDevice'] -and $Entry.flutterDevice -eq 'chrome') {
        Write-SgInfo 'Flutter is already running in its managed visible Chrome session.'
        return $Entry
    }
    if ($Entry.kind -eq 'flutter-web' -and $Entry.PSObject.Properties['flutterDevice'] -and $Entry.flutterDevice -eq 'windows') {
        Write-SgInfo 'Flutter is already running in its managed Windows app session.'
        return $Entry
    }
    if ($Entry.kind -eq 'flutter-web' -and $Entry.PSObject.Properties['flutterDevice'] -and $Entry.flutterDevice -eq 'android') {
        Write-SgInfo 'Flutter is already running in its managed Android app session.'
        return $Entry
    }
    Start-Process "http://127.0.0.1:$([int]$Entry.port)"
    return $Entry
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

. (Join-Path $PSScriptRoot 'ShipGlows.Backend.ps1')

Export-ModuleMember -Function Write-SgInfo,Write-SgWarn,Write-SgError,Ensure-SgDirectory,ConvertTo-SgCanonicalPath,Get-SgDevConfig,Complete-SgManagedProcessExit,Get-SgCliCapabilityRecords,Write-SgCliCapabilitySnapshot,Read-SgCliCapabilitySnapshot,Get-SgProjectKind,Get-SgProjectExperience,Format-SgProjectStatus,Get-SgProjectDescriptor,Get-SgProjectDescriptors,Get-SgRuntimeSettings,Get-SgObsidianPluginDescriptor,Get-SgObsidianBratArtifactReport,Wait-SgObsidianPluginReady,Sync-SgObsidianPluginArtifacts,Invoke-SgObsidianPluginLab,Resolve-SgObsidianVault,Get-SgBrowserExtensionDescriptor,Get-SgManagedPlaywrightModulePath,Invoke-SgBrowserExtensionLab,Get-SgFlutterAndroidDevices,Resolve-SgFlutterAndroidDevice,Read-SgRegistry,Reconcile-SgRegistry,Register-SgProject,Sync-SgRegisteredProjectEnvironments,Start-SgProject,Stop-SgProject,Open-SgProject,Invoke-SgFlutterSupervisorCommand,Invoke-SgFlutterProjectReload,Install-SgDevShortcut,Get-SgGitCheckoutInfo,Unregister-SgProject,Show-SgDashboard,Test-SgGitUrl,Test-SgProjectPath,ConvertTo-SgGitHubRepositoryIdentity,Get-SgInstalledGitHubRepositoryIdentities,Select-SgGitHubCloneCandidates,Get-SgFreePort,Test-SgPortAvailable,Reserve-SgProjectPort,Set-SgReservationState,Release-SgProjectPort,Get-SgRunnableIdentity,Get-SgCanonicalSurfaceName,Get-SgDisplayName,Add-SgDiscoveredMetadata,Sync-SgDiscoveredProjectMetadata,Get-SgOwnedFlutterListenerPids,Stop-SgOwnedFlutterListener,Get-SgOwnedFlutterBrowserPids,Stop-SgOwnedFlutterBrowser,Rotate-SgLogFile,Get-SgProjectEnvironmentPath,Write-SgProjectEnvironment,Get-SgProjectEnvironment,Remove-SgLegacyProjectServerState,Get-SgWorkspaceProjectCandidates,Get-SgProjectCatalog,Get-SgProjectCatalogForDisplay,Clear-SgProjectCatalogCache,Resolve-SgProjectCatalogEntry,New-SgProjectChoiceMap
Export-ModuleMember -Function Clear-SgProjectCatalogMemoryCache,Test-SgProjectCatalogRefreshRequired
