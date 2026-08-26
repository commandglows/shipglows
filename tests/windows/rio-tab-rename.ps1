$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$command = Join-Path $repoRoot 'cli\windows\shipglows.ps1'
$installer = Join-Path $repoRoot 'cli\windows\install-devserver.ps1'
$bootstrap = Join-Path $repoRoot 'install-shipglows.ps1'
$escape = [char]27
$bell = [char]7

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Invoke-RenameFixture([string[]]$CommandArguments) {
    $stdout = [IO.Path]::GetTempFileName()
    $stderr = [IO.Path]::GetTempFileName()
    try {
        $process = Start-Process -FilePath 'powershell.exe' -ArgumentList (@('-NoLogo','-NoProfile','-ExecutionPolicy','Bypass','-File',$command) + $CommandArguments) -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr -WindowStyle Hidden
        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Output = [IO.File]::ReadAllText($stdout)
            Error = [IO.File]::ReadAllText($stderr)
        }
    } finally {
        Remove-Item -LiteralPath $stdout,$stderr -Force -ErrorAction SilentlyContinue
    }
}

Assert-Sg (Test-Path -LiteralPath $command -PathType Leaf) 'Missing Windows ShipGlows command entrypoint.'

$ordinary = Invoke-RenameFixture @('rename','rio','Nom de session')
Assert-Sg ($ordinary.ExitCode -eq 0) 'A valid Rio title failed.'
Assert-Sg ($ordinary.Output -ceq "$escape]0;Nom de session$bell") 'The Rio title sequence was not exact.'
Assert-Sg ([string]::IsNullOrEmpty($ordinary.Error)) 'A valid Rio title wrote an error.'

$unicode = Invoke-RenameFixture @('rename','rio','Équipe','créative')
Assert-Sg ($unicode.ExitCode -eq 0) 'A Unicode Rio title failed.'
Assert-Sg ($unicode.Output -ceq "$escape]0;Équipe créative$bell") 'Unicode or multi-argument spacing drifted.'

$atBoundary = Invoke-RenameFixture @('rename','rio',('x' * 120))
Assert-Sg ($atBoundary.ExitCode -eq 0) 'The documented 120-character boundary failed.'

foreach ($case in @(
    @('rename','rio','   '),
    @('rename','rio',('x' * 121)),
    @('rename','rio',("unsafe${escape}title")),
    @('rename','codex','name'),
    @('rename','rio'),
    @('unknown')
)) {
    $result = Invoke-RenameFixture $case
    Assert-Sg ($result.ExitCode -ne 0) "Unsafe or unsupported arguments unexpectedly succeeded: $($case -join ' ')"
    Assert-Sg (-not $result.Output.Contains($escape)) "A failed command emitted an escape sequence: $($case -join ' ')"
}

$installerText = [IO.File]::ReadAllText($installer)
$bootstrapText = [IO.File]::ReadAllText($bootstrap)
Assert-Sg ($installerText.Contains("'shipglows.ps1'")) 'The runtime installer does not copy shipglows.ps1.'
Assert-Sg ($installerText.Contains("'shipglows.cmd'")) 'The runtime installer does not own the shipglows.cmd wrapper.'
Assert-Sg ($bootstrapText.Contains("'shipglows.ps1'")) 'The bootstrap payload does not include shipglows.ps1.'
Assert-Sg ($bootstrapText.Contains("'bin/shipglows.ps1'")) 'The bootstrap manifest does not own the active command script.'

Write-Host 'Rio tab rename contract passed.'
