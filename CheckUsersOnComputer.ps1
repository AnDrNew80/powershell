# This script gets users who have been logged into computers in domain 
Import-Module ActiveDirectory


$LogPath = "CheckUsersOnComputer.log";
$ValidComputers = "CheckUsersOnComputer.csv";
$DomainPath = "OU=PR,OU=klp,OU=Clients,OU=test,OU=PL,OU=xyz,DC=ad,DC=bcd,DC=com"



Write-Output `n "[$(Get-Date -Format G)] =================Start script==================" `n  > $LogPath;


$Computers = Get-ADComputer -SearchBase $DomainPath -Filter '*' | Select -Exp Name
 
ForEach( $Computer in $Computers )
{
   if ( Test-Connection -ComputerName $Computer -Count 2 )
   {
      Get-Childitem "\\$Computer\c$\Users\*\"  | Select FullName,LastAccessTime | Out-File –Append $ValidComputers ;

	  
	  #Write-Output $Users `n >> $LogPath;
   }
   Else
   {
       Write-Output "Cannot connect computer: $Computer" >> $LogPath;
   }      
} 

 
Write-Output `n "[$(Get-Date -Format G)] ================== End script ==================" `n  >> $LogPath; 
 