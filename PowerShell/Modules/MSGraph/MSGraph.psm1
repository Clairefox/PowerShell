function Get-AuthToken () {
    <#
        .SYNOPSIS
        This script is used to connect to the Microsoft Graph API.

        .INPUTS
        None. Objects cannot be piped to this script.

        .EXAMPLE
        Get-AuthToken -Tenant $Tenant -ClientId $ClientId -ClientKey $ClientKey -Username $Username -Password $Password
        Returns a Bearer auth object to be used with other API calls.

        .EXAMPLE
        Get-AuthToken $Tenant $ClientId $ClientKey $Username $Password
        For shorthand, just the variables can be used, but they have to be in this order.

        .NOTES
        Example Variables:
            $Tenant = "mydigitalspace.onmicrosoft.com"

            $Client = Get-AutomationPSCredential -Name "SpnName"
            $ClientId = $Client.GetNetworkCredential().UserName
            $ClientKey = $Client.GetNetworkCredential().Password

            $Credentials = Get-AutomationPSCredential -Name "CredentialName"
            $Username = $Credentials.GetNetworkCredential().UserName
            $Password = $Credentials.GetNetworkCredential().Password
    #>
    [CmdLetBinding()]
    param (
        [Parameter(Position = 0,Mandatory = $true)]
            [string]$Tenant,

        [Parameter(Position = 1,Mandatory = $true)]
            [string]$ClientId,

        [Parameter(Position = 2,Mandatory = $true)]
            [string]$ClientKey,

        [Parameter(Position = 3,Mandatory = $true)]
            [string]$Username,

        [Parameter(Position = 4,Mandatory = $true)]
            [SecureString]$Password
    ) #end param

    $ReqTokenBody = @{
        Grant_Type    = "Password"
        client_Id     = $ClientID
        Client_Secret = $ClientKey
        Username      = $Username
        Password      = $Password
        Scope         = "https://graph.microsoft.com/.default"
    } 

    $authToken = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token" `
                                        -Method POST `
                                        -Body $ReqTokenBody

    return $authToken
} #end Get-AuthToken