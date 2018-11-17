
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

    [string]$CurrentExportRootFolder = Join-Path -Path (Get-ODUConfigExportRootFolder) -ChildPath ('{0:yyyyMMdd-HHmmss}' -f (Get-Date))
    New-Item -ItemType Directory -Path $CurrentExportRootFolder > $null

    # get filtered list of api call details to process
    $ApiCallInfo = Get-ODUFilteredExportRestApiCallInfo

    # separate function: loop through all, create folders

    # for ItemIdOnly calls, get create lookup with key of reference property names and value empty array (for capturing values)

    # loop through non-ItemIdOnly calls
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


#region Function: Get-ODUFilteredExportRestApiCallInfo
<#
.SYNOPSIS
Returns standard export rest api call info filtered based on user black / white list
.DESCRIPTION
Returns standard export rest api call info filtered based on user black / white list
.EXAMPLE
Get-ODUFilteredExportRestApiCallInfo
<returns subset of rest api call objects>
#>
function Get-ODUFilteredExportRestApiCallInfo {
  [CmdletBinding()]
  param()
  process {

    # get users black / white lists
    [object[]]$TypeBlackList = Get-ODUConfigTypeBlacklist
    [object[]]$TypeWhiteList = Get-ODUConfigTypeWhitelist

    # either type whitelist or blacklist should be set - but not both!
    # this shouldn't be possible unless user hand-edit config file
    if (($null -ne $TypeBlackList) -and ($null -ne $TypeWhiteList)) {
      throw 'Type blacklist and type whitelist both have values; this cannot be processed. Check your config values using Get-ODUConfigTypeBlacklist (or ...WhiteList) then set with Set-ODUConfigTypeBlackWhitelist (or ...WhiteList)'
    }

    # get all call info
    [object[]]$ApiCallInfo = Get-ODUStandardExportRestApiCallInfo
    # filter as necessary
    if ($null -ne $TypeWhiteList -and $TypeWhiteList.Count -gt 0) {
      $ApiCallInfo = $ApiCallInfo | Where-Object { $TypeWhiteList -contains $_.RestName }
    } elseif ($null -ne $TypeBlackList -and $TypeBlackList.Count -gt 0) {
      $ApiCallInfo = $ApiCallInfo | Where-Object { $TypeBlackList -notcontains $_.RestName }
    }

    $ApiCallInfo
  }
}
#endregion



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
