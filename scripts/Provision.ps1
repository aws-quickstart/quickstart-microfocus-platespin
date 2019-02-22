[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$UsePublicIP,

    [Parameter(Mandatory=$false)]
    [switch]$LeaveResources
)
try {

    $ErrorActionPreference = "Stop"
    Start-Transcript -Path C:\cfn\log\$($MyInvocation.MyCommand.Name).log -Append

    $scriptDirectory = "C:\cfn\log"
    $LogFile = Join-Path $scriptDirectory Provision.log

    $publicIp = ""
    if ($UsePublicIP) {
        $uri = "http://169.254.169.254/latest/meta-data/public-ipv4"
        $publicIp = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI $uri -Method get
        if (!$publicIp) {
            Write-Verbose "Unable to get the public ip address."
            Write-Verbose "Warning! You must set the public IP in AlternateServerAddresses configuration setting."
        }
        else {
            Write-Verbose "Got public IP: $publicIp"
        }
    }
    else {
        Write-Verbose "Will do private IP configuration."
    }

    #Try starting services
    Start-Service PlateSpin_Management_Service -ErrorAction SilentlyContinue
    Start-Service OfxController -ErrorAction SilentlyContinue

    C:\Windows\OEM\ForgeApplianceConfigurator\ForgeApplianceConfigurator.exe /skip_network_config /cloud_config_only /hosting_cloud="aws" /alternate_address=$publicIp /log=$LogFile

    if (-not $LeaveResources) {
        Remove-Item -Path "C:\Windows\OEM" -Force -Recurse -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}