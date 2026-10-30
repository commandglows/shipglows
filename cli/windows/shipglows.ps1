[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CommandArguments
)

$ErrorActionPreference = 'Stop'
$maximumTitleCharacters = 120

function Stop-SgCommand([string]$Message) {
    [Console]::Error.WriteLine("shipglows: $Message")
    exit 2
}

function Invoke-SgManagedDevServer([string[]]$Arguments) {
    # PowerShell resolves shipglows.ps1 before shipglows.cmd on PATH.
    # Use the same secure bootstrap when that script runs in a foreign host.
    $expectedHost = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe'))
    $currentHost = [IO.Path]::GetFullPath((Get-Process -Id $PID).Path)
    if ($currentHost -ine $expectedHost -or $env:SHIPGLOWS_MANAGED_PWSH -ine $expectedHost) {
        $bootstrap = Join-Path $PSScriptRoot 'ShipGlows.PowerShellBootstrap.ps1'
        if (-not (Test-Path -LiteralPath $bootstrap -PathType Leaf)) {
            Stop-SgCommand 'The managed PowerShell bootstrap is missing; rerun the official ShipGlows installer.'
        }
        & $bootstrap @Arguments
    } else {
        & (Join-Path $PSScriptRoot 'shipglows-devserver.ps1') @Arguments
    }
    exit $LASTEXITCODE
}

function Invoke-SgLinkedSkills([ValidateSet('check','repair')][string]$Mode) {
    # Skills follow the selected developer source; never invoke the runtime updater.
    $statePath = Join-Path $env:USERPROFILE '.shipglows\development-channel.json'
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        Stop-SgCommand 'No linked developer channel. Manage the public plugin through its plugin manager; runtime update was not started.'
    }
    try { $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json }
    catch { Stop-SgCommand 'Invalid developer-channel state; no skills were changed.' }
    if ($state.schemaVersion -ne 1 -or $state.channel -cne 'linked' -or
        [string]::IsNullOrWhiteSpace([string]$state.root) -or
        [string]$state.root -notmatch '^(?:[A-Za-z]:[\\/]|\\\\[^\\]+\\[^\\]+)') {
        Stop-SgCommand 'An explicit linked developer root is required; no channel was changed.'
    }
    $root = [IO.Path]::GetFullPath([string]$state.root)
    $helper = Join-Path $root 'tools\shipglows_sync_skills.ps1'
    $catalog = 'public'
    if ($state.PSObject.Properties['catalog']) { $catalog = [string]$state.catalog }
    if ($catalog -cnotin @('public','expert')) { Stop-SgCommand 'Invalid linked skills catalog; no skills were changed.' }
    if (-not (Test-Path -LiteralPath (Join-Path $root 'skills\000-shipglows\SKILL.md') -PathType Leaf) -or
        -not (Test-Path -LiteralPath $helper -PathType Leaf)) {
        Stop-SgCommand 'The linked checkout is incomplete; no runtime fallback or update was attempted.'
    }
    Write-Output "ShipGlows skills: channel=linked source=$root catalog=$catalog"
    $shellPath = (Get-Process -Id $PID).Path
    & $shellPath -NoLogo -NoProfile -File $helper -Mode $Mode -All -Runtime all -Catalog $catalog -CodexEntrypoint linked -TargetHome $env:USERPROFILE -ShipGlowsRoot $root
    $result = $LASTEXITCODE
    if ($result -eq 0) {
        Write-Output 'Skills use the live checkout, including uncommitted edits. Existing agent context is not reloaded; start a new session or explicitly reread the changed skill.'
    }
    exit $result
}

