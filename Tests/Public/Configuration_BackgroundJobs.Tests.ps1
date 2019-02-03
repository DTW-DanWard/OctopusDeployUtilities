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
    # validation on set method is int between 0 - 9
    function Get-ODUConfigBackgroundJobsMax { [PSCustomObject]@{ BackgroundJobsMax = (Get-Random -Minimum 1 -Maximum 9) } }
    $Value = (Get-ODUConfigBackgroundJobsMax).BackgroundJobsMax
    $Value | Should BeOfType [int]
    $Value | Should BeGreaterThan 0
    $Value | Should BeLessThan 10
  }
}
#endregion