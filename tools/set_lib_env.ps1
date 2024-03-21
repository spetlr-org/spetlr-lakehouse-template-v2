param (
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]
  $environmentName,

  [Parameter(Mandatory = $false)]
  [ValidateNotNullOrEmpty()]
  [string]
  $buildId = "0",


  [Parameter(Mandatory = $false)]
  [string]
  $environmentType = "NonLocal"
)

$repoRoot = (git rev-parse --show-toplevel)

$env_config = [ordered]@{
  ENV          = "$environmentName"
  ResourceName = "spetlrlhv2" + $environmentName.ToLower()
} | ConvertTo-Json -Depth 4

Set-Content $repoRoot/src/dataplatform/environment/config/environment.json $env_config

&"$repoRoot/tools/build_spark_conf.ps1" $environmentName
