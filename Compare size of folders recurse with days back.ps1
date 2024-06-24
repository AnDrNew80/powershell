# Script which compare size of folders in source and destination paths


$SourceFolderPath = "C:\test\datos\"  
$DestFolderPath = "C:\Backup\datos\"

# How many days back will be checked 
$DaysBack = 0 

# Get folders from source and destination path with exlude option (for names without subfloders , recourse option !!! )
$SourceFolderItems = Get-ChildItem -Path $SourceFolderPath -Exclude reports, DATOS_BK | where-object {$_.PSIsContainer -and $_.LastWriteTime -le (get-date).AddDays(-$DaysBack)}
 
$LogPath="c:\Backup\Evo_Backup.log"


 
Write-Output "[$(Get-Date -Format g)] Checking folders size on two location: `n" >> $LogPath;

    foreach ($SourceFolderItem in $SourceFolderItems)  
    {
        $SourceFolderSize = $(Get-ChildItem "$($SourceFolderPath)$($SourceFolderItem.Name)" -Recurse | Measure-Object -Sum Length | select -expand Sum);
     
        $DestFolderItem = "$($DestFolderPath)$($SourceFolderItem.Name)";
        
        # Check if mirrord folder check folder size
        If (Test-Path $DestFolderItem)
        {
            $DestFolderSize = $(Get-ChildItem $DestFolderItem -Recurse | Measure-Object -Sum Length | select -expand Sum);
        }
      
        # Compare size and put "OK" or ""
        If ( $SourceFolderSize -eq $DestFolderSize ) {  $CompResult = " OK " } Else {   $CompResult = " -- " }  
        
        # With paths
        #Write-Output "$($SourceFolderItem) ( $($SourceFolderSize) ) `t $($CompResult) ( $($DestFolderSize) ) $($DestFolderItem)" >> $LogPath;
        # Without paths - only source file name
        Write-Output "$($SourceFolderItem) ( $($SourceFolderSize) ) `t $($CompResult) ( $($DestFolderSize) ) " >> $LogPath;
    }
    
    Write-Output "`n[$(Get-Date -Format g)] End checking folders size " >> $LogPath;

