
Set-StrictMode -Version Latest

#region Function: Find-ODUVariableInExport

function Find-ODUVariableInExport {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Export,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SearchText,
    [Parameter(Mandatory = $false)]
    [switch]$Exact
  )
  #endregion
  process {
    #region Loop through all LibraryVariableSets looking where variable defined or used
    [object[]]$LibraryVariableSetDefined = $null
    [object[]]$LibraryVariableSetUsed = $null
    $Export.LibraryVariableSets | ForEach-Object {
      $LibraryVariableSet = $_
      # may not have variables
      if ($null -ne $LibraryVariableSet.VariableSet.Variables -and $LibraryVariableSet.VariableSet.Variables.Count -gt 0) {
        # find where variable defined
        $LibraryVariableSetDefined += $LibraryVariableSet.VariableSet.Variables | Where-Object { (($Exact -and ($_.Name -eq $SearchText)) -or (!$Exact -and ($_.Name -match $SearchText))) } | ForEach-Object {
          $Variable = $_
          [PSCustomObject]@{
            ContainerName = $LibraryVariableSet.Name
            Variable      = $Variable
          }
        }
        # find where variable used
        $LibraryVariableSetUsed += $LibraryVariableSet.VariableSet.Variables | Where-Object { (($Exact -and ($_.Value -eq $SearchText)) -or (!$Exact -and ($_.Value -match $SearchText))) } | ForEach-Object {
          $Variable = $_
          [PSCustomObject]@{
            ContainerName = $LibraryVariableSet.Name
            Variable      = $Variable
          }
        }
      }
    }
    #endregion

    #region Loop through all Projects looking where variable defined or used
    [object[]]$ProjectDefined = $null
    [object[]]$ProjectUsed = $null

    $Export.Projects | ForEach-Object {
      $Project = $_
      # may not have variables
      if ($null -ne $Project.VariableSet.Variables -and $Project.VariableSet.Variables.Count -gt 0) {
        # find where variable defined
        $ProjectDefined += $Project.VariableSet.Variables | Where-Object {(($Exact -and ($_.Name -eq $SearchText)) -or (!$Exact -and ($_.Name -match $SearchText))) } | ForEach-Object {
          $Variable = $_
          [PSCustomObject]@{
            ContainerName = $Project.Name
            Variable      = $Variable
          }
        }
        # find where variable used
        $ProjectUsed += $Project.VariableSet.Variables | Where-Object { (($Exact -and ($_.Value -eq $SearchText)) -or (!$Exact -and ($_.Value -match $SearchText))) } | ForEach-Object {
          $Variable = $_
          [PSCustomObject]@{
            ContainerName = $Project.Name
            Variable      = $Variable
          }
        }
      }
    }
    #endregion

    # construct object to return
    [PSCustomObject]@{
      SearchText                = $SearchText
      LibraryVariableSetDefined = $LibraryVariableSetDefined
      LibraryVariableSetUsed    = $LibraryVariableSetUsed
      ProjectDefined            = $ProjectDefined
      ProjectUsed               = $ProjectUsed
    }
  }
}
#endregion
