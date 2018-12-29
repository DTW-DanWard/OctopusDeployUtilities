
Set-StrictMode -Version Latest


#region Function: Find-ODUVariable

<#
.SYNOPSIS
Find variables in Octopus Deploy configuration by name or value
.DESCRIPTION
Find variables in Octopus Deploy configuration by name or value.
.PARAMETER SearchText
Variable name to search for; can be partial text
.PARAMETER Exact
Instead of partial matches return only exact matches
.PARAMETER WriteOutput
Instead of using Write-Host to produced highlightened content, use only Write-Output
(prevents colors and also allows for storing search results in files via > file.txt
.PARAMETER PSObject
Instead of writing any output to host, return search results as a PSObject.  Useful
for programmatic usage of search results.
#>
function Find-ODUVariable {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$SearchText,
    [Parameter(Mandatory = $false)]
    [switch]$Exact,
    [Parameter(Mandatory = $false)]
    [switch]$WriteOutput,
    [Parameter(Mandatory = $false)]
    [switch]$PSObject
  )
  #endregion
  process {
    #region Confirm scripts params WriteOutput and PSObject both not specified at same time
    if ($WriteOutput -and $PSObject) {
      Write-Host "`nCannot specify both WriteOutput and PSObject at same time`n" -ForegroundColor Cyan
      return
    }
    #endregion


    $Export = oduobject

    # asdf old cache code below; needs update
    # #region Specify export to use (for now just use latest export)
    # if (($false -eq (Test-Path variable:global:OD_LatestExport)) -or ($null -eq $global:OD_LatestExport)) {
    #   Write-Host ''
    #   Write-Host 'Find script uses latest export in memory.  Make sure your PowerShell profile contains a line like:'
    #   Write-Host '$global:OD_LatestExport = Get-ODExportObjectFromFile' -ForegroundColor Cyan
    #   Write-Host 'or your profile calls alias: '  -NoNewline
    #   Write-Host 'odmemoryupdate' -ForegroundColor Cyan
    #   Write-Host ''
    #   return
    # }
    # # use latest export in memory
    # # this could be modified to pass in a export reference or a path to an export
    # $Export = $global:OD_LatestExport
    # #endregion

    # do initial search with cmdline param
    $Results = Find-ODUVariableInExport -Export $Export -SearchText $SearchText
    if ($PSObject) {
      $Results
    } else {
      Out-ODUSearchResultsText -SearchResults $Results
      Write-Output ''
    }
  }
}
#endregion
