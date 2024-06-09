param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $environmentName,

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
    $clientSecret
)

$repoRoot = (git rev-parse --show-toplevel)

. "$repoRoot/.github/deploy/application/check.ps1"
. "$repoRoot/.github/deploy/application/config.ps1"

###############################################################################################
# Connect to Databricks
###############################################################################################
Write-Host "Get Databricks workspace URL" -ForegroundColor Green
$workspaceUrl = az resource show `
    --resource-group $resourceGroupName `
    --name $resourceName `
    --resource-type "Microsoft.Databricks/workspaces" `
    --query properties.workspaceUrl `
    --out tsv

$workspaceUrl = "https://$workspaceUrl"
Write-Host "Workspace URL is: $workspaceUrl" -ForegroundColor DarkYellow

Write-Host "Get Bearer token for Pipeline SPN" -ForegroundColor DarkYellow
$accessToken = Get-OAuthToken `
    -tenantId $tenantId `
    -clientId $clientId `
    -clientSecret $clientSecret

Write-Host "Convert Bearer token to Databricks access token" -ForegroundColor DarkYellow
$databricksAccessToken = ConvertTo-DatabricksPersonalAccessToken `
    -workspaceUrl $workspaceUrl `
    -bearerToken $accessToken

Write-Host "Generate .databrickscfg" -ForegroundColor DarkYellow
Set-Content ~/.databrickscfg "[DEFAULT]"
Add-Content ~/.databrickscfg "host = $workspaceUrl"
Add-Content ~/.databrickscfg "token = $databricksAccessToken"
Add-Content ~/.databrickscfg ""