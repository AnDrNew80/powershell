<# 
#>
Set-ExecutionPolicy RemoteSigned
Import-Module WebAdministration


$LogPath = "RecycleIIS.log";
 

Write-Output `n "[$(Get-Date -Format G)] =================Start script==================" `n  >> $LogPath;


	try 
	{
		& Restart-WebAppPool ".NET v4.5 (xxx.xxx.TraceEngine.API)" >> $LogPath;
	}
	catch { Write-Output "Error: " + $_ >> $LogPath; }   

	& Get-WebAppPoolState ".NET v4.5 (xxx.xxx.TraceEngine.API)"  >> $LogPath;


Write-Output `n "[$(Get-Date -Format G)] ================== End script ==================" `n  >> $LogPath; 
 


 
 
 
 


