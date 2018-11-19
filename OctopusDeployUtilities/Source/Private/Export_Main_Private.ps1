
Set-StrictMode -Version Latest

#region Function: Export-ODUJob

<#
.SYNOPSIS
Processes a single ExportJobDetail - i.e. data from a single Url
.DESCRIPTION
Processes a single ExportJobDetail:
 - fetches content for a single url;
 - captures ItemIdOnly value references;
 - filters propertes on the exported data;
 - saves data to file.
 Data might be 0, 1 or multiple items.
 Returns hashtable of ItemIdOnly reference values.  That is: if a property listed in
 ItemIdOnlyReferencePropertyNames is found on the object, the value for that property is
 captured and returned at the end of the function call.
.PARAMETER ExportJobDetail
Information about the export: ApiCall info, Url, ApiKey to use in call, folder to save to
.PARAMETER ItemIdOnlyReferencePropertyNames
ItemIdOnly property names to look for in data that is retrieved; return values for these if found
.EXAMPLE
Export-ODUJob
<...>
#>
function Export-ODUJob {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ExportJobDetail,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ItemIdOnlyReferencePropertyNames
  )
  process {
    $ExportItems = Invoke-ODURestMethod -Url $ExportJobDetail.Url -ApiKey $ExportJobDetail.ApiKey

    [hashtable]$ItemIdOnlyReferenceValues = @{}
    if ($null -ne $ExportItems) {

      # simple references have a single item which does not have ItemIdOnly references; just save it
      # same is true of items fetched by IdOnly
      if (($ExportJobDetail.ApiCall.ApiFetchType -eq $ApiFetchType_Simple) ) { # -or ($null -eq (Get-Member -InputObject $ExportItems -Name Items))) {
        $FilePath = Join-Path -Path ($ExportJobDetail.ExportFolder) -ChildPath ((Format-ODUSanitizedFileName -FileName (Get-ODUExportItemFileName -ApiCall $ExportJobDetail.ApiCall -ExportItem $ExportItems)) + '.json')
        Write-Verbose "$($MyInvocation.MyCommand) :: Saving content to: $FilePath"
        Out-ODUFileJson -FilePath $FilePath -Data (Remove-ODUFilterPropertiesFromExportItem -RestName ($ExportJobDetail.ApiCall.RestName) -ExportItem $ExportItems)

      } else {
        # this is for TenantVariables, which returns multiple values that should be stored in multiple files
        # BUT, for whatever really dumb reason, Octo API does not provide this info in the standard TotalResults / .Items format
        # so we have this dumb workaround here - try to get the items as-is without the .Items property
        [object[]]$ExportItemsToProcess = $ExportItems
        if ($null -ne (Get-Member -InputObject $ExportItems -Name Items)) {
          $ExportItemsToProcess = $ExportItems.Items
        }
        $ExportItemsToProcess | ForEach-Object {
          $ExportItem = $_
          # inspect exported item for ItemIdOnly id references
          $ItemIdOnlyReferenceValuesOnItem = Get-ODUItemIdOnlyReferenceValues -ExportJobDetail $ExportJobDetail -ItemIdOnlyReferencePropertyNames $ItemIdOnlyReferencePropertyNames -ExportItem $ExportItem
          # transfer values to main hash table
          $ItemIdOnlyReferenceValuesOnItem.Keys | ForEach-Object {
            if (! $ItemIdOnlyReferenceValues.Contains($_)) { $ItemIdOnlyReferenceValues.$_ = @() }
            $ItemIdOnlyReferenceValues.$_ += $ItemIdOnlyReferenceValuesOnItem.$_
          }

          $FilePath = Join-Path -Path ($ExportJobDetail.ExportFolder) -ChildPath ((Format-ODUSanitizedFileName -FileName (Get-ODUExportItemFileName -ApiCall $ExportJobDetail.ApiCall -ExportItem $ExportItem)) + '.json')
          Write-Verbose "$($MyInvocation.MyCommand) :: Saving content to: $FilePath"
          Out-ODUFileJson -FilePath $FilePath -Data (Remove-ODUFilterPropertiesFromExportItem -RestName ($ExportJobDetail.ApiCall.RestName) -ExportItem $ExportItem)
        }
      }
    }
    $ItemIdOnlyReferenceValues
  }
}
#endregion


#region Function: Export-ODUOctopusDeployConfigPrivate

