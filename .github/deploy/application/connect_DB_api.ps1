param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $environmentName
)

$repoRoot = (git rev-parse --show-toplevel)

. "$repoRoot/.github/deploy/application/check.ps1"
. "$repoRoot/.github/deploy/application/config.ps1"

###############################################################################################
# Connect to Databricks
###############################################################################################
Write-Host "Get Databricks workspace admin SPN credentials" -ForegroundColor Green

$workspaceUrlFull = Get-KeyVaultSecret -key $workspaceUrlKeyName -keyVaultName $resourceName
$workspaceClientId = Get-KeyVaultSecret -key $workspaceSpnClientIdKeyName -keyVaultName $resourceName
$workspaceClientSecret = Get-KeyVaultSecret -key $workspaceSpnClientSecretKeyName -keyVaultName $resourceName
$tenantId = Get-KeyVaultSecret -key $azureTenantId -keyVaultName $resourceName

$resourceId = az resource show `
    --resource-group $resourceGroupName `
    --name $resourceName `
    --resource-type "Microsoft.Databricks/workspaces" `
    --query id `
    --out tsv

Throw-WhenError -output $resourceId

$workspaceUrl = az resource show `
    --resource-group $resourceGroupName `
    --name $databricksName `
    --resource-type "Microsoft.Databricks/workspaces" `
    --query properties.workspaceUrl `
    --out tsv

Throw-WhenError -output $workspaceUrl

Write-Host "  Add the SPN to the Databricks Workspace as an admin user" -ForegroundColor DarkYellow
$accessToken = Set-DatabricksSpnAdminUser `
    -tenantId $tenantId `
    -clientId $workspaceClientId `
    -clientSecret $workspaceClientSecret `
    -workspaceUrl $workspaceUrl `
    -resourceId $resourceId

Write-Host "  Generate SPN personal access token" -ForegroundColor DarkYellow
$token = ConvertTo-DatabricksPersonalAccessToken `
    -workspaceUrl $workspaceUrl `
    -bearerToken $accessToken `
    -tokenComment "$tokenComment"

Write-Host "  Generate .databrickscfg" -ForegroundColor DarkYellow
Set-Content ~/.databrickscfg "[DEFAULT]"
Add-Content ~/.databrickscfg "host = $workspaceUrlFull"
Add-Content ~/.databrickscfg "token = $token"
Add-Content ~/.databrickscfg ""