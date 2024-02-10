param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $clientId ,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $clientSecret,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $tenantId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $subscriptionId
)

$RESOURCE_GROUP_NAME = 'Terraform-State-Stoarge'
$STORAGE_ACCOUNT_NAME = 'spetlrlh2tfstate'

$ACCOUNT_KEY = az storage account keys list `
    --resource-group $RESOURCE_GROUP_NAME `
    --account-name $STORAGE_ACCOUNT_NAME `
    --query '[0].value' -o tsv

$env:ARM_ACCESS_KEY = $ACCOUNT_KEY
$env:ARM_CLIENT_ID = $clientId
$env:ARM_CLIENT_SECRET = $clientSecret
$env:ARM_TENANT_ID = $tenantId
$env:ARM_SUBSCRIPTION_ID = $subscriptionId