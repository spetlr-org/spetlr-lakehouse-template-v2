param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $environmentName='dev'
)

$tenantId = (az account show --query tenantId --out tsv)
$environmentName = $environmentName.ToLower()

# get the true repository root
$repoRoot = (git rev-parse --show-toplevel)


# Storage accounts to which we need access
$storageAccounts = @(
    "spetlrlh$environmentName"
)

# the final spark configuration
# $spark_conf = @{}
$spark_conf = [ordered]@{}

# standard prefixes
$fsaa = "fs.azure.account"
$dcwn = "dfs.core.windows.net"
$scope = "spetlrlh$environmentName"

# Loop over each accounts
foreach ($acc in $storageAccounts) {
    $spark_conf.Add("$fsaa.auth.type.$acc.$dcwn", "OAuth")
    $spark_conf.Add("$fsaa.oauth.provider.type.$acc.$dcwn", "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider")
    $spark_conf.Add("$fsaa.oauth2.client.id.$acc.$dcwn", "{{ '{{' }}secrets/$scope/Databricks--ClientId{{ '}}' }}")
    $spark_conf.Add("$fsaa.oauth2.client.secret.$acc.$dcwn", "{{ '{{' }}secrets/$scope/Databricks--ClientSecret{{ '}}' }}")
    $spark_conf.Add("$fsaa.oauth2.client.endpoint.$acc.$dcwn", "{{ '{{' }}secrets/$scope/Databricks--AuthEndpoint{{ '}}' }}")
}

$spark_conf | ConvertTo-Json -Depth 10 | Out-File -FilePath "$repoRoot/src/jobs/sparkconf.json.j2"

# the configurations contain the strange construction {{ '{{' }} which resolves to literal {{ after jinja2 processing
# This is necessary to dbx to be able to read the file correctly
# to obtain the regular contents for other purposes, please use the jinja cli
#
# $> pip install jinja-cli
# $> jinja sparkconf.json.js2

# now provide the spark configuration to the test job:

$spark_conf_final = jinja "$repoRoot/src/jobs/sparkconf.json.j2" | ConvertFrom-Json

# Read the content of cluster.json
$cluster = Get-Content -Raw -Path "$repoRoot/src/jobs/cluster.json" | ConvertFrom-Json


# Extend the spark_conf section
$spark_conf_final.PSObject.Properties | ForEach-Object {
    $key = $_.Name
    $value = $_.Value
    $cluster.spark_conf | Add-Member -NotePropertyName $key -NotePropertyValue $value
}

# Convert back to JSON
$cluster | ConvertTo-Json -Depth 10 | Out-File -FilePath "$repoRoot/src/jobs/cluster_env.json" -Force
