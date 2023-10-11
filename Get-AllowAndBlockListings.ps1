<#PSScriptInfo
 
.VERSION 2.0.1
 
.GUID 593703ef-d363-43ad-9f13-ea64af9ad05c
 
.AUTHOR Aaron Guilmette
 
.COMPANYNAME Microsoft
 
.COPYRIGHT 2021
 
.TAGS
 
.LICENSEURI
 
.PROJECTURI https://www.undocumented-features.com/2018/12/10/find-allowed-users-domains-and-ips-in-office-365/
 
.ICONURI
 
.EXTERNALMODULEDEPENDENCIES
 
.REQUIREDSCRIPTS
 
.EXTERNALSCRIPTDEPENDENCIES
 
.RELEASENOTES
 
.DESCRIPTION
Use this script to list allow entries across transport rules, content filter policies, and connection filter policies.
 
.PRIVATEDATA
 
#>

<#
.SYNOPSIS
Compile allow and block lists from Exchange Online Protection.
 
.PARAMETER Credential
Supply an Exchange Online credential.
 
.EXAMPLE
.\Get-AllowAndBlockListings.ps1
Generate listing of all allowed and block item entries.
 
.LINK
https://www.undocumented-features.com/2018/12/10/find-allowed-users-domains-and-ips-in-office-365/
 
.NOTES
2021-02-15 - Cleaned up filter syntax and formatting.
             Updated nomenclature in variables to "allow" and "block" instead of legacy biased terminology.
2021-02-13 - Updated and publisehd to PowerShell Gallery.
2018-12-10 - Original release.
 
All environments perform differently. Please test this code before using it
in production.
 
THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR RESULTS FROM THE USE OF
THIS CODE REMAINS WITH THE USER.
 
Author: Aaron Guilmette
        aaron.guilmette@microsoft.com
#>

param (
    [System.Management.Automation.PSCredential]$Credential,
    [string]$Output = (Get-Date -Format yyyy-MM-dd) + "_AllowedBlockedenderOutput.csv"
)


function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput, [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")][string]$LogLevel)
{
    $Message = $Message + $Input
    If (!$LogLevel) { $LogLevel = "INFO" }
    switch ($LogLevel)
    {
        SUCCESS { $Color = "Green" }
        INFO { $Color = "White" }
        WARN { $Color = "Yellow" }
        ERROR { $Color = "Red" }
        DEBUG { $Color = "Gray" }
    }
    if ($Message -ne $null -and $Message.Length -gt 0)
    {
        $TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
        if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
        {
            Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] [$LogLevel] :: $Message"
        }
        if ($ConsoleOutput -eq $true)
        {
            Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color
        }
    }
}

# Detect Office 365 Session
Try
{
    $Sessions = Get-PSSession -ea stop | ? {$_.ComputerName -eq "outlook.office365.com" -and $_.State -eq "Opened" }
    If ($Sessions) { Write-Log -Message "Detected open Office 365 session." -Loglevel SUCCESS -ConsoleOutput }
    else
    {
        If (!($Credential))
        {
            $Credential = Get-Credential
        }
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credential -Authentication Basic -AllowRedirection
        Import-PSSession $Session
    }
}
Catch
{
    Write-Log -Message "No open Office 365 session detected." -LogLevel WARN
    If (!($Credential))
    {
        $Credential = Get-Credential
    }
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
}

# Build Report Collection
Write-Log -Message "Initializing report." -LogLevel INFO -ConsoleOutput
[System.Collections.ArrayList]$report = @()

# Evaluate Content Filter Policies
Write-Log -Message "Collecting Content (Spam) Filter policies." -LogLevel INFO -ConsoleOutput
[array]$ContentFilterPolicies = Get-HostedContentFilterPolicy

Write-Log -Message "Retrieved $($ContentFilterPolicies.Count) content filter policies." -LogLevel INFO -ConsoleOutput
foreach ($policy in $ContentFilterPolicies)
{
    # Whitelisted Senders per policy
    foreach ($Sender in $policy.AllowedSenders)
    {
        $AllowedSenders = New-Object -TypeName PSObject
        $AllowedSenders | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "ContentOrSpamFilter"
        $AllowedSenders | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($policy.Name)
        $AllowedSenders | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($policy.Guid)
        $AllowedSenders | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "User"
        $AllowedSenders | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($Sender)
        $AllowedSenders | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $AllowedSenders
        $AllowedSenders = $null
    }
    
    # Blocked Senders per policy
    foreach ($Sender in $policy.BlockedSenders)
    {
        $BlockedSenders = New-Object -TypeName PSObject
        $BlockedSenders | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "ContentOrSpamFilter"
        $BlockedSenders | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($policy.Name)
        $BlockedSenders | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($policy.Guid)
        $BlockedSenders | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "User"
        $BlockedSenders | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($Sender)
        $BlockedSenders | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Block"
        $report += $BlockedSenders
        $BlockedSenders = $null
    }
    
    # Allowed Domains per policy
    foreach ($Domain in $policy.AllowedSenderDomains)
    {
        $AllowedSenderDomains = New-Object -TypeName PSObject
        $AllowedSenderDomains | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "ContentOrSpamFilter"
        $AllowedSenderDomains | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($policy.Name)
        $AllowedSenderDomains | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($policy.Guid)
        $AllowedSenderDomains | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "Domain"
        $AllowedSenderDomains | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($Domain)
        $AllowedSenderDomains | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $AllowedSenderDomains
        $AllowedSenderDomains = $null
    }
    
    # Blocked Domains per policy
    foreach ($Domain in $policy.BlockedSenderDomains)
    {
        $BlockedSenderDomains = New-Object -TypeName PSObject
        $BlockedSenderDomains | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "ContentOrSpamFilter"
        $BlockedSenderDomains | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($policy.Name)
        $BlockedSenderDomains | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($policy.Guid)
        $BlockedSenderDomains | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "Domain"
        $BlockedSenderDomains | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($Domain)
        $BlockedSenderDomains | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Block"
        $report += $BlockedSenderDomains
        $BlockedSenderDomains = $null
    }
}

