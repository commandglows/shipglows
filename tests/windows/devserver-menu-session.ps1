$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $root 'cli\windows\shipglows-devserver.ps1'), [ref]$tokens, [ref]$errors)
if ($errors) { throw ($errors | Out-String) }
function Get-TestFunction([string]$Name) {
    $node = $ast.Find({ param($item) $item -is [Management.Automation.Language.FunctionDefinitionAst] -and $item.Name -eq $Name }, $true)
    if (-not $node) { throw "Missing function $Name" }
    return $node.Extent.Text
}
& {
    param($definition, $items)
    $script:visits = @()
    $script:answers = [Collections.Generic.Queue[string]]::new()
    $script:answers.Enqueue('n  Navigate to a project')
    $script:answers.Enqueue('0  Quit ShipGlows')
    function Get-Content { param($LiteralPath) return $items }
    function Complete-SgBackgroundCatalogRefresh {}
    function Start-SgBackgroundCatalogRefresh {}
    function Start-SgBackgroundUpdateStatusRefresh {}
    function Read-SgChoice { param($Header, $Options) return $script:answers.Dequeue() }
    function Invoke-Navigate { $script:visits += $PID }
    $InitialMenuSelection = 'n'
    $MenuSessionRequestPath = ''
    $choiceUiAvailable = $true
    $definition = $definition.Replace("(Join-Path `$PSScriptRoot 'shipglows-menu.txt')", "'fixture-menu.txt'")
    . ([scriptblock]::Create($definition))
    Invoke-Menu
    if ($script:visits.Count -ne 2 -or @($script:visits | Where-Object { $_ -ne $PID }).Count) { throw 'Menu must reuse one backend process.' }
    if ($script:answers.Count) { throw 'First action skipped the warm menu.' }
} (Get-TestFunction 'Invoke-Menu') @(Get-Content -LiteralPath (Join-Path $root 'cli\windows\shipglows-menu.txt'))
& {
    param($definition)
    $script:authReads = 0
    $script:statusQueries = @()
    function Import-SgAuthenticationModule {}
    function Get-SgAuthenticationDefinitions {
        foreach ($name in @('ToolA','ToolB')) { [pscustomobject]@{Name=$name;Category='Service';Command='fixture.exe';LoginMode='command'} }
    }
    function Get-SgAuthenticationMenuState { param($Definition) $script:statusQueries += $Definition.Name; return [pscustomobject]@{Status='connected'} }
    function Get-SgApplication { param($Name,$KnownPaths) return 'fixture.exe' }
    function Read-SgChoice {
        param($Header,$Options)
        $script:authReads++
        switch ($script:authReads) {
            1 { if ($script:statusQueries.Count) { throw 'Opening authentication probed providers.' }; return 'Service - ToolB' }
            2 { if ($Header -notmatch 'ToolB.*connected') { throw 'Selected provider status missing.' }; return 'Back' }
            3 { return '0  Back to menu' }
            default { throw 'Authentication failed to return.' }
        }
    }
    $choiceUiAvailable = $true
    . ([scriptblock]::Create($definition))
    Invoke-SgAuthenticationMenu
    if (($script:statusQueries -join ',') -cne 'ToolB') { throw 'Authentication must probe only the selected provider.' }
} (Get-TestFunction 'Invoke-SgAuthenticationMenu')
& {
    param($definition)
    $script:resolveCount = 0; $script:select = $false
    $config = [pscustomobject]@{}
    $entry = [pscustomobject]@{Name='Demo';Id='demo-id';IsRegistered=$true;logPath='fixture.log'}
    function Get-SgProjectCatalog { param($Config,[switch]$SkipProcessReconciliation) if (-not $SkipProcessReconciliation) { throw 'Picker probed all projects.' }; return $entry }
    function Read-SgChoice { param($Header,$Options,$IdentityByLabel) if ($script:select) { return 'demo-id' }; return '' }
    function Resolve-SgProjectCatalogEntry { param($Config,$Identity,[switch]$RequireRegistered) if ($Identity -ne 'demo-id' -or -not $RequireRegistered) { throw 'Selected identity validation lost.' }; $script:resolveCount++; return $entry }
    $choiceUiAvailable = $true
    . ([scriptblock]::Create($definition))
    $result = Get-SelectedProject 'open'
    if ($null -ne $result -or $script:resolveCount) { throw 'Cancellation resolved a project.' }
    $script:select = $true
    $result = Get-SelectedProject 'open'
    if ($result.Id -ne 'demo-id' -or $script:resolveCount -ne 1) { throw 'Selected project was not authoritatively resolved.' }
} (Get-TestFunction 'Get-SelectedProject')
Write-Host 'Interactive menu: persistent session, lazy provider status, snapshot picker and selected identity: OK'