<#
.SYNOPSIS
Main function controlling a standard export process
.DESCRIPTION
Main function controlling a standard export process
Create.... asdf fill in here
.EXAMPLE
Export-ODUOctopusDeployConfigPrivate
<...>
#>
function Export-ODUOctopusDeployConfigPrivate {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    # get Octopus Server details now, pass into job creation
    $OctopusServer = Get-ODUConfigOctopusServer
    $ServerName = $OctopusServer.Name
    $ServerUrl = $OctopusServer.Url
    $ApiKey = Convert-ODUDecryptApiKey -ApiKey ($OctopusServer.ApiKey)

    # create root folder for this export instance
    $CurrentExportRootFolder = New-ODURootExportFolder -MainExportRoot (Get-ODUConfigExportRootFolder) -ServerName $ServerName -DateTime (Get-Date)

    # get filtered list of api call details to process
    $ApiCalls = Get-ODUFilteredExportRestApiCalls
    # create folders for each api call
    Write-Verbose "$($MyInvocation.MyCommand) :: Creating folder for api calls"
    New-ODUFolderForEachApiCall -ParentFolder $CurrentExportRootFolder -ApiCalls $ApiCalls

    # for ItemIdOnly calls, create lookup with key of reference property names and value empty array (for capturing values)
    [hashtable]$ItemIdOnlyIdsLookup = Initialize-ODUFetchTypeItemIdOnlyIdsLookup -ApiCalls ($ApiCalls | Where-Object { $_.ApiFetchType -eq $ApiFetchType_ItemIdOnly })

    # loop through non-ItemIdOnly calls creating zero, one more more jobs for exporting content from it
    [object[]]$ExportJobDetails = $ApiCalls | Where-Object { $_.ApiFetchType -ne $ApiFetchType_ItemIdOnly } | ForEach-Object {
      $ApiCall = $_
      New-ODUExportJobInfo -ServerBaseUrl $ServerUrl -ApiKey $ApiKey -ApiCall $ApiCall -ParentFolder $CurrentExportRootFolder
    }

    # process (export/save) the non-ItemIdOnly jobs, capturing ItemIdOnly Ids to process after
    $ExportJobDetails | ForEach-Object {
      $ItemIdOnlyDetails = Export-ODUJob -ExportJobDetail $_ -ItemIdOnlyReferencePropertyNames ($ItemIdOnlyIdsLookup.Keys)
      # transfer values to main hash table
      $ItemIdOnlyDetails.Keys | ForEach-Object { $ItemIdOnlyIdsLookup.$_ += $ItemIdOnlyDetails.$_ }
    }

    # now loop through ItemIdOnly calls, creating jobs using captured ItemIdOnly Ids
    [object[]]$ExportJobDetails = $ApiCalls | Where-Object { $_.ApiFetchType -eq $ApiFetchType_ItemIdOnly } | ForEach-Object {
      $ApiCall = $_
      $ItemIdOnlyPropertyName = $ApiCall.ItemIdOnlyReferencePropertyName
      if (($null -ne $ItemIdOnlyIdsLookup.$ItemIdOnlyPropertyName) -and ($ItemIdOnlyIdsLookup.$ItemIdOnlyPropertyName.Count -gt 0)) {
        New-ODUExportJobInfo -ServerBaseUrl $ServerUrl -ApiKey $ApiKey -ApiCall $ApiCall -ParentFolder $CurrentExportRootFolder -ItemIdOnlyIds $ItemIdOnlyIdsLookup.$ItemIdOnlyPropertyName
      }
    }

    # process (export/save) the ItemIdOnly jobs
    $ExportJobDetails | ForEach-Object {
      # shouldn't be any values returned; even if there are, we ignore
      Export-ODUJob -ExportJobDetail $_ -ItemIdOnlyReferencePropertyNames ($ItemIdOnlyIdsLookup.Keys) > $null
    }

    # return path to this export
    $CurrentExportRootFolder
  }
}
#endregion


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
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ApiCall,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ExportItem
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


#region Function: Get-ODUItemIdOnlyReferenceValues

