# This script checks website url. If not respond then restart related suspended process..

$LogPath = "CheckUrlAndRestartProcess_TETA.log";




#-----------------------------------Functions used inside script---------------------------------------

# THIS FUNCTION CHECKS AND RESTART PROCESS

Function RestartProcess ($serviceName) 
{

	$Service = Get-WmiObject -Class win32_service | Where-Object { $_.name -eq $serviceName }

	if ($Service) 
	{
		try 
		{
			Write-Output "Trying to stop process.." >> $LogPath;
			Stop-Process -Id $service.processid -Force -PassThru -ErrorAction Stop
		}
		catch 
		{
			Write-Warning -Message " Error. Error details: $_.Exception.Message"
		}
	}

	else 
	{
		Write-Output "No service found"
	}

	Write-Output "Starting service in 10 seconds ... " >> $LogPath;
	Start-Sleep -Seconds 10 
	Start-Service -name $serviceName -PassThru >> $LogPath;

}





#------------------------------------------------------------------------------------------------------

# THIS FUNCTION CHECKS WEBSITE URL AND GET THE RESPONSE

Function CheckUrl ($url,$timeout,$serviceName) 
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
		Write-Output "Site is OK. Response code: $($StatusCode)" >> $LogPath 
		$response.Close()
	}
	Else 
	{
		Write-Output "The site may be down!"  >> $LogPath 
		# Invoke "RestartProcess" function
		RestartProcess $serviceName
	}

}

#-----------------------------------------End of functions---------------------------------------------  




Write-Output `n "[$(Get-Date -Format G)] =================Start script==================" `n  >> $LogPath;


# Parameters 
#$url 	 		- website url to check if is working or not   
#$timeout 		- website url timeout response
#$serviceName	- service name to restart

CheckUrl "https://tetaTest.ad.test.com/test" "10000" "Tomcat8_5"


Write-Output `n "[$(Get-Date -Format G)] ================== End script ==================" `n  >> $LogPath; 
 


 
 
 
 


