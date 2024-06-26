
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $environmentName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $buildId
)

$repoRoot = (git rev-parse --show-toplevel)

Push-Location -Path $repoRoot

# Build Dependencies
Write-Host "Now Installing Build Dependencies"
python -m pip install --upgrade pip
pip install -r requirements-deploy.txt

# we want a really clean build (even locally)
Write-Host "Clean up before build"
if (Test-Path -Path dist) {
    Remove-Item -Force -Recurse dist
}
if (Test-Path -Path build) {
    Remove-Item -Force -Recurse build
}
if (Test-Path -Path src\*.egg-info) {
    Remove-Item -Force -Recurse src\*.egg-info
}

pyclean -v .

# Set up environment
Write-Host "Setting up build environment"
. "$repoRoot/tools/set_lib_env.ps1" `
    -buildId $buildId `
    -environmentName $environmentName

# Update the spetlr version of the python library
Write-Host "Updating spetlr version"
$newVersion = $buildId

$setupCfgContent = Get-Content setup.cfg

$newSetupCfgContent = $setupCfgContent -replace "(version = ).*", "version = ${newVersion}"
Set-Content -Path setup.cfg -Value $newSetupCfgContent

# Build the wheel
Write-Host "Building the wheel"
python setup.py bdist_wheel


Pop-Location

