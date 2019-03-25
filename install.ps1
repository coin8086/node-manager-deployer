param(
    [Parameter(Mandatory = $true)]
    [string] $packageUrl
)

# Filename must be like: xyz-1.2.3.4.zip
$filename = [System.IO.Path]::GetFileName($packageUrl)
$basename = $filename -replace '\..{3}$', ''
$version = $basename -replace '^.*-', ''
if (! $version -match '\d+\.\d+\.\d+\.\d+') {
  throw "Package version is not found in `"$packageUrl`"!"
}

$dir = 'C:\Packages'
if (!(Test-Path $dir -PathType Container)) {
    $dir = 'C:\'
}
"Enter $dir" | Out-Default
cd $dir

$namePrefix = 'Microsoft.HpcPack.HpcAcmAgent-'
dir "$namePrefix*" -Directory |
    foreach {
        cd $_;
        "Disable and uninstall `"$_`"..." | Out-Default
        .\handler.ps1 disable
        .\handler.ps1 uninstall
        if (! $?) {
            "Warning: disable/uninstall `"$_`" failed!" | Out-Default
        }
        cd ..
    }

if ($packageUrl -match 'http[s]?://') {
    "Downloading `"$packageUrl`" to `"$filename`"..." | Out-Default
    Invoke-WebRequest $packageUrl -OutFile $filename
    $source = "$dir\$filename"
}
else {
    "Assume `"$packageUrl` is already on local computer." | Out-Default
    $source = Resolve-Path $packageUrl
}
$target = "$dir\$namePrefix$version"
"Unzipping `"$source`" to `"$target`"..." | Out-Default
# Expand-Archive is available from PS Ver5.0(Windows Server 2016) and above
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($source, $target)

cd $target
"Starting..." | Out-Default
.\handler.ps1 install
.\handler.ps1 enable

$code=$?
"Return code: $code" | Out-Default
$code
