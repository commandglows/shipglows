# ShipGlows disk hygiene for the Windows development surface.
#
# The development surface fills itself silently: package managers keep every
# version they ever downloaded, Gradle keeps every distribution a project ever
# pinned, dev sessions outlive the work that started them, and regenerable build
# outputs stay behind on projects nobody runs anymore. This module measures that
# growth and builds one bounded cleanup plan. Every removal goes through the
# owning tool (npm, pnpm, uv, docker) or targets an explicit regenerable path
# that Git itself reports as ignored. Source, .git, credentials, package stores
# outside their own prune command, and virtual disks are never deleted here.

Set-StrictMode -Version Latest

# Same thresholds as the server disk-hygiene playbook.
$script:SgDiskThresholds = @(
    @{ State='critical'; UsedPercent=90; FreeGb=6 },
    @{ State='high';     UsedPercent=85; FreeGb=12 },
    @{ State='warning';  UsedPercent=75; FreeGb=20 }
)

function Get-SgDiskPolicy {
    $read = {
        param([string]$Name, [double]$Default)
        $raw = [Environment]::GetEnvironmentVariable($Name)
        $value = 0.0
        if ($raw -and [double]::TryParse($raw, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$value) -and $value -gt 0) { return $value }
        return $Default
    }
    [pscustomobject]@{
        SessionMaxAgeHours  = & $read 'SHIPGLOWS_SESSION_MAX_AGE_HOURS' 24
        BuildStaleDays      = & $read 'SHIPGLOWS_BUILD_STALE_DAYS' 14
        CacheBudgetGb       = & $read 'SHIPGLOWS_CACHE_BUDGET_GB' 5
        PnpmStoreBudgetGb   = & $read 'SHIPGLOWS_PNPM_STORE_BUDGET_GB' 15
    }
}

