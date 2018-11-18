
Set-StrictMode -Version Latest


#region Function: Export-ODUOctopusDeployConfigPrivate

<#
.SYNOPSIS
asdf Main function controlling export process
.DESCRIPTION
asdf Main function controlling export process
.EXAMPLE
Export-ODUOctopusDeployConfigPrivate
<asdf lots of notes needed here>
#>
function Export-ODUOctopusDeployConfigPrivate {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    # root folder was tested/created when initially set; unless user manually modified the config these will always work
    [string]$CurrentExportRootFolder = Join-Path -Path (Get-ODUConfigExportRootFolder) -ChildPath ('{0:yyyyMMdd-HHmmss}' -f (Get-Date))
    Write-Verbose "$($MyInvocation.MyCommand) :: Create root folder: $CurrentExportRootFolder"
    New-Item -ItemType Directory -Path $CurrentExportRootFolder > $null

    # get filtered list of api call details to process
    $ApiCalls = Get-ODUFilteredExportRestApiCalls
    # create folders for each api call
    Write-Verbose "$($MyInvocation.MyCommand) :: Creating folder for api calls"
    New-ODUFolderForEachApiCall -ParentFolder $CurrentExportRootFolder -ApiCalls $ApiCalls

    # for ItemIdOnly calls, get create lookup with key of reference property names and value empty array (for capturing values)
    [hashtable]$ItemIdOnlyIdsLookup = Initialize-ODUFetchTypeItemIdOnlyIdsLookup -ApiCalls ($ApiCalls | Where-Object { $_.ApiFetchType -eq $ApiFetchType_ItemIdOnly })

    # loop through non-ItemIdOnly calls
    $ApiCalls | Where-Object { $_.ApiFetchType -ne $ApiFetchType_ItemIdOnly } | ForEach-Object {


    }

    # get folder name
    # generate export info object

    # create array of export info:
    #   simple calls, one object
    #   multicall, lookup take 1 and return 0 or more objects

    # export info:
    #  full folder path
    #  ApiCallInfo
    #  full url

    # in export process
    #   make rest call
    #   get ItemIdOnly lookup info from this item
    #   determine file name
    #   save contents to file (filtering if necessary)
    #  *return ItemIdOnly lookup info

    # loop through ItemIdCalls
    # generate export info object
    # run export process



    # return path to this export
    $CurrentExportRootFolder
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
asdf update this
asdf update this
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
      New-ODUIExportItemFolder -FolderPath (Join-Path -Path $ParentFolder -ChildPath (Get-ODUFolderNameForApiCall -ApiCall $_))
    }
  }

}
#endregion


#region Function: xxx-ODUxxx

<#
.SYNOPSIS
asdf update this
.DESCRIPTION
asdf update this
.EXAMPLE
asdf update this
asdf update this
#>
function xxx-ODUxxx {
  [CmdletBinding()]
  param()
  process {


  }

}
#endregion