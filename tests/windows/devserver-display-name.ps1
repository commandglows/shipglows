$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $root = 'C:\workspace\gocharbon'
    $cases = @(
        @{ Expected='gocharbon'; Entry=[pscustomobject]@{ name='old-root'; rootPath=$root; launchPath=$root; path=$root } },
        @{ Expected='gocharbon-site'; Entry=[pscustomobject]@{ name='site'; rootPath=$root; launchPath="$root\site"; path="$root\site" } },
        @{ Expected='gocharbon-app_quiz-backend'; Entry=[pscustomobject]@{ name='backend'; rootPath=$root; launchPath="$root\app_quiz\backend"; path="$root\app_quiz\backend" } },
        @{ Expected='legacy-name'; Entry=[pscustomobject]@{ name='legacy-name'; path='C:\legacy' } }
    )
    foreach ($case in $cases) {
        $actual = Get-SgDisplayName $case.Entry
        if ($actual -ne $case.Expected) { throw "Expected '$($case.Expected)', got '$actual'." }
    }
    Write-Host 'Windows DevServer display names: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
