Import-Module ExchangeOnlineManagement

Connect-IPPSSession -UserPrincipalName kevin@jlwarranty.com -ConnectionUri https://ps.protection.outlook.com/powershell-liveid/

Connect-ExchangeOnline -UserPrincipalName kevin@jlwarranty.com

Set-HostedContentFilterPolicy default -BlockedSenders @{add="nemon2ib.com"} 

Set-HostedContentFilterPolicy default -BlockedSenderDomains @{add="nemon2ib.com"} 

Set-HostedConnectionFilterPolicy "Default" -IPBlockList @{Add="211.133.134.210"}

# $x = Get-HostedContentFilterPolicy -Identity "default" 

# $x | foreach {write-host ("`r`n"*3)$_.Name,`r`n,("="*79),`r`n,"Allowed Senders"`r`n,("-"*79),`r`n,$_.AllowedSenders,("`r`n"*2),"Allowed Sender Domains",`r`n,("-"*79),`r`n,$_.AllowedSenderDomains,("`r`n"*2),"Blocked Senders"`r`n,("-"*79),`r`n,$_.BlockedSenders,("`r`n"*2),"Blocked Sender Domains",`r`n,("-"*79),`r`n,$_.BlockedSenderDomains}

