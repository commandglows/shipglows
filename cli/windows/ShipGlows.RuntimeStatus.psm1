Set-StrictMode -Version Latest

$script:SgRuntimeStatusSchemaVersion = 1
$script:SgRuntimeStatusCacheTtlMinutes = 360
$script:SgRuntimeVersionPattern = '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$'
$script:SgOfficialVersionUrl = 'https://raw.githubusercontent.com/commandglows/shipglows/main/shipglows-version.json'

function Get-SgRuntimeStatusPaths([object]$Config) {
    [pscustomobject]@{
        CachePath = Join-Path $Config.RuntimeDirectory 'shipglows-update-status.json'
        RefreshPath = Join-Path $Config.RuntimeDirectory 'shipglows-update-status.refreshing'
        InstallStatePath = Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'runtime\.shipglows-install.json'
        DevelopmentChannelPath = Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'development-channel.json'
    }
}

function Read-SgRuntimeVersionFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    try {
        $document = [IO.File]::ReadAllText($Path) | ConvertFrom-Json
        $version = [string]$document.version
        if ($version -notmatch $script:SgRuntimeVersionPattern) { return $null }
        return $version
    } catch { return $null }
}

function Read-SgRuntimeInstallState([object]$Config) {
    $paths = Get-SgRuntimeStatusPaths $Config
    if (-not (Test-Path -LiteralPath $paths.InstallStatePath -PathType Leaf)) { return $null }
    try { return [IO.File]::ReadAllText($paths.InstallStatePath) | ConvertFrom-Json }
    catch { return $null }
}

function Get-SgInstalledShipGlowsVersion([object]$Config) {
    $state = Read-SgRuntimeInstallState $Config
    if ($state -and ([string]$state.version -match $script:SgRuntimeVersionPattern)) { return [string]$state.version }
    $runtimeVersion = Join-Path (Join-Path $env:USERPROFILE '.shipglows\runtime') 'shipglows-version.json'
    return Read-SgRuntimeVersionFile $runtimeVersion
}

function Get-SgLinkedShipGlowsSource([object]$Config) {
    $paths = Get-SgRuntimeStatusPaths $Config
    if (-not (Test-Path -LiteralPath $paths.DevelopmentChannelPath -PathType Leaf)) { return $null }
    try { $channel = [IO.File]::ReadAllText($paths.DevelopmentChannelPath) | ConvertFrom-Json }
    catch { return $null }
    if ($channel.channel -cne 'linked' -or [string]::IsNullOrWhiteSpace([string]$channel.root) -or -not [IO.Path]::IsPathRooted([string]$channel.root)) { return $null }
    $root = [IO.Path]::GetFullPath([string]$channel.root)
    $version = Read-SgRuntimeVersionFile (Join-Path $root 'shipglows-version.json')
    if (-not $version) { return $null }
    $commit = ''
    $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($git) {
        $commit = (& $git.Source -C $root rev-parse HEAD 2>$null).Trim()
        if ($LASTEXITCODE -ne 0) { $commit = '' }
    }
    return [pscustomobject]@{ Version=$version; Commit=$commit; Root=$root }
}

function Compare-SgSemanticVersion([string]$InstalledVersion,[string]$AvailableVersion) {
    if ($InstalledVersion -notmatch $script:SgRuntimeVersionPattern -or $AvailableVersion -notmatch $script:SgRuntimeVersionPattern) { return $null }
    try { return ([version]($AvailableVersion -replace '-.*$','')).CompareTo([version]($InstalledVersion -replace '-.*$','')) }
    catch { return $null }
}

function Get-SgShipGlowsUpdateAssessment([string]$InstalledVersion,[string]$AvailableVersion,[string]$InstalledCommit='',[string]$SourceCommit='') {
    if ($InstalledVersion -notmatch $script:SgRuntimeVersionPattern) {
        return [pscustomobject]@{ Level='unknown'; Message='Version ShipGlows indisponible - lancez shipglows update runtime.'; Available=$false }
    }
    $comparison = Compare-SgSemanticVersion $InstalledVersion $AvailableVersion
    if ($comparison -gt 0) {
        $installed = [version]($InstalledVersion -replace '-.*$','')
        $available = [version]($AvailableVersion -replace '-.*$','')
        $level = if ($available.Major -gt $installed.Major -or $available.Minor -gt $installed.Minor) { 'major-update' } else { 'update' }
        return [pscustomobject]@{ Level=$level; Message="Nouvelle version disponible: v${AvailableVersion} - lancez shipglows update runtime."; Available=$true }
    }
    if ($comparison -eq 0 -and $InstalledCommit -and $SourceCommit -and $InstalledCommit -ne $SourceCommit) {
        return [pscustomobject]@{ Level='update'; Message='Une source development plus recente est disponible - lancez shipglows update runtime.'; Available=$true }
    }
    return [pscustomobject]@{ Level='current'; Message='ShipGlows est a jour.'; Available=$false }
}

