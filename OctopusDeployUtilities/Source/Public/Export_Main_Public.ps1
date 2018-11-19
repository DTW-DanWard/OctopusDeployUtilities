
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

    # asdf this is what is should be, just output results for now
#     [string]$CurrentExportRootFolder = Export-ODUOctopusDeployConfigPrivate

# asdf remove - should be captured above
Export-ODUOctopusDeployConfigPrivate


#    Write-Host "Export root: $CurrentExportRootFolder"

#    Write-Host "Performing data lookups"

    # asdf - return export read into memory?  parameter switch?
    Write-Host "Updating `$global:ODU_Export"
  }
}
