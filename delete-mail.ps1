# Install the EXO V2 module if not already installed
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module -Name ExchangeOnlineManagement
}

# Warning and agreement
$Warning = "WARNING: Running this script can be dangerous and destructive. By agreeing to proceed, you acknowledge the potential risks. Do you agree to proceed? (yes/no)"
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

# Loop for continuous user input
$Continue = $true
while ($Continue) {
    # Get user input
    $Mailbox = Read-Host -Prompt "Enter the email of the mailbox from which to delete messages"
    $From = Read-Host -Prompt "Enter the email address of the sender (leave blank to skip)"
    $Subject = Read-Host -Prompt "Enter the subject of the emails (leave blank to skip)"
    $StartDate = Read-Host -Prompt "Enter the start date (MM/dd/yyyy or hit Enter for today's date)"
    $EndDate = Read-Host -Prompt "Enter the end date (MM/dd/yyyy or hit Enter for today's date)"

    # Use today's date if start and end date are not provided
    if ($StartDate -eq "") { $StartDate = Get-Date -Format "MM/dd/yyyy" }
    if ($EndDate -eq "") { $EndDate = Get-Date -Format "MM/dd/yyyy" }

    # Build the search query
    $Query = @()
    if ($From -ne "") { $Query += "From:`"$From`"" }
    if ($Subject -ne "") { $Query += "Subject:`"$Subject`"" }
    $Query += "Received:`"$StartDate..$EndDate`""
    $SearchQuery = $Query -join ' AND '

    # Prompt for action
    $ActionPrompt = "What action do you want to take? Type 'delete' to delete the found messages or 'results' to just display search results"
    $Action = Read-Host -Prompt $ActionPrompt

    # Take action based on user input
    if ($Action -eq "delete") {
        Get-ExoMailbox -Identity $Mailbox | Search-Mailbox -SearchQuery $SearchQuery -DeleteContent
    } elseif ($Action -eq "results") {
        Get-ExoMailbox -Identity $Mailbox | Search-Mailbox -SearchQuery $SearchQuery -EstimateResultOnly
    } else {
        Write-Host "Invalid input. Please type either 'delete' or 'results'."
    }

    # Ask if the user wants to continue
$ContinuePrompt = Read-Host -Prompt "Do you want to continue? (yes/no)"
if ($ContinuePrompt -ne "yes") {
    $Continue = $false
    Disconnect-ExchangeOnline -Confirm:$false
}

} # This is the closing brace for the while loop
