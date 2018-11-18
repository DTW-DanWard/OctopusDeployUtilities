
Set-StrictMode -Version Latest

#region Function: Export-ODUOctopusDeployConfig

<#
.SYNOPSIS
Exports Octopus Deploy configuration, performs data lookups... asdf
.DESCRIPTION
Exports Octopus Deploy configuration
asdf lots of notes needed here
.EXAMPLE
Export-ODUOctopusDeployConfig
<asdf lots of notes needed here>
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
