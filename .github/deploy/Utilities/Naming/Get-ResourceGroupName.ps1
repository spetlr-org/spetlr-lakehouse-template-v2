function Get-ResourceGroupName {
    param (
  
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $systemName,
  
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $environmentName,
  
      [Parameter(Mandatory=$false)]
      [string]
      $serviceName = ""
    )
  
    if ($serviceName.Length -gt 0) {
      return $systemName + "-" + $environmentName.ToUpper() + "-" + $serviceName
    }
  
    return $systemName + "-" + $environmentName.ToUpper()
  }