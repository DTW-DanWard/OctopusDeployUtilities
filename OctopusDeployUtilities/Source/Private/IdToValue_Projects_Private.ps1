
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
Update-ODUExportProjectAddDeploymentProcess -Path c:\Exports\MyOctoServer.com\20181120-103152
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
