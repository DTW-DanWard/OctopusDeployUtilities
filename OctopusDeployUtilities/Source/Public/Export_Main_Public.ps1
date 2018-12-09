
Set-StrictMode -Version Latest

#region Function: Export-ODUOctopusDeployConfig

<#
.SYNOPSIS
Exports Octopus Deploy configuration from a server and saves in local JSON files.
.DESCRIPTION
Exports Octopus Deploy configuration from a server to a unique datetimestamp folder.
Fetches from server and saves to folder based on settings entered by user via the
Set-ODUConfig* functions.
.PARAMETER Quiet
Suppress status output
.PARAMETER PassThru
Returns string path to export; also suppresses status output (sets Quiet = $true)
.EXAMPLE
Export-ODUOctopusDeployConfig
asdf
#>
function Export-ODUOctopusDeployConfig {
  [CmdletBinding()]
  param(
    [switch]$Quiet,
    [switch]$PassThru
  )
  process {
    # if user specified PassThru, disable output (enable Quiet) so only path returned
    if ($PassThru) { $Quiet = $true }

    # export data and capture export folder instance
    if (! $Quiet) { Write-Output "Exporting data..." }
    [string]$CurrentExportRootFolder = Export-ODUOctopusDeployConfigMain
    if (! $Quiet) { Write-Output "  Data exported to: $CurrentExportRootFolder" }

    Update-ODUExportJoinData -Path $CurrentExportRootFolder -Quiet:$Quiet

    if ($PassThru) { Write-Output $CurrentExportRootFolder }
  }
}
#endregion
