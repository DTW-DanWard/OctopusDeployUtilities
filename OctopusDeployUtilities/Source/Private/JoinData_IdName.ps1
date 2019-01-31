
Set-StrictMode -Version Latest

#region Function: Get-ODUIdToNameLookup

<#
.SYNOPSIS
Creates hashtable of containing all Id to Name lookup values for files under $Path
.DESCRIPTION
Creates hashtable of containing all Id to Name lookup values for files under $Path
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Get-ODUIdToNameLookup -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<hash table of lookup values>
#>
function Get-ODUIdToNameLookup {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([hashtable])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Path = $(throw "$($MyInvocation.MyCommand) : missing parameter Path")
  )
  #endregion
  process {
    if ($false -eq (Test-Path -Path $Path)) { throw "No export found at: $Path" }

    $IdToNameLookup = @{ }
    # when fetching lookup data, drive off rest api call info (instead of existing folders) as need Name field
    # note: there's no lookup data for Simple rest api calls, so skip them
    Get-ODUStandardExportRestApiCall | Where-Object { $_.ApiFetchType -ne $ApiFetchType_Simple } | ForEach-Object {
      $RestApiCall = $_
      $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
      Get-ChildItem -Path $ItemExportFolder -File -Recurse | ForEach-Object {
        $ExportItem = ConvertFrom-Json -InputObject (Get-Content -Path $_.FullName -Raw)
        if ($null -ne $ExportItem) {
          # if item has BOTH Id and IdToNamePropertyName properties, capture it
          $PropertyName = $RestApiCall.IdToNamePropertyName
          if ( ($null -ne (Get-Member -InputObject $ExportItem -Name Id)) -and ($null -ne (Get-Member -InputObject $ExportItem -Name $PropertyName)) ) {
            $Id = $ExportItem.Id
            $IdToNameLookup.$Id = $ExportItem.$PropertyName
          }
        }
      }
    }
    $IdToNameLookup
  }
}
#endregion


#region Function: New-ODUIdToNameLookup

<#
.SYNOPSIS
Creates Id to name lookup file containing Id to Name lookup values for files under Path
.DESCRIPTION
Creates Id to name lookup file in export instance root containing all Id to Name lookup values
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
New-ODUIdToNameLookup -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<creates c:\Exports\MyOctoServer.octopus.app\20181120-103152\IdToNameLookup.json with Id to name lookup data>
#>
function New-ODUIdToNameLookup {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Path = $(throw "$($MyInvocation.MyCommand) : missing parameter Path")
  )
  #endregion
  process {
    if ($false -eq (Test-Path -Path $Path)) { throw "No export found at: $Path" }

    # make sure standard export type folders exist under path; if less than half, probably wrong path but write warning only
    [string[]]$StandardExportFolders = @('DeploymentProcesses','Environments','LibraryVariableSets','Machines','Projects','Variables')
    $FoundCount = ($StandardExportFolders | Where-Object { Test-Path -Path (Join-Path -Path $Path -ChildPath $_) } | Measure-Object).Count
    if ($FoundCount -lt ([math]::Floor(($StandardExportFolders.Count) / 2))) {
      throw "This does not appear to be a proper export folder - less than half of the standard folders ($StandardExportFolders) were found at $Path - is this a proper export?"
    }

    # save lookup info in root of export instance folder
    Out-ODUFileJson -FilePath (Join-Path -Path $Path -ChildPath $IdToNameLookupFileName) -Data (Get-ODUIdToNameLookup -Path $Path)
  }
}
