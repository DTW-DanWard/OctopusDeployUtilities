
Set-StrictMode -Version Latest

#region Function: Update-ODUExportIncludedVariableSetsAddVariable

<#
.SYNOPSIS
Adds variables to included variable sets
.DESCRIPTION
Adds variables to included variable sets
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportIncludedVariableSetsAddVariable -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds variables to included variable sets>
#>
function Update-ODUExportIncludedVariableSetsAddVariable {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Path = $(throw "$($MyInvocation.MyCommand) : missing parameter Path")
  )
  #endregion
  process {
    if ($false -eq (Test-Path -Path $Path)) { throw "No export found at: $Path" }

    # get folder paths
    $IncludedLibraryVariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCall | Where-Object { $_.RestName -eq 'LibraryVariableSets' }).RestName)
    $VariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCall | Where-Object { $_.RestName -eq 'Variables' }).RestName)

    Get-ChildItem -Path $IncludedLibraryVariableSetExportFolder -Recurse | ForEach-Object {
      $ExportFileIncludedLibraryVariableSet = $_.FullName
      $ExportItemIncludedLibraryVariableSet = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFileIncludedLibraryVariableSet -Raw)

      # get the variables for this included library variable set
      $ExportItemVariableSet = ConvertFrom-Json -InputObject (Get-Content -Path (Join-Path -Path $VariableSetExportFolder -ChildPath ($ExportItemIncludedLibraryVariableSet.VariableSetId + $JsonExtension)) -Raw)
      # add variables to included library variable set
      Add-ODUOrUpdateMember -InputObject $ExportItemIncludedLibraryVariableSet -PropertyName 'VariableSet' -Value $ExportItemVariableSet

      # and finally save included library variable set
      Out-ODUFileJson -FilePath $ExportFileIncludedLibraryVariableSet -Data $ExportItemIncludedLibraryVariableSet
    }
  }
}
#endregion
