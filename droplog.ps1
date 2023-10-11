<#  
Script to log drop in connectivity
Checks every 10 seconds. If a drop is detected it checks every 60 seconds until it comes back online.
#>

#Variables

#Set the IP or Hostname you want to test
$target = "8.8.8.8"
#Set the location of the log file
$logfile = "C:\temp\result.txt"
#set how often to check connectivity (in seconds)
$checktime = 10
#set how long before chacking after a drop in connectivity (in seconds)
$rechecktime = 60

#no changes required past here
function Test-Ping
 {
 param($ip)
 trap {$false; continue}
 $timeout = 1000
 $object = New-Object system.Net.NetworkInformation.Ping
 (($object.Send($ip, $timeout)).Status -eq 'Success')
 }
 
$killswitch=1
 Write-Host "Running a network test. **PLEASE DO NOT CLOSE THIS WINDOW**" -Fo Red
while ($killswitch -ne 0) {
 
If (!(Test-Ping $target)) {
 Write-output 'No connection at: ' $(Get-Date -format "dd-MM-yyyy @ hh:mm:ss") | out-file -append $logfile -force
 Start-Sleep $rechecktime
 }
 Else {
 Start-Sleep $checktime
 }
}