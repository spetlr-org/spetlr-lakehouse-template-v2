
function Get-ResourceName {
    param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $companyAbbreviation,
  
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $systemAbbreviation,
  
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $environmentName,
  
      [Parameter(Mandatory=$false)]
      [string]
      $serviceAbbreviation = "",
  
      [Parameter(Mandatory=$false)]
      [string]
      $suffix = ""
    )
  
    return $companyAbbreviation.ToLower() + $systemAbbreviation.ToLower() + $environmentName.ToLower() + $serviceAbbreviation.ToLower() + $suffix.ToLower();
  }
  
  