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


#region Add or update member
Describe 'Add or update member' {

  It 'no parameters throws error' {
    { Add-ODUOrUpdateMember } | Should throw
  }

  It 'null parameters throws error' {
    { $BadParam1 = $BadParam2 = $null; Add-ODUOrUpdateMember -InputObject $BadParam1 -PropertyName $BadParam2 } | Should throw
  }

  It 'pre-existing value gets updated' {
    $PropertyName1 = 'Prop1'
    $Value1 = 5
    $Object = [PSCustomObject]@{ $PropertyName1 = $Value1 }
    $NewValue1 = 10
    Add-ODUOrUpdateMember -InputObject $Object -PropertyName $PropertyName1 -Value $NewValue1
    $Object.$PropertyName1 | Should Be $NewValue1
  }

  It 'non-existing value gets added' {
    $PropertyName1 = 'Prop1'
    $Value1 = 5
    $Object = [PSCustomObject]@{ $PropertyName1 = $Value1 }
    $PropertyName2 = 'Prop2'
    $Value2 = 30
    Add-ODUOrUpdateMember -InputObject $Object -PropertyName $PropertyName2 -Value $Value2
    $Object.$PropertyName2 | Should Be $Value2
  }
}
