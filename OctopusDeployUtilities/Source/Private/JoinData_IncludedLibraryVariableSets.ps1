
Set-StrictMode -Version Latest

#region Function: Update-ODUExportIncludedVariableSetsAddVariables

<#
.SYNOPSIS
Adds variables to included variable sets
.DESCRIPTION
Adds variables to included variable sets
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportIncludedVariableSetsAddVariables -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds variables to included variable sets>
#>
function Update-ODUExportIncludedVariableSetsAddVariables {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  #endregion
  process {
    if ($false -eq (Test-Path -Path $Path)) { throw "No export found at: $Path" }

    # get folder paths
    $IncludedLibraryVariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'LibraryVariableSets' }).RestName)
    $VariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Variables' }).RestName)

    Get-ChildItem -Path $IncludedLibraryVariableSetExportFolder -Recurse | ForEach-Object {
      $ExportFileIncludedLibraryVariableSet = $_.FullName
      $ExportItemIncludedLibraryVariableSet = Get-Content -Path $ExportFileIncludedLibraryVariableSet | ConvertFrom-Json

      # get the variables for this included library variable set
      $ExportItemVariableSet = Get-Content -Path (Join-Path -Path $VariableSetExportFolder -ChildPath ($ExportItemIncludedLibraryVariableSet.VariableSetId + $JsonExtension)) | ConvertFrom-Json
      # add variables to included library variable set
      Add-ODUOrUpdateMember -InputObject $ExportItemIncludedLibraryVariableSet -PropertyName 'VariableSet' -Value $ExportItemVariableSet

      # and finally save included library variable set
      Out-ODUFileJson -FilePath $ExportFileIncludedLibraryVariableSet -Data $ExportItemIncludedLibraryVariableSet
    }
  }
}
#endregion