<#
.SYNOPSIS
Returns standard export rest api call info filtered based on user black / white list
.DESCRIPTION
Returns standard export rest api call info filtered based on user black / white list
.PARAMETER ExportJobDetail
Details about export job
.PARAMETER ItemIdOnlyReferencePropertyNames
Property names to look for in exported item, find values for these properties and return
.PARAMETER ExportItem
Exported data item to review
.EXAMPLE
Get-ODUItemIdOnlyReferenceValues
<returns subset of rest api call objects>
#>
function Get-ODUItemIdOnlyReferenceValues {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ExportJobDetail,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ItemIdOnlyReferencePropertyNames,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ExportItem
  )
  process {
    [hashtable]$ItemIdOnlyReferenceValues = @{}
    $ItemIdOnlyReferencePropertyNames | ForEach-Object {
      $ItemIdOnlyReferencePropertyName = $_
      if ($null -ne (Get-Member -InputObject $ExportItem -Name $ItemIdOnlyReferencePropertyName)) {
        Write-Verbose "$($MyInvocation.MyCommand) :: Property $ItemIdOnlyReferencePropertyName FOUND on $($ExportJobDetail.ApiCall.RestName) with id $($ExportItem.Id)"
        # add array entry if first time
        if (! $ItemIdOnlyReferenceValues.Contains($ItemIdOnlyReferencePropertyName)) {
          $ItemIdOnlyReferenceValues.$ItemIdOnlyReferencePropertyName = @()
        }
        Write-Verbose "$($MyInvocation.MyCommand) :: ItemIdOnly reference value is: $($ExportItem.$ItemIdOnlyReferencePropertyName)"
        $ItemIdOnlyReferenceValues.$ItemIdOnlyReferencePropertyName += $ExportItem.$ItemIdOnlyReferencePropertyName
      } else {
        Write-Verbose "$($MyInvocation.MyCommand) :: Property $ItemIdOnlyReferencePropertyName NOT found on $($ExportJobDetail.ApiCall.RestName)"
      }
    }
    $ItemIdOnlyReferenceValues
  }
}
#endregion


#region Function: Get-ODUFilteredExportRestApiCalls

<#
.SYNOPSIS
Returns standard export rest api call info filtered based on user black / white list
.DESCRIPTION
Returns standard export rest api call info filtered based on user black / white list
.EXAMPLE
Get-ODUFilteredExportRestApiCalls
<returns subset of rest api call objects>
#>
function Get-ODUFilteredExportRestApiCalls {
  [CmdletBinding()]
  param()
  process {

    # get users black / white lists
    [object[]]$TypeBlackList = Get-ODUConfigTypeBlacklist
    [object[]]$TypeWhiteList = Get-ODUConfigTypeWhitelist

    # either type whitelist or blacklist should be set - but not both!
    # this shouldn't be possible unless user hand-edit config file
    if (($null -ne $TypeBlackList) -and ($null -ne $TypeWhiteList)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Both Type blacklist and whitelist defined; that's a no no"
      throw 'Type blacklist and type whitelist both have values; this cannot be processed. Check your config values using Get-ODUConfigTypeBlacklist (or ...WhiteList) then set with Set-ODUConfigTypeBlackWhitelist (or ...WhiteList)'
    }

    # get all call info
    [object[]]$ApiCallInfo = Get-ODUStandardExportRestApiCalls
    # filter as necessary
    if ($null -ne $TypeWhiteList -and $TypeWhiteList.Count -gt 0) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Filtering RestApiCalls based on Type whitelist: $TypeWhiteList"
      $ApiCallInfo = $ApiCallInfo | Where-Object { $TypeWhiteList -contains $_.RestName }
    } elseif ($null -ne $TypeBlackList -and $TypeBlackList.Count -gt 0) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Filtering RestApiCalls based on Type blacklist: $TypeBlackList"
      $ApiCallInfo = $ApiCallInfo | Where-Object { $TypeBlackList -notcontains $_.RestName }
    }

    $ApiCallInfo
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
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ApiCall
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
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object[]]$ApiCalls
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


#region Function: New-ODUExportJobInfo

