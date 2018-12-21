
Set-StrictMode -Version Latest

#region Function: Update-ODUExportProjectAddDeploymentProcess

<#
.SYNOPSIS
Adds deploy process info to projects
.DESCRIPTION
Adds deploy process info to projects
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportProjectAddDeploymentProcess -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds deploy process info to projects>
#>
function Update-ODUExportProjectAddDeploymentProcess {
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

    # get project and deployment process folders
    $ProjectExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Projects' }).RestName)
    $DeploymentProcessExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'DeploymentProcesses' }).RestName)

    Get-ChildItem -Path $ProjectExportFolder -Recurse | ForEach-Object {
      $ExportFileProject = $_.FullName
      $ExportItemProject = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFileProject -Raw)
      $ExportItemDeploymentProcess = ConvertFrom-Json -InputObject (Get-Content -Path (Join-Path -Path $DeploymentProcessExportFolder -ChildPath ($ExportItemProject.DeploymentProcessId + $JsonExtension)) -Raw)
      Add-ODUOrUpdateMember -InputObject $ExportItemProject -PropertyName 'DeploymentProcess' -Value $ExportItemDeploymentProcess
      Out-ODUFileJson -FilePath $ExportFileProject -Data $ExportItemProject
    }
  }
}
#endregion


#region Function: Update-ODUExportProjectAddIncludedLibraryVariableSets

<#
.SYNOPSIS
Adds included variable set(s) to projects
.DESCRIPTION
Adds included variable set(s) to projects
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportProjectAddIncludedLibraryVariableSets -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds variable set to projects>
#>
function Update-ODUExportProjectAddIncludedLibraryVariableSets {
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
    $ProjectExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Projects' }).RestName)
    $IncludedLibraryVariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'LibraryVariableSets' }).RestName)

    Get-ChildItem -Path $ProjectExportFolder -Recurse | ForEach-Object {
      $ExportFileProject = $_.FullName
      $ExportItemProject = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFileProject -Raw)

      # loop through all IncludedLibraryVariableSetIds, get the IncludedLibraryVariableSet and add to array
      [object[]]$IncludedLibraryVariableSets = @()
      $ExportItemProject.IncludedLibraryVariableSetIds | ForEach-Object {
        $IncludedLibraryVariableSetId = $_
        $ExportItemIncludedLibraryVariableSet = ConvertFrom-Json -InputObject (Get-Content -Path (Join-Path -Path $IncludedLibraryVariableSetExportFolder -ChildPath ($IncludedLibraryVariableSetId + $JsonExtension)) -Raw)

        # add included library variable set to array
        $IncludedLibraryVariableSets += $ExportItemIncludedLibraryVariableSet
      }

      # now add library variable set array to project
      Add-ODUOrUpdateMember -InputObject $ExportItemProject -PropertyName 'IncludedLibraryVariableSets' -Value $IncludedLibraryVariableSets
      # and finally save project
      Out-ODUFileJson -FilePath $ExportFileProject -Data $ExportItemProject
    }
  }
}
#endregion


#region Function: Update-ODUExportProjectAddVariableSet

<#
.SYNOPSIS
Adds main variable set to projects
.DESCRIPTION
Adds main variable set to projects
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportProjectAddVariableSet -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds main variable set to projects>
#>
function Update-ODUExportProjectAddVariableSet {
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

    # get project and variable set folders
    $ProjectExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Projects' }).RestName)
    $VariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Variables' }).RestName)

    Get-ChildItem -Path $ProjectExportFolder -Recurse | ForEach-Object {
      $ExportFileProject = $_.FullName
      $ExportItemProject = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFileProject -Raw)
      $ExportItemVariableSet = ConvertFrom-Json -InputObject (Get-Content -Path (Join-Path -Path $VariableSetExportFolder -ChildPath ($ExportItemProject.VariableSetId + $JsonExtension)) -Raw)
      Add-ODUOrUpdateMember -InputObject $ExportItemProject -PropertyName 'VariableSet' -Value $ExportItemVariableSet
      Out-ODUFileJson -FilePath $ExportFileProject -Data $ExportItemProject
    }
  }
}
#endregion
