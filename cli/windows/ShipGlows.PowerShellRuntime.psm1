Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SgPowerShellRuntimeManifest {
    $path = Join-Path $PSScriptRoot 'ShipGlows.PowerShellRuntime.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'ShipGlows PowerShell runtime manifest is missing.' }
    $manifest = [IO.File]::ReadAllText($path) | ConvertFrom-Json
    if ($manifest.version -ne '7.6.5' -or $manifest.platform -ne 'win-x64' -or
        $manifest.archiveUrl -ne 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.5/PowerShell-7.6.5-win-x64.zip' -or
        $manifest.sha256 -ne '32EB8F6CDCE08F86E987D625A2733E54AC3E289AE7E1621B14C0B5BCEC2434EA') {
        throw 'ShipGlows PowerShell runtime manifest does not match the trusted release.'
    }
    return $manifest
}

function Assert-SgLocalOwnedPath {
    param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$OwnedRoot)
    if (-not [IO.Path]::IsPathRooted($Path) -or $Path.StartsWith('\\') -or $Path.StartsWith('\\?\') -or $Path.StartsWith('\\.\')) {
        throw 'ShipGlows PowerShell runtime requires a local absolute path.'
    }
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    $root = [IO.Path]::GetFullPath($OwnedRoot).TrimEnd('\')
    if ($full -ne $root -and -not $full.StartsWith($root + '\',[StringComparison]::OrdinalIgnoreCase)) {
        throw 'ShipGlows PowerShell runtime path escaped its owned root.'
    }
    $cursor = $full
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'ShipGlows PowerShell runtime path contains a reparse point.' }
        }
        $parent = Split-Path -Parent $cursor
        if (-not $parent -or $parent -eq $cursor) { break }
        $cursor = $parent
    }
    return $full
}

