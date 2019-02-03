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



#region Get config background jobs max
Describe 'get config background jobs max' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUConfigBackgroundJobsMax | Should BeNullOrEmpty
  }

  It 'returns an int betweeen 1 - 9' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfig { @{ BackgroundJobsMax = (Get-Random -Minimum 1 -Maximum 9) } }
    $Value = Get-ODUConfigBackgroundJobsMax
    $Value | Should BeOfType [int]
    $Value | Should BeIn (1..9)
  }
}
#endregion


#region Set config background jobs max
Describe 'set config background jobs max' {

  It 'no parameter throws error' {
    { Set-ODUConfigBackgroundJobsMax } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Set-ODUConfigBackgroundJobsMax -BackgroundJobsMax $BadParam1 } | Should throw
  }

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Set-ODUConfigBackgroundJobsMax -BackgroundJobsMax (Get-Random -Minimum 1 -Maximum 9) | Should BeNullOrEmpty
  }

  It 'non-int parameter throws error' {
    function Confirm-ODUConfig { $true }
    { Set-ODUConfigBackgroundJobsMax -BackgroundJobsMax 'W' } | Should throw
  }

  It 'int less than 1 throws error' {
    function Confirm-ODUConfig { $true }
    { Set-ODUConfigBackgroundJobsMax -BackgroundJobsMax 0 } | Should throw
  }

  It 'int greater than 9 range throws error' {
    function Confirm-ODUConfig { $true }
    { Set-ODUConfigBackgroundJobsMax -BackgroundJobsMax 10 } | Should throw
  }

  It 'int betweeen 1 - 9 works' {
    function Confirm-ODUConfig { $true }
    # validation on set method is int between 0 - 9
    function Get-ODUConfig { @{ BackgroundJobsMax = (Get-Random -Minimum 1 -Maximum 9) } }
    function Save-ODUConfig { param([hashtable]$Config) }
    Mock 'Save-ODUConfig'
    $Config = Get-ODUConfig
    $Value = Get-Random -Minimum 1 -Maximum 9
    Set-ODUConfigBackgroundJobsMax -BackgroundJobsMax $Value
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.BackgroundJobsMax -eq $Value }
  }
}
#endregion