# Evaluate Connection Filter Policies
Write-Log -Message "Collecting Connection Filter policies." -LogLevel INFO -ConsoleOutput

[array]$ConnectionFilterPolicies = Get-HostedConnectionFilterPolicy
Write-Log -Message "Retrieved $($ConnectionFilterPolicies.Count) connection filter policies." -LogLevel INFO -ConsoleOutput    

foreach ($policy in $ConnectionFilterPolicies)
{
    # IP allow list
    foreach ($IP in $policy.IPAllowList)
    {
        $IPAllow = New-Object -TypeName PSObject
        $IPAllow | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "ConnectionFilter"
        $IPAllow | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($policy.Name)
        $IPAllow | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($policy.Guid)
        $IPAllow | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "IP"
        $IPAllow | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($IP)
        $IPAllow | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $IPAllow
        $IPAllow = $null
    }
    
    # IP Block list
    foreach ($IP in $policy.IPBlockList)
    {
        $IPBlock = New-Object -TypeName PSObject
        $IPBlock | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "ConnectionFilter"
        $IPBlock | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($policy.Name)
        $IPBlock | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($policy.Guid)
        $IPBlock | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "IP"
        $IPBlock | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($IP)
        $IPBlock | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Block"
        $report += $IPBlock
        $IPBlock = $null
    }
}

# Evaluate Transport Rules
Write-Log -Message "Collecting Transport Rules with an action of SetSCL -1 (bypass spam filtering)." -LogLevel INFO -ConsoleOutput
[array]$TransportRules = Get-TransportRule | ? { $_.SetScl -eq "-1" }
Write-Log -Message "Retrieved $($TransportRules.Count) matching transport rules." -LogLevel INFO -ConsoleOutput

foreach ($rule in $TransportRules)
{
    # Allowed Sender Domain (SenderDomainIs)
    foreach ($Domain in $rule.SenderDomainIs)
    {
        $DomainAllow = New-Object -TypeName PSObject
        $DomainAllow | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "TransportRule"
        $DomainAllow | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($rule.Name)
        $DomainAllow | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($rule.Guid)
        $DomainAllow | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "Domain"
        $DomainAllow | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($Domain)
        $DomainAllow | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $DomainAllow
        $DomainAllow = $null
    }
    
    # Allowed Senders (From)
    foreach ($User in $rule.From)
    {
        $FromAllow = New-Object -TypeName PSObject
        $FromAllow | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "TransportRule"
        $FromAllow | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($rule.Name)
        $FromAllow | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($rule.Guid)
        $FromAllow | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "User"
        $FromAllow | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($User)
        $FromAllow | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $FromAllow
        $FromAllow = $null
    }
    
    # Allowed IPs (SenderIpRanges)
    foreach ($IP in $rule.SenderIpRanges)
    {
        $IPAllow = New-Object -TypeName PSObject
        $IPAllow | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "TransportRule"
        $IPAllow | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($rule.Name)
        $IPAllow | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($rule.Guid)
        $IPAllow | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "IP"
        $IPAllow | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $($IP)
        $IPAllow | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $IPAllow
        $IPAllow = $null
    }
    
    # Allowed Sender or Domain Contains (FromAddressContainsWords)
    foreach ($Sender in $rule.FromAddressContainsWords)
    {
        $SenderOrDomainContains = New-Object -TypeName PSObject
        $SenderOrDomainContains | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "TransportRule"
        $SenderOrDomainContains | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($rule.Name)
        $SenderOrDomainContains | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($rule.Guid)
        $SenderOrDomainContains | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "ContainsWords"
        $SenderOrDomainContains | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $Sender
        $report += $SenderOrDomainContains
        $SenderOrDomainContains = $null
    }
    
    # Allowed Sender or Domain Regex (FromAddressMatchesPatterns)
    foreach ($Sender in $rule.FromAddressMatchesPatterns)
    {
        $SenderOrDomainMatches = New-Object -TypeName PSObject
        $SenderOrDomainMatches | Add-Member -MemberType NoteProperty -Name "PolicyType" -Value "TransportRule"
        $SenderOrDomainMatches | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $($rule.Name)
        $SenderOrDomainMatches | Add-Member -MemberType NoteProperty -Name "PolicyGuid" -Value $($rule.Guid)
        $SenderOrDomainMatches | Add-Member -MemberType NoteProperty -Name "ObjectType" -Value "PatternMatch"
        $SenderOrDomainMatches | Add-Member -MemberType NoteProperty -Name "ObjectName" -Value $Sender
        $SenderOrDomainMatches | Add-Member -MemberType NoteProperty -Name "ActionType" -Value "Allow"
        $report += $SenderOrDomainMatches
        $SenderOrDomainMatches = $null
    }
}
$global:report = $report
$report | Export-Csv $Output -NoTypeInformation -Force
Write-Log -Message "Report $($Output) generated. You can also access the content by accessing the `$report object." -ConsoleOutput