function Invoke-SgCheck {
    # Runs the lint and test commands declared by every manifest in the current directory.
    # Placeholder scripts (echo, exit 0, true, :) count as not configured, never as passing.
    # Bun is refused, as in the required gate: its setup is not inferred.
    $projectRoot = (Get-Location).ProviderPath
    $steps = [System.Collections.Generic.List[object]]::new()
    $placeholder = '^\s*(echo\b|exit\s+0\s*$|true\s*$|:\s*$)'
    $manifest = Join-Path $projectRoot 'package.json'
    $pubspec = Join-Path $projectRoot 'pubspec.yaml'
    $hasManifest = $false
    if (Test-Path -LiteralPath $manifest -PathType Leaf) {
        $hasManifest = $true
        try { $scripts = (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json).scripts }
        catch { Stop-SgCommand 'package.json is not valid JSON; nothing was run.' }
        if ((Test-Path -LiteralPath (Join-Path $projectRoot 'bun.lock') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $projectRoot 'bun.lockb') -PathType Leaf)) {
            Stop-SgCommand 'Bun setup is not inferred; run its lint and test by hand, as the required gate does.'
        }
        $runner = 'npm'
        if (Test-Path -LiteralPath (Join-Path $projectRoot 'pnpm-lock.yaml') -PathType Leaf) { $runner = 'pnpm' }
        elseif (Test-Path -LiteralPath (Join-Path $projectRoot 'yarn.lock') -PathType Leaf) { $runner = 'yarn' }
        foreach ($name in 'lint', 'test') {
            $body = if ($scripts -and $scripts.PSObject.Properties[$name]) { [string]$scripts.$name } else { '' }
            if (-not $body.Trim() -or $body -match $placeholder) {
                $steps.Add([pscustomobject]@{ Name = "node:$name"; Executable = $null; Arguments = @() })
            } else {
                $steps.Add([pscustomobject]@{ Name = "node:$name"; Executable = $runner; Arguments = @('run', $name) })
            }
        }
    }
    if (Test-Path -LiteralPath $pubspec -PathType Leaf) {
        $hasManifest = $true
        $steps.Add([pscustomobject]@{ Name = 'flutter:lint'; Executable = 'flutter'; Arguments = @('analyze') })
        if (Test-Path -LiteralPath (Join-Path $projectRoot 'test') -PathType Container) {
            $steps.Add([pscustomobject]@{ Name = 'flutter:test'; Executable = 'flutter'; Arguments = @('test') })
        } else {
            $steps.Add([pscustomobject]@{ Name = 'flutter:test'; Executable = $null; Arguments = @() })
        }
    }
    if (-not $hasManifest) {
        Stop-SgCommand 'no package.json or pubspec.yaml in this directory; nothing to check.'
    }

    Write-Output "ShipGlows check: $projectRoot"
    $problem = $false
    $stopped = $false
    foreach ($step in $steps) {
        if ($null -eq $step.Executable) {
            Write-Output "$($step.Name): NOT CONFIGURED (no real script declared)"
            $problem = $true
            continue
        }
        if ($stopped) {
            Write-Output "$($step.Name): SKIPPED (earlier failure)"
            continue
        }
        Write-Output "== $($step.Name): $($step.Executable) $($step.Arguments -join ' ')"
        if (-not (Get-Command -Name $step.Executable -CommandType Application, ExternalScript -ErrorAction SilentlyContinue)) {
            Write-Output "$($step.Name): FAIL (command not found: $($step.Executable))"
            $problem = $true
            $stopped = $true
            continue
        }
        & $step.Executable @($step.Arguments)
        if ($LASTEXITCODE -ne 0) {
            Write-Output "$($step.Name): FAIL (exit $LASTEXITCODE)"
            $problem = $true
            $stopped = $true
            continue
        }
        Write-Output "$($step.Name): OK"
    }
    if ($problem) {
        Write-Output 'shipglows check: NOT PASSED. Paste this summary in the PR.'
        exit 1
    }
    Write-Output 'shipglows check: PASSED. Paste this summary in the PR.'
    exit 0
}

function Read-SgStackFileText([string]$Path) {
    # Bounded read for manifests: a missing, unreadable, directory or over-1-MiB file yields '' and is ignored.
    try {
        $file = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if (-not $file.PSIsContainer -and $file.Length -le 1048576) { return [IO.File]::ReadAllText($file.FullName) }
    } catch { }
    return ''
}

function Test-SgStackPath([string]$Root, [string]$Relative, [string]$PathType) {
    return (Test-Path -LiteralPath (Join-Path $Root $Relative) -PathType $PathType)
}

function Get-SgStackSurfaceRoots([string]$Root) {
    # The project tree model (skills/references/project-tree-model.md): the repository root, every
    # first-level folder and every packages\* folder. Hidden, generated and vendored folders are skipped.
    $skipped = @('node_modules', 'build', 'dist', '.output', 'target', 'vendor', 'third_party', 'public')
    $isSurfaceFolder = { param($Directory) $Directory.Name -notmatch '^\.' -and $skipped -notcontains $Directory.Name -and -not ($Directory.Attributes -band [IO.FileAttributes]::ReparsePoint) }
    $roots = New-Object Collections.Generic.List[string]
    $roots.Add($Root)
    foreach ($child in @(Get-ChildItem -LiteralPath $Root -Directory -Force -ErrorAction SilentlyContinue | Where-Object { & $isSurfaceFolder $_ } | Sort-Object Name)) {
        $roots.Add($child.FullName)
        if ($child.Name -ine 'packages') { continue }
        foreach ($package in @(Get-ChildItem -LiteralPath $child.FullName -Directory -Force -ErrorAction SilentlyContinue | Where-Object { & $isSurfaceFolder $_ } | Sort-Object Name)) {
            $roots.Add($package.FullName)
        }
    }
    return $roots
}

