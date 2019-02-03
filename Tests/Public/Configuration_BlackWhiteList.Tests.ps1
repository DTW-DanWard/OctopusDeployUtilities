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



#region Get config property blacklist
Describe 'get config property blacklist' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUConfigPropertyBlacklist | Should BeNullOrEmpty
  }

  It 'Octo server not configured yet returns null' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigOctopusServer { $null }
    Get-ODUConfigPropertyBlacklist | Should BeNullOrEmpty
  }


  It 'Octo server configured returns values' {
    function Confirm-ODUConfig { $true }
    $Values = @('Val1','Val2')
    function Get-ODUConfigOctopusServer { @{ PropertyBlacklist = $Values } }
    Compare-Object -ReferenceObject (Get-ODUConfigPropertyBlacklist) -DifferenceObject $Values | Should BeNullOrEmpty
  }
}
#endregion


#region Get config property whitelist
Describe 'get config property whitelist' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUConfigPropertyWhitelist | Should BeNullOrEmpty
  }

  It 'Octo server not configured yet returns null' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigOctopusServer { $null }
    Get-ODUConfigPropertyWhitelist | Should BeNullOrEmpty
  }


  It 'Octo server configured returns values' {
    function Confirm-ODUConfig { $true }
    $Values = @('Val1','Val2')
    function Get-ODUConfigOctopusServer { @{ PropertyWhitelist = $Values } }
    Compare-Object -ReferenceObject (Get-ODUConfigPropertyWhitelist) -DifferenceObject $Values | Should BeNullOrEmpty
  }
}
#endregion
