$companyAbbreviation = "spetlr"
$systemName = "Demo"
$serviceName = "LakeHouse-V2"
$systemAbbreviation = "lhv2"

$resourceGroupName = Get-ResourceGroupName -systemName $systemName -environmentName $environmentName -serviceName $serviceName
$resourceName = Get-ResourceName -companyAbbreviation $companyAbbreviation -systemAbbreviation $systemAbbreviation -environmentName $environmentName


Write-Host "Resource group name is $resourceGroupName"
Write-Host "Resource name is $resourceName"

$workspaceUrlKeyName = "Databricks--Workspace-URL"
$workspaceSpnClientIdKeyName = "Databricks--Workspace--SPN-ID"
$workspaceSpnClientSecretKeyName = "Databricks--Workspace--SPN-Password"