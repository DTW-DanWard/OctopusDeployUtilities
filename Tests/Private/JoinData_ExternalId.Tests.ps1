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



#region Id to Name lookup value
Describe 'Id to Name lookup value' {

  BeforeAll {
    $Key = 'ABC'
    $Value = 123
    $script:Lookup = [PSCustomObject]@{ $Key = $Value }
  }

  It 'lookup null returns null' {
    Get-ODUIdToNameLookupValue -Lookup $Lookup -Key $null | Should BeNullOrEmpty
  }

  It 'lookup valid key returns value' {
    Get-ODUIdToNameLookupValue -Lookup $Lookup -Key $Key | Should Be $Value
  }

  It 'lookup invalid key returns <key>_NOT_FOUND' {
    $InvalidKey = 'WillNotFind'
    $NotFoundSuffix = '_NOT_FOUND'
    Get-ODUIdToNameLookupValue -Lookup $Lookup -Key $InvalidKey | Should Be ($InvalidKey + $NotFoundSuffix)
  }
}
#endregion
