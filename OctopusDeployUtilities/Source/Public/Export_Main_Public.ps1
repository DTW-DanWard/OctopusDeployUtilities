
Set-StrictMode -Version Latest

#region Function: Export-ODUOctopusDeployConfig

<#
.SYNOPSIS
Exports Octopus Deploy configuration from a server to a unique datetimestamp folder
.DESCRIPTION
Exports Octopus Deploy configuration from a server to a unique datetimestamp folder.
Fetches from server and saves to folder based on settings entered by user via the
Set-ODUConfig* functions.
.EXAMPLE
Export-ODUOctopusDeployConfig
#>
function Export-ODUOctopusDeployConfig {
  [CmdletBinding()]
  param()
  process {
    # export data and capture export folder instance
    Write-Output "Exporting data"
    [string]$CurrentExportRootFolder = Export-ODUOctopusDeployConfigMain
    Write-Verbose "$($MyInvocation.MyCommand) :: Export folder: $CurrentExportRootFolder"

    # create lookup object in root of export with every Id and name for every exported item
    Write-Output "Creating Id to name lookup"
    New-ODUIdToNameLookup $CurrentExportRootFolder

    # for each exported item, look for external Id values in it, lookup the external name for the external id and add to exported item
    Write-Output "Adding external names for ids in exported data"
    Update-ODUExportAddExternalNamesForIds $CurrentExportRootFolder

    # for exported variables, add scope names and breadth
    Update-ODUExportAddScopeNamesToVariables $CurrentExportRootFolder

    # asdf - return export read into memory?  parameter switch?
    Write-Output "Updating `$global:ODU_Export"
  }
}


function Test {

  $Path = 'C:\temp\Temp\dtw-test1.octopus.app\zzz'
  
  New-ODUIdToNameLookup $Path
  Update-ODUExportAddExternalNamesForIds $Path
  Update-ODUExportAddScopeNamesToVariables $Path

}