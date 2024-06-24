    
$LogPath = "MonitorCPUandRecycleIIS.log"

Function RecycleApplicationPool($NameOfAppPoolToRecycle)
{
    Set-ExecutionPolicy RemoteSigned
    Import-Module WebAdministration     
    
    Write-Output `n "[$(Get-Date -Format G)] =================Start Recycle==================" `n  >> $LogPath
    
    try 
    {
       & Restart-WebAppPool $NameOfAppPoolToRecycle >> $LogPath
    }
    catch { Write-Output "Error: " + $_ >> $LogPath; }   
    
    & Get-WebAppPoolState $NameOfAppPoolToRecycle >> $LogPath
    
    
    Write-Output `n "[$(Get-Date -Format G)] ================== End Recycle ==================" `n  >> $LogPath        
}

Function LoadPercentageToInt($CPU_utilisation) 
{
     $str = $CPU_utilisation  | ft | out-string
     $utilisation = 0
     
     if ($str.Length -eq 30) {   
         $utilisation = $str.Substring($str.IndexOf(":") + 2, 1)
     }
     else {
         $utilisation = $str.Substring($str.IndexOf(":") + 2, 2)
     }
    return [convert]::ToInt32($utilisation)
}

Function MonitorApplicationPool ($NameOfAppPoolToRecycle, $CpuMaxLoad, $CpuMaxLoadTicks, $CheckInterval, $TimeoutAfterRecycle) 
{
    
	
	
	
	$maxLoadTicks = 0
    while($true) {            
        $CPU_utilisation = Get-WmiObject win32_processor | select LoadPercentage  |fl        
        $CPU_utilisation = LoadPercentageToInt $CPU_utilisation
        
        Write-Output `n "[$(Get-Date -Format G)] CPU utilisation: $CPU_utilisation"  >> $LogPath
        if($CPU_utilisation -gt $CpuMaxLoad) {
            for($i = 0; $i -lt $CpuMaxLoadTicks; $i++) { 
              
              # omit first read
              if($i -gt 0) {              
                  $CPU_utilisation = Get-WmiObject win32_processor | select LoadPercentage  |fl        
                  $CPU_utilisation = LoadPercentageToInt $CPU_utilisation        
                  Write-Output `n "[$(Get-Date -Format G)] CPU utilisation: $CPU_utilisation"  >> $LogPath
               }
                          
               if($CPU_utilisation -gt $CpuMaxLoad) {    
                  $maxLoadTicks++
               }
               else {
                  $maxLoadTicks = 0
                  break
               }                  
                            
               Start-Sleep -Seconds $CheckInterval   
            }
            if($maxLoadTicks -eq $CpuMaxLoadTicks) {             
                
				Write-Output `n "[$(Get-Date -Format G)] CPU utilisation exceeded: $CPU_utilisation "  >> $LogPath
				Write-Output `n "[$(Get-Date -Format G)] Invoke recycle application pool "  >> $LogPath
				RecycleApplicationPool $NameOfAppPoolToRecycle
                Start-Sleep -Seconds $TimeoutAfterRecycle 
            }
            $maxLoadTicks = 0
        }
        Start-Sleep -Seconds $CheckInterval 
    }     
}

<# example of invoking parameters:
	application pool name		: ".NET v4.5 (exapmle.TraceEngine.API)"
	max CPU to treshold [%]		: 90 %
	check CPU interwal [s]		: 3 seconds
	check number to threshold	: 2 count 
	recycle after seconds		: 1 second
#>


Write-Output "[$(Get-Date -Format G)] =================Start monitor=================="  >> $LogPath;

MonitorApplicationPool ".NET v4.5 (example.SDP.TraceEngine.API)" 90 3 2 1 

