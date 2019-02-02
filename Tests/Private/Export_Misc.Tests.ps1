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



#region Load OctopusDeployUtilities\Source\Public\Export_OctoApi.ps1 into memory
# it's all hard-coded values needed for processing; not going to just cut & paste hard-code here
$ScriptToLoad = Join-Path -Path $env:BHModulePath -ChildPath 'Source'
$ScriptToLoad = Join-Path -Path $ScriptToLoad -ChildPath 'Public'
$ScriptToLoad = Join-Path -Path $ScriptToLoad -ChildPath 'Export_OctoApi.ps1'
. $ScriptToLoad
#endregion


#region Get export item file name
Describe 'Get export item file name' {

  It 'no parameter throws error' {
    { Get-ODUExportItemFileName } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $BadParam2 = $null; Get-ODUExportItemFileName -ApiCall $BadParam1 -ExportItem $BadParam2 } | Should throw
  }

  It 'simple api type uses rest name' {
    $RestName = 'MyRestName'
    $ApiCall = [PSCustomObject]@{ ApiFetchType = $ApiFetchType_Simple; RestName = $RestName }
    $ExportItem = 'not used'
    Get-ODUExportItemFileName -ApiCall $ApiCall -ExportItem $ExportItem | Should Be $RestName
  }

  It 'non-simple api type with invalid or missing file property name throws error' {
    $RestName = 'MyRestName'
    $ApiCall = [PSCustomObject]@{ ApiFetchType = $ApiFetchType_MultiFetch; RestName = $RestName; FileNamePropertyName = 'C' }
    $ExportItem = [PSCustomObject]@{ Id = 123; A = 1; B = 2 }
    { Get-ODUExportItemFileName -ApiCall $ApiCall -ExportItem $ExportItem } | Should throw
  }

  It 'non-simple api type with valid property name returns value' {
    $RestName = 'MyRestName'
    $ApiCall = [PSCustomObject]@{ ApiFetchType = $ApiFetchType_MultiFetch; RestName = $RestName; FileNamePropertyName = 'C' }
    $C_Value = 3
    $ExportItem = [PSCustomObject]@{ Id = 123; A = 1; B = 2; C = $C_Value }
    Get-ODUExportItemFileName -ApiCall $ApiCall -ExportItem $ExportItem | Should Be $C_Value
  }
}
#endregion


#region Get folder name for Api call
Describe 'Get folder name for Api call' {

  It 'no parameter throws error' {
    { Get-ODUFolderNameForApiCall } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Get-ODUFolderNameForApiCall -ApiCall $BadParam1 } | Should throw
  }

  It 'simple api type returns Miscellaneous folder name' {
    $Miscellaneous = 'Miscellaneous'
    $RestName = 'MyRestName'
    $ApiCall = [PSCustomObject]@{ ApiFetchType = $ApiFetchType_Simple; RestName = $RestName }
    Get-ODUFolderNameForApiCall -ApiCall $ApiCall | Should Be $Miscellaneous
  }

  It 'non-simple api type returns RestName for folder name' {
    $RestName = 'MyRestName'
    $ApiCall = [PSCustomObject]@{ ApiFetchType = $ApiFetchType_MultiFetch; RestName = $RestName }
    Get-ODUFolderNameForApiCall -ApiCall $ApiCall | Should Be $RestName
  }
}
#endregion
