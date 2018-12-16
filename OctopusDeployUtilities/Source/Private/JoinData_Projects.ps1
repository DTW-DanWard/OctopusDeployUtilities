
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
      $ExportItemProject = Get-Content -Path $ExportFileProject | ConvertFrom-Json
      $ExportItemDeploymentProcess = Get-Content -Path (Join-Path -Path $DeploymentProcessExportFolder -ChildPath ($ExportItemProject.DeploymentProcessId + $JsonExtension)) | ConvertFrom-Json
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

    # get project and variable set folders
    $ProjectExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Projects' }).RestName)
    $IncludedLibraryVariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'LibraryVariableSets' }).RestName)
    $VariableSetExportFolder = Join-Path -Path $Path -ChildPath ((Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Variables' }).RestName)

    Get-ChildItem -Path $ProjectExportFolder -Recurse | ForEach-Object {
      $ExportFileProject = $_.FullName
      $ExportItemProject = Get-Content -Path $ExportFileProject | ConvertFrom-Json

      # loop through all IncludedLibraryVariableSetIds, for each, get the IncludedLibraryVariableSet, for that, get it's VariableSet
      #   add the VariableSet to the IncludedLibraryVariableSet and add the whole array to the project
      [object[]]$IncludedLibraryVariableSets = @()
      $ExportItemProject.IncludedLibraryVariableSetIds | ForEach-Object {
        $IncludedLibraryVariableSetId = $_
        $ExportItemIncludedLibraryVariableSet = Get-Content -Path (Join-Path -Path $IncludedLibraryVariableSetExportFolder -ChildPath ($IncludedLibraryVariableSetId + $JsonExtension)) | ConvertFrom-Json
        # now fetch the variables for this IncludedLibraryVariableSet
        $ExportItemVariableSet = Get-Content -Path (Join-Path -Path $VariableSetExportFolder -ChildPath ($ExportItemIncludedLibraryVariableSet.VariableSetId + $JsonExtension)) | ConvertFrom-Json
        # now add variable set to included library variable set
        Add-ODUOrUpdateMember -InputObject $ExportItemIncludedLibraryVariableSet -PropertyName 'VariableSet' -Value $ExportItemVariableSet
        # now add included library variable set to array
        $IncludedLibraryVariableSets += $ExportItemIncludedLibraryVariableSet
      }

      # now add array to project
      Add-ODUOrUpdateMember -InputObject $ExportItemProject -PropertyName 'IncludedLibraryVariableSets' -Value $IncludedLibraryVariableSets
      # and finally save
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
      $ExportItemProject = Get-Content -Path $ExportFileProject | ConvertFrom-Json
      $ExportItemVariableSet = Get-Content -Path (Join-Path -Path $VariableSetExportFolder -ChildPath ($ExportItemProject.VariableSetId + $JsonExtension)) | ConvertFrom-Json
      Add-ODUOrUpdateMember -InputObject $ExportItemProject -PropertyName 'VariableSet' -Value $ExportItemVariableSet
      Out-ODUFileJson -FilePath $ExportFileProject -Data $ExportItemProject
    }
  }
}
#endregion
