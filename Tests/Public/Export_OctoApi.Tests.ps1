Set-StrictMode -Version Latest

#region Set module/script-level variables
$ScriptLevelVariables = Join-Path -Path $env:BHModulePath -ChildPath 'Set-ScriptLevelVariables.ps1'
. $ScriptLevelVariables
#endregion

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion



#region Function: New-ODUExportRestApiCall
# Quickly create PSObject with values; simplified version used for testing. No validation of parameters, etc.
function New-ODUExportRestApiCall {
  param(
    [string]$RestName,
    [string]$RestMethod,
    [string]$ApiFetchType,
    [string]$FileNamePropertyName,
    [string]$IdToNamePropertyName = 'Name',
    [string[]]$ExternalIdToResolvePropertyName,
    [string]$ItemIdOnlyReferencePropertyName
  )
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
#endregion


#region get rest api type names
Describe 'get rest api type names' {

  It 'names are returned' {
    (Get-ODURestApiTypeName).Count | Should BeGreaterThan 0
  }

  It 'known names are found in results' {
    [string[]]$ApiTypeNames = Get-ODURestApiTypeName
    $ApiTypeNames -contains 'Authentication' | Should Be $true
    $ApiTypeNames -contains 'Projects' | Should Be $true
    $ApiTypeNames -contains 'Teams' | Should Be $true
  }

  It 'unknown names are not found in results' {
    [string[]]$ApiTypeNames = Get-ODURestApiTypeName
    $ApiTypeNames -contains 'JunkValue1' | Should Be $false
    $ApiTypeNames -contains 'JunkValue2' | Should Be $false
  }
}
#endregion


#region get rest api call info
Describe 'get rest api call info' {

  It 'api call details are returned' {
    (Get-ODUStandardExportRestApiCall).Count | Should BeGreaterThan 0
  }

  It 'known api calls are found in results' {
    [object[]]$ApiCalls = Get-ODUStandardExportRestApiCall
    $ApiCalls.RestName -contains 'Authentication' | Should Be $true
    $ApiCalls.RestName -contains 'Projects' | Should Be $true
    $ApiCalls.RestName -contains 'Teams' | Should Be $true
  }

  It 'unknown api calls are not found in results' {
    [object[]]$ApiCalls = Get-ODUStandardExportRestApiCall
    $ApiCalls.RestName -contains 'JunkValue1' | Should Be $false
    $ApiCalls.RestName -contains 'JunkValue2' | Should Be $false
  }
}
#endregion
