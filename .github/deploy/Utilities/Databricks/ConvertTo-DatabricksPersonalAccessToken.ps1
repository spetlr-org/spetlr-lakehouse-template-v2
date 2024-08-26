
function ConvertTo-DatabricksPersonalAccessToken {
  
  param (
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $workspaceUrl,
  
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $bearerToken,
  
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $lifetimeSeconds = 3600,

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]
    $tokenComment = "SPN Token"
  )

  Write-Host $workspaceUrl

  $databricksResponse = Invoke-RestMethod -Method Post -Uri "$workspaceUrl/api/2.0/token/create" `
    -Headers @{
    Authorization  = "Bearer $bearerToken"
    "Content-Type" = "application/json"
  } `
    -Body (@{
      lifetimeSeconds = $lifetimeSeconds
      comment         = "Databricks Access Token"
    } | ConvertTo-Json)

  Throw-WhenError -output $databricksResponse

  return $databricksResponse.token_value
}