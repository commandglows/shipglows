$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-pnpm-workspace-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $capture = Join-Path $fixture 'argv.txt'
    $cwdCapture = Join-Path $fixture 'cwd.txt'
    $fakePnpm = Join-Path $fixture 'pnpm.cmd'
    [IO.File]::WriteAllText($fakePnpm, "@echo off`r`n>>`"$capture`" echo %*`r`n>>`"$cwdCapture`" echo %CD%`r`nif not exist node_modules mkdir node_modules`r`ntype nul > node_modules\.modules.yaml`r`nif not exist site\node_modules\astro mkdir site\node_modules\astro`r`necho {}>site\node_modules\astro\package.json`r`necho pnpm-output`r`n", [Text.Encoding]::ASCII)
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    $config = [pscustomobject]@{RuntimeDirectory=(Join-Path $fixture 'runtime')}

    # Workspace root (claiire-style): packages lists site and app, lockfile lives at the root.
    $root = Join-Path $fixture 'claiire'
    $site = Join-Path $root 'site'
    New-Item -ItemType Directory -Path $site -Force | Out-Null
    Set-Content (Join-Path $root 'package.json') '{"name":"claiire","private":true}' -Encoding UTF8
    Set-Content (Join-Path $root 'pnpm-workspace.yaml') "packages:`n  - site`n  - app`n" -Encoding UTF8
    Set-Content (Join-Path $root 'pnpm-lock.yaml') "lockfileVersion: '9.0'" -Encoding UTF8
    Set-Content (Join-Path $site 'package.json') '{"name":"site","scripts":{"dev":"astro dev"},"dependencies":{"astro":"5.0.0"}}' -Encoding UTF8

    $plan = & $module { param($Project,$Pnpm) function Get-SgCommandPath { $Pnpm }; New-SgDependencyPlan $Project 'astro' } $site $fakePnpm
    if (($plan.Arguments -join ' ') -cne 'install --frozen-lockfile --filter ./site') { throw "Workspace plan did not filter the project from the root: $($plan.Arguments -join ' ')" }
    if ([IO.Path]::GetFullPath([string]$plan.WorkingDirectory) -cne [IO.Path]::GetFullPath($root)) { throw 'Workspace plan did not run from the workspace root.' }
    if ([string]$plan.Manager -cne [IO.Path]::GetFullPath($fakePnpm)) { throw 'Workspace plan did not use the pnpm manager.' }

    $installed = @(& $module { param($Config,$Project,$Log,$Pnpm) function Get-SgCommandPath { $Pnpm }; Invoke-SgDependencySetup $Config $Project 'astro' $Log } $config $site (Join-Path $fixture 'site.log') $fakePnpm)
    if ($installed -notcontains $true) { throw 'Workspace dependency setup did not install.' }
    if ((Get-Content -LiteralPath $capture -Raw).Trim() -cne 'install --frozen-lockfile --filter ./site') { throw 'Workspace install did not pass the frozen lockfile and project filter.' }
    if ((Split-Path -Leaf (Get-Content -LiteralPath $cwdCapture -Raw).Trim()) -cne 'claiire') { throw 'Workspace install did not run from the workspace root.' }
    $reused = & $module { param($Config,$Project,$Log,$Pnpm) function Get-SgCommandPath { $Pnpm }; Invoke-SgDependencySetup $Config $Project 'astro' $Log } $config $site (Join-Path $fixture 'site.log') $fakePnpm
    if ($reused -or @(Get-Content -LiteralPath $capture).Count -ne 1) { throw 'Unchanged workspace inputs re-ran dependency setup.' }
    Set-Content (Join-Path $root 'pnpm-lock.yaml') "lockfileVersion: '9.0'`r`n# changed" -Encoding UTF8
    $changed = & $module { param($Config,$Project,$Log,$Pnpm) function Get-SgCommandPath { $Pnpm }; Invoke-SgDependencySetup $Config $Project 'astro' $Log } $config $site (Join-Path $fixture 'site.log') $fakePnpm
    if (-not $changed -or @(Get-Content -LiteralPath $capture).Count -ne 2) { throw 'Workspace root lockfile change did not invalidate dependency state.' }

    # A project with its own pnpm lock keeps the project-local install.
    $standalone = Join-Path $fixture 'standalone'
    New-Item -ItemType Directory -Path $standalone -Force | Out-Null
    Set-Content (Join-Path $standalone 'package.json') '{"name":"standalone"}' -Encoding UTF8
    Set-Content (Join-Path $standalone 'pnpm-lock.yaml') "lockfileVersion: '9.0'" -Encoding UTF8
    $own = & $module { param($Project,$Pnpm) function Get-SgCommandPath { $Pnpm }; New-SgDependencyPlan $Project 'vite' } $standalone $fakePnpm
    if (($own.Arguments -join ' ') -cne 'install --frozen-lockfile' -or [IO.Path]::GetFullPath([string]$own.WorkingDirectory) -cne [IO.Path]::GetFullPath($standalone)) { throw 'Project-local pnpm lock did not keep the project-local install.' }

    # A workspace that does not list the project is not adopted; the project keeps the no-lock plan.
    $other = Join-Path $fixture 'other'
    $otherSite = Join-Path $other 'site'
    New-Item -ItemType Directory -Path (Join-Path $other 'packages\web') -Force | Out-Null
    New-Item -ItemType Directory -Path $otherSite -Force | Out-Null
    Set-Content (Join-Path $other 'package.json') '{"name":"other"}' -Encoding UTF8
    Set-Content (Join-Path $other 'pnpm-workspace.yaml') "packages:`n  - 'packages/*'`n" -Encoding UTF8
    Set-Content (Join-Path $other 'pnpm-lock.yaml') "lockfileVersion: '9.0'" -Encoding UTF8
    Set-Content (Join-Path $otherSite 'package.json') '{"name":"site"}' -Encoding UTF8
    Set-Content (Join-Path $other 'packages\web\package.json') '{"name":"web"}' -Encoding UTF8
    $notListed = & $module { param($Project,$Pnpm) function Get-SgCommandPath { $Pnpm }; New-SgDependencyPlan $Project 'astro' } $otherSite $fakePnpm
    if (($notListed.Arguments -join ' ') -cne 'install' -or [IO.Path]::GetFullPath([string]$notListed.WorkingDirectory) -cne [IO.Path]::GetFullPath($otherSite)) { throw 'Workspace that does not list the project was adopted.' }
    $globbed = & $module { param($Project,$Pnpm) function Get-SgCommandPath { $Pnpm }; New-SgDependencyPlan $Project 'astro' } (Join-Path $other 'packages\web') $fakePnpm
    if (($globbed.Arguments -join ' ') -cne 'install --frozen-lockfile --filter ./packages/web') { throw 'Workspace packages glob did not match the listed project.' }

    # The root package.json pins pnpm when the project does not; the pin is honored through corepack.
    $pinned = Join-Path $fixture 'pinned'
    $pinnedSite = Join-Path $pinned 'site'
    New-Item -ItemType Directory -Path $pinnedSite -Force | Out-Null
    Set-Content (Join-Path $pinned 'package.json') '{"name":"pinned","packageManager":"pnpm@11.8.0"}' -Encoding UTF8
    Set-Content (Join-Path $pinned 'pnpm-workspace.yaml') "packages:`n  - site`n" -Encoding UTF8
    Set-Content (Join-Path $pinned 'pnpm-lock.yaml') "lockfileVersion: '9.0'" -Encoding UTF8
    Set-Content (Join-Path $pinnedSite 'package.json') '{"name":"site"}' -Encoding UTF8
    $pinnedPlan = & $module { param($Project,$Pnpm) function Get-SgCommandPath { $Pnpm }; New-SgDependencyPlan $Project 'astro' } $pinnedSite $fakePnpm
    if (($pinnedPlan.Arguments -join ' ') -cne 'pnpm@11.8.0 install --frozen-lockfile --filter ./site' -or $pinnedPlan.ArtifactStrategy -cnotlike '*corepack-pnpm*') { throw 'Root packageManager pin was not honored for the workspace install.' }

    Write-Host 'Windows DevServer pnpm workspace dependency setup: OK'
} finally {
    Get-Job -ErrorAction SilentlyContinue | Remove-Job -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
