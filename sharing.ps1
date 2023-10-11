Get-NetFirewallRule -DisplayGroup 'Network Discovery'|Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true -PassThru|select Name,DisplayName,Enabled,Profile|ft -a
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
md c:\temp
md c:\temp\PDFattach
New-SmbShare -Name PDFAttach -Description "PDF Attcahment" -Path C:\temp\pdfattach
Grant-SmbShareAccess -Name PDFAttach -AccountName everyone -AccessRight change -force