
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
  param()
  process {
    (Get-ODUStandardExportRestApiCalls).RestName | Sort-Object
  }
}
