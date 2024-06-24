#removing directories with old Farm_backup - 4 days old sharepoint

Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Force 
cd D:\Backup\SharePoint_backup\Farm_backup
$dirs = Get-ChildItem "D:\Backup\SharePoint_backup\Farm_backup\" | ?{ $_.PSIsContainer  -and $_.LastWriteTime -le (get-date).AddDays(-4)}

if ($dirs -gt $null)
{
	get-item $dirs | foreach {
		
		$directory_date = $(get-date)
		Remove-Item $_.FullName -Recurse 
        "$directory_date : Deleted: $_"


		
	} | out-file D:\Backup\SharePoint_backup\Cleanlog.log -Append
}

#removing directories with old Site_collection_backup - 4 days old

cd D:\Backup\SharePoint_backup\Site_collection_backup
$dirs2 = Get-ChildItem "D:\Backup\SharePoint_backup\Site_collection_backup\" | ?{ $_.PSIsContainer  -and $_.LastWriteTime -le (get-date).AddDays(-4)}

if ($dirs2 -gt $null)
{
	get-item $dirs2 | foreach {
		
		$directory_date = $(get-date)
		Remove-Item $_.FullName -Recurse 
        "$directory_date : Deleted: $_"
	
	} | out-file D:\Backup\SharePoint_backup\Cleanlog.log -Append
}