function Get-SgStackDetectedNames([string]$Root) {
    # Surface roots only, never deeper. Returns the sorted, unique technology names.
    $found = @{}
    foreach ($surface in @(Get-SgStackSurfaceRoots -Root $Root)) { Add-SgStackSurfaceNames -Root $surface -Found $found }
    return @($found.Keys | Sort-Object { [string]$_ })
}

function Add-SgStackSurfaceNames([string]$Root, [hashtable]$Found) {
    # Adds the technologies found at one surface root to $Found.
    if (Test-SgStackPath $Root 'pubspec.yaml' 'Leaf') { $Found['flutter'] = $true }

    $packageText = Read-SgStackFileText (Join-Path $Root 'package.json')
    if ($packageText) {
        try { $package = $packageText | ConvertFrom-Json } catch { $package = $null }
        if ($null -ne $package) {
            $dependencyNames = @()
            foreach ($section in 'dependencies', 'devDependencies') {
                if ($package.PSObject.Properties[$section] -and $package.$section) {
                    $dependencyNames += @($package.$section.PSObject.Properties | ForEach-Object { $_.Name })
                }
            }
            foreach ($name in 'astro', 'next', 'react', 'vue', 'svelte', 'convex', 'wxt', 'obsidian') {
                if ($dependencyNames -contains $name) { $Found[$name] = $true }
            }
            if (($dependencyNames -contains 'wxt') -or ($dependencyNames -contains '@crxjs/vite-plugin')) { $Found['browser-extension'] = $true }
            if (($dependencyNames -contains '@tauri-apps/cli') -or ($dependencyNames -contains '@tauri-apps/api')) { $Found['tauri'] = $true }
        }
    }
    # A static extension keeps manifest.json at its surface root; an Obsidian manifest has no manifest_version.
    $manifestText = Read-SgStackFileText (Join-Path $Root 'manifest.json')
    if ($manifestText) {
        try { $manifest = $manifestText | ConvertFrom-Json } catch { $manifest = $null }
        if ($manifest -is [pscustomobject] -and $manifest.PSObject.Properties['manifest_version']) { $Found['browser-extension'] = $true }
    }
    if (Test-SgStackPath $Root 'vercel.json' 'Leaf') { $Found['vercel'] = $true }

    $pythonFiles = @('pyproject.toml', 'requirements.txt') | Where-Object { Test-SgStackPath $Root $_ 'Leaf' }
    if (@($pythonFiles).Count -gt 0) {
        $Found['python'] = $true
        $pythonText = (@($pythonFiles) | ForEach-Object { Read-SgStackFileText (Join-Path $Root $_) }) -join "`n"
        foreach ($name in 'fastapi', 'django', 'flask') {
            if ($pythonText -match "(?i)\b$name\b") { $Found[$name] = $true }
        }
    }

    # Tauri keeps its Cargo.toml in src-tauri\, next to the frontend package.json.
    foreach ($cargo in 'Cargo.toml', 'src-tauri\Cargo.toml') {
        if (-not (Test-SgStackPath $Root $cargo 'Leaf')) { continue }
        $Found['rust'] = $true
        if ((Read-SgStackFileText (Join-Path $Root $cargo)) -match '(?i)\btauri\b') { $Found['tauri'] = $true }
    }
    if (Test-SgStackPath $Root 'go.mod' 'Leaf') { $Found['go'] = $true }

    if ((Test-SgStackPath $Root 'firebase.json' 'Leaf') -or (Test-SgStackPath $Root '.firebaserc' 'Leaf')) { $Found['firebase'] = $true }
    if (Test-SgStackPath $Root 'supabase\config.toml' 'Leaf') { $Found['supabase'] = $true }
    if ((Test-SgStackPath $Root 'convex.json' 'Leaf') -or (Test-SgStackPath $Root 'convex' 'Container')) { $Found['convex'] = $true }
}

function ConvertTo-SgStackJsonValue($Value) {
    if ($null -eq $Value) { return 'null' }
    return (ConvertTo-Json -InputObject $Value -Compress -Depth 8)
}

