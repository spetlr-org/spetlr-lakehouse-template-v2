function Copy-Keyvault-To-Databricks {

    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $keyVaultName
    )

    # The databricks scope is named after the keyvaultname
    $scope = $keyVaultName

    
    New-DatabricksScope -name $scope
    
    Copy-DatabricksSecrets -keyVaultName $keyVaultName -scope $scope -deleteNonExistent $True
    
    

}