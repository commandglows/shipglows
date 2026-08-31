$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$module=Join-Path $root 'cli\windows\ShipGlows.PowerShellRuntime.psm1'
Import-Module $module -Force -DisableNameChecking
$script:passed=0
function Assert-True([bool]$Condition,[string]$Message){if(-not $Condition){throw $Message};$script:passed++}
function Assert-Throws([scriptblock]$Action,[string]$Pattern){try{& $Action;throw 'Expected failure was not raised.'}catch{if($_.Exception.Message -eq 'Expected failure was not raised.' -or $_.Exception.Message -notmatch $Pattern){throw}};$script:passed++}
function New-TestZip([string]$Path,[hashtable]$Entries){
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $stream=[IO.File]::Open($Path,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    $zip=New-Object IO.Compression.ZipArchive($stream,[IO.Compression.ZipArchiveMode]::Create,$false)
    try{foreach($name in $Entries.Keys){$entry=$zip.CreateEntry($name);$writer=New-Object IO.StreamWriter($entry.Open());try{$writer.Write([string]$Entries[$name])}finally{$writer.Dispose()}}}finally{$zip.Dispose();$stream.Dispose()}
}
function New-CollisionZip([string]$Path){
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $stream=[IO.File]::Open($Path,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    $zip=New-Object IO.Compression.ZipArchive($stream,[IO.Compression.ZipArchiveMode]::Create,$false)
    try{foreach($name in @('A.txt','a.TXT')){$entry=$zip.CreateEntry($name);$writer=New-Object IO.StreamWriter($entry.Open());try{$writer.Write('x')}finally{$writer.Dispose()}}}finally{$zip.Dispose();$stream.Dispose()}
}
function New-SpecialZip([string]$Path,[object[]]$Entries){
    Add-Type -AssemblyName System.IO.Compression
    $stream=[IO.File]::Open($Path,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    $zip=New-Object IO.Compression.ZipArchive($stream,[IO.Compression.ZipArchiveMode]::Create,$false)
    try{foreach($item in $Entries){$entry=$zip.CreateEntry([string]$item.Name);if($item.PSObject.Properties['Attributes']){$entry.ExternalAttributes=[int]$item.Attributes};$writer=New-Object IO.StreamWriter($entry.Open());try{$writer.Write([string]$item.Content)}finally{$writer.Dispose()}}}finally{$zip.Dispose();$stream.Dispose()}
}
function Assert-NoStaging([string]$Profile){
    $owned=Join-Path $Profile '.shipglows\toolchains\powershell'
    Assert-True (-not (Test-Path $owned) -or @((Get-ChildItem -LiteralPath $owned -Force -Filter '.staging-*' -ErrorAction SilentlyContinue)).Count -eq 0) 'A failed acquisition left staging behind.'
}
$temp=Join-Path ([IO.Path]::GetTempPath()) ('sg-pwsh-test-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp|Out-Null
try{
    $profile=Join-Path $temp 'profile';New-Item -ItemType Directory -Path $profile|Out-Null
    $archive=Join-Path $temp 'valid.zip';New-TestZip $archive @{'pwsh.exe'='fixture'}
    $sha=(Get-FileHash $archive -Algorithm SHA256).Hash
    $fixture=[pscustomobject]@{version='7.6.5';platform='win-x64';archiveUrl='https://github.com/PowerShell/PowerShell/releases/download/v7.6.5/PowerShell-7.6.5-win-x64.zip';sha256=$sha;maxEntries=20;maxExpandedBytes=1024}
    $download={param($url,$target) Copy-Item -LiteralPath $archive -Destination $target}
    $probe={param($exe) if((Get-Content -LiteralPath $exe -Raw)-eq 'fixture'){'7.6.5|Core|X64'}else{'bad'}}
    $resolved=Ensure-SgPowerShellRuntime -UserProfile $profile -DownloadRunner $download -ProbeRunner $probe -TrustedManifest $fixture
    Assert-True (Test-Path -LiteralPath $resolved -PathType Leaf) 'Fresh fixture runtime was not activated.'
    Assert-True ($resolved -like '*\.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe') 'Runtime coordinate is not canonical.'
    $pointer=Get-Content -LiteralPath (Join-Path $profile '.shipglows\toolchains\powershell\current.json') -Raw|ConvertFrom-Json
    Assert-True ($pointer.schemaVersion -eq 2) 'Runtime pointer does not use the integrity-bound schema.'
    Assert-True ($pointer.relativePath -eq '7.6.5/win-x64') 'Atomic pointer does not contain the immutable coordinate.'
    Assert-True ($pointer.executableSha256 -eq (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash) 'Runtime pointer is not bound to the managed executable hash.'
    $fastProbe={param($exe) throw 'The valid launch pointer unexpectedly started a probe process.'}
    $fastResolved=Resolve-SgManagedPowerShellForLaunch -Offline -UserProfile $profile -ProbeRunner $fastProbe -TrustedManifest $fixture -DownloadRunner $download
    Assert-True ($fastResolved -eq $resolved) 'Valid launch pointer did not resolve the managed runtime directly.'
    $pointer.executableSha256='0'*64
    $pointer|ConvertTo-Json -Compress|Set-Content -LiteralPath (Join-Path $profile '.shipglows\toolchains\powershell\current.json') -Encoding UTF8
    $revalidated=Resolve-SgManagedPowerShellForLaunch -Offline -UserProfile $profile -ProbeRunner $probe -TrustedManifest $fixture -DownloadRunner $download
    Assert-True ($revalidated -eq $resolved) 'Invalid launch pointer did not fall back to full runtime validation.'
    $pointer=Get-Content -LiteralPath (Join-Path $profile '.shipglows\toolchains\powershell\current.json') -Raw|ConvertFrom-Json
    Assert-True ($pointer.executableSha256 -eq (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash) 'Full validation did not repair the invalid launch pointer.'
    $called=$false;$noDownload={param($u,$t)$script:called=$true}
    $again=Ensure-SgPowerShellRuntime -Offline -UserProfile $profile -ProbeRunner $probe
    Assert-True ($again -eq $resolved) 'Offline valid runtime was not reused.'
    [IO.File]::WriteAllText($resolved,'corrupt')
    $repaired=Ensure-SgPowerShellRuntime -UserProfile $profile -DownloadRunner $download -ProbeRunner $probe -TrustedManifest $fixture
    Assert-True ((Get-Content -LiteralPath $repaired -Raw)-eq 'fixture') 'Corrupt immutable coordinate was not transactionally repaired.'
    $missing=Join-Path $temp 'missing';New-Item -ItemType Directory -Path $missing|Out-Null
    Assert-Throws {Ensure-SgPowerShellRuntime -Offline -UserProfile $missing -ProbeRunner $probe} 'missing or invalid'
    $badProfile=Join-Path $temp 'badsha';New-Item -ItemType Directory -Path $badProfile|Out-Null
    $bad=[pscustomobject]@{version='7.6.5';platform='win-x64';archiveUrl=$fixture.archiveUrl;sha256=('0'*64);maxEntries=20;maxExpandedBytes=1024}
    Assert-Throws {Ensure-SgPowerShellRuntime -UserProfile $badProfile -DownloadRunner $download -ProbeRunner $probe -TrustedManifest $bad} 'SHA-256'
    Assert-True (-not (Test-Path (Join-Path $badProfile '.shipglows\toolchains\powershell\current.json'))) 'SHA failure changed the pointer.'
    Assert-NoStaging $badProfile
    $lockedProfile=Join-Path $temp 'locked';$lockDir=Join-Path $lockedProfile '.shipglows\toolchains\powershell';New-Item -ItemType Directory -Path $lockDir -Force|Out-Null
    $held=[IO.File]::Open((Join-Path $lockDir '.runtime.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    try{Assert-Throws {Ensure-SgPowerShellRuntime -UserProfile $lockedProfile -LockTimeoutSeconds 1 -DownloadRunner $download -ProbeRunner $probe -TrustedManifest $fixture} 'Timed out'}finally{$held.Dispose()}
    foreach($hostile in @('../escape.txt','CON.txt','safe:ads','A/../b')){
        $z=Join-Path $temp (([Guid]::NewGuid().ToString('N'))+'.zip');New-TestZip $z @{$hostile='x'}
        $dest=Join-Path $temp ([Guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $dest|Out-Null
        Assert-Throws {Expand-SgTrustedRuntimeArchive $z $dest 20 1024} 'traversal|unsafe|alternate'
    }
    foreach($rooted in @('/absolute.txt','C:/absolute.txt')){
        $z=Join-Path $temp (([Guid]::NewGuid().ToString('N'))+'.zip');New-SpecialZip $z @([pscustomobject]@{Name=$rooted;Content='x'})
        $dest=Join-Path $temp ([Guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $dest|Out-Null
        Assert-Throws {Expand-SgTrustedRuntimeArchive $z $dest 20 1024} 'absolute path'
    }
    $unixLink=Join-Path $temp 'unix-link.zip';New-SpecialZip $unixLink @([pscustomobject]@{Name='link';Content='target';Attributes=-1610612736})
    $unixDest=Join-Path $temp 'unix-link';New-Item -ItemType Directory -Path $unixDest|Out-Null
    Assert-Throws {Expand-SgTrustedRuntimeArchive $unixLink $unixDest 20 1024} 'symbolic link'
    $reparse=Join-Path $temp 'reparse.zip';New-SpecialZip $reparse @([pscustomobject]@{Name='junction';Content='target';Attributes=[int][IO.FileAttributes]::ReparsePoint})
    $reparseDest=Join-Path $temp 'reparse';New-Item -ItemType Directory -Path $reparseDest|Out-Null
    Assert-Throws {Expand-SgTrustedRuntimeArchive $reparse $reparseDest 20 1024} 'reparse point'
    $collision=Join-Path $temp 'collision.zip';New-CollisionZip $collision
    $collisionDest=Join-Path $temp 'collision';New-Item -ItemType Directory -Path $collisionDest|Out-Null
    Assert-Throws {Expand-SgTrustedRuntimeArchive $collision $collisionDest 20 1024} 'collision'
    foreach($entries in @(
        @([pscustomobject]@{Name='node';Content='file'},[pscustomobject]@{Name='node/child';Content='child'}),
        @([pscustomobject]@{Name='node/child';Content='child'},[pscustomobject]@{Name='node';Content='file'})
    )){
        $z=Join-Path $temp (([Guid]::NewGuid().ToString('N'))+'.zip');New-SpecialZip $z $entries
        $dest=Join-Path $temp ([Guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $dest|Out-Null
        Assert-Throws {Expand-SgTrustedRuntimeArchive $z $dest 20 1024} 'file/directory conflict'
    }
    $many=Join-Path $temp 'many.zip';New-SpecialZip $many @([pscustomobject]@{Name='1';Content='1'},[pscustomobject]@{Name='2';Content='2'})
    $manyDest=Join-Path $temp 'many';New-Item -ItemType Directory -Path $manyDest|Out-Null
    Assert-Throws {Expand-SgTrustedRuntimeArchive $many $manyDest 1 1024} 'too many entries'
    $large=Join-Path $temp 'large.zip';New-SpecialZip $large @([pscustomobject]@{Name='large';Content=('x'*20)})
    $largeDest=Join-Path $temp 'large';New-Item -ItemType Directory -Path $largeDest|Out-Null
    Assert-Throws {Expand-SgTrustedRuntimeArchive $large $largeDest 20 10} 'expanded-size limit'
    foreach($invalidProbe in @('7.6.4|Core|X64','7.6.5|Desktop|X64','7.6.5|Core|Arm64')){
        $invalidProfile=Join-Path $temp ('probe-'+[Guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $invalidProfile|Out-Null
        $badProbe={param($exe)$invalidProbe}.GetNewClosure()
        Assert-Throws {Ensure-SgPowerShellRuntime -UserProfile $invalidProfile -DownloadRunner $download -ProbeRunner $badProbe -TrustedManifest $fixture} 'version, edition, or architecture'
        Assert-NoStaging $invalidProfile
    }
    $extractProfile=Join-Path $temp 'extract-fail';New-Item -ItemType Directory -Path $extractProfile|Out-Null
    $hostileArchive=Join-Path $temp 'hostile-download.zip';New-TestZip $hostileArchive @{'../escape'='x'}
    $hostileSha=(Get-FileHash $hostileArchive -Algorithm SHA256).Hash
    $hostileManifest=[pscustomobject]@{version='7.6.5';platform='win-x64';archiveUrl=$fixture.archiveUrl;sha256=$hostileSha;maxEntries=20;maxExpandedBytes=1024}
    $hostileDownload={param($u,$t)Copy-Item $hostileArchive $t}
    Assert-Throws {Ensure-SgPowerShellRuntime -UserProfile $extractProfile -DownloadRunner $hostileDownload -ProbeRunner $probe -TrustedManifest $hostileManifest} 'traversal'
    Assert-NoStaging $extractProfile
    $rollbackProfile=Join-Path $temp 'rollback';New-Item -ItemType Directory -Path $rollbackProfile|Out-Null
    $rollbackPath=Ensure-SgPowerShellRuntime -UserProfile $rollbackProfile -DownloadRunner $download -ProbeRunner $probe -TrustedManifest $fixture
    [IO.File]::WriteAllText($rollbackPath,'old-corrupt')
    $pointerPath=Join-Path $rollbackProfile '.shipglows\toolchains\powershell\current.json';$pointerBefore=[IO.File]::ReadAllText($pointerPath)
    $pointerFailure={param($path,$layout)throw 'injected pointer failure'}
    Assert-Throws {Ensure-SgPowerShellRuntime -UserProfile $rollbackProfile -DownloadRunner $download -ProbeRunner $probe -TrustedManifest $fixture -PointerWriter $pointerFailure} 'injected pointer failure'
    Assert-True ((Get-Content $rollbackPath -Raw)-eq 'old-corrupt') 'Pointer failure did not restore the previous corrupt coordinate.'
    Assert-True ([IO.File]::ReadAllText($pointerPath)-eq $pointerBefore) 'Pointer failure changed the active pointer.'
    Assert-NoStaging $rollbackProfile
    $pathLayout=Get-SgPowerShellRuntimeLayout -UserProfile $profile
    Assert-True ($pathLayout.Executable -eq $resolved) 'Resolver consulted a PATH pwsh instead of the managed coordinate.'
    $bootstrap=Get-Content -LiteralPath (Join-Path $root 'cli\windows\ShipGlows.PowerShellBootstrap.ps1') -Raw
    $frontend=Get-Content -LiteralPath (Join-Path $root 'cli\windows\shipglows-devserver.ps1') -Raw
    Assert-True ($bootstrap -match 'SHIPGLOWS_MANAGED_PWSH' -and $bootstrap -notmatch 'Get-Command\s+pwsh') 'Bootstrap does not enforce the managed host.'
    Assert-True ($bootstrap -match 'exit \$LASTEXITCODE') 'Bootstrap does not statically propagate the managed frontend exit code.'
    Assert-True ($frontend -match "PSEdition -ne 'Core'" -and $frontend -match 'refused an unmanaged PowerShell Core') 'Frontend host gate is missing.'
    $installer=Get-Content -LiteralPath (Join-Path $root 'cli\windows\install-devserver.ps1') -Raw
    Assert-True ($installer -match '_SHIPGLOWS_PWSH' -and $installer -match 'SHIPGLOWS_MANAGED_PWSH=%_SHIPGLOWS_PWSH%' -and $installer -match 'shipglows-devserver\.ps1' -and $installer -match ':shipglows_bootstrap' -and $installer -match 'ShipGlows\.PowerShellBootstrap\.ps1') 'Installed wrappers do not preserve the direct managed-runtime path and secure bootstrap fallback.'
    $binder=Join-Path $temp 'binder.ps1'
    [IO.File]::WriteAllText($binder,'param([switch]$Offline,[Parameter(ValueFromRemainingArguments=$true)][string[]]$RemainingArgs=@()); [pscustomobject]@{offline=[bool]$Offline;remaining=@($RemainingArgs)}|ConvertTo-Json -Compress',[Text.UTF8Encoding]::new($false))
    $bound=& powershell.exe -NoLogo -NoProfile -File $binder -Offline 'path with spaces' 'quoted value' '--literal=-Offline'|ConvertFrom-Json
    Assert-True ($bound.offline -and @($bound.remaining).Count -eq 3) 'Bootstrap binder did not consume only its reserved Offline option.'
    Assert-True ($bound.remaining[0] -eq 'path with spaces' -and $bound.remaining[1] -eq 'quoted value' -and $bound.remaining[2] -eq '--literal=-Offline') 'Bootstrap binder changed quoted spaces or literal Offline text.'
    Write-Host "PowerShell runtime contract passed: $script:passed assertions."
}finally{
    [GC]::Collect();[GC]::WaitForPendingFinalizers()
    if(Test-Path $temp){for($i=0;$i -lt 5;$i++){try{Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction Stop;break}catch{if($i -eq 4){throw};Start-Sleep -Milliseconds 100}}}
}
