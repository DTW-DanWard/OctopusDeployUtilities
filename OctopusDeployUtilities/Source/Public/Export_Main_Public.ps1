
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

    Write-Host "Exporting data"

    # export data and capture export folder instance
    [string]$CurrentExportRootFolder = Export-ODUOctopusDeployConfigMain

    Write-Host "Performing data lookups in $CurrentExportRootFolder"
    # asdf refactor into single function?
    # create lookup object in root of export with every Id and name for every exported item
    New-ODUIdToNameLookup $CurrentExportRootFolder

    # for each exported item, look for external Id values in it, lookup the external name for the external id and add to exported item
    Update-ODUExportAddExternalNamesForIds $CurrentExportRootFolder


    # asdf - return export read into memory?  parameter switch?
    Write-Host "Updating `$global:ODU_Export"
  }
}


function Test {

  $Path = 'C:\temp\Temp\dtw-test1.octopus.app\20181120-103152'
  
  New-ODUIdToNameLookup $Path
  Update-ODUExportAddExternalNamesForIds $Path


}