param (
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]
  $environmentName,

  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]
  $buildId,

  [Parameter(Mandatory = $false)]
  [string]
  $testDirectory
)

$repoRoot = (git rev-parse --show-toplevel)

Push-Location -Path $repoRoot

# Set up environment
Write-Host "Setting up build environment"
. "$repoRoot/tools/set_lib_env.ps1" `
  -buildId $buildId `
  -environmentName $environmentName

# Step 1 Build
Write-Host "Now Building"
.github/deploy/application/build.ps1 -environmentName $environmentName -buildId $buildId

# Step 2: submit test
Write-Host "Now Submitting"

if ($testDirectory) {
  spetlr-test-job submit `
    --tests test/ `
    --task $testDirectory `
    --cluster-file test/test_jobs_cluster_settings/cluster_env.json `
    --requirements-file requirements-test.txt `
    --sparklibs-file test/test_jobs_cluster_settings/sparklibs.json `
    --out-json test.json `
    --upload-to "workspace"
}
else {
  spetlr-test-job submit `
    --tests test/ `
    --tasks-from test/cluster/ `
    --cluster-file test/test_jobs_cluster_settings/cluster_env.json `
    --requirements-file requirements-test.txt `
    --sparklibs-file test/test_jobs_cluster_settings/sparklibs.json `
    --out-json test.json `
    --upload-to "workspace"
}

# Step 3: wait for test
Write-Host "Now Waiting for test"

spetlr-test-job fetch --runid-json test.json

Pop-Location

