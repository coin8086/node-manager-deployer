param(
    [Parameter(Mandatory = $true)]
    [string] $vmResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $vmName
)

$vm = Get-AzVM -ResourceGroupName $vmResourceGroup -Name $vmName
$vm | Out-Default

if ($vm.OSProfile.LinuxConfiguration) {
    $settings = @{
        timestamp = $(Get-Date).Ticks
        fileUris = @('https://raw.githubusercontent.com/coin8086/node-manager-deployer/master/uninstall.sh')
        commandToExecute = "./uninstall.sh"
        skipDos2Unix = $true
    }
    "Unsetting VM Extension..." | Out-Default
    Set-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Location $vm.Location -ExtensionType CustomScript -Publisher Microsoft.Azure.Extensions -TypeHandlerVersion 2.0 -Name VME -Settings $settings
}
else {
    $settings = @{
        timestamp = $(Get-Date).Ticks
        fileUris = @('https://raw.githubusercontent.com/coin8086/node-manager-deployer/master/uninstall.ps1')
        commandToExecute = "powershell -ExecutionPolicy Unrestricted -File uninstall.ps1"
    }
    "Setting VM Extension..." | Out-Default
    Set-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Location $vm.Location -ExtensionType CustomScriptExtension -Publisher Microsoft.Compute -TypeHandlerVersion 1.9 -Name VME -Settings $settings
}

