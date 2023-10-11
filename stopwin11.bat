reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /t REG_DWORD /d 1 /f
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /t REG_SZ /d 21H2 /f

net stop wuauserv
cd /d %SystemRoot%\SoftwareDistribution
del /s /q /f Download
net start wuauserv