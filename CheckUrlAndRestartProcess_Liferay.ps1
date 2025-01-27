<# 
This script checks if website url respond. 
Then checks page source to be sure if Liferay is displayed correclty  ( Liferay sometimes does not load itself properly and the website is unusable )
If website not responds or is inproperly loaded, script restarts Liferay service
#>

$LogPath = "CheckUrlAndRestartProcess_Liferay.log";




#-----------------------------------Functions used inside script---------------------------------------

# THIS FUNCTION CHECKS WEBSITE URL AND GET THE RESPONSE

# Parameters:
# $url 	 		- website url to check if is working or not   
# $timeout 		- website url timeout response
# $serviceName	- windows service to restart   
# $string 		- string to check if present inside website source

Function CheckUrl ($url, $timeout, $serviceName, $string ) 
{
    try  
	{ 
		# Create the request.
		$request = [System.Net.WebRequest]::Create($url)
		$request.Timeout = $timeout

		# Get a response from the site.
		$response = $request.GetResponse()
	}
	catch [System.Net.WebException] 
	{
		$response = $_.Exception.Response      
	}
  
	# Get the HTTP code as an integer.  
	$StatusCode = [int]$response.StatusCode
	#$status = $response.StatusCode
	
	If ($StatusCode -eq 200) 
	{
		Write-Output "Site is OK. Response code: $StatusCode ." >> $LogPath
		$response.Close()
        
        # invoking function:
        CheckWebSource $url $serviceName $string 

	}
	Else 
	{
		Write-Output "The site may be down!"  >> $LogPath
        # invoking function:
		RestartProcess $serviceName
	}
}


#------------------------------------------------------------------------------------------------------

# THIS FUNCTION CHECKS WEBSITE SOURCE FOR SPECIFIC STRING 

# Parameters:
# $url 	 		- website url to check if is working or not   
# $serviceName	- windows service to restart   
# $string 		- string to check if present inside website source

Function CheckWebSource ($url,$serviceName,$string) 
{
    # Download page source and check for string 
	try  
	{ 
		# First we create the request.
		$web = New-Object Net.WebClient
		$WebSource = $web.DownloadString($url) 
		
		# Check page source for specific string
		$Found = $WebSource -match $string

	}
	catch [Net.WebException] 
	{
		Write-Output -Message " Error. Error details: $_.Exception.Message ." >> $LogPath;	
	}
	  
	If ($Found) 
	{
		Write-Output "String in page source found. Site looks correctly." >> $LogPath;	
	}
	Else 
	{
		Write-Output "String in page source not found!"  >> $LogPath;	
        # invoking function:
		RestartProcess $serviceName
	}
}


#------------------------------------------------------------------------------------------------------

# THIS FUNCTION CHECKS AND RESTART PROCESS

# Parameters:
# $serviceName	- windows service to restart   

Function RestartProcess ($serviceName) 
{

	$Service = Get-WmiObject -Class win32_service | Where-Object { $_.name -eq $serviceName }

	if ($Service) 
	{
		try 
		{
			Write-Output "Trying to stop process ..." >> $LogPath;	
			Stop-Process -Id $service.processid -Force -PassThru -ErrorAction Stop >> $LogPath;
		}
		catch 
		{
			Write-Output -Message " Error. Error details: $_.Exception.Message ."  >> $LogPath;	
		}
	}
	else 
	{
		Write-Output "No service found." >> $LogPath;	
	}
	
	Write-Output "Starting service in 10 seconds ... " >> $LogPath;	
	Start-Sleep -Seconds 10 
	Start-Service -name $serviceName -PassThru >> $LogPath;

}



#-----------------------------------------End of functions---------------------------------------------  




Write-Output `n "[$(Get-Date -Format G)] =================Start script==================" `n  >> $LogPath;



# CheckUrl params: $url $timeout $serviceName $string(optional)

CheckUrl "http://test:8080/web/guest/test" "10000" "Liferay" "X-UA-Compatible"


Write-Output `n "[$(Get-Date -Format G)] ================== End script ==================" `n  >> $LogPath; 
 


 
 
 
 


