$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# `s private-data connect --repo <URL>` must reach private_data.py even though
# PowerShell binds `--repo` to the entrypoint's -RepositoryUrl by prefix.
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$entrypoint = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$shell = (Get-Process -Id $PID).Path
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-private-data-forwarding-' + [guid]::NewGuid().ToString('N'))
$saved = @{}
foreach ($name in @('SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE','SHIPGLOWS_PRIVATE_DATA_DIR','SHIPGLOWS_PRIVATE_DATA_REPO','SHIPGLOWS_MANAGED_PWSH')) { $saved[$name] = [Environment]::GetEnvironmentVariable($name,'Process') }
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $env:SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE = Join-Path $fixture 'private-data.env'
    $env:SHIPGLOWS_PRIVATE_DATA_DIR = Join-Path $fixture 'data'
    $env:SHIPGLOWS_PRIVATE_DATA_REPO = $null
    $env:SHIPGLOWS_MANAGED_PWSH = $shell
    $repository = 'https://github.com/example/shipglows_private.git'

    # Dry plans only: nothing is cloned and no configuration is written.
    $text = @(& $shell -NoLogo -NoProfile -File $entrypoint private-data connect --repo $repository 2>&1) -join "`n"
    if ($LASTEXITCODE -ne 0 -or $text -notmatch 'connect: planned' -or $text -notmatch 'mode: clone') { throw "Windows private-data connect dropped --repo: $text" }
    $json = (@(& $shell -NoLogo -NoProfile -File $entrypoint private-data --format json connect --repo $repository 2>&1) -join "`n") | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or $json.connect -cne 'planned') { throw 'Windows private-data connect dropped --repo after --format.' }
    $missing = @(& $shell -NoLogo -NoProfile -File $entrypoint private-data connect 2>&1) -join "`n"
    if ($LASTEXITCODE -eq 0 -or $missing -notmatch '--repo') { throw 'Windows private-data connect without --repo was accepted.' }
    if (Test-Path -LiteralPath $env:SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE) { throw 'A dry private-data connect wrote configuration.' }
    if (Test-Path -LiteralPath $env:SHIPGLOWS_PRIVATE_DATA_DIR) { throw 'A dry private-data connect created the data directory.' }
    Write-Host 'Windows private-data argument forwarding: OK'
} finally {
    foreach ($name in $saved.Keys) { [Environment]::SetEnvironmentVariable($name, $saved[$name], 'Process') }
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
