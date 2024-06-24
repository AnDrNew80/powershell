$Now = Get-Date

# ------------ BEGIN SECTION OF removing old order files older then 15 days 
$TargetFolder = "D:\Liferay\liferay-portal-6.1.1-ce-ga2\tomcat-7.0.27\logs"
$Days = "15" 
$LastWrite = $Now.AddDays(-$Days) 
$Files = Get-Childitem $TargetFolder -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
foreach ($File in $Files)  
{ 
	if ($File -ne $NULL) 
	{
		write-output "Deleting File $File" >> deleted_logs_history.txt 
		Remove-Item $File.FullName | out-null
	}
	else
	{
		write-output "No more files to delete!" >> deleted_logs_history.txt 	
	}
}

# ------------ END SECTION OF removing old order files older then 15 days 

