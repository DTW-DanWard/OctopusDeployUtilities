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


#region Format sanitize file name
# Whitelisted characters: a-z 0-9 space dash
# Multiple spaces replaced with single space
# Value trimmed as well
Describe 'Format sanitize file name' {

  It 'throws error if no file name' {
    { Format-ODUSanitizeFileName } | Should throw
  }

  It 'throws error if empty file name' {
    { Format-ODUSanitizeFileName -FileName '   ' } | Should throw
  }

  It 'valid values are not modified' {
    Format-ODUSanitizeFileName -FileName 'A1 - B2 - C3' | Should Be 'A1 - B2 - C3'
  }

  It 'multiple spaces in a row are replaced with single space' {
    Format-ODUSanitizeFileName -FileName 'A1 -   B2      - C3' | Should Be 'A1 - B2 - C3'
  }

  It 'characters other than a-z 0-9 space dash are removed' {
    Format-ODUSanitizeFileName -FileName 'A#1% -&*() B2!@# - C3' | Should Be 'A1 - B2 - C3'
  }

  It 'values with nothing but bad characters throws error ' {
    { Format-ODUSanitizeFileName -FileName '  #% &*() !@#  #$@    %^  ' } | Should throw
  }

  It 'prefix/suffix spaces are trimmed' {
    Format-ODUSanitizeFileName -FileName '  A1 - B2 - C3  ' | Should Be 'A1 - B2 - C3'
  }
}
#endregion
