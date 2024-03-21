param (
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]
  $environmentName,

  [Parameter(Mandatory=$false)]
  [ValidateNotNullOrEmpty()]
  [string]
  $buildId="0"
)

$repoRoot = (git rev-parse --show-toplevel)

Push-Location -Path $repoRoot


# Step 0 Build Dependencies
Write-Host "Now Installing Test Dependencies"
python -m pip install --upgrade pip
pip install -r requirements-deploy.txt
pip install -r requirements-test.txt

. "$repoRoot/tools/set_lib_env.ps1" `
    -buildId "0" `
    -environmentName $environmentName

# Step 0 Build Dependencies
Write-Host "Now Running Local Unit Test"
python -m pytest test/local

Pop-Location