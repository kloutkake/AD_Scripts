<#
Purpose:
	To find and create a list of users in AD within <your location> that are enabled 
	and also find the users that have Microsoft 365 licenses (not inclusively). 
 	With the option to remove that license.
#>

# Import the AD module
Import-Module ActiveDirectory

# Specify OU
$ouDN = "OU=YourOU,OU=YourOrganizationalUnit,DC=YourDomain,DC=com"

# Get all enabled users
$enabledUsers = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ouDN -Properties DisplayName

# Get users with 365 license
$groupName = "YourGroupName"
$ouUsers = Get-ADUser -Filter * -SearchBase $ouDN -Properties MemberOf, DisplayName
$licensedUsers = @()

# Check if user has 365 license
foreach ($user in $ouUsers) {
    $isMember = $user.MemberOf | Where-Object { $_ -like "*$groupName*" }
    if ($isMember) {
        # Add user to licensedUsers array
        $licensedUsers += $user
    }
}

# Output the summary of found users
Write-Output "Operations complete"
Write-Output "Users enabled found: $($enabledUsers.Count)"
Write-Output "Users with 365 licenses found: $($licensedUsers.Count)"

# Prompt for confirmation if there are licensed users
if ($licensedUsers.Count -gt 0) {
    $confirmation = Read-Host "Do you want to revoke these users' 365 licenses? (y/n)"
    
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
        foreach ($user in $licensedUsers) {
            Write-Output "$($user.DisplayName) is a member of $groupName. Removing..."
            # Remove user from the group
            Remove-ADGroupMember -Identity $groupName -Members $user -Confirm:$false
        }
        Write-Output "Users have been removed from the group."
    } else {
        Write-Output "No users were removed."
    }
} else {
    Write-Output "No users with 365 licenses were found."
}

# Output results
$enabledUsers | Select-Object DisplayName | Export-Csv -Path "EnabledUsers.csv" -NoTypeInformation
$licensedUsers | Select-Object DisplayName, SamAccountName | Export-Csv -Path "LicensedUsers.csv" -NoTypeInformation
