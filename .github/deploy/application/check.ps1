# Check that we are in a subscription that is correctly tagged

# get the true repository root
$repoRoot = (git rev-parse --show-toplevel)

# import utility functions
. "$repoRoot/.github/deploy/Utilities/all.ps1"

if (-not (Check-AzureAccountTag $expectedAccountTag)) {
    throw "Wrong subscription"
}

