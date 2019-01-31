
Set-StrictMode -Version Latest

#region Function: Get-ODUIdToNameLookupValue

<#
.SYNOPSIS
Looks through object properties, returns value for lookup
.DESCRIPTION
If $Key is $null, returns $null else it always returns something.  If $Key
isn't $null but $Key not found, returns <$Key>_NOT_FOUND else returns value
.PARAMETER Lookup
PSObject with properties (name is key)
.PARAMETER Key
Property (key) to look up
.EXAMPLE
Get-ODUIdToNameLookupValue -Lookup <PSObject> -Key AProperty
<A value>
#>
function Get-ODUIdToNameLookupValue {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Lookup,
    $Key
  )
  #endregion
  process {
    # if null/empty key passed, return $null
    # if key passed but not found on lookup, return <key>_NOT_FOUND
    # else return value
    $Result = $null
    if ($null -ne $Key -and $Key.Trim() -ne '') {
      $Result = $Key + '_NOT_FOUND'
      if ($null -ne (Get-Member -InputObject $Lookup -Name $Key)) {
        $Result = $Lookup.$Key
      }
    }
    $Result
  }
}
#endregion


#region Function: Update-ODUExportAddExternalNameForId

<#
.SYNOPSIS
Scans each exported item, finds external Id references and adds property to item with name of referenced id
.DESCRIPTION
Scans each exported item, finds external Id references and adds property to item with name of referenced id
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportAddExternalNameForId -Path c:\Exports\MyOctoServer.octopus.app\20181120-103152
<adds properties to exported items>
#>
function Update-ODUExportAddExternalNameForId {
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

    [string]$LookupPath = Join-Path -Path $Path -ChildPath $IdToNameLookupFileName
    if ($false -eq (Test-Path -Path $LookupPath)) { throw "Export Id to name lookup file not found: $LookupPath" }
    $IdToNameLookup = ConvertFrom-Json -InputObject (Get-Content -Path $LookupPath -Raw)

    # when fetching lookup data, drive off rest api call info (instead of existing folders) as need Name and ExternalIdToResolvePropertyName fields
    # note: there's no lookup data for Simple rest api calls, so skip them
    Get-ODUStandardExportRestApiCall | Where-Object { $_.ApiFetchType -ne $ApiFetchType_Simple } | ForEach-Object {
      $RestApiCall = $_
      if (($null -ne $RestApiCall.ExternalIdToResolvePropertyName) -and ($RestApiCall.ExternalIdToResolvePropertyName.Count -gt 0)) {
        $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
        # loop through all files under item folder
        Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
          $ExportFilePath = $_.FullName
          $ExportItem = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFilePath -Raw)

          # for the item, loop through all external id property names
          $RestApiCall.ExternalIdToResolvePropertyName | ForEach-Object {
            $ExternalIdToResolvePropertyName = $_

            # create new project name with name values - take 'Id'/'Ids' suffix and replace with 'Name'
            $ExternalNamePropertyName = $ExternalIdToResolvePropertyName.SubString(0, $ExternalIdToResolvePropertyName.LastIndexOf('Id')) + 'Name'
            # external id might be a single value or an array, can tell by looking at name suffix: is 'Id' or 'Ids'
            if ($ExternalIdToResolvePropertyName -match "Id$") {
              # singular
              $ExternalId = $ExportItem.$ExternalIdToResolvePropertyName
              $ExternalDisplayName = Get-ODUIdToNameLookupValue -Lookup $IdToNameLookup -Key $ExternalId
              # while it seems we should only have one Add-Member call after the if statement, we can't; we need two separate
              # variables for $ExternalDisplayName and $ExternalDisplayNames; one is an array, one isn't, if we only had one variable for
              # the value the variable type would unexpectedly get changed to an array while processing data and stay that way
              # changing the stored structure for all future values
              Add-ODUOrUpdateMember -InputObject $ExportItem -PropertyName $ExternalNamePropertyName -Value $ExternalDisplayName
            } else {
              # make it plural
              $ExternalNamePropertyName += 's'
              [string[]]$ExternalDisplayNames = @()
              $ExportItem.$ExternalIdToResolvePropertyName | ForEach-Object {
                $ExternalId = $_
                $ExternalDisplayNames += (Get-ODUIdToNameLookupValue -Lookup $IdToNameLookup -Key $ExternalId)
              }
              # if there are values, sort before adding - only sort if values else sort changes empty array to null
              if ($ExternalDisplayNames.Count -gt 0) { $ExternalDisplayNames = $ExternalDisplayNames | Sort-Object }
              # see note above about why there are two separate Add-Member calls
              Add-ODUOrUpdateMember -InputObject $ExportItem -PropertyName $ExternalNamePropertyName -Value $ExternalDisplayNames
            }
          }
          Out-ODUFileJson -FilePath $ExportFilePath -Data $ExportItem
        }
      }
    }
  }
}
#endregion