function ConvertTo-SgStackJson([Collections.Generic.List[object]]$Entries) {
    # Hand-written 2-space indentation so the file looks the same under Windows PowerShell 5.1 and PowerShell 7.
    $lines = New-Object Collections.Generic.List[string]
    $lines.Add('{')
    $lines.Add('  "schema_version": 1,')
    if ($Entries.Count -eq 0) {
        $lines.Add('  "technologies": []')
    } else {
        $lines.Add('  "technologies": [')
        for ($index = 0; $index -lt $Entries.Count; $index++) {
            $entry = $Entries[$index]
            $lines.Add('    {')
            $keys = @($entry.Keys)
            for ($keyIndex = 0; $keyIndex -lt $keys.Count; $keyIndex++) {
                $key = [string]$keys[$keyIndex]
                $comma = if ($keyIndex -lt $keys.Count - 1) { ',' } else { '' }
                $lines.Add('      ' + (ConvertTo-Json -InputObject $key -Compress) + ': ' + (ConvertTo-SgStackJsonValue ($entry[$key])) + $comma)
            }
            $entryComma = if ($index -lt $Entries.Count - 1) { ',' } else { '' }
            $lines.Add('    }' + $entryComma)
        }
        $lines.Add('  ]')
    }
    $lines.Add('}')
    return (($lines -join "`n") + "`n")
}

function Get-SgStackDeclaredEntries([string]$StackPath) {
    # Existing declared entries are kept verbatim. An unreadable or foreign stack.json is never overwritten.
    $entries = New-Object Collections.Generic.List[object]
    if (Test-Path -LiteralPath $StackPath -PathType Container) { Stop-SgCommand 'stack.json path is a directory; nothing was written' }
    if (-not (Test-Path -LiteralPath $StackPath -PathType Leaf)) { return ,$entries }
    $file = Get-Item -LiteralPath $StackPath -Force
    if ($file.Length -gt 1048576) { Stop-SgCommand 'existing stack.json is larger than 1 MiB; nothing was written' }
    try { $data = [IO.File]::ReadAllText($file.FullName) | ConvertFrom-Json }
    catch { Stop-SgCommand 'existing stack.json is not valid JSON; nothing was written' }
    if ($null -eq $data -or -not $data.PSObject.Properties['schema_version'] -or $data.schema_version -ne 1) {
        Stop-SgCommand 'existing stack.json has an unsupported schema_version; nothing was written'
    }
    if ($data.PSObject.Properties['technologies'] -and $data.technologies) {
        foreach ($item in @($data.technologies)) {
            if ($item.PSObject.Properties['source'] -and [string]$item.source -ceq 'declared') {
                $entry = [ordered]@{}
                foreach ($property in $item.PSObject.Properties) { $entry[$property.Name] = $property.Value }
                $entries.Add($entry)
            }
        }
    }
    return ,$entries
}

function Invoke-SgStack([string[]]$Arguments) {
    # shipglows stack scan -ProjectPath <path> [-Write]
    # Detects technologies from the surface roots of one project. Without -Write nothing is written.
    if ($Arguments.Count -lt 2 -or $Arguments[1] -ine 'scan') {
        Stop-SgCommand 'expected: shipglows stack scan -ProjectPath <path> [-Write]'
    }
    $projectPath = ''
    $write = $false
    $index = 2
    while ($index -lt $Arguments.Count) {
        $token = $Arguments[$index]
        if ($token -ieq '-ProjectPath') {
            if ($index + 1 -ge $Arguments.Count -or [string]::IsNullOrWhiteSpace($Arguments[$index + 1]) -or $Arguments[$index + 1].StartsWith('-')) {
                Stop-SgCommand '-ProjectPath requires a path'
            }
            if (-not [string]::IsNullOrWhiteSpace($projectPath)) { Stop-SgCommand '-ProjectPath may be given only once' }
            $projectPath = $Arguments[$index + 1]
            $index += 2
        } elseif ($token -ieq '-Write') {
            $write = $true
            $index++
        } else {
            Stop-SgCommand "unexpected argument '$token'; expected: shipglows stack scan -ProjectPath <path> [-Write]"
        }
    }
    if ([string]::IsNullOrWhiteSpace($projectPath)) { Stop-SgCommand 'stack scan requires -ProjectPath <path>' }
    if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
        Stop-SgCommand "project path does not exist or is not a directory: $projectPath"
    }
    $root = (Resolve-Path -LiteralPath $projectPath).ProviderPath

    $detectedEntries = New-Object Collections.Generic.List[object]
    foreach ($name in @(Get-SgStackDetectedNames -Root $root)) {
        $detectedEntries.Add([ordered]@{ name = $name; version = $null; source = 'detected' })
    }

    if (-not $write) {
        Write-Output ((ConvertTo-SgStackJson -Entries $detectedEntries).TrimEnd("`n"))
        exit 0
    }

    $stackDir = Join-Path $root 'shipglows_data'
    $stackPath = Join-Path $stackDir 'stack.json'
    if (Test-Path -LiteralPath $stackDir -PathType Leaf) { Stop-SgCommand 'shipglows_data exists as a file; nothing was written' }
    $declaredEntries = Get-SgStackDeclaredEntries -StackPath $stackPath

    # A declared entry always wins over a detected one with the same name, so names stay unique.
    $declaredNames = @{}
    $merged = New-Object Collections.Generic.List[object]
    foreach ($entry in $declaredEntries) {
        $declaredNames[[string]$entry['name']] = $true
        $merged.Add($entry)
    }
    foreach ($entry in $detectedEntries) {
        if (-not $declaredNames.ContainsKey([string]$entry['name'])) { $merged.Add($entry) }
    }
    $sorted = New-Object Collections.Generic.List[object]
    foreach ($entry in @($merged | Sort-Object { [string]$_['name'] })) { $sorted.Add($entry) }

    [IO.Directory]::CreateDirectory($stackDir) | Out-Null
    [IO.File]::WriteAllText($stackPath, (ConvertTo-SgStackJson -Entries $sorted), [Text.UTF8Encoding]::new($false))
    Write-Output "Wrote $stackPath"
    exit 0
}

