[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$UsePublicIP
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

    C:\Windows\OEM\ForgeApplianceConfigurator\ForgeApplianceConfigurator.exe /skip_network_config /cloud_config_only /hosting_cloud="aws" /alternate_address=$publicIp /log=$LogFile

    $defaultDbPassPath = Join-Path "C:\Windows\OEM" DefaultPwd.txt
    Remove-Item $defaultDbPassPath -Force -Recurse -ErrorAction SilentlyContinue
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}