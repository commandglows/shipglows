$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-readiness-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $fixture)
try {
    & (Get-Module ShipGlows.DevServer) {
        param($Fixture)
        function Assert-That([bool]$Value, [string]$Message) { if (-not $Value) { throw $Message } }

        # Log folders: same display name, different paths, never the same folder.
        $first = Get-SgProjectLogKey ([pscustomobject]@{ name = 'site'; path = 'C:\workspace\claiire\site' })
        $second = Get-SgProjectLogKey ([pscustomobject]@{ name = 'site'; path = 'C:\workspace\beatglows\site' })
        Assert-That ($first -ne $second) 'Two projects named "site" must not share a log folder.'
        Assert-That ($first -match '^site-[0-9a-f]{8}$') "Unexpected log key format: $first"
        $sameWithSlash = Get-SgProjectLogKey ([pscustomobject]@{ name = 'site'; path = 'C:\Workspace\Claiire\site\' })
        Assert-That ($first -eq $sameWithSlash) 'The log key must not depend on path case or a trailing separator.'
        $unsafe = Get-SgProjectLogKey ([pscustomobject]@{ name = 'my app/..'; path = 'C:\workspace\x' })
        Assert-That ($unsafe -match '^my-app-\.\.-[0-9a-f]{8}$') "Unsafe characters leaked into the log key: $unsafe"
        Assert-That (-not $unsafe.Contains('/')) 'A path separator leaked into the log key.'

        # Readiness timeout: default, valid value, and rejected values.
        $envFile = Join-Path $Fixture '.shipglows.env'
        Assert-That ((Get-SgRuntimeSettings $Fixture).ReadyTimeoutSeconds -eq 0) 'Without a declaration the default timeout must apply.'
        Set-Content -LiteralPath $envFile -Value 'SHIPGLOWS_READY_TIMEOUT_SECONDS=600'
        Assert-That ((Get-SgRuntimeSettings $Fixture).ReadyTimeoutSeconds -eq 600) 'A declared readiness timeout was ignored.'
        foreach ($invalid in @('10', '1801', 'abc', '')) {
            Set-Content -LiteralPath $envFile -Value "SHIPGLOWS_READY_TIMEOUT_SECONDS=$invalid"
            $blocked = $false
            try { [void](Get-SgRuntimeSettings $Fixture) } catch { $blocked = $true }
            Assert-That $blocked "Invalid readiness timeout '$invalid' was accepted."
        }
    } $fixture
    Write-Host 'Windows DevServer readiness timeout and log folders: OK'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
}
