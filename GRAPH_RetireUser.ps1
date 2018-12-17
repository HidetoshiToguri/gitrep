cd C:\account\scripts

#退職ユーザ名を入力
$upn_names = @('ユーザ名1','ユーザ名2')

Function GetAccessToken
   {
    param (        
        [Parameter(Position=0, Mandatory=$false)] 
        [string] $Office365Username, 
        [Parameter(Position=1, Mandatory=$false)] 
        [string] $Office365Password
      )
    # Add ADAL (Microsoft.IdentityModel.Clients.ActiveDirectory.dll) assembly path from Azure Resource Manager SDK location
    Add-Type -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Microsoft.Xrm.Data.PowerShell\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    # or simply import AzureRm module using below command
    # Import-Module AzureRm
    #PowerShell Client Id. This is a well known Azure AD client id of PowerShell client. You don't need to create an Azure AD app.
    $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $resourceURI = "https://graph.microsoft.com"
    $authority = "https://login.microsoftonline.com/common"
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
     
    if (([string]::IsNullOrEmpty($Office365Username) -eq $false) -and ([string]::IsNullOrEmpty($Office365Password) -eq $false)) 
    { 
    $SecurePassword = ConvertTo-SecureString -AsPlainText $Office365Password -Force           
    #Build Azure AD credentials object  
    $AADCredential = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential" -ArgumentList $Office365Username,$SecurePassword
    # Get token without login prompts.
    $authResult = $authContext.AcquireToken($resourceURI, $clientId,$AADCredential)
    } 
    else 
    {     
    # Get token by prompting login window.
    $authResult = $authContext.AcquireToken($resourceURI, $clientId, $redirectUri, [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Always)
    } 
    return $authResult.AccessToken
}

#ログファイル出力
$filename = Get-Date -Format "yyyyMMdd"
$filename = $filename + "checkO365retire"

$accessToken= GetAccessToken

foreach($upn in $upn_names){

$apiUrl = "https://graph.microsoft.com/beta/users/$upn"
$Userdata = Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $apiUrl -Method Get

$Userdata | Out-File -FilePath ..\log\log_$filename.log -Encoding UTF8 -Append

}
