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


#region Get config type blacklist
Describe 'get config type blacklist' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUConfigTypeBlacklist | Should BeNullOrEmpty
  }

  It 'Octo server not configured yet returns null' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigOctopusServer { $null }
    Get-ODUConfigTypeBlacklist | Should BeNullOrEmpty
  }


  It 'Octo server configured returns values' {
    function Confirm-ODUConfig { $true }
    $Values = @('Val1','Val2')
    function Get-ODUConfigOctopusServer { @{ TypeBlacklist = $Values } }
    Compare-Object -ReferenceObject (Get-ODUConfigTypeBlacklist) -DifferenceObject $Values | Should BeNullOrEmpty
  }
}
#endregion


#region Get config type whitelist
Describe 'get config type whitelist' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUConfigTypeWhitelist | Should BeNullOrEmpty
  }

  It 'Octo server not configured yet returns null' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigOctopusServer { $null }
    Get-ODUConfigTypeWhitelist | Should BeNullOrEmpty
  }


  It 'Octo server configured returns values' {
    function Confirm-ODUConfig { $true }
    $Values = @('Val1','Val2')
    function Get-ODUConfigOctopusServer { @{ TypeWhitelist = $Values } }
    Compare-Object -ReferenceObject (Get-ODUConfigTypeWhitelist) -DifferenceObject $Values | Should BeNullOrEmpty
  }
}
#endregion


#region Set config type blacklist
Describe 'set config type blacklist' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Set-ODUConfigTypeBlacklist | Should BeNullOrEmpty
  }

  It 'invalid type name param throws error' {
    function Confirm-ODUConfig { $true }
    function Find-ODUInvalidRestApiTypeName { throw 'Not a valid type name' }
    { Set-ODUConfigTypeBlacklist -TypeName @('Not','Valid') } | Should throw
  }

  It 'Octo server not configured yet returns null' {
    function Confirm-ODUConfig { $true }
    function Find-ODUInvalidRestApiTypeName { $null }
    function Get-ODUConfigOctopusServer { $null }
    { Set-ODUConfigTypeBlacklist -TypeName @('Not','Valid') } | Should throw
  }

  It 'valid values works' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigOctopusServer { 'something not null' }
    function Find-ODUInvalidRestApiTypeName { $null }
    $Values = @('Val1','Val2')
    function Get-ODUConfig {
      $OctopusServer = @{ TypeBlacklist = @(); TypeWhitelist = @();  }
      [object[]]$OctopusServers = @($OctopusServer)
      @{ OctopusServers = $OctopusServers }
    }
    function Save-ODUConfig { param([hashtable]$Config) }
    Mock 'Save-ODUConfig'
    $Config = Get-ODUConfig

    Set-ODUConfigTypeBlacklist -TypeName $Values

    # blacklist should be set
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.OctopusServers[0].TypeBlacklist.Count -eq $Values.Count }
    # whitelist should be reset
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.OctopusServers[0].TypeWhitelist.Count -eq 0 }
  }
}
#endregion


#region Set config type whitelist
Describe 'set config type whitelist' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Set-ODUConfigTypeWhitelist | Should BeNullOrEmpty
  }

  It 'invalid type name param throws error' {
    function Confirm-ODUConfig { $true }
    function Find-ODUInvalidRestApiTypeName { throw 'Not a valid type name' }
    { Set-ODUConfigTypeWhitelist -TypeName @('Not','Valid') } | Should throw
  }

  It 'Octo server not configured yet returns null' {
    function Confirm-ODUConfig { $true }
    function Find-ODUInvalidRestApiTypeName { $null }
    function Get-ODUConfigOctopusServer { $null }
    { Set-ODUConfigTypeWhitelist -TypeName @('Not','Valid') } | Should throw
  }

  It 'valid values works' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigOctopusServer { 'something not null' }
    function Find-ODUInvalidRestApiTypeName { $null }
    $Values = @('Val1','Val2')
    function Get-ODUConfig {
      $OctopusServer = @{ TypeBlacklist = @(); TypeWhitelist = @();  }
      [object[]]$OctopusServers = @($OctopusServer)
      @{ OctopusServers = $OctopusServers }
    }
    function Save-ODUConfig { param([hashtable]$Config) }
    Mock 'Save-ODUConfig'
    $Config = Get-ODUConfig

    Set-ODUConfigTypeWhitelist -TypeName $Values

    # whitelist should be set
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.OctopusServers[0].TypeWhitelist.Count -eq $Values.Count }
    # blacklist should be reset
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.OctopusServers[0].TypeBlacklist.Count -eq 0 }
  }
}
#endregion
