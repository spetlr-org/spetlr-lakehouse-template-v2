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

$workspaceUrl = Get-KeyVaultSecret -key $workspaceUrlKeyName -keyVaultName $resourceName
$workspaceClientId = Get-KeyVaultSecret -key $workspaceSpnClientIdKeyName -keyVaultName $resourceName
$workspaceClientSecret = Get-KeyVaultSecret -key $workspaceSpnClientSecretKeyName -keyVaultName $resourceName

$workspaceUrl = $workspaceUrl -replace '"', ''
$workspaceClientId = $workspaceClientId -replace '"', ''
$workspaceClientSecret = $workspaceClientSecret -replace '"', ''

Write-Host $workspaceUrl


Write-Host "  Generate .databrickscfg" -ForegroundColor DarkYellow
Set-Content ~/.databrickscfg "[DEFAULT]"
Add-Content ~/.databrickscfg "host = $workspaceUrl"
Add-Content ~/.databrickscfg "client_id = $workspaceClientId"
Add-Content ~/.databrickscfg "client_secret = $workspaceClientSecret"
Add-Content ~/.databrickscfg ""