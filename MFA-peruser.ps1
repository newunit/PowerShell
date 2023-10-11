# Import modules
Import-Module MSOnline
Import-Module AzureAD

# Connect to Azure AD
$cred = Get-Credential
Connect-MsolService -Credential $cred

# Prompt for user to enable MFA for 
$user = Read-Host "Enter the user principal name to enable MFA for"

# Enable MFA 
Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements Enabled

# Prompt for MFA method
$method = Read-Host "Set MFA method to App or SMS"

if ($method -eq "App") {
  Set-MsolUser -UserPrincipalName $user -StrongAuthenticationMethods @("AppNotification")
  Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements @("AppNotificationRequired")
}
elseif ($method -eq "SMS") {
  Set-MsolUser -UserPrincipalName $user -StrongAuthenticationMethods @("Sms")
}

# Disable MFA
# Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements Disabled