# Prompt for admin credentials
$adminCredentials = Get-Credential -Message "Please enter your admin account credentials."

# Connect to Exchange Online using the admin credentials
Connect-ExchangeOnline -Credential $adminCredentials

# Prompt for the new Distribution Group name
$groupName = Read-Host -Prompt "Enter the new Distribution Group name"

# Concatenate to form the primary SMTP address
$primarySmtpAddress = $groupName + "@jlwarranty.com"

# New Distribution Group parameters
$parameters = @{
    Name = $groupName
    DisplayName = $groupName
    Alias = $groupName
    PrimarySmtpAddress = $primarySmtpAddress
    ManagedBy = "jlcloud@jlwarranty.com", "sdowker@jlwarranty.com"
    Description = $groupName + " OTP"
    MemberJoinRestriction = "closed"
    MemberDepartRestriction = "closed"
    Members = "Kevin@jlwarranty.com", "Rob@jlwarranty.com", "holly@jlwarranty.com", "angie@jlwarranty.com", "kristen@jlwarranty.com"
}

# Create the new Distribution Group
New-DistributionGroup @parameters

# Set Distribution Group properties
Set-DistributionGroup -Id $groupName -HiddenFromAddressListsEnabled:$true
Set-DistributionGroup -ID $groupName -RequireSenderAuthenticationEnabled $False

# Get and format the newly created Distribution Group
Get-DistributionGroup -Identity $groupName | Format-List
