param(
    [Parameter(Mandatory = $true)]
    [string] $vmResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $vmName,
    [Parameter(Mandatory = $true)]
    [string] $packageUrl
)

# FIXME: The vmelog_xxx is almost "empty", while it's OK in an interactive shell.
$script = "curl -L https://raw.githubusercontent.com/coin8086/node-manager-deployer/master/start | bash -s -- $packageUrl > /var/log/vmelog_`$(date -Ins)"
"Command to run:`n$script`n" | Out-Default

$bytes = [System.Text.Encoding]::UTF8.GetBytes($script)
$b64s = [Convert]::ToBase64String($Bytes)
$settings = @{ script = $b64s }

$vm = Get-AzVM -ResourceGroupName $vmResourceGroup -Name $vmName

"Setting VM Extension..." | Out-Default
Set-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Location $vm.Location -ExtensionType CustomScript -Publisher Microsoft.Azure.Extensions -TypeHandlerVersion 2.0 -Name VME -Settings $settings
