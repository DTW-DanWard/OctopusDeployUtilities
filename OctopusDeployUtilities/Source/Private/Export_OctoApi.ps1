
Set-StrictMode -Version Latest

#region Function: Find-ODUInvalidRestApiTypeName

<#
.SYNOPSIS
For list of Type names, throws error if finds invalid entry, else does nothing
.DESCRIPTION
For list of Type names, throws error if finds invalid entry, else does nothing
.PARAMETER TypeName
Type name to validate
.EXAMPLE
Find-ODUInvalidRestApiTypeName Projects
<does nothing>
Find-ODUInvalidRestApiTypeName Projects, Variables
<does nothing>
Find-ODUInvalidRestApiTypeName Projects, Variables, blahblahblah
<throws error 'blahblahblah' not valid>
#>
function Find-ODUInvalidRestApiTypeName {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [string[]]$TypeName
  )
  process {
    $ValidTypeNames = Get-ODURestApiTypeName
    $TypeName | ForEach-Object {
      if ($_ -notin $ValidTypeNames) {
        throw "Not a valid REST API Type name: $_"
      }
    }
  }
}
#endregion


#region Function: Get-ODUFilteredExportRestApiCall

<#
.SYNOPSIS
Returns standard export rest api call info filtered based on user black / white list
.DESCRIPTION
Returns standard export rest api call info filtered based on user black / white list
.EXAMPLE
Get-ODUFilteredExportRestApiCall
<returns subset of rest api call objects>
#>
function Get-ODUFilteredExportRestApiCall {
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
    [object[]]$ApiCallInfo = Get-ODUStandardExportRestApiCall
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
Helper function for Get-ODUStandardExportRestApiCall
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
    [ValidateNotNullOrEmpty()]
    [string]$RestName = $(throw "$($MyInvocation.MyCommand) : missing parameter RestName"),
    [ValidateNotNullOrEmpty()]
    [string]$RestMethod = $(throw "$($MyInvocation.MyCommand) : missing parameter RestMethod"),
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { $_ -in $ApiFetchTypeList})]
    [string]$ApiFetchType = $(throw "$($MyInvocation.MyCommand) : missing parameter ApiFetchType"),
    [ValidateNotNullOrEmpty()]
    [string]$FileNamePropertyName = $(throw "$($MyInvocation.MyCommand) : missing parameter FileNamePropertyName"),
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


#region Function: Test-ODUValidateRestApiTypeName

<#
.SYNOPSIS
Validates list of values against Type names used with Octopus Deploy REST API
.DESCRIPTION
Validates list of values against Type names used with Octopus Deploy REST API
If all passed values are valid, returns $true, if any one is invalid, returns $false
.PARAMETER TypeName
Type name to validate
.EXAMPLE
Test-ODUValidateRestApiTypeName Projects
$true
Test-ODUValidateRestApiTypeName Projects, Variables
$true
Test-ODUValidateRestApiTypeName Projects, Variables, blahblahblah
$false
#>
function Test-ODUValidateRestApiTypeName {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$TypeName
  )
  process {
    $ValidTypeNames = Get-ODURestApiTypeName
    $null -eq ($TypeName | Where-Object { $_ -notin $ValidTypeNames })
  }
}
#endregion
