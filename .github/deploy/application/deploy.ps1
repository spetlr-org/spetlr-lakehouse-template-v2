param (
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]
  $environmentName

  # [Parameter(Mandatory = $true)]
  # [ValidateNotNullOrEmpty()]
  # [string]
  # $storageAccountName,

  # [Parameter(Mandatory = $true)]
  # [ValidateNotNullOrEmpty()]
  # [string]
  # $volumeName
)

$repoRoot = (git rev-parse --show-toplevel)

Push-Location -Path $repoRoot


# Step 0 Build Dependencies
Write-Host "Now Installing Build Dependencies"
python -m pip install --upgrade pip
pip install -r requirements-deploy.txt

# Step 1 Build
Write-Host "Now Building the package python wheel"
.github/deploy/application/build.ps1 -environmentName $environmentName

# Step 2 Upload
Write-Host "Now uploading the package python wheel"
az storage blob upload `
  --account-name spetlrlhv2dev `
  --container-name volume `
  --name dataplatform-1.0.0-py3-none-any.whl `
  --file dist/dataplatform-1.0.0-py3-none-any.whl `
  --overwrite `
  --auth-mode login


Pop-Location

