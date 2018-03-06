Configuration Main
{
 
[CmdletBinding()]
 
Param (
    [string] $NodeName,
    [string] $domainName,
    [System.Management.Automation.PSCredential]$domainAdminCredentials
)
 
Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory
 
Node $AllNodes.Where{$_.Role -eq "DC"}.Nodename
    {
		    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = “Present”
      Name = “Web-Server”
    }

    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = “Present”
      Name = “Web-Asp-Net45”
    }

     WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
        }
 
        WindowsFeature DNS_RSAT
        { 
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
        }
 
        WindowsFeature ADDS_Install 
        { 
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        } 
 
        WindowsFeature RSAT_AD_AdminCenter 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-AdminCenter'
        }
 
        WindowsFeature RSAT_ADDS 
        {
            Ensure = 'Present'
            Name   = 'RSAT-ADDS'
        }
 
        WindowsFeature RSAT_AD_PowerShell 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-PowerShell'
        }
 
        WindowsFeature RSAT_AD_Tools 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-Tools'
        }
 
        WindowsFeature RSAT_Role_Tools 
        {
            Ensure = 'Present'
            Name   = 'RSAT-Role-Tools'
        }      
 
        WindowsFeature RSAT_GPMC 
        {
            Ensure = 'Present'
            Name   = 'GPMC'
        } 
        xADDomain CreateForest 
        { 
            DomainName = $domainName           
            DomainAdministratorCredential = $domainAdminCredentials
            SafemodeAdministratorPassword = $domainAdminCredentials
            DatabasePath = "C:\Windows\NTDS"
            LogPath = "C:\Windows\NTDS"
            SysvolPath = "C:\Windows\Sysvol"
            DependsOn = '[WindowsFeature]ADDS_Install'
        }
    }
	}