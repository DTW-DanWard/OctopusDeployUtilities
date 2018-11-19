
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
Find-ODUInvalidRestApiTypeName Projects, Variables, asdfasdfasdf
<throws error 'asdfasdfasdf' not valid>
#>
function Find-ODUInvalidRestApiTypeName {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$TypeName
  )
  process {
    $ValidTypeNames = Get-ODURestApiTypeNames
    $TypeName | ForEach-Object {
      if ($_ -notin $ValidTypeNames) {
        throw "Not a valid REST API Type name: $_"
      }
    }
  }
}
#endregion


#region Function: Get-ODURestApiTypeNames

<#
.SYNOPSIS
Returns list of Type names used with Octopus Deploy REST API
.DESCRIPTION
Returns list of Type names used with Octopus Deploy REST API
These are the available Type names that can be used with Type and Property
blacklist and whitelist
.EXAMPLE
Get-ODURestApiTypeNames
Authentication
BuiltInRepository
ExternalSecurityGroups
FeaturesConfiguration
...
#>
function Get-ODURestApiTypeNames {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  process {
    (Get-ODUStandardExportRestApiCalls).RestName | Sort-Object
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
Test-ODUValidateRestApiTypeName Projects, Variables, asdfasdfasdf
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
    $ValidTypeNames = Get-ODURestApiTypeNames
    $null -eq ($TypeName | Where-Object { $_ -notin $ValidTypeNames })
  }
}
#endregion
