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

"OK" | Out-Default
