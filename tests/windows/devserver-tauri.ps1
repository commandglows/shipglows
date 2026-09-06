$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-tauri-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixture 'src-tauri') -Force | Out-Null
try {
    Set-Content (Join-Path $fixture '.shipglows.runtime.json') '{"surface":"tauri"}'
    Set-Content (Join-Path $fixture 'src-tauri\tauri.conf.json') '{"build":{"devUrl":"http://127.0.0.1:3006","beforeDevCommand":"pnpm tauri:dev"}}'
    if ((Get-SgProjectKind $fixture) -ne 'tauri') { throw 'Tauri selection was ignored.' }
    & (Get-Module ShipGlows.DevServer) {
        param($project)
        try { Get-SgLaunchSpec $project 'tauri' 3008; throw 'Mismatched port accepted.' }
        catch { if ($_.Exception.Message -notmatch 'assigned local port') { throw } }
    } $fixture
    Set-Content (Join-Path $fixture '.shipglows.runtime.json') '{"surface":"unknown"}'
    try { Get-SgProjectKind $fixture; throw 'Unknown surface accepted.' }
    catch { if ($_.Exception.Message -notmatch 'Unsupported runtime surface') { throw } }
    Write-Output 'Tauri selection and fail-closed port checks: PASS'
} finally {
    # The fixture is a directly created unique child of the OS temporary directory.
    if ([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $fixture -Recurse -Force
    }
}
