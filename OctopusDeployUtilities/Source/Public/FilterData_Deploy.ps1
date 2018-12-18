
Set-StrictMode -Version Latest



#region Function: Test-ODUProjectDeployIISSite

<#
.SYNOPSIS
Returns true if Project contains deploy step(s) for IIS Site
.DESCRIPTION
Returns true if Project contains one or more deploy steps for IIS Site,
specifically ActionType of Octopus.IIS
.PARAMETER Project
Project to test
.EXAMPLE
Test-ODUProjectDeployIISSite $MyWebProject
$true
.EXAMPLE
Test-ODUProjectDeployIISSite $MyWinServiceProject
$false
#>
function Test-ODUProjectDeployIISSite {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Project
  )
  process {
    Test-ODUProjectDeployActionType -Project $Project -ActionType 'Octopus.IIS'
  }
}
#endregion




#region Function: Test-ODUProjectDeployWindowsService

<#
.SYNOPSIS
Returns true if Project contains deploy step(s) for Windows Service
.DESCRIPTION
Returns true if Project contains one or more deploy steps for Windows Service,
specifically ActionType of Octopus.WindowsService
.PARAMETER Project
Project to test
.EXAMPLE
Test-ODUProjectDeployWindowsService $MyWebProject
$false
.EXAMPLE
Test-ODUProjectDeployWindowsService $MyWinServiceProject
$true
#>
function Test-ODUProjectDeployWindowsService {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Project
  )
  process {
    Test-ODUProjectDeployActionType -Project $Project -ActionType 'Octopus.WindowsService'
  }
}
#endregion
