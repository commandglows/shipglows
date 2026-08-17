Set-StrictMode -Version Latest

function Format-SgInstallerConsoleEvent {
    param([Parameter(Mandatory=$true)][object]$Event,[bool]$Interactive)
    $elapsed = [Math]::Max(0,[int]$Event.ElapsedSeconds)
    switch ([string]$Event.Code) {
        'INSTALL_STEP_STARTED' {
            if ($Interactive) { return [pscustomobject]@{ Text=("| {0}... 0s" -f $Event.Label); NoNewline=$false; Color='Cyan' } }
            return [pscustomobject]@{ Text="[ShipGlows] $($Event.Label)..."; NoNewline=$false; Color='Cyan' }
        }
        'INSTALL_STEP_PROGRESS' {
            if (-not $Interactive) { return $null }
            $frames = @('|','/','-','\')
            $frame = $frames[[int]$Event.Tick % $frames.Count]
            return [pscustomobject]@{ Text=("`r{0} {1}... {2}s" -f $frame,$Event.Label,$elapsed); NoNewline=$true; Color='Cyan' }
        }
        'INSTALL_STEP_COMPLETED' { return [pscustomobject]@{ Text=("[ok] {0} ({1}s)" -f $Event.Label,$elapsed); NoNewline=$false; Color='Green' } }
        'INSTALL_STEP_TIMED_OUT' { return [pscustomobject]@{ Text=("[timeout] {0} ({1}s)" -f $Event.Label,$elapsed); NoNewline=$false; Color='Yellow' } }
        'INSTALL_STEP_FAILED' { return [pscustomobject]@{ Text=("[failed] {0} ({1}s)" -f $Event.Label,$elapsed); NoNewline=$false; Color='Yellow' } }
        'INSTALL_STEP_AWAITING_INPUT' { return [pscustomobject]@{ Text=("[input] {0}" -f $Event.Label); NoNewline=$false; Color='Yellow' } }
        'INSTALL_STEP_INPUT_RECEIVED' { return [pscustomobject]@{ Text=("[continue] Answer received - continuing: {0}" -f $Event.Label); NoNewline=$false; Color='Cyan' } }
        default { throw "Unknown installer event code: $($Event.Code)" }
    }
}

function New-SgInstallerConsoleEventSink {
    param(
        [bool]$Interactive = ([Environment]::UserInteractive -and -not [Console]::IsOutputRedirected),
        [scriptblock]$Writer
    )
    if (-not $Writer) {
        $Writer = {
            param([string]$Text,[bool]$NoNewline,[string]$Color)
            if ($NoNewline) { Write-Host $Text -NoNewline -ForegroundColor $Color }
            else { Write-Host $Text -ForegroundColor $Color }
        }
    }
    $hadProgress = $false
    return {
        param($Event)
        $formatted = Format-SgInstallerConsoleEvent -Event $Event -Interactive $Interactive
        if (-not $formatted) { return }
        if ($Interactive -and $Event.Code -eq 'INSTALL_STEP_PROGRESS') { $hadProgress = $true }
        elseif ($Interactive -and $hadProgress) {
            & $Writer ("`r" + (' ' * 100) + "`r") $true 'DarkGray'
            $hadProgress = $false
        }
        & $Writer $formatted.Text $formatted.NoNewline $formatted.Color
    }.GetNewClosure()
}

function Read-SgInstallerConsent {
    param(
        [bool]$Interactive,
        [string[]]$Missing = @(),
        [string[]]$Outdated = @(),
        [string]$Subject,
        [string]$Guidance = '',
        [string]$Prompt
    )
    if (-not $Interactive -or (-not $Missing.Count -and -not $Outdated.Count)) { return '' }
    if ($Missing.Count) { Write-Host "Missing ${Subject}: $($Missing -join ', ')." -ForegroundColor Yellow }
    if ($Outdated.Count) { Write-Host "${Subject} updates available: $($Outdated -join ', ')." -ForegroundColor Yellow }
    if ($Guidance) { Write-Host $Guidance -ForegroundColor DarkGray }
    return (Read-Host $Prompt).Trim()
}

function Read-SgInstallerChoice {
    param([bool]$Interactive,[string]$Prompt)
    if (-not $Interactive) { return '' }
    return (Read-Host $Prompt).Trim()
}

Export-ModuleMember -Function Format-SgInstallerConsoleEvent,New-SgInstallerConsoleEventSink,Read-SgInstallerConsent,Read-SgInstallerChoice
