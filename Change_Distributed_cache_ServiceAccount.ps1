Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Get the Farm
$Farm=Get-SPFarm

#Get Distributed Cache Service
$CacheService = $Farm.Services | where {$_.Name -eq "AppFabricCachingService"}

#Get the Managed account 
$ManagedAccount = Get-SPManagedAccount -Identity "adtrw\webcons"

#Set Service Account for Distributed Cache Service
$cacheService.ProcessIdentity.CurrentIdentityType = "SpecificUser"
$cacheService.ProcessIdentity.ManagedAccount = $ManagedAccount
$cacheService.ProcessIdentity.Update()
$cacheService.ProcessIdentity.Deploy()

Write-host "Service Account successfully changed for Distributed Service!"
 