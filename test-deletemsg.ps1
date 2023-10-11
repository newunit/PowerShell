# Import Exchange Online Management Module
Import-Module ExchangeOnlineManagement

# Connect to Office 365
$credentials = Get-Credential
Connect-ExchangeOnline -Credential $credentials -ShowBanner:$false

# Define the mailbox and the subject to delete
$targetmailbox = 'Kevin@jlwarranty.com'
$destination = 'testuser1@jlwarranty.com'
$subject = 'test'

# Get messages with specific subject
$messages = Search-Mailbox -Identity $targetmailbox -SearchQuery "Subject:'$subject'" -TargetMailbox $destination -TargetFolder 'SearchResults' -LogLevel Full

# Delete the messages
if ($messages.ResultItemsCount -gt 0) {
    $messagesID = $messages | Select-Object -ExpandProperty ResultItems | ForEach-Object {
        $_.Split(",")[1]
    }

    foreach ($messageID in $messagesID) {
        Remove-Message -Identity $messageID -Confirm:$false
    }
} else {
    Write-Output "No messages found with the subject $subject in mailbox $mailbox"
}

# Disconnect from Office 365
Disconnect-ExchangeOnline
