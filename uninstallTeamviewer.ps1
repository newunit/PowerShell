$credential = Get-Credential
$computername = "REMOTE_COMPUTER_NAME"

# Uninstall existing TeamViewer Host
Invoke-Command -ComputerName $computername -Credential $credential -ScriptBlock {
    $uninstallPath = "$env:ProgramFiles\TeamViewer\uninstall.exe"
    & $uninstallPath /S
}

# Wait for the uninstallation to complete
Start-Sleep -Seconds 10

# Install new TeamViewer full version
$tvSetup = "PATH_TO_TEAMVIEWER_SETUP.EXE"
Invoke-Command -ComputerName $computername -Credential $credential -ScriptBlock {
    & $using:tvSetup /S
}
