<#
    .SYNOPSIS
    This script retrieves a list of all associates who report at some level to a requested user,
    ignoring any elevated/service accounts. 

    .PARAMETER User
    $User can be supplied with either the SamAccountName or an email address.
    
    .EXAMPLE
    .\Get-AD_AllDirectReports $User
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $true)]
        [string]$User
)

try {
    if (-not (Get-Module -Name ActiveDirectory)) { 
        Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false 
    }
} catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

[regex]$userNameRegex = '' #Update this before running!
[regex]$emailRegex = '[A-Z]+@[A-Z]+.com'
[string]$OUFilter = 'OU=Users' #main AD OU where default Users are stored
$finalUsers = @()
$usersToBeSearched = @() 

switch -regex ($User) {
    $emailRegex {
        $email = $User
        $User = (Get-ADUser -Filter "UserPrincipalName -eq '$($User)'").SamAccountName
        Write-Host "Email address `"$email`" submitted. Found User `"$User`" to search Active Directory with." -ForegroundColor Gray
    }
    $userNameRegex {
        Write-Host "No change to `"$User`" because it's already in the expected format." -ForegroundColor Gray
    }
    default {
        Write-Host "Unexpected format for `"$User`". Unable to search Active Directory." -ForegroundColor Red
    }
}

$usersToBeSearched += @("$User")
do {
    foreach ($User in $usersToBeSearched) {
        $usersToBeSearched = $usersToBeSearched | Where-Object { $_ -ne $User } #remove current user from future search list

        $UserInfo = Get-ADUser $User -Properties * 
        if ([bool](($UserInfo.DisplayName -notlike '* Service Account*') `
                    -and ($UserInfo.DisplayName -notlike '*Account*') `
                    -and ($null -ne $UserInfo.UserPrincipalName) `
            )) {
            $Id = $UserInfo.SamAccountName
            $DisplayName = $UserInfo.DisplayName
            $Email = $UserInfo.UserPrincipalName
            $Manager = (Get-ADUser (((($UserInfo.Manager).Split(",")[0]).Split("=")[1]).Split(" ")[0]) -Properties DisplayName) #Splits off the long distinguished name to just the SamAccountName
            $ManagerId = $Manager.SamAccountName
            $ManagerName = $Manager.DisplayName
            $ManagerEmail = $Manager.UserPrincipalName

            $finalUsers += @(
                [PSCustomObject]@{
                    ID           = "$Id"
                    DisplayName  = "$DisplayName";
                    Email        = "$Email";
                    ManagerId    = "$ManagerId"
                    ManagerName  = "$ManagerName";
                    ManagerEmail = "$ManagerEmail"
                }
            )
            
            Write-Host "Searching User `"$User`"..." -ForegroundColor Green
            $DirectReports = $UserInfo.directReports | Where-Object { $_ -match $OUFilter }
            foreach ($reportUser in $DirectReports) {
                $reportUserSAN = ((($reportUser.split(",")[0]).split("=")[1]).split("\")[0]).split(" ")[0] #Splits off the long distinguished name to just the SamAccountName
                if ([bool]($reportUserSAN -match $userNameRegex)) {
                    if ([bool]($finalUsers.Id -notcontains "$reportUserSAN")) {
                        $usersToBeSearched += @("$reportUserSAN")
                        Write-Host "Found direct report `"$reportUserSAN`" and added to list to be searched." -ForegroundColor Blue
                    } else {
                        Write-Host "Found direct report `"$reportUserSAN`", but it has already searched and added to final user list. Skipping." -ForegroundColor Gray
                    }
                } else {
                    Write-Host "Found direct report `"$reportUserSAN`", but it is not valid base associate account. Skipping." -ForegroundColor DarkGray
                }
            } # end foreach
        } else {
            Write-Host "User `"$reportUserSAN`" is a Service Account. Skipping." -ForegroundColor DarkGray
        }
    } #end foreach
} while (($usersToBeSearched).Count -gt 0)

$outFile = "C:\temp\DirectReports.csv"
$UserList = $finalUsers #keep $finalUsers unaltered in case manually working with this and make accidental changes
$UserList | Export-Csv -path $outFile -Force -NoTypeInformation
Write-Host "Total User List Count: " + $UserList.count -ForegroundColor Blue
Invoke-Item $outFile


<#
$UserList = Import-CSV "C:\temp\DirectReports.csv"

#Separate out Associates who are Managers of others:
$ManagerList = $UserList | Where-Object { $UserList.ManagerName -contains $_.DisplayName }
$ManagerList | Export-Csv -path "C:\temp\DirectReports_Managers.csv" -NoTypeInformation


#The rest would be Associates with no reports other than their own elevated accounts
$AssociateList = $UserList | Where-Object { $ManagerList.Id -notcontains $_.Id }
$AssociateList | Export-Csv -path "C:\temp\DirectReports_Associate.csv" -NoTypeInformation


#Get a random sampling form the list of users
$SampleSize = ($UserList.count / 3) #change this for number of sample groups to get
$Sample1 = $UserList | Get-Random -count ($UserList.count / $SampleSize)
$Sample1 | Export-Csv "C:\temp\DirectReports_Sample1.csv" -Force -NoTypeInformation

$NewUserList = $UserList | Where-Object { $Sample1.Id -notcontains $_.Id }
$Sample2 = $NewUserList | Get-Random -count $SampleSize
$Sample2 | Export-Csv "C:\temp\DirectReports_Sample2.csv" -NoTypeInformation

$LastUserList = $NewUserList | Where-Object { $Sample2.Id -notcontains $_.Id }
$LastUserList | Export-Csv "C:\temp\DirectReports_Sample3.csv" -NoTypeInformation
#>
