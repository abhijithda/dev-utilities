# A tool to get MAC addresses of vCenter VMs

param(
    [Parameter(Mandatory=$false)]
    [String]$vCenter,
    [String]$prefix,
    [switch]$allVMs,
    [switch]$help
)

$myprog = $MyInvocation.MyCommand.Name
# Log File
$verboseLogFile = $myprog+".log"

Function Usage ($env_type) {
    Write-Host
    Write-Host "${myprog} - A tool to list MAC addresses of vCenter VMs"
    Write-Host
    Write-Host "Usage:"
    Write-Host
    Write-Host "  ${myprog} -vcenter <vCenter> "
    Write-Host "                [ -prefix <ClusterName> | -allVMs ]"
    Write-Host
    Write-Host "  Where, "
    Write-Host "    vcenter     VMware vCenter FQHN or IP address "
    Write-Host "    prefix      Informs " ${myprog} " to gets mac addresses of "
    Write-Host "                VMs whose VM name start with prefix, and are in"
    Write-Host "                the format: <prefix>vmNN. Where, NN is 01-04."
    Write-Host "    allVMs      Displays MAC addresses of all VMs."
    Write-Host
}

Function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Message,
        [switch]$Warning,
        [switch]$Error,
        [switch]$Info
    )
    $timeStamp = Get-Date -Format "dd-MM-yyyy hh:mm:ss"
    Write-Host -NoNewline -ForegroundColor White "[$timeStamp]"
    if ($Warning) {
        Write-Host -ForegroundColor Yellow " $Message"
    }
    elseif ($Error) {
        Write-Host -ForegroundColor Red " $Message"
    }
    elseif ($Info) {
        Write-Host -ForegroundColor White " $Message"
    }
    else {
        Write-Host -ForegroundColor Green " $Message"
    }
    "[$($timeStamp)] $($Message)" | Out-File -Append -LiteralPath $verboseLogFile
}

Function Connect_VIServer {
    param(
        [Parameter(Mandatory = $true)][String]$vCenter
    )

    $vCenterServer = $vCenter
    $vCenterUser = ""
    $vCenterUserPassword = ""
    # $vCenterServer = $vm_spec.vsphere_server
    # $vCenterUser = $vm_spec.vsphere_user
    # $vCenterUserPassword = $vm_spec.vsphere_password

    $credential_file = "vcenter_" + $vCenterServer + ".xml"
    # $credential_file = Join-Path $PSScriptRoot $credential_file
    $credential_file = Join-Path $HOME $credential_file

    # Ignore certificate
    Set-PowerCLIConfiguration -DefaultVIServerMode multiple -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

    # Connect to vCenter
    if (!$vCenterServer) {
        Write-Log "Need connect to a vCenter server. Connect below."
        Connect-ViServer
    }
    elseif (Test-Path -Path $credential_file -PathType Leaf) {
        Write-Log "Connecting to vCenter $vCenterServer"
        $credential = Import-Clixml -Path $credential_file
        Connect-ViServer -Server $vCenterServer -Credential $credential -ErrorAction Stop | Out-Null
    }
    elseif (!$vCenterUser -or !$vCenterUserPassword) {
        Write-Log "Enter vCenter credentials for $vCenterServer"
        $credential = Get-Credential
        Connect-VIServer -Server $vCenterServer -Credential $credential -ErrorAction Stop | Out-Null
        $credential | Export-Clixml -Path $credential_file
    }
    else {
        Write-Log "Connecting to vCenter $vCenterServer"
        Connect-VIServer -Server $vCenterServer -user $vCenterUser -password $vCenterUserPassword -ErrorAction Stop | Out-Null
    }
}


Function GetVMsMac {
    param($prefix = "prefix") 
    Write-Host "Getting MAC addresses of all nodes of cluster prefix..."

    for ($num = 1; $num -le 4; $num++) {
        $vmname = prefix + "vm0" + $num
        Write-Host "Getting $vmname Network Adapater 2 mac details"
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 2"
    }
}


Function GetAllVMsMac {
    # For checking whether anyone else is using a particular IP!
    Write-Host "Getting VMs list..."
    $vmslist = Get-VM

    # $vmslist = @("lagoscl01vm01")
    

    foreach ($vmname in $vmslist) {
        Write-Log "VM: $vmname"
        Write-Log "Getting $vmname Network Adapater 2 and 6 mac details"
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 1" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 2" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 3" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 4" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 5" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 6" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 7" | Out-File -Append -LiteralPath $verboseLogFile
        Get-NetworkAdapter -VM $vmname -Name "Network Adapter 8" | Out-File -Append -LiteralPath $verboseLogFile
    }

}


#################################### main ####################################
if ($help) {
    Usage $env_type
    exit 0
}

if($vcenter){
    Connect_VIServer $vCenter
} else {
    Connect_VIServer
}

if ($prefix){
    Write-Log "Prefix: $prefix"
    GetVMsMac $prefix
} elseif ($allVMs) {
    GetAllVMsMac
} else {
    Usage $env_type
}