function Get-SgDiskVolumeState([string]$Path = $env:SystemDrive) {
    $drive = [IO.DriveInfo]::new([IO.Path]::GetPathRoot([IO.Path]::GetFullPath(($Path.TrimEnd('\') + '\'))))
    $total = [double]$drive.TotalSize
    $free = [double]$drive.AvailableFreeSpace
    $usedPercent = if ($total -gt 0) { [Math]::Round((($total - $free) / $total) * 100, 1) } else { 0 }
    $freeGb = $free / 1GB
    $state = 'healthy'
    # On a large disk a high percentage can still leave ample room: the percentage
    # only counts while less than 50 GB remain, the absolute floor always counts.
    foreach ($threshold in $script:SgDiskThresholds) {
        if (($usedPercent -ge $threshold.UsedPercent -and $freeGb -lt 50) -or $freeGb -lt $threshold.FreeGb) { $state = $threshold.State; break }
    }
    [pscustomobject]@{ Drive=$drive.Name; TotalBytes=[long]$total; FreeBytes=[long]$free; UsedPercent=$usedPercent; State=$state }
}

function Format-SgBytes([long]$Bytes) {
    if ($Bytes -ge 1GB) { return '{0:N1} GB' -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return '{0:N0} MB' -f ($Bytes / 1MB) }
    return '{0:N0} KB' -f ($Bytes / 1KB)
}

# Sums file sizes without following junctions or symlinks (pnpm and WSL use them).
function Get-SgDirectoryBytes([string]$Path) {
    if (-not $Path -or -not (Test-Path -LiteralPath $Path -PathType Container)) { return [long]0 }
    $options = [IO.EnumerationOptions]::new()
    $options.RecurseSubdirectories = $true
    $options.IgnoreInaccessible = $true
    $options.AttributesToSkip = [IO.FileAttributes]::ReparsePoint
    $total = [long]0
    try { foreach ($file in [IO.DirectoryInfo]::new($Path).EnumerateFiles('*', $options)) { $total += $file.Length } } catch { }
    return $total
}

function Get-SgFileBytes([string]$Path) {
    if ($Path -and (Test-Path -LiteralPath $Path -PathType Leaf)) { return [long](Get-Item -LiteralPath $Path -Force).Length }
    return [long]0
}

function Get-SgGradleHome { if ($env:GRADLE_USER_HOME) { [string]$env:GRADLE_USER_HOME } else { Join-Path $env:USERPROFILE '.gradle' } }

function Get-SgPnpmStorePath {
    if ($env:SHIPGLOWS_PNPM_STORE) { return [string]$env:SHIPGLOWS_PNPM_STORE }
    $default = Join-Path $env:LOCALAPPDATA 'pnpm\store'
    if (Test-Path -LiteralPath $default -PathType Container) { return $default }
    return ''
}

function Get-SgProjectSurfacePath([object]$Entry) {
    if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { return [string]$Entry.launchPath }
    return [string]$Entry.path
}

# Gradle versions pinned by the wrappers of the registered projects.
function Get-SgPinnedGradleVersions([object[]]$Entries) {
    $versions = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $roots = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @($Entries)) {
        foreach ($candidate in @((Get-SgProjectSurfacePath $entry), [string]$entry.path, $(if ($entry.PSObject.Properties['rootPath']) { [string]$entry.rootPath }))) {
            if ($candidate) { [void]$roots.Add($candidate) }
        }
    }
    foreach ($root in $roots) {
        foreach ($relative in @('android\gradle\wrapper\gradle-wrapper.properties','gradle\wrapper\gradle-wrapper.properties','src-tauri\gen\android\gradle\wrapper\gradle-wrapper.properties')) {
            $file = Join-Path $root $relative
            if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
            $match = [regex]::Match([IO.File]::ReadAllText($file), 'gradle-([0-9][0-9A-Za-z.\-]*?)-(bin|all)\.zip')
            if ($match.Success) { [void]$versions.Add($match.Groups[1].Value) }
        }
    }
    return [string[]]@($versions)
}

function Get-SgUnusedGradleArtifacts([object[]]$Entries) {
    $gradleHome = Get-SgGradleHome
    $pinned = @(Get-SgPinnedGradleVersions $Entries)
    $result = New-Object Collections.Generic.List[object]
    # No registered project pins Gradle: removing every distribution would be a guess, not a rule.
    if ($pinned.Count -eq 0) { return @() }
    $dists = Join-Path $gradleHome 'wrapper\dists'
    if (Test-Path -LiteralPath $dists -PathType Container) {
        foreach ($directory in Get-ChildItem -LiteralPath $dists -Directory -ErrorAction SilentlyContinue) {
            $match = [regex]::Match($directory.Name, '^gradle-(.+)-(bin|all)$')
            if ($match.Success -and $pinned -notcontains $match.Groups[1].Value) {
                $result.Add([pscustomobject]@{ Version=$match.Groups[1].Value; Path=$directory.FullName })
            }
        }
    }
    $caches = Join-Path $gradleHome 'caches'
    if (Test-Path -LiteralPath $caches -PathType Container) {
        foreach ($directory in Get-ChildItem -LiteralPath $caches -Directory -ErrorAction SilentlyContinue) {
            if ($directory.Name -match '^[0-9]+\.[0-9]+' -and $pinned -notcontains $directory.Name) {
                $result.Add([pscustomobject]@{ Version=$directory.Name; Path=$directory.FullName })
            }
        }
    }
    $daemon = Join-Path $gradleHome 'daemon'
    if (Test-Path -LiteralPath $daemon -PathType Container) {
        foreach ($directory in Get-ChildItem -LiteralPath $daemon -Directory -ErrorAction SilentlyContinue) {
            if ($directory.Name -match '^[0-9]+\.[0-9]+' -and $pinned -notcontains $directory.Name) {
                $result.Add([pscustomobject]@{ Version=$directory.Name; Path=$directory.FullName })
            }
        }
    }
    return $result.ToArray()
}

function Get-SgEntryLastActivityUtc([object]$Entry) {
    $stamps = New-Object Collections.Generic.List[datetime]
    $sources = @($Entry) + @(if ($Entry.PSObject.Properties['sessions'] -and $Entry.sessions) { $Entry.sessions })
    foreach ($source in $sources) {
        foreach ($name in @('stoppedAtUtc','startedAtUtc','startTimeUtc')) {
            if ($source.PSObject.Properties[$name] -and $source.$name) {
                $parsed = [datetime]::MinValue
                if ([datetime]::TryParse([string]$source.$name, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AdjustToUniversal -bor [Globalization.DateTimeStyles]::AssumeUniversal, [ref]$parsed)) { $stamps.Add($parsed) }
            }
        }
    }
    if ($stamps.Count -eq 0) { return $null }
    return ($stamps | Sort-Object -Descending | Select-Object -First 1)
}

function Test-SgEntryRunning([object]$Entry) {
    if ([string]$Entry.status -in @('starting','running','stopping')) { return $true }
    foreach ($session in @(if ($Entry.PSObject.Properties['sessions'] -and $Entry.sessions) { $Entry.sessions })) {
        if ($session.PSObject.Properties['status'] -and [string]$session.status -in @('starting','running','stopping')) { return $true }
    }
    return $false
}

# Running sessions started longer ago than the policy allows.
function Get-SgIdleSessions([object[]]$Entries, [object]$Policy) {
    $limit = [DateTime]::UtcNow.AddHours(-[double]$Policy.SessionMaxAgeHours)
    $result = New-Object Collections.Generic.List[object]
    foreach ($entry in @($Entries)) {
        foreach ($session in @(if ($entry.PSObject.Properties['sessions'] -and $entry.sessions) { $entry.sessions })) {
            if (-not ($session.PSObject.Properties['status'] -and [string]$session.status -eq 'running')) { continue }
            $started = $null
            foreach ($name in @('startedAtUtc','startTimeUtc')) {
                $parsed = [datetime]::MinValue
                if ($session.PSObject.Properties[$name] -and $session.$name -and [datetime]::TryParse([string]$session.$name, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AdjustToUniversal -bor [Globalization.DateTimeStyles]::AssumeUniversal, [ref]$parsed)) { $started = $parsed; break }
            }
            if ($started -and $started -lt $limit) {
                $result.Add([pscustomobject]@{ Name=[string]$entry.name; Path=[string]$entry.path; Target=[string]$session.target; StartedAtUtc=$started })
            }
        }
    }
    return $result.ToArray()
}

# Regenerable outputs left on projects that have not run for BuildStaleDays.
$script:SgBuildOutputDirectories = @('build','.dart_tool\flutter_build','android\.gradle','android\app\build','android\build','src-tauri\target','target','.next','.nuxt','.astro','.svelte-kit','.turbo','.parcel-cache','.vite','dist','out','coverage','windows\flutter\ephemeral','.output')

function Test-SgGitIgnoredPath([string]$Repository, [string]$Path) {
    $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $git) { return $false }
    & $git.Source -C $Repository rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) { return $false }
    & $git.Source -C $Repository check-ignore -q -- $Path *> $null
    if ($LASTEXITCODE -ne 0) { return $false }
    # Ignored but tracked files would be lost: refuse any directory holding one.
    $tracked = & $git.Source -C $Repository ls-files -- $Path 2>$null | Select-Object -First 1
    return -not $tracked
}

function Get-SgStaleBuildOutputs([object[]]$Entries, [object]$Policy) {
    $limit = [DateTime]::UtcNow.AddDays(-[double]$Policy.BuildStaleDays)
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $result = New-Object Collections.Generic.List[object]
    foreach ($entry in @($Entries)) {
        if (Test-SgEntryRunning $entry) { continue }
        $surface = Get-SgProjectSurfacePath $entry
        if (-not $surface -or -not (Test-Path -LiteralPath $surface -PathType Container) -or -not $seen.Add($surface)) { continue }
        $last = Get-SgEntryLastActivityUtc $entry
        if ($last -and $last -gt $limit) { continue }
        if (-not $last) {
            # Never started through ShipGlows: use the newest write on the surface root instead.
            $written = (Get-Item -LiteralPath $surface).LastWriteTimeUtc
            if ($written -gt $limit) { continue }
        }
        foreach ($relative in $script:SgBuildOutputDirectories) {
            $candidate = Join-Path $surface $relative
            if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { continue }
            $item = Get-Item -LiteralPath $candidate -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            if (-not (Test-SgGitIgnoredPath $surface $candidate)) { continue }
            $result.Add([pscustomobject]@{ Name=[string]$entry.name; Path=$candidate; Relative=$relative; LastActivityUtc=$last })
        }
    }
    return $result.ToArray()
}

function Get-SgWslVirtualDisks {
    $disks = New-Object Collections.Generic.List[object]
    $docker = Join-Path $env:LOCALAPPDATA 'Docker\wsl'
    if (Test-Path -LiteralPath $docker -PathType Container) {
        foreach ($file in Get-ChildItem -LiteralPath $docker -Recurse -Filter '*.vhdx' -File -ErrorAction SilentlyContinue) { $disks.Add([pscustomobject]@{ Label="Docker ($($file.Name))"; Path=$file.FullName; Bytes=[long]$file.Length }) }
    }
    $packages = Join-Path $env:LOCALAPPDATA 'Packages'
    if (Test-Path -LiteralPath $packages -PathType Container) {
        foreach ($package in Get-ChildItem -LiteralPath $packages -Directory -ErrorAction SilentlyContinue) {
            $file = Join-Path $package.FullName 'LocalState\ext4.vhdx'
            if (Test-Path -LiteralPath $file -PathType Leaf) { $disks.Add([pscustomobject]@{ Label="WSL ($(($package.Name -split '_')[0]))"; Path=$file; Bytes=(Get-SgFileBytes $file) }) }
        }
    }
    return $disks.ToArray()
}

# One report: volume state, measured caches, and the cleanup plan.
# Plan items carry Kind = stop-session | remove-path | tool-command and Auto =
# whether an unattended run (scheduled task) may apply them.
function Get-SgDiskHygienePlan([object[]]$Entries, [object]$Policy = (Get-SgDiskPolicy)) {
    $volume = Get-SgDiskVolumeState
    $pressure = $volume.State -ne 'healthy'
    $budget = [long]($Policy.CacheBudgetGb * 1GB)
    $caches = New-Object Collections.Generic.List[object]
    $plan = New-Object Collections.Generic.List[object]

    foreach ($session in @(Get-SgIdleSessions $Entries $Policy)) {
        $plan.Add([pscustomobject]@{ Kind='stop-session'; Category='dev-server'; Label="Stop $($session.Name) [$($session.Target)], running since $($session.StartedAtUtc.ToLocalTime().ToString('yyyy-MM-dd HH:mm'))"; Path=$session.Path; Target=$session.Target; Bytes=[long]0; Auto=$true })
    }
    foreach ($output in @(Get-SgStaleBuildOutputs $Entries $Policy)) {
        $bytes = Get-SgDirectoryBytes $output.Path
        if ($bytes -lt 1MB) { continue }
        $plan.Add([pscustomobject]@{ Kind='remove-path'; Category='build-output'; Label="Remove $($output.Name)\$($output.Relative) (project idle $([int]$Policy.BuildStaleDays)+ days)"; Path=$output.Path; Bytes=$bytes; Auto=$true })
    }
    # A running Gradle daemon may hold any version's files: skip Gradle removal until it exits.
    $gradleBusy = @(Get-CimInstance Win32_Process -Filter "Name='java.exe'" -ErrorAction SilentlyContinue | Where-Object { [string]$_.CommandLine -match 'GradleDaemon|GradleWrapperMain' }).Count -gt 0
    foreach ($artifact in @(if (-not $gradleBusy) { Get-SgUnusedGradleArtifacts $Entries })) {
        $bytes = Get-SgDirectoryBytes $artifact.Path
        $plan.Add([pscustomobject]@{ Kind='remove-path'; Category='gradle'; Label="Remove Gradle $($artifact.Version) (no registered project pins it)"; Path=$artifact.Path; Bytes=$bytes; Auto=$true })
    }

    $toolCaches = @(
        @{ Id='npm';  Label='npm cache';   Path=(Join-Path $env:LOCALAPPDATA 'npm-cache'); Commands=@('npm.cmd','npm'); Arguments=@('cache','clean','--force'); Budget=$budget },
        @{ Id='uv';   Label='uv cache';    Path=$(if ($env:UV_CACHE_DIR) { $env:UV_CACHE_DIR } else { Join-Path $env:LOCALAPPDATA 'uv\cache' }); Commands=@('uv.exe','uv'); Arguments=@('cache','prune'); Budget=$budget },
        @{ Id='pnpm'; Label='pnpm store';  Path=(Get-SgPnpmStorePath); Commands=@('pnpm.cmd','pnpm.exe','pnpm'); Arguments=@('store','prune'); Budget=[long]($Policy.PnpmStoreBudgetGb * 1GB) }
    )
    foreach ($cache in $toolCaches) {
        if (-not $cache.Path) { continue }
        $bytes = Get-SgDirectoryBytes $cache.Path
        $caches.Add([pscustomobject]@{ Label=$cache.Label; Path=$cache.Path; Bytes=$bytes; Budget=$cache.Budget })
        $command = $cache.Commands | ForEach-Object { Get-Command $_ -CommandType Application -ErrorAction SilentlyContinue } | Select-Object -First 1
        if ($command -and $bytes -gt 0 -and ($bytes -gt $cache.Budget -or $pressure)) {
            $plan.Add([pscustomobject]@{ Kind='tool-command'; Category='cache'; Label="$($cache.Label): $($command.Name) $($cache.Arguments -join ' ')"; Path=$cache.Path; Command=$command.Source; Arguments=$cache.Arguments; Bytes=$bytes; Auto=$true })
        }
    }

    $gradleHome = Get-SgGradleHome
    foreach ($item in @(
        @{ Label='Gradle caches'; Path=(Join-Path $gradleHome 'caches') },
        @{ Label='Gradle distributions'; Path=(Join-Path $gradleHome 'wrapper\dists') },
        @{ Label='Dart/Flutter pub cache'; Path=(Join-Path $env:LOCALAPPDATA 'Pub\Cache') },
        @{ Label='Playwright browsers'; Path=(Join-Path $env:LOCALAPPDATA 'ms-playwright') }
    )) { $caches.Add([pscustomobject]@{ Label=$item.Label; Path=$item.Path; Bytes=(Get-SgDirectoryBytes $item.Path); Budget=[long]0 }) }

    $docker = Get-Command docker.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    $disks = @(Get-SgWslVirtualDisks)
    if ($docker -and ($pressure -or @($disks | Where-Object { $_.Label -like 'Docker*' -and $_.Bytes -gt $budget }).Count)) {
        & $docker.Source info *> $null
        if ($LASTEXITCODE -eq 0) {
            $plan.Add([pscustomobject]@{ Kind='tool-command'; Category='docker'; Label='Docker build cache older than 7 days: docker builder prune'; Path=''; Command=$docker.Source; Arguments=@('builder','prune','--force','--filter','until=168h'); Bytes=[long]0; Auto=$true })
        }
    }

    [pscustomobject]@{
        GeneratedAtUtc = [DateTime]::UtcNow.ToString('o')
        Volume = $volume
        Policy = $Policy
        Caches = $caches.ToArray()
        VirtualDisks = $disks
        Plan = $plan.ToArray()
        ReclaimableBytes = [long]($plan | Measure-Object -Property Bytes -Sum).Sum
    }
}

function Remove-SgDiskHygienePath([string]$Path, [string[]]$AllowedRoots) {
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    $inside = $false
    foreach ($root in @($AllowedRoots)) {
        if (-not $root) { continue }
        $prefix = [IO.Path]::GetFullPath($root).TrimEnd('\') + '\'
        if ($full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { $inside = $true; break }
    }
    if (-not $inside) { throw "Refusing disk cleanup outside the managed roots: $full" }
    if (-not (Test-Path -LiteralPath $full)) { return }
    $item = Get-Item -LiteralPath $full -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing to remove a junction or symbolic link: $full" }
    Remove-Item -LiteralPath $full -Recurse -Force
}

# Applies the plan. StopSession is a scriptblock (path, target) supplied by the
# CLI so stops keep their identity checks and registry lock.
function Invoke-SgDiskHygienePlan([object]$Report, [object[]]$Entries, [scriptblock]$StopSession, [switch]$Unattended) {
    $roots = @((Get-SgGradleHome)) + @($Entries | ForEach-Object { Get-SgProjectSurfacePath $_ })
    $before = $Report.Volume.FreeBytes
    $results = New-Object Collections.Generic.List[object]
    foreach ($item in @($Report.Plan)) {
        if ($Unattended -and -not $item.Auto) { continue }
        $status = 'done'; $detail = ''
        try {
            switch ($item.Kind) {
                'stop-session' { & $StopSession $item.Path $item.Target | Out-Null }
                'remove-path' { Remove-SgDiskHygienePath $item.Path $roots }
                'tool-command' {
                    $output = & $item.Command @($item.Arguments) 2>&1
                    if ($LASTEXITCODE -ne 0) { $status = 'failed'; $detail = (($output | Select-Object -Last 3) -join ' ').Trim() }
                }
            }
        } catch { $status = 'failed'; $detail = $_.Exception.Message }
        $results.Add([pscustomobject]@{ Label=$item.Label; Status=$status; Detail=$detail })
    }
    $after = Get-SgDiskVolumeState
    [pscustomobject]@{ Results=$results.ToArray(); FreedBytes=[long]($after.FreeBytes - $before); Volume=$after }
}

function Register-SgDiskHygieneTask([string]$LauncherPath, [string]$At = '04:00') {
    if (-not (Test-Path -LiteralPath $LauncherPath -PathType Leaf)) { throw "ShipGlows launcher not found: $LauncherPath" }
    $taskName = 'ShipGlows Disk Hygiene'
    $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\cmd.exe" -Argument "/d /c `"`"$LauncherPath`" disk clean -Unattended`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $At
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 2) -MultipleInstances IgnoreNew
    $principal = New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'ShipGlows: stop forgotten dev sessions, remove stale regenerable build outputs and unused Gradle versions, prune package caches over budget.' -Force | Out-Null
    return $taskName
}

Export-ModuleMember -Function Get-SgDiskPolicy, Get-SgDiskVolumeState, Format-SgBytes, Get-SgDiskHygienePlan, Invoke-SgDiskHygienePlan, Register-SgDiskHygieneTask, Get-SgPinnedGradleVersions