if ($CommandArguments.Count -eq 2 -and $CommandArguments[0] -ieq 'skills' -and $CommandArguments[1] -ieq 'status') {
    Invoke-SgLinkedSkills -Mode check
}
if ($CommandArguments.Count -eq 2 -and $CommandArguments[0] -ieq 'update' -and $CommandArguments[1] -ieq 'skills') {
    Invoke-SgLinkedSkills -Mode repair
}

if ($CommandArguments.Count -lt 1) {
    Stop-SgCommand 'expected: shipglows update [status|skills], shipglows skills status, shipglows check, shipglows stack scan, shipglows tools <status|update>, or shipglows rename rio <name>'
}

if ($CommandArguments[0] -ieq 'update') {
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer update command is unavailable; rerun the official ShipGlows installer.'
    }
    [string[]]$remaining = @(if ($CommandArguments.Count -gt 1) { $CommandArguments[1..($CommandArguments.Count - 1)] })
    if ($remaining.Count -eq 1 -and $remaining[0] -ieq 'runtime') { $remaining = @() }
    Invoke-SgManagedDevServer -Arguments (@('update') + $remaining)
    exit $LASTEXITCODE
}

if ($CommandArguments[0] -ieq 'tools') {
    if ($CommandArguments.Count -ne 2 -or $CommandArguments[1] -notin @('status','update')) {
        Stop-SgCommand 'expected: shipglows tools <status|update>'
    }
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer developer-tools command is unavailable; rerun the official ShipGlows installer.'
    }
    Invoke-SgManagedDevServer -Arguments @('tools', $CommandArguments[1])
    exit $LASTEXITCODE
}

if ($CommandArguments.Count -eq 1 -and $CommandArguments[0] -ieq 'check') {
    Invoke-SgCheck
}

if ($CommandArguments[0] -ieq 'stack') {
    Invoke-SgStack -Arguments $CommandArguments
}

if ($CommandArguments[0] -ine 'rename') {
    Stop-SgCommand "unknown command '$($CommandArguments[0])'; expected: shipglows update [status], shipglows check, shipglows stack scan, shipglows tools <status|update>, or shipglows rename rio <name>"
}
if ($CommandArguments.Count -lt 2 -or $CommandArguments[1] -ine 'rio') {
    $target = if ($CommandArguments.Count -ge 2) { $CommandArguments[1] } else { '' }
    Stop-SgCommand "unsupported rename target '$target'; expected: shipglows rename rio <name>"
}

$title = if ($CommandArguments.Count -gt 2) {
    (($CommandArguments[2..($CommandArguments.Count - 1)] -join ' ').Trim())
} else {
    ''
}
if ([string]::IsNullOrWhiteSpace($title)) {
    Stop-SgCommand 'the Rio title must not be empty'
}
if ($title -match '[\p{Cc}]') {
    Stop-SgCommand 'the Rio title must not contain control characters'
}
$characterCount = [Globalization.StringInfo]::ParseCombiningCharacters($title).Count
if ($characterCount -gt $maximumTitleCharacters) {
    Stop-SgCommand "the Rio title must contain at most $maximumTitleCharacters characters"
}

[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
[Console]::Out.Write(([char]27) + ']0;' + $title + ([char]7))
