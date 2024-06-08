# get the true repository root
$repoRoot = (git rev-parse --show-toplevel)

# import utility functions
. "$repoRoot/.github/deploy/Utilities/all.ps1"

