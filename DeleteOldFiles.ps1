# -------------------------------------------------------------
# This script deletes files on first level inside directory

# Log file path
$LogPath="DeleteOldFiles.log"



Function DeleteOldFiles($Path,$DaysBack) 
{
    # Get files older then $DaysBack 
    $FilesToDelete = Get-ChildItem $Path | Where {!$_.PSIsContainer -and $_.LastWriteTime -le (get-date).AddDays(-$DaysBack)}
   
    foreach ($File in $FilesToDelete) 
    {
        if ($File -ne $NULL)
        {
            Remove-Item $File.FullName -Force 
            if (Test-Path $File) { Write-Output "Fail deleting: $($File.Fullname)" >> $LogPath; }
            else                 { Write-Output "Deleted: $($File.Fullname)" >> $LogPath; }
        }
        else 
        { 
            Write-Output "No files to delete in: $Path" >> $LogPath;  
        }  
    }
}




Write-Output `n "[$(Get-Date -Format G)] =================Start job==================" `n  >> $LogPath;

# Provide dir path in with old files should be delete and number of days back
DeleteOldFiles "c:\test\database\" "15"; 

Write-Output `n "[$(Get-Date -Format G)] =================End job==================" >> $LogPath;