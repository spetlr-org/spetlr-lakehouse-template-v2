function Copy-DatabricksSecrets {
    param (
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $keyVaultName,
  
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $scope,
  
      [Parameter(Mandatory = $false)]
      [bool]
      $deleteNonExistent = $false
    )

    if(-not (Get-Command databricks)){ throw "DATABRICKS NOT INSTALLED"}

    Write-Host "  Copy secrets from Key vault '$keyVaultName' to secret scope '$scope'" -ForegroundColor DarkYellow

    # for each key in the keyvault, ony use it if:
    # - it is not disabled
    # - it either has a contentType or has an expiration date set
    # - that expiration, if present, is in the future
    # - if it has an activation date, that must be in the past.
    $json = ( `
        Convert-Safe-FromJson -text (`
            az keyvault secret list --vault-name $keyVaultName) | `
        Where-Object {
            $_.attributes.enabled -eq $true `
            -and (
                $_.contentType -or $_.attributes.expires
            )`
            -and (
                $_.attributes.expires -eq $null `
                -or (
                     ($_.attributes.expires -is [DateTime]) ? $_.attributes.expires
                    : [DateTimeOffset]::Parse($_.attributes.expires) `
                    -gt [DateTimeOffset]::UtcNow
                )
            )`
            -and (
                $_.attributes.notBefore -eq $null `
                -or (
                    ($_.attributes.notBefore -is [DateTime]) ? $_.attributes.notBefore
                    : [DateTimeOffset]::Parse($_.attributes.notBefore) `
                    -lt [DateTimeOffset]::UtcNow
                )
            )
        }
    )

    $new_keys = $json | Select-Object -expand "name"
    foreach ($key in $new_keys) {
      $value = az keyvault secret show --name $key --query "value" --vault-name $keyVaultName
      databricks secrets put --scope $scope --key $key --string-value $value
    }
    if ($deleteNonExistent -and ($new_keys.Length -gt 0)) {
      $json = Convert-Safe-FromJson -text (databricks secrets list --scope $scope --output JSON)
      $old_keys = $json | Select-Object -expand "secrets" | Select-Object -expand "key"
      foreach ($key in $old_keys) {
        if (!($new_keys -contains $key)) {
          databricks secrets delete --scope $scope --key $key
          Write-Host "  Deleted key '$key'"
        }
      }
    }
  }
  