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


#region new export rest api call
Describe 'new export rest api call' {

  It 'no parameter throws error' {
    { New-ODUExportRestApiCall } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $BadParam2 = $BadParam3 = $BadParam4 = $null; New-ODUExportRestApiCall -RestName $BadParam1 -RestMethod $BadParam2 -ApiFetchType $BadParam3 -FileNamePropertyName $BadParam4 } | Should throw
  }

  It 'invalid ApiFetchType throws error' {
    { New-ODUExportRestApiCall -RestName 'value1' -RestMethod 'value2' -ApiFetchType 'value3' -FileNamePropertyName 'value4' } | Should throw
  }

  It 'valid data returns object - required params' {
    $RestName = 'value1'
    $RestMethod = 'value2'
    $ApiFetchType = 'Simple' # must be a value in ApiFetchTypeList
    $FileNamePropertyName = 'value4'

    $Object = New-ODUExportRestApiCall -RestName $RestName -RestMethod $RestMethod -ApiFetchType $ApiFetchType -FileNamePropertyName $FileNamePropertyName
    $Object | Should Not BeNullOrEmpty
    $Object.RestName | Should Be $RestName
    $Object.RestMethod | Should Be $RestMethod
    $Object.ApiFetchType | Should Be $ApiFetchType
    $Object.FileNamePropertyName | Should Be $FileNamePropertyName
  }

  It 'valid data returns object - required & optional params' {
    $RestName = 'value1'
    $RestMethod = 'value2'
    $ApiFetchType = 'Simple' # must be a value in ApiFetchTypeList
    $FileNamePropertyName = 'value4'
    $IdToNamePropertyName = 'Name1'
    $ExternalIdToResolvePropertyName = @('A','B','C')
    $ItemIdOnlyReferencePropertyName = 'Name2'

    $Object = New-ODUExportRestApiCall -RestName $RestName -RestMethod $RestMethod -ApiFetchType $ApiFetchType -FileNamePropertyName $FileNamePropertyName `
     -IdToNamePropertyName $IdToNamePropertyName -ExternalIdToResolvePropertyName $ExternalIdToResolvePropertyName -ItemIdOnlyReferencePropertyName $ItemIdOnlyReferencePropertyName
    $Object | Should Not BeNullOrEmpty
    $Object.RestName | Should Be $RestName
    $Object.RestMethod | Should Be $RestMethod
    $Object.ApiFetchType | Should Be $ApiFetchType
    $Object.FileNamePropertyName | Should Be $FileNamePropertyName
    $Object.IdToNamePropertyName | Should Be $IdToNamePropertyName
    $Object.ExternalIdToResolvePropertyName | Should Be $ExternalIdToResolvePropertyName
    $Object.ItemIdOnlyReferencePropertyName | Should Be $ItemIdOnlyReferencePropertyName
  }

}
#endregion