function Get-SgPowerShellRuntimeLayout {
    param([string]$UserProfile = $env:USERPROFILE,$TrustedManifest)
    if ([string]::IsNullOrWhiteSpace($UserProfile)) { throw 'USERPROFILE is unavailable; the managed PowerShell runtime root cannot be resolved.' }
    $profile = [IO.Path]::GetFullPath($UserProfile).TrimEnd('\')
    if ($profile.StartsWith('\\') -or $profile.StartsWith('\\?\') -or $profile.StartsWith('\\.\')) { throw 'USERPROFILE must be a local path.' }
    $owned = Join-Path $profile '.shipglows\toolchains\powershell'
    $manifest = if ($TrustedManifest) { $TrustedManifest } else { Get-SgPowerShellRuntimeManifest }
    $runtime = Join-Path $owned ("{0}\{1}" -f $manifest.version,$manifest.platform)
    [pscustomobject]@{
        OwnedRoot = Assert-SgLocalOwnedPath $owned $owned
        RuntimeRoot = Assert-SgLocalOwnedPath $runtime $owned
        Executable = Join-Path $runtime 'pwsh.exe'
        Pointer = Join-Path $owned 'current.json'
        Lock = Join-Path $owned '.runtime.lock'
        Manifest = $manifest
    }
}

function Test-SgManagedPowerShell {
    param([Parameter(Mandatory=$true)][string]$Executable,[Parameter(Mandatory=$true)]$Manifest,[scriptblock]$ProbeRunner)
    if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) { return $false }
    try {
        $result = if ($ProbeRunner) { & $ProbeRunner $Executable } else {
            # Windows PowerShell 5.1 rewrites quoting when it launches a native
            # executable. EncodedCommand keeps the probe byte-for-byte identical
            # across the bootstrap and PowerShell Core hosts.
            $probe = '[Console]::Out.Write("{0}|{1}|{2}",$PSVersionTable.PSVersion.ToString(),$PSVersionTable.PSEdition,[Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString())'
            $encodedProbe = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($probe))
            $output = & $Executable -NoLogo -NoProfile -NonInteractive -EncodedCommand $encodedProbe
            if ($LASTEXITCODE -ne 0) { throw 'probe failed' }
            [string]$output
        }
        return ([string]$result).Trim() -eq ("{0}|Core|X64" -f $Manifest.version)
    } catch { return $false }
}

function Get-SgManagedPowerShellHash {
    param([Parameter(Mandatory=$true)][string]$Executable)
    if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) { return $null }
    return (Get-FileHash -LiteralPath $Executable -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Test-SgRuntimePointer {
    param([Parameter(Mandatory=$true)]$Layout)
    if (-not (Test-Path -LiteralPath $Layout.Pointer -PathType Leaf)) { return $false }
    try {
        [void](Assert-SgLocalOwnedPath $Layout.Executable $Layout.OwnedRoot)
        $pointer = [IO.File]::ReadAllText($Layout.Pointer) | ConvertFrom-Json
        $expectedRelativePath = ("{0}/{1}" -f $Layout.Manifest.version,$Layout.Manifest.platform)
        if ($pointer.schemaVersion -ne 2 -or
            [string]$pointer.version -ne [string]$Layout.Manifest.version -or
            [string]$pointer.platform -ne [string]$Layout.Manifest.platform -or
            [string]$pointer.relativePath -ne $expectedRelativePath -or
            [string]::IsNullOrWhiteSpace([string]$pointer.executableSha256)) {
            return $false
        }
        $actualHash = Get-SgManagedPowerShellHash $Layout.Executable
        return $null -ne $actualHash -and $actualHash -eq ([string]$pointer.executableSha256).ToUpperInvariant()
    } catch { return $false }
}

function Enter-SgRuntimeLock {
    param([string]$Path,[int]$TimeoutSeconds = 30)
    $deadline = [DateTime]::UtcNow.AddSeconds([Math]::Max(1,$TimeoutSeconds))
    do {
        try { return [IO.File]::Open($Path,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None) }
        catch [IO.IOException] { Start-Sleep -Milliseconds 100 }
    } while ([DateTime]::UtcNow -lt $deadline)
    throw 'Timed out waiting for another ShipGlows PowerShell runtime operation. Retry after it finishes.'
}

function Test-SgReservedWindowsName([string]$Name) {
    $stem = ([IO.Path]::GetFileNameWithoutExtension($Name)).TrimEnd(' .').ToUpperInvariant()
    return $stem -match '^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])$'
}

function Expand-SgTrustedRuntimeArchive {
    param([string]$Archive,[string]$Destination,[int]$MaxEntries,[long]$MaxExpandedBytes)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($Archive)
    try {
        if ($zip.Entries.Count -gt $MaxEntries) { throw 'PowerShell runtime archive has too many entries.' }
        $seen = New-Object 'Collections.Generic.HashSet[string]' -ArgumentList ([StringComparer]::OrdinalIgnoreCase)
        $files = New-Object 'Collections.Generic.HashSet[string]' -ArgumentList ([StringComparer]::OrdinalIgnoreCase)
        $total = [long]0
        foreach ($entry in $zip.Entries) {
            $raw = $entry.FullName.Replace('/','\')
            if ([string]::IsNullOrWhiteSpace($raw)) { continue }
            if ($raw.StartsWith('\') -or [IO.Path]::IsPathRooted($raw) -or $raw.Contains(':')) { throw 'PowerShell runtime archive contains an absolute path or alternate data stream.' }
            $parts = @($raw.Split('\') | Where-Object { $_ -ne '' })
            if (-not $parts.Count -or $parts -contains '..' -or $parts -contains '.') { throw 'PowerShell runtime archive contains path traversal.' }
            foreach ($part in $parts) {
                if ($part.EndsWith(' ') -or $part.EndsWith('.') -or (Test-SgReservedWindowsName $part)) { throw 'PowerShell runtime archive contains an unsafe Windows name.' }
            }
            $normalized = $parts -join '\'
            if (-not $seen.Add($normalized)) { throw 'PowerShell runtime archive contains a case-insensitive path collision.' }
            $isDirectory = $entry.FullName.EndsWith('/') -or $entry.FullName.EndsWith('\')
            $parents = @()
            for ($i=1; $i -lt $parts.Count; $i++) { $parents += (($parts[0..($i-1)]) -join '\') }
            foreach ($parent in $parents) { if ($files.Contains($parent)) { throw 'PowerShell runtime archive contains a file/directory conflict.' } }
            if (-not $isDirectory) {
                foreach ($known in $seen) { if ($known.StartsWith($normalized + '\',[StringComparison]::OrdinalIgnoreCase)) { throw 'PowerShell runtime archive contains a file/directory conflict.' } }
                [void]$files.Add($normalized)
            }
            $mode = ($entry.ExternalAttributes -shr 16) -band 0xF000
            if ($mode -eq 0xA000) { throw 'PowerShell runtime archive contains a symbolic link.' }
            $windowsAttributes = $entry.ExternalAttributes -band 0xFFFF
            if (($windowsAttributes -band [int][IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'PowerShell runtime archive contains a reparse point.' }
            $total += [long]$entry.Length
            if ($total -gt $MaxExpandedBytes) { throw 'PowerShell runtime archive exceeds the expanded-size limit.' }
            $target = [IO.Path]::GetFullPath((Join-Path $Destination $normalized))
            $destRoot = [IO.Path]::GetFullPath($Destination).TrimEnd('\')
            if (-not $target.StartsWith($destRoot + '\',[StringComparison]::OrdinalIgnoreCase)) { throw 'PowerShell runtime archive escaped staging.' }
            [void](Assert-SgLocalOwnedPath $target $destRoot)
            if ($isDirectory) { [void][IO.Directory]::CreateDirectory($target); continue }
            [void][IO.Directory]::CreateDirectory((Split-Path -Parent $target))
            $input = $entry.Open()
            try {
                $output = [IO.File]::Open($target,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
                try { $input.CopyTo($output) } finally { $output.Dispose() }
            } finally { $input.Dispose() }
        }
    } finally { $zip.Dispose() }
}

function Write-SgRuntimePointer {
    param([string]$Path,$Layout)
    $temporary = $Path + '.new-' + [Guid]::NewGuid().ToString('N')
    $backup = $Path + '.previous-' + [Guid]::NewGuid().ToString('N')
    $executableSha256 = Get-SgManagedPowerShellHash $Layout.Executable
    if ([string]::IsNullOrWhiteSpace($executableSha256)) { throw 'Managed PowerShell executable is unavailable for pointer activation.' }
    $payload = [ordered]@{ schemaVersion=2; version=$Layout.Manifest.version; platform=$Layout.Manifest.platform; relativePath=("{0}/{1}" -f $Layout.Manifest.version,$Layout.Manifest.platform); executableSha256=$executableSha256 } | ConvertTo-Json -Compress
    [IO.File]::WriteAllText($temporary,$payload,(New-Object Text.UTF8Encoding($false)))
    try {
        if (Test-Path -LiteralPath $Path) {
            [IO.File]::Replace($temporary,$Path,$backup)
            Remove-Item -LiteralPath $backup -Force
        } else { [IO.File]::Move($temporary,$Path) }
    } catch {
        if (-not (Test-Path -LiteralPath $Path) -and (Test-Path -LiteralPath $backup)) { [IO.File]::Move($backup,$Path) }
        throw
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
        if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Force }
    }
}

function Ensure-SgPowerShellRuntime {
    [CmdletBinding()]
    param([switch]$Offline,[int]$LockTimeoutSeconds=30,[string]$UserProfile=$env:USERPROFILE,[scriptblock]$DownloadRunner,[scriptblock]$ProbeRunner,$TrustedManifest,[scriptblock]$PointerWriter)
    if ($TrustedManifest -and -not $DownloadRunner) { throw 'A fixture manifest is accepted only with an injected download runner.' }
    if ($PointerWriter -and -not $DownloadRunner) { throw 'A pointer-writer fixture is accepted only with an injected download runner.' }
    $layout = Get-SgPowerShellRuntimeLayout $UserProfile $TrustedManifest
    [void][IO.Directory]::CreateDirectory($layout.OwnedRoot)
    if (Test-SgManagedPowerShell $layout.Executable $layout.Manifest $ProbeRunner) {
        if (-not (Test-SgRuntimePointer $layout)) {
            if ($PointerWriter) { & $PointerWriter $layout.Pointer $layout } else { Write-SgRuntimePointer $layout.Pointer $layout }
        }
        return $layout.Executable
    }
    if ($Offline) { throw 'Managed PowerShell 7.6.5 is missing or invalid. Re-run ShipGlows once online to repair it.' }
    $lock = Enter-SgRuntimeLock $layout.Lock $LockTimeoutSeconds
    $staging = Join-Path $layout.OwnedRoot ('.staging-' + [Guid]::NewGuid().ToString('N'))
    $quarantine = $null
    $activated = $false
    try {
        if (Test-SgManagedPowerShell $layout.Executable $layout.Manifest $ProbeRunner) { return $layout.Executable }
        [void][IO.Directory]::CreateDirectory($staging)
        $archive = Join-Path $staging 'runtime.zip'
        if ($DownloadRunner) { & $DownloadRunner $layout.Manifest.archiveUrl $archive }
        else {
            $curl = Join-Path ([Environment]::SystemDirectory) 'curl.exe'
            if (-not (Test-Path -LiteralPath $curl -PathType Leaf)) { throw 'System curl.exe is unavailable; managed PowerShell cannot be acquired.' }
            & $curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 --output $archive $layout.Manifest.archiveUrl
            if ($LASTEXITCODE -ne 0) { throw 'The trusted PowerShell runtime download failed.' }
        }
        if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'The trusted PowerShell runtime archive was not produced.' }
        $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($actual -ne $layout.Manifest.sha256) { throw 'PowerShell runtime SHA-256 verification failed; no runtime was activated.' }
        # Authenticode is complementary evidence. The release ZIP may be unsigned and
        # revocation services may be offline; SHA-256 plus the executable probe remain
        # the activation authority.
        try {
            $signature = Get-AuthenticodeSignature -FilePath $archive
            if ($signature.Status -eq [Management.Automation.SignatureStatus]::HashMismatch) { throw 'PowerShell runtime Authenticode hash validation failed.' }
        } catch {
            if ($_.Exception.Message -match 'Authenticode hash validation failed') { throw }
        }
        $expanded = Join-Path $staging 'expanded'
        [void][IO.Directory]::CreateDirectory($expanded)
        Expand-SgTrustedRuntimeArchive $archive $expanded ([int]$layout.Manifest.maxEntries) ([long]$layout.Manifest.maxExpandedBytes)
        $candidate = Join-Path $expanded 'pwsh.exe'
        if (-not (Test-SgManagedPowerShell $candidate $layout.Manifest $ProbeRunner)) { throw 'Downloaded PowerShell runtime failed its version, edition, or architecture probe.' }
        [void][IO.Directory]::CreateDirectory((Split-Path -Parent $layout.RuntimeRoot))
        if (Test-Path -LiteralPath $layout.RuntimeRoot) {
            $quarantine = $layout.RuntimeRoot + '.invalid-' + [Guid]::NewGuid().ToString('N')
            [IO.Directory]::Move($layout.RuntimeRoot,$quarantine)
        }
        [IO.Directory]::Move($expanded,$layout.RuntimeRoot)
        $activated = $true
        if ($PointerWriter) { & $PointerWriter $layout.Pointer $layout } else { Write-SgRuntimePointer $layout.Pointer $layout }
        if ($quarantine -and (Test-Path -LiteralPath $quarantine)) { Remove-Item -LiteralPath $quarantine -Recurse -Force }
        return $layout.Executable
    } catch {
        if ($activated -and (Test-Path -LiteralPath $layout.RuntimeRoot)) { Remove-Item -LiteralPath $layout.RuntimeRoot -Recurse -Force }
        if ($quarantine -and (Test-Path -LiteralPath $quarantine) -and -not (Test-Path -LiteralPath $layout.RuntimeRoot)) { [IO.Directory]::Move($quarantine,$layout.RuntimeRoot) }
        throw
    } finally {
        $lock.Dispose()
        if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
    }
}

function Resolve-SgManagedPowerShell {
    [CmdletBinding()]
    param([switch]$Offline,[string]$UserProfile=$env:USERPROFILE)
    Ensure-SgPowerShellRuntime -Offline:$Offline -UserProfile $UserProfile
}

function Resolve-SgManagedPowerShellForLaunch {
    [CmdletBinding()]
    param([switch]$Offline,[string]$UserProfile=$env:USERPROFILE,[scriptblock]$DownloadRunner,[scriptblock]$ProbeRunner,$TrustedManifest,[scriptblock]$PointerWriter)
    $layout = Get-SgPowerShellRuntimeLayout $UserProfile $TrustedManifest
    if (Test-SgRuntimePointer $layout) { return $layout.Executable }
    Ensure-SgPowerShellRuntime -Offline:$Offline -UserProfile $UserProfile -DownloadRunner $DownloadRunner -ProbeRunner $ProbeRunner -TrustedManifest $TrustedManifest -PointerWriter $PointerWriter
}

Export-ModuleMember -Function Get-SgPowerShellRuntimeManifest,Get-SgPowerShellRuntimeLayout,Test-SgManagedPowerShell,Test-SgRuntimePointer,Expand-SgTrustedRuntimeArchive,Ensure-SgPowerShellRuntime,Resolve-SgManagedPowerShell,Resolve-SgManagedPowerShellForLaunch
