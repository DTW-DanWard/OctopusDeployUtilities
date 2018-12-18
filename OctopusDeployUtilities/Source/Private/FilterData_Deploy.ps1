
Set-StrictMode -Version Latest

#region Function: Test-ODUProjectDeployActionType

<#
.SYNOPSIS
Returns true if Project contains deploy step(s) of ActionType
.DESCRIPTION
Returns true if Project contains one or more deploy steps with ActionType
equal to $ActionType
.PARAMETER Project
Project to test
.PARAMETER ActionType
ActionType to look for (Octopus.WindowsService, Octopus.IIS, etc.)
.EXAMPLE
Test-ODUProjectDeployActionType $Project1 'Octopus.WindowsService'
$true
#>
function Test-ODUProjectDeployActionType {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Project,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ActionType
  )
  process {
    if (($null -eq $Project.DeploymentProcess.Steps) -or ($Project.DeploymentProcess.Steps.Count -eq 0) -or ($null -eq ($Project.DeploymentProcess.Steps | Get-Member -Name 'Actions'))) { 
      $false
    } else {
      $Project.DeploymentProcess.Steps.Actions.ActionType -contains $ActionType
    }
  }
}
#endregion
