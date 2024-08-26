
function Get-OAuthToken {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $tenantId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $clientId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $clientSecret,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $scope = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d/.default" # AzureDatabricks Resource ID
  )

  $response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{
    client_id     = "$clientId"
    grant_type    = "client_credentials"
    scope         = "$scope"
    client_secret = "$clientSecret"
  }

  $bearerToken = $response.access_token

  return $bearerToken
}
