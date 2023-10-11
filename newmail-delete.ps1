# Install the EXO V2 module if not already installed
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module -Name ExchangeOnlineManagement
}

# Warning and agreement
$Warning = @"
WARNING: Running this script can be dangerous and destructive.
By agreeing to proceed, you acknowledge the potential risks.
Do you agree to proceed? (yes/no)
"@
$Agree = Read-Host -Prompt $Warning
if ($Agree -ne "yes") {
    Write-Host "You did not agree to proceed. The script will now exit."
    return
}

# Prompt for credentials
$Username = Read-Host -Prompt "Enter your username"
$Password = Read-Host -Prompt "Enter your password" -AsSecureString
$UserCredential = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Connect to Exchange Online
Connect-ExchangeOnline -Credential $UserCredential -ShowBanner:$false

# Get user input
$Mailbox = Read-Host -Prompt "Enter the email of the mailbox from which to delete messages"
$From = Read-Host -Prompt "Enter the email address of the sender (leave blank to skip)"
$Subject = Read-Host -Prompt "Enter the subject of the emails (leave blank to skip)"
$StartDate = Read-Host -Prompt "Enter the start date (MM/dd/yyyy)"
$EndDate = Read-Host -Prompt "Enter the end date (MM/dd/yyyy)"
$Delete = Read-Host -Prompt "Do you want to delete the found messages? (yes/no)"

# Build the search query
$Query = @()
if ($From -ne "") { $Query += "From:`"$From`"" }
if ($Subject -ne "") { $Query += "Subject:`"$Subject`"" }
if ($StartDate -ne "" -and $EndDate -ne "") { $Query += "Received:`"$StartDate..$EndDate`"" }
$SearchQuery = $Query -join ' AND '

# Attempt to search the mailbox to check for permissions
try {
    Get-ExoMailbox -Identity $Mailbox | Search-Mailbox -SearchQuery $SearchQuery -EstimateResultOnly -ErrorAction Stop
}
catch {
    Write-Host "Error: $($Error[0])"
    Write-Host "You may not have the necessary permissions to perform this operation. Please check your permissions and try again."
    Disconnect-ExchangeOnline -Confirm:$false
    return
}

# Search and optionally delete the messages
if ($Delete -eq "yes") {
    Get-ExoMailbox -Identity $Mailbox | Search-Mailbox -SearchQuery $SearchQuery -DeleteContent
} else {
    Get-ExoMailbox -Identity $Mailbox | Search-Mailbox -SearchQuery $SearchQuery -EstimateResultOnly
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
