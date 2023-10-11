Connect-IPPSSession -UserPrincipalName Kevin@jlwarranty.com

New-ComplianceSearch -Name "Erases_Pain@gearupfit.co" -ExchangeLocation all -ContentMatchQuery 'sent>=01/01/2020 AND sent<=10/09/2023 AND from:"Erases_Pain@gearupfit.co" '

Start-ComplianceSearch -Identity "Erases_Pain@gearupfit.co"

Get-ComplianceSearch -Identity "Erases_Pain@gearupfit.co" | Format-List

New-ComplianceSearchAction -SearchName "Erases_Pain@gearupfit.co" -Purge -PurgeType HardDelete

Disconnect-ExchangeOnline

