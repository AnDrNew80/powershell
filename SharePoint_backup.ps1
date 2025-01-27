Set-ExecutionPolicy RemoteSigned
Add-PsSnapin Microsoft.SharePoint.Powershell

 
# Script for backup SharePoint Farm and Site Collection.
# Local path do directory has been changed to UNC path ...



# Paths
$LogPath="\\testserver\SharePoint_backup$\Logs\SharePoint_Backup.log"
$FarmBackupPath = "\\testserver\SharePoint_backup$\Farm_backup\Farm_backup_$(Get-Date -Format  yyyy-MM-dd)"
$SiteBackupPath = "\\testserver\SharePoint_backup$\Site_collection_backup\Site_collection_backup_$(Get-Date -Format yyyy-MM-dd)\"
$SiteBackupName = "SharePointSiteColl.bak"

# Cleaning old backups settings  
$Days = "4"
$Keep = "2"
$DeleteFarmBackup = "\\testserver\SharePoint_backup$\Farm_backup\"
$DeleteSiteBackup = "\\testserver\SharePoint_backup$\Site_collection_backup\"

# Email settings - body from log file, subject depends on backup result   
$From = "SHAREPOINT_BACKUPS_ <SHAREPOINT_BACKUPS@xyzexample.com>"
$To = "abcd <abc.abc@xyzexample.com>"
$SMTPServer = "smtp-xyzexample.com"
$Subject = ""
$Body= ""

  
Write-Output `n "[$(Get-Date -Format G)] =================Start job==================" `n  > $LogPath;


# Backup SharePoint Farm
# ----------------------------------------------- 1 -----------------------------------------------

Write-Output "[$(Get-Date -Format G)] Start backup SharePoint Farm" >> $LogPath;
try 
{ 
    New-Item -ItemType directory -Path $FarmBackupPath;
	Backup-SPFarm -Directory $FarmBackupPath -BackupMethod full >> $LogPath;
} 
catch 
{ 
    Write-Output "Error: " + $_ >> $LogPath;
} 

#-----------------------------Test if file has been created and is grather then 0 kb------------
If (Test-Path "$FarmBackupPath")
{
    $BackupFileSize = (Get-ChildItem $FarmBackupPath -Recurse | Measure-Object -Sum Length).Sum;
    
    #Check if file is grather then 0 kb for ensure that is no empty and write file path with size 
    if($BackupFileSize -gt 0kb )
    {
        Write-Output "[$(Get-Date -Format G)] Farm backup finished. File created: $([string]::Format("$FarmBackupPath ( {0:0.00} MB )",$BackupFileSize / 1MB))" >> $LogPath ;  
    }
    else
    {
        Write-Output "[$(Get-Date -Format G)] Error: Backup not finished - backup is empty or has incorrect size" >> $LogPath;
    }
} 
Else
{
    Write-Output "[$(Get-Date -Format G)] Error: Backup not finished. Folder not created" >> $LogPath;
}   



 




# Backup SharePoint Site Collection
# ----------------------------------------------- 2 -----------------------------------------------

Write-Output "[$(Get-Date -Format G)] Start backup SharePoint Site Collection" >> $LogPath;
try 
{ 
    New-Item -ItemType directory -Path $SiteBackupPath;
	Backup-SPSite -Identity http://xyzexample/ -Path "$SiteBackupPath\SharePointSiteColl.bak" >> $LogPath;
} 
catch 
{ 
    Write-Output "Error: " + $_ >> $LogPath;
} 

#-----------------------------Test if file has been created and is grather then 0 kb------------
If (Test-Path "$SiteBackupPath$SiteBackupName")
{

    $BackupFileSize = (Get-Item "$SiteBackupPath$SiteBackupName").length;
    
    #Check if file is grather then 0 kb for ensure that is no empty and write file path with size 
    if($BackupFileSize -gt 0kb )
    {
        Write-Output "[$(Get-Date -Format G)] Site collection backup finished. File created: $([string]::Format("$SiteBackupPath$SiteBackupName ( {0:0.00} MB )",$BackupFileSize / 1MB))" >> $LogPath ;  
    }
    else
    {
        Write-Output "[$(Get-Date -Format G)] Error: Backup not finished - incorrect file size ( 0 kb! )" >> $LogPath;
    }
} 
Else
{
    Write-Output "[$(Get-Date -Format G)] Error: Backup not finished. File not created" >> $LogPath;
}
 





# Cleaning old Farm and Site Collection Backup
# ----------------------------------------------- 3 -----------------------------------------------    
Write-Output "[$(Get-Date -Format G)] Cleaning old backups" >> $LogPath;


# Get files older then $Days but leave 3 oldest files to avoid deleting all files in case of missing last backups
$DirsToDelete = Get-ChildItem $DeleteFarmBackup | Where {$_.PSIsContainer -and $_.LastWriteTime -le (get-date).AddDays(-$Days)}| Sort LastWriteTime -Descending | select -Skip $Keep
 
foreach ($Dir in $DirsToDelete) 
{
    if ($Dir -ne $NULL)
    {
        Remove-Item $Dir.FullName -Force -Recurse
        if (Test-Path $Dir) { Write-Output "Fail deleting: $($Dir.Fullname)" >> $LogPath; }
        else                 { Write-Output "Deleted: $($Dir.Fullname)" >> $LogPath; }
    }
    else { Write-Output "No files to delete in: $DeleteFarmBackup" >> $LogPath; } 
} 


# Get files older then $Days but leave 3 oldest files to avoid deleting all files in case of missing last backups
$DirsToDelete = Get-ChildItem $DeleteSiteBackup | Where {$_.PSIsContainer -and $_.LastWriteTime -le (get-date).AddDays(-$Days)}| Sort LastWriteTime -Descending | select -Skip $Keep
 
foreach ($Dir in $DirsToDelete) 
{
    if ($Dir -ne $NULL)
    {
        Remove-Item $Dir.FullName -Force -Recurse
        if (Test-Path $Dir) { Write-Output "Fail deleting: $($Dir.Fullname)" >> $LogPath; }
        else                 { Write-Output "Deleted: $($Dir.Fullname)" >> $LogPath; }
    }
    else { Write-Output "No files to delete in: $DeleteSiteBackup" >> $LogPath; } 
} 




Write-Output `n "[$(Get-Date -Format G)] ================== End backup ==================" `n  >> $LogPath;

# Send email 
# ----------------------------------------------- 4 -----------------------------------------------

$Body= Get-Content $LogPath | out-string

$FarmBackupIsOK = select-string -pattern "Farm backup finished" -path $LogPath 
$SiteBackupIsOK = select-string -pattern "Site collection backup finished" -path $LogPath 

If ($FarmBackupIsOK -eq $null -or $SiteBackupIsOK -eq $null ) 
{ 
    $Subject = "Backup Job: xyzexample SharePoint  FAILED !!! Check log for details" 
} 
Else 
{ 
    $Subject = "Backup Job: xyzexample SharePoint  COMPLETED successfully" 
}

Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer; 
  

# Archive last backup log with date  
# -------------------------------------------------- 4 ---------------------------------------------
Copy-Item -Path $LogPath -Destination $LogPath.replace(".log", "_$(Get-Date -Format yyyy-MM-dd).log")
  