function Read-SgShipGlowsStatusCache([object]$Config) {
    $paths = Get-SgRuntimeStatusPaths $Config
    if (-not (Test-Path -LiteralPath $paths.CachePath -PathType Leaf)) { return $null }
    try {
        $cache = [IO.File]::ReadAllText($paths.CachePath) | ConvertFrom-Json
        if ([int]$cache.schemaVersion -ne $script:SgRuntimeStatusSchemaVersion -or -not $cache.checkedAt) { return $null }
        return $cache
    } catch { return $null }
}

function Test-SgShipGlowsStatusCacheFresh([object]$Cache) {
    if (-not $Cache) { return $false }
    try {
        $checkedAt = if ($Cache.checkedAt -is [datetime]) { ([datetime]$Cache.checkedAt).ToUniversalTime() } else { [datetime]::Parse([string]$Cache.checkedAt,[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime() }
        return ((Get-Date).ToUniversalTime() - $checkedAt).TotalMinutes -lt $script:SgRuntimeStatusCacheTtlMinutes
    }
    catch { return $false }
}

function Write-SgShipGlowsStatusCache([object]$Config,[object]$Status) {
    [void][IO.Directory]::CreateDirectory($Config.RuntimeDirectory)
    $paths = Get-SgRuntimeStatusPaths $Config
    $temporary = "$($paths.CachePath).new-$([guid]::NewGuid().ToString('N'))"
    try {
        [IO.File]::WriteAllText($temporary,($Status | ConvertTo-Json -Compress -Depth 5),[Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temporary -Destination $paths.CachePath -Force
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
    }
}

function Update-SgShipGlowsStatusCache([object]$Config,[scriptblock]$VersionReader) {
    $installedState = Read-SgRuntimeInstallState $Config
    $installedVersion = Get-SgInstalledShipGlowsVersion $Config
    $linked = Get-SgLinkedShipGlowsSource $Config
    $availableVersion = if ($linked) { [string]$linked.Version } else { & $VersionReader }
    if (-not $linked -and $availableVersion -notmatch $script:SgRuntimeVersionPattern) {
        $existing = Read-SgShipGlowsStatusCache $Config
        if ($existing) { return $existing }
        return [pscustomobject]@{ schemaVersion=$script:SgRuntimeStatusSchemaVersion; checkedAt=''; installedVersion=$installedVersion; availableVersion=''; level='unknown'; message='Verification de mise a jour indisponible.'; available=$false }
    }
    $sourceCommit = if ($linked) { [string]$linked.Commit } else { '' }
    $installedCommit = if ($installedState) { [string]$installedState.sourceCommit } else { '' }
    $assessment = Get-SgShipGlowsUpdateAssessment $installedVersion $availableVersion $installedCommit $sourceCommit
    $status = [ordered]@{
        schemaVersion = $script:SgRuntimeStatusSchemaVersion
        checkedAt = (Get-Date).ToUniversalTime().ToString('o')
        installedVersion = $installedVersion
        availableVersion = $availableVersion
        level = $assessment.Level
        message = $assessment.Message
        available = $assessment.Available
    }
    Write-SgShipGlowsStatusCache $Config ([pscustomobject]$status)
    return [pscustomobject]$status
}

function Get-SgOfficialShipGlowsVersion {
    try {
        $response = Invoke-WebRequest -Uri $script:SgOfficialVersionUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $document = $response.Content | ConvertFrom-Json
        $version = [string]$document.version
        if ($version -notmatch $script:SgRuntimeVersionPattern) { return '' }
        return $version
    } catch { return '' }
}

Export-ModuleMember -Function Get-SgRuntimeStatusPaths,Get-SgInstalledShipGlowsVersion,Get-SgLinkedShipGlowsSource,Get-SgShipGlowsUpdateAssessment,Read-SgShipGlowsStatusCache,Test-SgShipGlowsStatusCacheFresh,Update-SgShipGlowsStatusCache,Get-SgOfficialShipGlowsVersion
