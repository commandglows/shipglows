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
    $skipped = @('node_modules', 'build', 'dist', '.output', 'target', 'vendor', 'third_party', 'public', 'shipglows_data')
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

function Get-SgStackRelative([string]$Root, [string]$Path) {
    return (($Path.Substring($Root.Length).TrimStart('\', '/')) -replace '\\', '/')
}

function Get-SgStackDependencies($Package) {
    # Flat list of { Section, Name, Spec } over every dependency section of a parsed package.json.
    $items = New-Object Collections.Generic.List[object]
    foreach ($section in 'dependencies', 'devDependencies', 'optionalDependencies') {
        if (-not $Package.PSObject.Properties[$section] -or -not $Package.$section) { continue }
        foreach ($property in $Package.$section.PSObject.Properties) {
            $items.Add([pscustomobject]@{ Section = $section; Name = [string]$property.Name; Spec = [string]$property.Value })
        }
    }
    return ,$items
}

function Get-SgStackAstroSurfaces([string]$Root) {
    # Surface roots whose package.json depends on astro. The shared @shipglows/astro-* packages themselves are not sites.
    $sites = New-Object Collections.Generic.List[object]
    foreach ($surface in @(Get-SgStackSurfaceRoots -Root $Root)) {
        $text = Read-SgStackFileText (Join-Path $surface 'package.json')
        if (-not $text) { continue }
        try { $package = $text | ConvertFrom-Json } catch { continue }
        if ($null -eq $package) { continue }
        if ($package.PSObject.Properties['name'] -and ([string]$package.name).StartsWith('@shipglows/astro-')) { continue }
        $dependencies = Get-SgStackDependencies -Package $package
        if (@($dependencies | Where-Object { $_.Name -ceq 'astro' }).Count -eq 0) { continue }
        $sites.Add([pscustomobject]@{ Root = $surface; Package = $package; Dependencies = $dependencies })
    }
    return ,$sites
}

function Get-SgStackGitRoot([string]$Start, [string]$Fallback) {
    $current = $Start
    while ($current) {
        if (Test-Path -LiteralPath (Join-Path $current '.git')) { return $current }
        $parent = Split-Path -Parent $current
        if (-not $parent -or $parent -eq $current) { break }
        $current = $parent
    }
    return $Fallback
}

function Get-SgStackSourceFiles([string]$SurfaceRoot) {
    # Source files of one site (extensions that can import a package), plus its root config files. Never node_modules.
    $files = New-Object Collections.Generic.List[string]
    $src = Join-Path $SurfaceRoot 'src'
    $extensions = '\.(astro|ts|tsx|js|jsx|mjs|cjs|mts|vue|svelte|css|mdx)$'
    if (Test-Path -LiteralPath $src -PathType Container) {
        foreach ($file in @(Get-ChildItem -LiteralPath $src -Recurse -File -Force -ErrorAction SilentlyContinue)) {
            if ($file.Name -match $extensions -and $file.FullName -notmatch '[\\/]node_modules[\\/]') { $files.Add($file.FullName) }
        }
    }
    foreach ($file in @(Get-ChildItem -LiteralPath $SurfaceRoot -File -Force -ErrorAction SilentlyContinue)) {
        if ($file.Name -match '^(astro|tailwind|vite|vitest)\.config\.' -or $file.Name -match '^(middleware|env)\.') { $files.Add($file.FullName) }
    }
    return ,$files
}

function Get-SgStackFrontmatterKeys([string]$Path) {
    # Top-level keys of the leading --- block, read line by line and stopped at the closing ---.
    $keys = New-Object Collections.Generic.List[string]
    $state = 0
    try {
        foreach ($line in [IO.File]::ReadLines($Path)) {
            if ($state -eq 0) {
                if ($line.TrimEnd() -ne '---') { break }
                $state = 1
                continue
            }
            if ($line.TrimEnd() -eq '---') { break }
            if ($line -match '^([A-Za-z_][\w-]*)\s*:') { $keys.Add($Matches[1]) }
        }
    } catch { }
    return ,$keys
}

function Get-SgStackSiteChecks($Site, [string]$ProjectRoot) {
    # Read-only checks of one Astro site against the shared packages and the content-tree doctrine.
    # Severity: error = must fix, warn = should migrate, info = decision pending.
    $root = $Site.Root
    $surfaceName = Get-SgStackRelative -Root $ProjectRoot -Path $root
    if (-not $surfaceName) { $surfaceName = '.' }
    $findings = New-Object Collections.Generic.List[object]
    $engineLinkSeen = $false
    $add = {
        param($Severity, $Code, $Path, $Package, $Message)
        $findings.Add([ordered]@{ surface = $surfaceName; severity = $Severity; code = $Code; path = $Path; package = $Package; message = $Message })
    }

    # 1. Duplicate: a site-owned copy of a module that a package already provides.
    $duplicateRules = @(
        @{ Pattern = '(^|/)content-model/model\.mjs$'; Package = '@shipglows/astro-content'; Use = "export * from '@shipglows/astro-content/model'" },
        @{ Pattern = '(^|/)remark-wikilinks\.(mjs|js|ts)$'; Package = '@shipglows/astro-content'; Use = 'createRemarkWikilinks from @shipglows/astro-content/model' },
        @{ Pattern = '(^|/)ThemeToggle[A-Za-z]*\.(astro|vue|tsx|jsx|svelte)$'; Package = '@shipglows/astro-ui'; Use = '@shipglows/astro-ui/theme/ThemeToggle.astro' },
        @{ Pattern = '(^|/)ThemeScript\.astro$'; Package = '@shipglows/astro-ui'; Use = '@shipglows/astro-ui/theme/ThemeScript.astro' },
        @{ Pattern = '(^|/)Breadcrumbs?\.astro$'; Package = '@shipglows/astro-seo'; Use = '@shipglows/astro-seo/breadcrumbs/Breadcrumbs.astro' },
        @{ Pattern = '(^|/)breadcrumbs\.(ts|js|mjs)$'; Package = '@shipglows/astro-seo'; Use = '@shipglows/astro-seo/breadcrumbs' },
        @{ Pattern = '(^|/)(LanguageSelector|LanguageSwitch(er)?|languageSwitch)\.(astro|vue|tsx|jsx|svelte|ts|js|mjs)$'; Package = '@shipglows/astro-i18n'; Use = '@shipglows/astro-i18n/LanguageSelector.astro' },
        @{ Pattern = '(^|/)LegalNotice\.astro$'; Package = '@shipglows/astro-seo'; Use = '@shipglows/astro-seo/legal/LegalNotice.astro' },
        @{ Pattern = '(^|/)Icon\.astro$'; Package = '@shipglows/astro-ui'; Use = '@shipglows/astro-ui/icons/Icon.astro' }
    )
    $sourceFiles = Get-SgStackSourceFiles -SurfaceRoot $root
    foreach ($file in $sourceFiles) {
        $relative = Get-SgStackRelative -Root $root -Path $file
        foreach ($rule in $duplicateRules) {
            if ($relative -notmatch $rule.Pattern) { continue }
            $text = Read-SgStackFileText $file
            if ($relative -match 'content-model/model\.mjs$') {
                # The accepted form is the one-line re-export of the package.
                if ($text.Trim() -match "^export \* from '@shipglows/astro-content/model';?$") { break }
            } elseif ($text -match '@shipglows/astro-') {
                # A site wrapper that already builds on a package is not a copy.
                break
            }
            & $add 'warn' 'duplicate-module' $relative $rule.Package "site-owned copy; replace with $($rule.Use)"
            break
        }
        # 2. Obsolete dependency: imports of the retired single package.
        if ((Read-SgStackFileText $file) -match '@shipglows/astro-engine') {
            & $add 'error' 'obsolete-import' $relative '@shipglows/astro-engine' 'imports the retired single package; use the matching @shipglows/astro-<name> package'
        }
    }
    # 2 and 3. Obsolete dependency, and link:/file: dependencies that leave the repository.
    $repositoryRoot = Get-SgStackGitRoot -Start $root -Fallback $ProjectRoot
    foreach ($dependency in $Site.Dependencies) {
        if ($dependency.Name -ceq '@shipglows/astro-engine') {
            & $add 'error' 'obsolete-dependency' "package.json ($($dependency.Section))" '@shipglows/astro-engine' 'retired single package; depend on the @shipglows/astro-<name> packages instead'
        }
        if ($dependency.Spec -notmatch '^(link|file|portal):(.+)$') { continue }
        $target = $Matches[2]
        try { $resolved = [IO.Path]::GetFullPath((Join-Path $root $target)) } catch { continue }
        $inside = $resolved.TrimEnd('\').StartsWith($repositoryRoot.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase) -or $resolved.TrimEnd('\') -ieq $repositoryRoot.TrimEnd('\')
        if ($inside) { continue }
        if ($dependency.Spec -match 'shipglows-astro-engine[\\/]packages[\\/]') {
            # The supported mode: a path to the sibling engine, cloned on Vercel and CI by tool/provide-engines.sh.
            if (-not $engineLinkSeen) {
                $engineLinkSeen = $true
                $vercelConfig = Read-SgStackFileText (Join-Path $root 'vercel.json')
                if ($vercelConfig -notmatch 'provide-engines\.sh' -and $vercelConfig -notmatch '"installCommand":\s*"echo ') {
                    & $add 'warn' 'engine-not-provided' 'vercel.json' $dependency.Name 'the Astro engine is read by path but installCommand does not run tool/provide-engines.sh; a Vercel build fails'
                }
            }
            continue
        }
        & $add 'info' 'fragile-link' "package.json ($($dependency.Section))" $dependency.Name "$($dependency.Spec) leaves the repository; breaks a Vercel or CI checkout"
    }

    # 4. Content-tree conformity (skills/references/content-tree-model.md).
    $contentRoot = Join-Path $root 'src\content'
    $articlesRoot = Join-Path $contentRoot 'articles'
    $manifestPath = Join-Path $root '.shipglows.content.json'
    $hasManifest = Test-Path -LiteralPath $manifestPath -PathType Leaf
    $markdownCount = 0
    $src = Join-Path $root 'src'
    if (Test-Path -LiteralPath $src -PathType Container) {
        $markdownCount = @(Get-ChildItem -LiteralPath $src -Recurse -File -Force -Include '*.md', '*.mdx' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' }).Count
    }
    if (-not $hasManifest) {
        if ($markdownCount -gt 0 -or (Test-Path -LiteralPath $articlesRoot -PathType Container)) {
            & $add 'warn' 'content-not-migrated' '.shipglows.content.json' '@shipglows/astro-content' "no content manifest while src holds $markdownCount Markdown file(s); the site does not follow the content-tree model"
        }
        return ,$findings
    }
    $astroConfig = ''
    foreach ($configName in 'astro.config.mjs', 'astro.config.ts', 'astro.config.js') {
        $configPath = Join-Path $root $configName
        if (Test-Path -LiteralPath $configPath -PathType Leaf) { $astroConfig = Read-SgStackFileText $configPath; break }
    }
    if ($astroConfig -notmatch 'createWikilinkPlugin|createRemarkWikilinks') {
        & $add 'warn' 'wikilinks-not-wired' 'astro.config.mjs' '@shipglows/astro-content' 'no shared wikilink plugin in the Markdown processor; [[slug]] renders as plain text'
    }
    if ($astroConfig -notmatch 'shipglowsContent\(') {
        & $add 'warn' 'content-integration-missing' 'astro.config.mjs' '@shipglows/astro-content' 'add shipglowsContent() from @shipglows/astro-content/integration; without it a broken wikilink ships an empty page'
    }
    $manifestLocales = @()
    try {
        $manifest = (Read-SgStackFileText $manifestPath) | ConvertFrom-Json
        if ($null -eq $manifest) { throw 'empty' }
        if ($manifest.PSObject.Properties['schema'] -and [string]$manifest.schema -cne 'shipglows-content/v1') {
            & $add 'warn' 'content-manifest-schema' '.shipglows.content.json' '@shipglows/astro-content' "unexpected schema '$($manifest.schema)'; expected shipglows-content/v1"
        }
        if ($manifest.PSObject.Properties['locales']) { $manifestLocales = @($manifest.locales | ForEach-Object { [string]$_ }) }
    } catch {
        & $add 'error' 'content-manifest-invalid' '.shipglows.content.json' '@shipglows/astro-content' 'not valid JSON'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $contentRoot 'taxonomy.yaml') -PathType Leaf)) {
        & $add 'error' 'taxonomy-missing' 'src/content/taxonomy.yaml' '@shipglows/astro-content' 'the subject tree is missing'
    }
    if (-not (Test-Path -LiteralPath $articlesRoot -PathType Container)) {
        & $add 'error' 'articles-missing' 'src/content/articles' '@shipglows/astro-content' 'articles collection folder is missing'
        return ,$findings
    }
    $forbidden = @('slug', 'locale', 'category', 'categories', 'section', 'permalink', 'url', 'parent', 'date', 'pubDate')
    $forbiddenHits = @{}
    foreach ($entry in @(Get-ChildItem -LiteralPath $articlesRoot -Force -ErrorAction SilentlyContinue)) {
        $entryPath = 'src/content/articles/' + $entry.Name
        if (-not $entry.PSIsContainer) {
            & $add 'error' 'article-outside-locale' $entryPath '@shipglows/astro-content' 'file directly under articles/; articles live in articles/<locale>/'
            continue
        }
        if ($manifestLocales.Count -gt 0 -and $manifestLocales -cnotcontains $entry.Name) {
            & $add 'error' 'unknown-locale-folder' $entryPath '@shipglows/astro-content' "folder is not a manifest locale ($($manifestLocales -join ', '))"
        }
        foreach ($child in @(Get-ChildItem -LiteralPath $entry.FullName -Force -ErrorAction SilentlyContinue)) {
            $childPath = $entryPath + '/' + $child.Name
            if ($child.PSIsContainer) {
                & $add 'error' 'article-subfolder' $childPath '@shipglows/astro-content' 'subfolder below a locale folder; articles are flat'
                continue
            }
            if ($child.Name.StartsWith('_')) { continue }
            if ($child.Extension -ine '.md') {
                & $add 'warn' 'article-not-markdown' $childPath '@shipglows/astro-content' 'articles are .md files'
                continue
            }
            if ($child.BaseName -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
                & $add 'warn' 'article-slug-invalid' $childPath '@shipglows/astro-content' 'file name must be a lowercase ASCII hyphenated slug'
            }
            $frontmatterKeys = Get-SgStackFrontmatterKeys -Path $child.FullName
            foreach ($key in ($frontmatterKeys | Select-Object -Unique)) {
                if ($forbidden -ccontains $key) {
                    if (-not $forbiddenHits.ContainsKey($key)) { $forbiddenHits[$key] = New-Object Collections.Generic.List[string] }
                    $forbiddenHits[$key].Add($childPath)
                }
            }
        }
    }
    foreach ($key in @($forbiddenHits.Keys | Sort-Object)) {
        $hits = $forbiddenHits[$key]
        $examples = (@($hits | Select-Object -First 3) -join ', ')
        & $add 'error' 'forbidden-frontmatter-field' $hits[0] '@shipglows/astro-content' "'$key' in $($hits.Count) article(s), e.g. $examples; the path or the taxonomy already carries it"
    }
    return ,$findings
}

function ConvertTo-SgStackChecksJson([Collections.Generic.List[object]]$Findings, [int]$SiteCount) {
    $lines = New-Object Collections.Generic.List[string]
    $lines.Add('{')
    $lines.Add('  "schema_version": 1,')
    $lines.Add('  "astro_sites": ' + $SiteCount + ',')
    foreach ($level in 'error', 'warn', 'info') {
        $lines.Add('  "' + $level + 's": ' + @($Findings | Where-Object { $_['severity'] -ceq $level }).Count + ',')
    }
    if ($Findings.Count -eq 0) {
        $lines.Add('  "checks": []')
    } else {
        $lines.Add('  "checks": [')
        for ($index = 0; $index -lt $Findings.Count; $index++) {
            $comma = if ($index -lt $Findings.Count - 1) { ',' } else { '' }
            $lines.Add('    ' + (ConvertTo-Json -InputObject $Findings[$index] -Compress -Depth 4) + $comma)
        }
        $lines.Add('  ]')
    }
    $lines.Add('}')
    return (($lines -join "`n") + "`n")
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
        Stop-SgCommand 'expected: shipglows stack scan -ProjectPath <path> [-Write|-Checks]'
    }
    $projectPath = ''
    $write = $false
    $checks = $false
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
        } elseif ($token -ieq '-Checks') {
            $checks = $true
            $index++
        } else {
            Stop-SgCommand "unexpected argument '$token'; expected: shipglows stack scan -ProjectPath <path> [-Write|-Checks]"
        }
    }
    if ([string]::IsNullOrWhiteSpace($projectPath)) { Stop-SgCommand 'stack scan requires -ProjectPath <path>' }
    if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
        Stop-SgCommand "project path does not exist or is not a directory: $projectPath"
    }
    $root = (Resolve-Path -LiteralPath $projectPath).ProviderPath
    if ($checks -and $write) { Stop-SgCommand '-Checks is read-only and cannot be combined with -Write' }

    if ($checks) {
        # Per-site Astro checks (duplicates of shared packages, retired dependency, fragile links, content-tree conformity).
        $sites = Get-SgStackAstroSurfaces -Root $root
        $findings = New-Object Collections.Generic.List[object]
        foreach ($site in $sites) {
            $siteFindings = Get-SgStackSiteChecks -Site $site -ProjectRoot $root
            foreach ($finding in $siteFindings) { $findings.Add($finding) }
        }
        Write-Output ((ConvertTo-SgStackChecksJson -Findings $findings -SiteCount $sites.Count).TrimEnd("`n"))
        exit 0
    }

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

if ($CommandArguments[0] -ieq 'private-data') {
    Invoke-SgManagedDevServer -Arguments $CommandArguments
}

if ($CommandArguments.Count -eq 1 -and $CommandArguments[0] -ieq 'check') {
    Invoke-SgCheck
}

if ($CommandArguments[0] -ieq 'stack') {
    Invoke-SgStack -Arguments $CommandArguments
}

if ($CommandArguments[0] -ine 'rename') {
    Stop-SgCommand "unknown command '$($CommandArguments[0])'; expected: shipglows update [status], shipglows check, shipglows stack scan, shipglows tools <status|update>, shipglows private-data ..., or shipglows rename rio <name>"
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
