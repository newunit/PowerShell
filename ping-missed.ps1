$ip = "68.41.24.136" # replace with the target IP address
$logFile = "c:\temp\missed_pings.log" # replace with the desired log file path and your actual username

# create the log file if it does not exist
if (!(Test-Path -Path $logFile)) {
    New-Item -ItemType File -Path $logFile | Out-Null
}

while ($true) {
    if (!(Test-Connection -ComputerName $ip -Count 1 -Quiet)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp - Failed to ping $ip`n"
        Add-Content -Path $logFile -Value $logEntry
    }
    Start-Sleep -Seconds 1 # wait 1 second before the next ping
}