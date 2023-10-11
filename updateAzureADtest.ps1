# Connect to AzureAD
Connect-AzureAD

# Get CSV content
$CSVrecords = Import-Csv C:\Temp\test.csv -Delimiter ","

# Create arrays for skipped and failed users
$SkippedUsers = @()
$FailedUsers = @()

# Loop trough CSV records
foreach ($CSVrecord in $CSVrecords) {
    $upn = $CSVrecord.UserPrincipalName
    $user = Get-AzureADUser -Filter "userPrincipalName eq '$upn'"  
    if ($user) {
        try{
       set-AzureADUser -Department $CSVrecord.Department -TelephoneNumber $CSVrecord.TelephoneNumber -mail $CSVrecord.mail -JobTitle $CSVrecord.jobtitle -StreetAddress $CSVrecord.streetAddress -State $CSVrecord.state -Country $CSVrecord.country -PostalCode $CSVrecord.postalCode -Mobile $CSVrecord.mobilePhone -city $CSVrecord.city
        } catch {
        $FailedUsers += $upn
        Write-Warning "$upn user found, but FAILED to update."
        }
    }
    else {
        Write-Warning "$upn not found, skipped"
        $SkippedUsers += $upn
    }
}

# Array skipped users
# $SkippedUsers

# Array failed users
# $FailedUsers