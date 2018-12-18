
Set-StrictMode -Version Latest

#region Function: Select-ODUProjectDeployActionProperty

<#
.SYNOPSIS
Returns a project's deploy step ActionProperty value (if found)
.DESCRIPTION
Returns a project's deploy step ActionProperty value (if found), null otherwise
.PARAMETER Project
Project to check
.PARAMETER PropertyName
Name of property to look for in deploy steps
.EXAMPLE
Select-ODUProjectDeployActionProperty $MyWebProject 'Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment'
$true
#>
function Select-ODUProjectDeployActionProperty {
  [CmdletBinding()]
  [OutputType([object[]])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Project,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PropertyName
  )
  process {
    [object[]]$PropertyValues = @()
    if (($null -eq $Project.DeploymentProcess.Steps) -or ($Project.DeploymentProcess.Steps.Count -eq 0) -or ($null -eq ($Project.DeploymentProcess.Steps | Get-Member -Name 'Actions'))) {
      $PropertyValues
      return
    } else {
      $Project.DeploymentProcess.Steps | ForEach-Object {
        $DeployStep = $_
        # deploy step might have multiple actions
        $DeployStep.Actions | ForEach-Object {
          $Action = $_
          $Properties = $Action.Properties
          $Property = $Properties | Get-Member -Name $PropertyName
          if ($null -ne $Property) {
            $PropertyValues += ($Properties | Select-Object $PropertyName).$PropertyName
          }
        }
      }
      $PropertyValues
    }
  }
}
#endregion


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
