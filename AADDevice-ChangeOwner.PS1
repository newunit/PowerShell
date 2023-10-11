# Import the required module
Import-Module AzureAD

# Login to Azure AD
$credential = Get-Credential
Connect-AzureAD -Credential $credential

# Get the target user and device
$User = Get-AzureADUser -SearchString "jlcloud@jlwarranty.com"
$Device = Get-AzureADDevice -SearchString "JLW-L120-FDR3KW2"

# Change the device owner
Add-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId -RefObjectId $User.ObjectId
