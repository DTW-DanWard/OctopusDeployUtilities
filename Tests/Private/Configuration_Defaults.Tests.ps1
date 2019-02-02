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



#region Get config default type blacklist
Describe 'Get config default type blacklist' {

  BeforeAll { $script:List = Get-ODUConfigDefaultTypeBlacklist }

  It 'contains expected values' {
    $List -contains 'Deployments' | Should Be $true
    $List -contains 'Events' | Should Be $true
    $List -contains 'Packages' | Should Be $true
    $List -contains 'Tasks' | Should Be $true
  }

  It 'does not contain unexpected values' {
    $List -contains 'DeploymentProcesses' | Should Be $false
    $List -contains 'Projects' | Should Be $false
    $List -contains 'Variables' | Should Be $false
    $List -contains 'Users' | Should Be $false
  }
}
#endregion


#region Get config default type whitelist
Describe 'Get config default type whitelist' {

  BeforeAll { $script:List = Get-ODUConfigDefaultTypeWhitelist }

  It 'does not contain any values' {
    $List.Count | Should Be 0
  }
}
#endregion


#region Get config default property blacklist
Describe 'Get config default property blacklist' {

  BeforeAll { $script:List = Get-ODUConfigDefaultPropertyBlacklist }

  It 'contains several entries' {
    $List.Keys.Count | Should BeGreaterThan 0
  }

  It 'contains entry for Variables with one value ScopeValues' {
    $List.Variables[0] | Should Be 'ScopeValues'
  }
}
#endregion


#region Get config default property whitelist
Describe 'Get config default property whitelist' {

  BeforeAll { $script:List = Get-ODUConfigDefaultPropertyWhitelist }

  It 'does not contain any values' {
    $List.Keys.Count | Should Be 0
  }
}
#endregion

