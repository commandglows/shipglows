[CmdletBinding()]
param(
    [Parameter(Position=0)][ValidateSet('register-local','sync-ci','status')][string]$Action = 'status',
    [string]$ProjectPath = (Get-Location).Path,
    [string]$ProjectName = '',
    [ValidateSet('windows','android')][string]$Platform = 'windows',
    [string]$ArtifactPath = '',
    [string]$PackageRoot = '',
    [string]$SourceId = '',
    [string]$Commit = '',
    [string]$Repository = '',
    [string]$Workflow = '',
    [string]$Branch = '',
    [string]$ArtifactName = '',
    [string]$EntryRelativePath = '',
    [string]$StateRoot = '',
    [string]$DesktopPath = '',
    [long]$MaxBytes = 2147483648,
    [int]$MaxFiles = 50000
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$module = Join-Path $PSScriptRoot 'ShipGlows.BuildArtifacts.psm1'
if (-not (Test-Path -LiteralPath $module -PathType Leaf)) { throw "Missing ShipGlows build-artifact module: $module" }
Import-Module $module -Force -DisableNameChecking

$common = @{
    ProjectPath = $ProjectPath
    ProjectName = $ProjectName
}
if ($StateRoot) { $common.StateRoot = $StateRoot }

switch ($Action) {
    'register-local' {
        if (-not $ArtifactPath -or -not $PackageRoot) { throw 'register-local requires ArtifactPath and PackageRoot.' }
        $arguments = $common + @{
            Platform = $Platform
            SourceKind = 'local'
            ArtifactPath = $ArtifactPath
            PackageRoot = $PackageRoot
            SourceId = $SourceId
            Commit = $Commit
            MaxBytes = $MaxBytes
            MaxFiles = $MaxFiles
        }
        if ($DesktopPath) { $arguments.DesktopPath = $DesktopPath }
        Publish-SgBuildArtifact @arguments | ConvertTo-Json -Depth 8
    }
    'sync-ci' {
        foreach ($required in @(@($Repository,'Repository'),@($Workflow,'Workflow'),@($Branch,'Branch'),@($ArtifactName,'ArtifactName'))) {
            if (-not $required[0]) { throw "sync-ci requires $($required[1])." }
        }
        $arguments = $common + @{
            Platform = $Platform
            Repository = $Repository
            Workflow = $Workflow
            Branch = $Branch
            ArtifactName = $ArtifactName
            EntryRelativePath = $EntryRelativePath
            MaxBytes = $MaxBytes
            MaxFiles = $MaxFiles
        }
        if ($DesktopPath) { $arguments.DesktopPath = $DesktopPath }
        Sync-SgGitHubBuildArtifact @arguments | ConvertTo-Json -Depth 8
    }
    'status' {
        Get-SgBuildArtifactStatus @common | ConvertTo-Json -Depth 8
    }
}
