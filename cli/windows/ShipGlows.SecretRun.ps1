# Runs one managed development command with values decrypted from a SOPS file.
# Plaintext stays in this process and in the child environment: never written to disk, never printed.
param(
    [Parameter(Mandatory=$true)][string]$SopsPath,
    [Parameter(Mandatory=$true)][string]$SecretsFile,
    [Parameter(Mandatory=$true)][string]$CommandBase64,
    [string]$Keys = ''
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Stop-SgSecretRun([string]$Message, [int]$Code = 1) {
    [Console]::Error.WriteLine("ShipGlows secrets: $Message")
    exit $Code
}

try { $command = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($CommandBase64)) } catch { Stop-SgSecretRun 'the launch command is not valid.' }
if ([string]::IsNullOrWhiteSpace($command)) { Stop-SgSecretRun 'the launch command is empty.' }
if (-not (Test-Path -LiteralPath $SopsPath -PathType Leaf)) { Stop-SgSecretRun 'sops is unavailable; no unauthenticated fallback is allowed.' 127 }
if (-not (Test-Path -LiteralPath $SecretsFile -PathType Leaf)) { Stop-SgSecretRun 'the declared secrets file is missing.' }

# sops reports only errors on stderr (missing key, MAC mismatch), never values.
$decrypt = [Diagnostics.ProcessStartInfo]::new($SopsPath)
foreach ($argument in @('decrypt','--output-type','json',$SecretsFile)) { $decrypt.ArgumentList.Add($argument) }
$decrypt.UseShellExecute = $false
$decrypt.RedirectStandardOutput = $true
$decrypt.RedirectStandardError = $true
$decrypt.StandardOutputEncoding = [Text.UTF8Encoding]::new($false)
$process = [Diagnostics.Process]::Start($decrypt)
$stdout = $process.StandardOutput.ReadToEndAsync()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()
if ($process.ExitCode -ne 0) { Stop-SgSecretRun "sops could not decrypt the secrets file (exit $($process.ExitCode)): $($stderr.Trim())" }

try { $values = $stdout.Result | ConvertFrom-Json -AsHashtable } catch { Stop-SgSecretRun 'the decrypted secrets are not a flat key/value document.' }
if ($values -isnot [Collections.IDictionary]) { Stop-SgSecretRun 'the decrypted secrets are not a flat key/value document.' }
foreach ($name in @($values.Keys)) {
    if ($name -cnotmatch '^[A-Za-z_][A-Za-z0-9_]{0,127}$' -or $values[$name] -isnot [string]) { Stop-SgSecretRun "the secrets file holds an invalid entry: $name" }
}

# -Keys restricts the injection to the declared public keys; without it the whole development file is injected.
$selected = [ordered]@{}
$requested = @($Keys.Split(',', [StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($requested.Count -gt 0) {
    foreach ($name in $requested) {
        if (-not $values.Contains($name)) { Stop-SgSecretRun "the declared key $name is missing from the secrets file." }
        $selected[$name] = $values[$name]
    }
} else {
    foreach ($name in @($values.Keys)) { $selected[$name] = $values[$name] }
}

$child = [Diagnostics.ProcessStartInfo]::new($env:ComSpec)
$child.Arguments = "/d /s /c `"$command`""
$child.UseShellExecute = $false
foreach ($name in @($selected.Keys)) { $child.Environment[$name] = [string]$selected[$name] }
$selected.Clear()
$values.Clear()
$run = [Diagnostics.Process]::Start($child)
$run.WaitForExit()
exit $run.ExitCode
