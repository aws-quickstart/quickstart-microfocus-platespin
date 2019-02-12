[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [string]$Password
)

try {

    $ErrorActionPreference = "Stop"
    Start-Transcript -Path C:\cfn\log\$($MyInvocation.MyCommand.Name).log -Append

    Write-Verbose "Creating Migrate admin account"
    $cn = [ADSI]"WinNT://$($env:COMPUTERNAME)"
    $user = $cn.Create("User", $Name)
    $user.SetPassword($Password)
    $user.setinfo()
    $user.description = "Migrate administrator created by Amazon QuickStart"
    $user.SetInfo()

    Write-Verbose "Adding $Name to local admin group"
    $localAdminGroup = [ADSI]"WinNT://$($env:COMPUTERNAME)/administrators, group"
    $localAdminGroup.Add($user.Path)
    
    $psAdminGroupName = "PlateSpin Administrators"
    Write-Verbose "Adding $Name to $psAdminGroupName group"
    $psAdminGroup = [ADSI]"WinNT://$($env:COMPUTERNAME)/$psAdminGroupName, group"
    $psAdminGroup.Add($user.Path)
    
    $wcAdminGroupName = "Workload Conversion Administrators"
    Write-Verbose "Adding $Name to $wcAdminGroupName group"
    $wcAdminGroup = [ADSI]"WinNT://$($env:COMPUTERNAME)/$wcAdminGroupName, group"
    $wcAdminGroup.Add($user.Path)

    Write-Verbose "Admin user $Name created successfully."
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}

