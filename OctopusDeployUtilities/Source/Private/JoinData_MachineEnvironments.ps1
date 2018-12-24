
Set-StrictMode -Version Latest

#region Function: Update-ODUExportAddMachinesToEnvironment

<#
.SYNOPSIS
Adds machine names to environments
.DESCRIPTION
Adds machine names to environments
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportAddMachinesToEnvironment -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds machine names to environments>
#>
function Update-ODUExportAddMachinesToEnvironment {
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
    $RestApiCall = Get-ODUStandardExportRestApiCall | Where-Object { $_.RestName -eq 'Machines' }
    $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
    $Machines = Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
      $ExportItem = ConvertFrom-Json -InputObject (Get-Content -Path ($_.FullName) -Raw)
      [PSCustomObject]@{
        Id = $ExportItem.Id
        Name = $ExportItem.Name
        EnvironmentIds = [string[]]($ExportItem.EnvironmentIds)
      }
    }
    # sort by names so display nice/consistent in storage
    $Machines = $Machines | Sort-Object -Property Name

    # now get environments; check each environment and add machine id/name values
    $RestApiCall = Get-ODUStandardExportRestApiCall | Where-Object { $_.RestName -eq 'Environments' }
    $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
    Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
      $ExportFile = $_.FullName
      $ExportItem = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFile -Raw)

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
