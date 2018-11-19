
Set-StrictMode -Version Latest

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
    $Valid = $true
    $TypeName | ForEach-Object {
      if ($_ -notin $ValidTypeNames) {
        $Valid = $false
      }
    }
    $Valid
  }
}
#endregion
