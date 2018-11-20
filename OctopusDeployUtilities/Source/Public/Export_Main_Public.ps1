
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
    New-ODUIdToNameLookup $CurrentExportRootFolder


    # asdf - return export read into memory?  parameter switch?
    Write-Host "Updating `$global:ODU_Export"
  }
}


function Test {

  


}