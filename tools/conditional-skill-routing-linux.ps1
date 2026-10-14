# Access the installed offline Linux environment; setup is a separate explicit step.
param(
    [ValidateSet('status', 'probe', 'subject', 'evaluator', 'subject-shell', 'evaluator-shell')]
    [string]$Mode = 'status',
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)
$runtimeScript = '/home/claude/.local/share/shipglows-isolated-codex-0.160.1/environment.py'
& wsl.exe -d Ubuntu --exec /usr/bin/python3 $runtimeScript $Mode -- @Arguments
exit $LASTEXITCODE
