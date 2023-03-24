# A tool to get MAC addresses of vCenter VMs

param(
    [Parameter(Mandatory = $false)]
    [String]$cluster,
    [String[]]$vms,
    [String]$interface,
    [switch]$help
)

$myprog = $MyInvocation.MyCommand.Name
# Log File
$verboseLogFile = $myprog + ".log"

Function Usage ($env_type) {
    Write-Host
    Write-Host "${myprog}"
    Write-Host "  A tool to get MAC addresses of all nodes of a specified cluster or all VMs that are accessible via specified credentials."
    Write-Host
    Write-Host "Usage:"
    Write-Host
    Write-Host "  ${myprog} -vcenter <vCenter> "
    Write-Host "                [ -prefix <ClusterName> | -VMs ]"
    Write-Host "                [ -interface <1|2|3...N>]"
    Write-Host
    Write-Host "  Where, "
    Write-Host "    vcenter     VMware vCenter FQHN or IP address "
    Write-Host "    prefix      Informs " ${myprog} " to gets mac addresses of "
    Write-Host "                VMs whose VM name start with prefix, and are in"
    Write-Host "                the format: <prefix>vmNN. Where, NN is 01-04."
    Write-Host "    VMs         Displays MAC addresses of specified VMs."
    Write-Host
}

Function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Message,
        [switch]$Warning,
        [switch]$ErrorMsg,
        [switch]$Info
    )
    $timeStamp = Get-Date -Format "dd-MM-yyyy hh:mm:ss"
    Write-Host -NoNewline -ForegroundColor White "[$timeStamp]"
    if ($Warning) {
        Write-Host -ForegroundColor Yellow " $Message"
    }
    elseif ($ErrorMsg) {
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
    param(
        [string]$prefix = "prefix",
        [string[]]$vms,
        [string]$interface = ""
    ) 

    if ($prefix -ne "") {
        for ($num = 1; $num -le 4; $num++) {
            $vms += $prefix + "vm0" + $num
        }
    }
    if ($vms.Length -eq 0) {
        # For checking whether anyone else is using a particular IP!
        Write-Host "Getting VMs list..."
        $vms = Get-VM
    }
    else {
        Write-Log "Gettings mac interface $interface details for $vms..."
    }

    foreach ($vmname in $vms) {
        Write-Log "VM: $vmname"
        Write-Log "Getting $vmname mac details"
        if ($interface -ne "") {
            Write-Host "Getting $vmname Network Adapater $interface mac details"
            Get-NetworkAdapter -VM $vmname -Name "Network Adapter $interface"
            continue
        }
        Get-NetworkAdapter -VM $vmname | Out-File -Append -LiteralPath $verboseLogFile
    }
}


#################################### main ####################################
if ($help) {
    Usage $env_type
    exit 0
}

Connect_VIServer
GetVMsMac $cluster $vms $interface

