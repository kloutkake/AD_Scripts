<#
Purpose:
	To find and create a list of users that have Microsoft 365 licenses in a specific dealership. 
	To search through a different dealership, change the Dealership and state in $ouDN
#>

# Import the AD module
Import-Module ActiveDirectory

# Specify OU
$ouDN = "OU=YourOU,OU=YourOrganizationalUnit,DC=YourDomain,DC=com"

# Get users with 365 license
#$groupName = "YourGroupName" (as many as needed to check)
$ouUsers = Get-ADUser -Filter * -SearchBase $ouDN -Properties MemberOf, DisplayName, msExchRemoteRecipientType
$licensedUsers = @()

# Check if user has 365 license
foreach ($user in $ouUsers) {
	$isMember = $user.MemberOf | Where-Object { $_ -like "*$groupName*" -or $_ -like "*$otherGroup*" }
	if ($isMember -and $user.msExchRemoteRecipientType -gt 0) {
        # Add user to licensedUsers array
        $licensedUsers += $user
    }
}

# Output the summary of found users
Write-Output "Operations complete"
Write-Output "Users with 365 licenses found: $($licensedUsers.Count)"


$licensedUsers | Select-Object DisplayName, SamAccountName | Export-Csv -Path "LicensedUsers.csv" -NoTypeInformation
