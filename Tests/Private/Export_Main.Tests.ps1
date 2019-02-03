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



#region New export job info
Describe 'new export job info' {

  It 'no parameter throws error' {
    { New-ODUExportJobInfo } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $BadParam2 = $BadParam3 = $BadParam4 = $null; New-ODUExportJobInfo -ServerBaseUrl $BadParam1 -ApiKey $BadParam2 -ApiCall $BadParam3 -ParentFolder $BadParam4 } | Should throw
  }

  It 'new export job info - type simple - creates single job info item' {
    function Get-ODUFolderNameForApiCall { 'Authentication' }
    function Invoke-ODURestMethod { [PSCustomObject]@{ } }

    $ApiCall = [PSCustomObject]@{ RestName = 'Authentication'; RestMethod = '/api/authentication'; ApiFetchType = $ApiFetchType_Simple; FileNamePropertyName = 'NOT_USED' }
    ([object[]](New-ODUExportJobInfo -ServerBaseUrl 'http://SomeServerUrl.com' -ApiKey 'API-1234567890' -ApiCall $ApiCall -ParentFolder $TestDrive)).Count | Should Be 1
  }

  It 'new export job info - type multi - creates 0 job info items' {
    function Get-ODUFolderNameForApiCall { 'Projects' }
    function Invoke-ODURestMethod { [PSCustomObject]@{ TotalResults = 0 } }

    $ApiCall = [PSCustomObject]@{ RestName = 'Projects'; RestMethod = '/api/projects'; ApiFetchType = $ApiFetchType_MultiFetch; FileNamePropertyName = 'Name' }
    New-ODUExportJobInfo -ServerBaseUrl 'http://SomeServerUrl.com' -ApiKey 'API-1234567890' -ApiCall $ApiCall -ParentFolder $TestDrive | Should BeNullOrEmpty
  }

  It 'new export job info - type multi - creates 1 job info item' {
    function Get-ODUFolderNameForApiCall { 'Projects' }
    # assuming DefaultTake of 30, this means 1 job info item
    function Invoke-ODURestMethod { [PSCustomObject]@{ TotalResults = 10 } }

    $ApiCall = [PSCustomObject]@{ RestName = 'Projects'; RestMethod = '/api/projects'; ApiFetchType = $ApiFetchType_MultiFetch; FileNamePropertyName = 'Name' }
    ([object[]](New-ODUExportJobInfo -ServerBaseUrl 'http://SomeServerUrl.com' -ApiKey 'API-1234567890' -ApiCall $ApiCall -ParentFolder $TestDrive)).Count | Should Be 1
  }

  It 'new export job info - type multi - creates multiple job info items' {
    function Get-ODUFolderNameForApiCall { 'Projects' }
    # assuming DefaultTake of 30, this means 3 job info items
    function Invoke-ODURestMethod { [PSCustomObject]@{ TotalResults = 70 } }

    $ApiCall = [PSCustomObject]@{ RestName = 'Projects'; RestMethod = '/api/projects'; ApiFetchType = $ApiFetchType_MultiFetch; FileNamePropertyName = 'Name' }
    (New-ODUExportJobInfo -ServerBaseUrl 'http://SomeServerUrl.com' -ApiKey 'API-1234567890' -ApiCall $ApiCall -ParentFolder $TestDrive).Count | Should Be 3
  }

  It 'new export job info - type multi - no results from Api, one job info item' {
    function Get-ODUFolderNameForApiCall { 'Projects' }
    function Invoke-ODURestMethod { $null }

    $ApiCall = [PSCustomObject]@{ RestName = 'Projects'; RestMethod = '/api/projects'; ApiFetchType = $ApiFetchType_MultiFetch; FileNamePropertyName = 'Name' }
    ([object[]](New-ODUExportJobInfo -ServerBaseUrl 'http://SomeServerUrl.com' -ApiKey 'API-1234567890' -ApiCall $ApiCall -ParentFolder $TestDrive)).Count | Should Be 1
  }

  It 'new export job info - type item id only - no results from Api, one job info item' {
    function Get-ODUFolderNameForApiCall { 'DeploymentProcesses' }
    function Invoke-ODURestMethod { $null }

    [string[]]$IdsToFetch = 1..5
    $ApiCall = [PSCustomObject]@{ RestName = 'DeploymentProcesses'; RestMethod = '/api/deploymentprocesses'; ApiFetchType = $ApiFetchType_ItemIdOnly; FileNamePropertyName = 'Id' }
    (New-ODUExportJobInfo -ServerBaseUrl 'http://SomeServerUrl.com' -ApiKey 'API-1234567890' -ApiCall $ApiCall -ParentFolder $TestDrive -ItemIdOnlyIds $IdsToFetch).Count | Should Be ($IdsToFetch.Count)
  }
}
#endregion
