
Set-StrictMode -Version Latest


#region Function: Find-ODUVariable

<#
.SYNOPSIS
Find variables by name or value in Octopus Deploy latest export
.DESCRIPTION
Find variables by name or value in Octopus Deploy latest export.  Matches either partial
text or Exact.  Uses latest available export for searching.  When first running, captures
oduobject and stores it in global scope variable $ODU_Export.  Future searches will use the
$ODU_Export to speed up the search process.  If a new export becomes available after 
$ODU_Export was captured, it loads that new export into memory and caches it.
.PARAMETER SearchText
Variable name or value to search for; can be partial text
.PARAMETER Exact
Return only exact matches
.PARAMETER WriteOutput
Instead of using Write-Host to produced highlightened content, use only Write-Output
(prevents colors but also allows for storing search results in files via > file.txt
.PARAMETER PSObject
Instead of writing any output to host, return search results as a PSObject.  Useful
for programmatic usage of search results.
.EXAMPLE
Find-ODUVariable SalesDb
<outputs to host all variables that contain 'SalesDb' in name and / or value>
.EXAMPLE
oduvar SalesDb
<same as previous example but uses alias>
.EXAMPLE
Find-ODUVariable SalesDb -Exact
<outputs to host all variables with exact name and / or exact value of 'SalesDb'>
.EXAMPLE
Find-ODUVariable SalesDb -WriteOutput > c:\temp\Results.txt
<outputs to standard output all variables that contain 'SalesDb' in name and / or value, save to file>
.EXAMPLE
Find-ODUVariable SalesDb -PSObject
<returns PSObject with search results, can be used for more detailed analyis or a part of another search tool>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
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

    #region Get export to use; fetch and store in memory
    $Export = $null
    $ExportLatestPath = Get-ODUExportLatestPath
    Write-Verbose "$($MyInvocation.MyCommand) :: Latest export path: $ExportLatestPath"
    # check if export cached in memory; if none found, capture latest, store it
    # also capturing file path so we know which one was used (in case newer becomes available)
    if (($false -eq (Test-Path variable:global:ODU_Export)) -or ($null -eq $global:ODU_Export)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: No export found in memory; reading latest and storing"
      $Export = Read-ODUExportFromFile -Path $ExportLatestPath
      $global:ODU_Export = $Export
      $global:ODU_ExportLatestPath = $ExportLatestPath
    } else {
      # export exists in memory - but is it latest?  check if latest
      # no need to test if exists; if export exists, so does path
      if ($ExportLatestPath -eq $global:ODU_ExportLatestPath) {
        Write-Verbose "$($MyInvocation.MyCommand) :: Export found in memory and is latest; using that"
        $Export = $global:ODU_Export
      } else {
        Write-Verbose "$($MyInvocation.MyCommand) :: Export found in memory but is NOT latest; updating"
        $Export = Read-ODUExportFromFile -Path $ExportLatestPath
        $global:ODU_Export = $Export
        $global:ODU_ExportLatestPath = $ExportLatestPath
      }
    }
    #endregion

    # do initial search with cmdline param
    $Results = Find-ODUVariableInExport -Export $Export -SearchText $SearchText -Exact:$Exact
    if ($PSObject) {
      $Results
    } else {
      Out-ODUSearchResultsText -SearchResults $Results
      Write-Output ''
    }
  }
}
#endregion
