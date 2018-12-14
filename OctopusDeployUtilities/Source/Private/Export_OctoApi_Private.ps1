
Set-StrictMode -Version Latest

#region Description of REST API call properties
<#
These names are not pretty but they have been named so as to (hopefully) be not confusing:
RestName                          name of REST API call (Accounts, Projects, etc.), used in display and
                                  type/property white/black lists
RestMethod                        relative api call to use (/api/accounts, /api/projects)
ApiFetchType                      type of fetch: Simple, MultiFetch or ItemIdOnly
FileNamePropertyName              when saving the item just fetched from server, this value is the name of
                                  a property on the item that will be unique and is best to use for the file name
                                     for Simple fetches, this will be 'NOT_USED" as the RestName is ultimately used
                                     for all others it will be either the item Id or Name property
IdToNamePropertyName              name of property on the item to use for Id -> name lookups; when you want
                                  to resolve "Projects-18" to it's proper name of "AuthorizationServer"
                                  this is the name of the property to use to provide the proper name
                                  most of the time this is the Name property but there are a few exceptions
ExternalIdToResolvePropertyName   for an item, these are the names of properties that reference an external item
                                  we will look up these id values and get the proper names for the items
ItemIdOnlyReferencePropertyName   for items fetched by ItemIdOnly, this is the name of the id property used by the other
                                  items to refer to this item
                                  for example, Variables is fetched by ItemIdOnly and other items refer to it by
                                  a local property (in those other items) named VariableSetId
#>
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




#region Function: New-ODUExportRestApiCall

<#
.SYNOPSIS
Creates single PSObject with Octopus Deploy REST API call information
.DESCRIPTION
Creates single PSObject with Octopus Deploy REST API call information
Helper function for Get-ODUStandardExportRestApiCalls
.PARAMETER RestName
Proper name of REST method
.PARAMETER RestMethod
REST API call
.PARAMETER ApiFetchType
Item fetch type
.PARAMETER FileNamePropertyName
Property name to use when saving file
.PARAMETER IdToNamePropertyName
Property name to use for Name value in Id -> Name lookup
.PARAMETER ExternalIdToResolvePropertyName
Property name containing external item references
.PARAMETER ItemIdOnlyReferencePropertyName
For items referenced/fetched by ItemIdOnly, the name of the property
.EXAMPLE
New-ODUExportRestApiCall 'Artifacts' '/api/artifacts' 'MultiFetch' 'Id'
<creates and returns PSObject with Artifacts info>
#>
function New-ODUExportRestApiCall {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RestName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RestMethod,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { $_ -in $ApiFetchTypeList})]
    [string]$ApiFetchType,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FileNamePropertyName,
    [string]$IdToNamePropertyName = 'Name',
    [string[]]$ExternalIdToResolvePropertyName,
    [string]$ItemIdOnlyReferencePropertyName
  )
  process {
    [PSCustomObject]@{
      RestName                        = $RestName
      RestMethod                      = $RestMethod
      ApiFetchType                    = $ApiFetchType
      FileNamePropertyName            = $FileNamePropertyName
      IdToNamePropertyName            = $IdToNamePropertyName
      ExternalIdToResolvePropertyName = $ExternalIdToResolvePropertyName
      ItemIdOnlyReferencePropertyName = $ItemIdOnlyReferencePropertyName
    }
  }
}
#endregion
