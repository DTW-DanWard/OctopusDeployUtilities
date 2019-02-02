
Set-StrictMode -Version Latest

#region Function: Get-ODUExportItemFileName

<#
.SYNOPSIS
Gets raw file name (no extension) to be used when saving $ExportItem
.DESCRIPTION
Gets raw file name (no extension) to be used when saving $ExportItem
If item's ApiFetchType is Simple, file name will be the RestName value
If not, get an actual value from the ExportItem itself (typically Id or Name)
based on Property name found in $ApiCall.FileNamePropertyName
.PARAMETER ApiCall
PSObject with ApiCall information
.PARAMETER ExportItem
PSObject with data exported from Octopus
.EXAMPLE
Get-ODUExportItemFileName
<...>
#>
function Get-ODUExportItemFileName {
  #region Function parameters
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [object]$ApiCall = $(throw "$($MyInvocation.MyCommand) : missing parameter ApiCall"),
    [ValidateNotNullOrEmpty()]
    [object]$ExportItem = $(throw "$($MyInvocation.MyCommand) : missing parameter ExportItem")
  )
  #endregion
  process {
    $FileName = $null
    # for Simple calls, file name is rest method
    if ($ApiCall.ApiFetchType -eq $ApiFetchType_Simple) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Simple rest call $($ApiCall.RestName) use RestName for file name"
      $FileName = $ApiCall.RestName
    } else {
      Write-Verbose "$($MyInvocation.MyCommand) :: Rest call $($ApiCall.RestName) uses property $($ApiCall.FileNamePropertyName)"
      $FileNamePropertyName = $ApiCall.FileNamePropertyName
      if ($null -eq (Get-Member -InputObject $ExportItem -Name $FileNamePropertyName)) {
        throw "FileNamePropertyName $FileNamePropertyName not found on rest type $($ApiCall.RestName) on item with Id $($ExportItem.Id)"
      }
      $FileName = $ExportItem.$FileNamePropertyName
      Write-Verbose "$($MyInvocation.MyCommand) :: File name for this item: $FileName"
    }
    $FileName
  }
}
#endregion


#region Function: Get-ODUFolderNameForApiCall

<#
.SYNOPSIS
Gets folder name to use for storing api call results
.DESCRIPTION
Gets folder name to use for storing api call results
Will be 'Miscellaneous' for Simple fetch types and the RestName for all others
.PARAMETER ApiCall
Object with api call information
.EXAMPLE
Get-ODUFolderNameForApiCall $ApiCall
Miscellaneous     # this item is a Simple fetch type
Get-ODUFolderNameForApiCall $ApiCall
Projects          # Use Projects RestName as it is not a Simple fetch type
#>
function Get-ODUFolderNameForApiCall {
  #region Function parameters
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [object]$ApiCall = $(throw "$($MyInvocation.MyCommand) : missing parameter ApiCall")
  )
  #endregion
  process {

    $FolderName = $null
    if ($ApiCall.ApiFetchType -eq $ApiFetchType_Simple) {
      $FolderName = 'Miscellaneous'
    } else {
      $FolderName = $ApiCall.RestName
    }
    $FolderName
  }
}
#endregion


#region Function: Initialize-ODUFetchTypeItemIdOnlyIdsLookup

<#
.SYNOPSIS
Creates hashtable initialized for storing ItemIdOnly Id values
.DESCRIPTION
Creates hashtable initialized for storing ItemIdOnly Id values
Key is property name to look for on objects, value is empty array (to be filled later)
.PARAMETER ApiCalls
Object array with api call information
.EXAMPLE
Initialize-ODUFetchTypeItemIdOnlyIdsLookup $ApiCalls
<returns initialized hashtable>
#>
function Initialize-ODUFetchTypeItemIdOnlyIdsLookup {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([hashtable])]
  param(
    [ValidateNotNullOrEmpty()]
    [object[]]$ApiCalls = $(throw "$($MyInvocation.MyCommand) : missing parameter ApiCalls")
  )
  #endregion
  process {
    [hashtable]$ItemIdOnlyIdsLookup = @{ }
    $ApiCalls | ForEach-Object {
      $ItemIdOnlyReferencePropertyName = $_.ItemIdOnlyReferencePropertyName
      $ItemIdOnlyIdsLookup.$ItemIdOnlyReferencePropertyName = @()
    }
    $ItemIdOnlyIdsLookup
  }
}
#endregion


#region Function: Remove-ODUFilterPropertiesFromExportItem

<#
.SYNOPSIS
Filters properties on/off an exported item based in users property white/black list settings
.DESCRIPTION
Filters properties on/off an exported item based in users property white/black list settings
.PARAMETER RestName
Name of type being processed
.PARAMETER ExportItem
Exported item to process
.EXAMPLE
Remove-ODUFilterPropertiesFromExportItem
<...>
#>
function Remove-ODUFilterPropertiesFromExportItem {
  #region Function parameters
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$RestName = $(throw "$($MyInvocation.MyCommand) : missing parameter RestName"),
    [ValidateNotNullOrEmpty()]
    [object]$ExportItem = $(throw "$($MyInvocation.MyCommand) : missing parameter ExportItem")
  )
  #endregion
  process {
    [PSCustomObject]$FilteredExportItem = $null
    [string[]]$BlackList = $null
    [string[]]$WhiteList = $null

    $PropertyWhiteList = Get-ODUConfigPropertyWhiteList
    $PropertyBlackList = Get-ODUConfigPropertyBlackList

    # white and black lists should not both have values (that is confirmed in configuration)
    if (($null -ne $PropertyWhiteList) -and $PropertyWhiteList.Contains($RestName) -and $PropertyWhiteList.$RestName.Count -gt 0) {
      [string[]]$WhiteList = $PropertyWhiteList.$RestName
    }
    if (($null -ne $PropertyBlackList) -and $PropertyBlackList.Contains($RestName) -and $PropertyBlackList.$RestName.Count -gt 0) {
      [string[]]$BlackList = $PropertyBlackList.$RestName
    }

    $FilteredExportItem = $ExportItem
    # white list and black list should not BOTH be set at same time so this should be safe
    if ($null -ne $WhiteList -or $null -ne $BlackList) {
      # has to use this way of creating PSCustomObject and adding members - not hashtable
      # or else we lose the original order of the properties on ExportItem
      $FilteredExportItem = New-Object -TypeName PSObject
      # don't use Get-Member to get properties, which sorts property names and loses original order, use this
      $ExportItem.PSObject.Properties.Name | ForEach-Object {
        if ($WhiteList -contains $_ -or $BlackList -notcontains $_) {
          Add-Member -InputObject $FilteredExportItem -MemberType NoteProperty -Name $_ -Value ($ExportItem.$_)
        }
      }
    }
    $FilteredExportItem
  }
}
#endregion