<#
.SYNOPSIS
Create PSObject with necessary info to export data from a single api call
.DESCRIPTION
Create PSObject with necessary info to export data from a single api call
.PARAMETER ServerBaseUrl
Base of the url, typically http/s along with domain name but no trailing /
.PARAMETER ApiKey
ApiKey to use with export
.PARAMETER ApiCall
Api call information
.PARAMETER ParentFolder
Root export folder
.PARAMETER ItemIdOnlyIds
List of Ids to use when creating Url
Used with creating jobs for types that can only be exported via Id
.EXAMPLE
New-ODUExportJobInfo
<...>
#>
function New-ODUExportJobInfo {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerBaseUrl,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ApiCall,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ParentFolder,
    [string[]]$ItemIdOnlyIds
  )
  process {
    # this appears to be the Octo desired default; I won't increase this least it beats up the servers
    [int]$DefaultTake = 30
    [object[]]$ExportJobs = @()

    # create basic hash table now
    $ExportFolder = Join-Path -Path $ParentFolder -ChildPath (Get-ODUFolderNameForApiCall -ApiCall $ApiCall)
    $MainUrl = $ServerBaseUrl + $ApiCall.RestMethod
    $ExportJobBaseSettings = @{
      Url          = $MainUrl
      ApiKey       = $ApiKey
      ExportFolder = $ExportFolder
      ApiCall      = $ApiCall
    }

    # if this is a Simple fetch, create a single job and return
    if ($ApiCall.ApiFetchType -eq $ApiFetchType_Simple) {
      Write-Verbose "$($MyInvocation.MyCommand) :: creating Simple fetch export job for $($ApiCall.RestName)"
      # only one value in Simple call, return base settings
      $ExportJobs += [PSCustomObject]$ExportJobBaseSettings

    } elseif ($ApiCall.ApiFetchType -eq $ApiFetchType_MultiFetch) {
      # it order to create the MultiFetch urls we actually need to call the API first
      # with a Take of 1 (retrieve only 1 record, if it exists) then use the TotalResults
      # to construct the urls
      $RestResults = Invoke-ODURestMethod -Url $MainUrl -ApiKey $ApiKey

      # results might be null if user doesn't have access to that api
      if (($null -ne $RestResults) -and ($null -ne (Get-Member -InputObject $RestResults -Name TotalResults))) {
        $TotalLoops = [math]::Floor($RestResults.TotalResults / $DefaultTake)
        # add extra loop if not perfect division
        if (($RestResults.TotalResults % $DefaultTake) -ne 0) { $TotalLoops += 1 }
        for ($LoopCount = 0; $LoopCount -le ($TotalLoops - 1); $LoopCount++) {
          $Skip = $LoopCount * $DefaultTake
          # clone base settings and update url
          $Clone = $ExportJobBaseSettings.Clone()
          $Clone.Url = $MainUrl + '?skip=' + $Skip + '&take=' + $DefaultTake
          $ExportJobs += [PSCustomObject]$Clone
        }
      } else {
        # this is for TenantVariables, which returns multiple values that should be stored in multiple files
        # BUT, for whatever really dumb reason, Octo API does not provide this info in the standard TotalResults / .Items format
        # so we have this dumb workaround here and in the job processing code
        # add with url as-is; processing code will handle it
        $ExportJobs += [PSCustomObject]$ExportJobBaseSettings
      }
    } elseif ($ApiCall.ApiFetchType -eq $ApiFetchType_ItemIdOnly) {
      $ItemIdOnlyIds | ForEach-Object {
        $Id = $_
        # clone base settings and update url
        $Clone = $ExportJobBaseSettings.Clone()
        $Clone.Url = $MainUrl + '/' + $Id
        $ExportJobs += [PSCustomObject]$Clone
      }
    }
    $ExportJobs
  }
}
#endregion


#region Function: New-ODUFolderForEachApiCall

<#
.SYNOPSIS
Creates a folder for each rest api call in ApiCallInfo under ParentFolder
.DESCRIPTION
Creates a folder for each rest api call in ApiCallInfo under ParentFolder
.PARAMETER ParentFolder
Folder under which to create the new folders
.PARAMETER ApiCalls
Object array of api calls
.EXAMPLE
New-ODUFolderForEachApiCall -ParentFolder c:\Temp -ApiCallInfo <PSObjects with api call info>
#>
function New-ODUFolderForEachApiCall {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ParentFolder,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object[]]$ApiCalls
  )
  process {
    Write-Verbose "$($MyInvocation.MyCommand) :: Parent folder is: $ParentFolder"
    $ApiCalls | ForEach-Object {
      New-ODUExportItemFolder -FolderPath (Join-Path -Path $ParentFolder -ChildPath (Get-ODUFolderNameForApiCall -ApiCall $_))
    }
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
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RestName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ExportItem
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

