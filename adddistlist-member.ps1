# Prompt for admin credentials
$adminCredentials = Get-Credential -Message "Please enter your admin account credentials."

# Connect to Exchange Online using the admin credentials
Connect-ExchangeOnline -Credential $adminCredentials

# Prompt for the Distribution Group name
$groupName = Read-Host -Prompt "Enter the Distribution Group name to which you want to add members"

# Prompt for the members to be added
$members = Read-Host -Prompt "Enter the email addresses of the members you want to add (separated by commas)"

# Split the list of members into an array
$memberArray = $members.Split(",")

# Iterate over the array of members and add them to the distribution group
foreach ($member in $memberArray) {
    Add-DistributionGroupMember -Identity $groupName -Member $member -Confirm:$false
}

# Output message to confirm action
Write-Host "The following members have been added to Distribution Group ${groupName}:"
foreach ($member in $memberArray) {
    Write-Host $member
}
