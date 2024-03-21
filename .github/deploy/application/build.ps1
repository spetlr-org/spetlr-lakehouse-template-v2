
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

# we want a really clean build (even locally)
if(Test-Path -Path dist)
{
    Remove-Item -Force -Recurse dist
}
if (Test-Path -Path build)
{
    Remove-Item -Force -Recurse build
}
if (Test-Path -Path src\*.egg-info)
{
    Remove-Item -Force -Recurse src\*.egg-info
}

pyclean -v .

. "$repoRoot/tools/set_lib_env.ps1" `
    -buildId "0" `
    -environmentName $environmentName

python setup.py bdist_wheel


Pop-Location

