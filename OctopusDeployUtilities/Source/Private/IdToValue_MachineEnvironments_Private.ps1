
Set-StrictMode -Version Latest

#region Function: Update-ODUExportAddMachinesToEnvironments

<#
.SYNOPSIS
Adds machine names to environments
.DESCRIPTION
Adds machine names to environments
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportAddMachinesToEnvironments -Path c:\Exports\MyOctoServer.com\20181120-103152
<adds machine names to environments>
#>
function Update-ODUExportAddMachinesToEnvironments {
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

    # get machine info first
    $RestApiCall = Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Machines' }
    $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
    $Machines = Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
      $ExportItem = Get-Content -Path ($_.FullName) | ConvertFrom-Json
      [PSCustomObject]@{
        Id = $ExportItem.Id
        Name = $ExportItem.Name
        EnvironmentIds = [string[]]($ExportItem.EnvironmentIds)
      }
    }
    # sort by names so display nice/consistent in storage
    $Machines = $Machines | Sort-Object -Property Name

    # now get environments; check each environment and add machine id/name values
    $RestApiCall = Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Environments' }
    $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
    Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
      $ExportFile = $_.FullName
      $ExportItem = Get-Content -Path ($ExportFile) | ConvertFrom-Json

      [string[]]$MachineIdsForEnvironment = @()
      [string[]]$MachineNamesForEnvironment = @()

      $Machines | ForEach-Object {
        $Machine = $_
        if ($Machine.EnvironmentIds -contains $ExportItem.Id) {
          $MachineIdsForEnvironment += $Machine.Id
          $MachineNamesForEnvironment += $Machine.Name
        }
      }
      Add-ODUOrUpdateMember -InputObject $ExportItem -PropertyName MachineIds -Value $MachineIdsForEnvironment
      Add-ODUOrUpdateMember -InputObject $ExportItem -PropertyName MachineNames -Value $MachineNamesForEnvironment
      Out-ODUFileJson -FilePath $ExportFile -Data $ExportItem
    }
  }
}