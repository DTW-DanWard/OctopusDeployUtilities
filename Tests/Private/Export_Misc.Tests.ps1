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


#region Get initialized item id only ids lookup
Describe 'get initialized item id only ids lookup' {

  It 'no parameter throws error' {
    { Initialize-ODUFetchTypeItemIdOnlyIdsLookup } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Initialize-ODUFetchTypeItemIdOnlyIdsLookup -ApiCalls $BadParam1 } | Should throw
  }

  It 'ApiCalls with ItemIdOnlyReferencePropertyName values hashtable with empty array' {
    $PropertyName = 'DeploymentProcessId'
    [object[]]$ApiCalls = @(([PSCustomObject]@{ ApiFetchType = $ApiFetchType_Simple; RestName = '1'; ItemIdOnlyReferencePropertyName = $PropertyName }),
      ([PSCustomObject]@{ ApiFetchType = $ApiFetchType_Simple; RestName = '2'; ItemIdOnlyReferencePropertyName = '' }))
    (Initialize-ODUFetchTypeItemIdOnlyIdsLookup -ApiCalls $ApiCalls).$PropertyName.Count | Should Be 0
  }
}
#endregion


#region Remove filter properties from export item
Describe 'remove filter properties from export item' {

  It 'no parameter throws error' {
    { Remove-ODUFilterPropertiesFromExportItem } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Remove-ODUFilterPropertiesFromExportItem -RestName $BadParam1 -ExportItem BadParam2 } | Should throw
  }

  It 'filter properties - blacklist test' {
    function Get-ODUConfigPropertyWhiteList { @{} }
    function Get-ODUConfigPropertyBlackList { @{ Type1 = @('A'); Type2 = @('B', 'C') } }

    $ExportItem = [PSCustomObject]@{ A = 1; B = 2; C = 3; D = 4; E = 5 }
    $Results = Remove-ODUFilterPropertiesFromExportItem -RestName 'Type1' -ExportItem $ExportItem
    $Results | Get-Member -Name A | Should BeNullOrEmpty
    $Results | Get-Member -Name B | Should Not BeNullOrEmpty
    $Results | Get-Member -Name C | Should Not BeNullOrEmpty
    $Results | Get-Member -Name D | Should Not BeNullOrEmpty
    $Results | Get-Member -Name E | Should Not BeNullOrEmpty

    $Results = Remove-ODUFilterPropertiesFromExportItem -RestName 'Type2' -ExportItem $ExportItem
    $Results | Get-Member -Name A | Should Not BeNullOrEmpty
    $Results | Get-Member -Name B | Should BeNullOrEmpty
    $Results | Get-Member -Name C | Should BeNullOrEmpty
    $Results | Get-Member -Name D | Should Not BeNullOrEmpty
    $Results | Get-Member -Name E | Should Not BeNullOrEmpty
  }

  It 'filter properties - white test' {
    function Get-ODUConfigPropertyWhiteList { @{ Type1 = @('A'); Type2 = @('B', 'C') } }
    function Get-ODUConfigPropertyBlackList { @{} }

    $ExportItem = [PSCustomObject]@{ A = 1; B = 2; C = 3; D = 4; E = 5 }

    $Results = Remove-ODUFilterPropertiesFromExportItem -RestName 'Type1' -ExportItem $ExportItem
    $Results | Get-Member -Name A | Should Not BeNullOrEmpty
    $Results | Get-Member -Name B | Should BeNullOrEmpty
    $Results | Get-Member -Name C | Should BeNullOrEmpty
    $Results | Get-Member -Name D | Should BeNullOrEmpty
    $Results | Get-Member -Name E | Should BeNullOrEmpty

    $Results = Remove-ODUFilterPropertiesFromExportItem -RestName 'Type2' -ExportItem $ExportItem
    $Results | Get-Member -Name A | Should BeNullOrEmpty
    $Results | Get-Member -Name B | Should Not BeNullOrEmpty
    $Results | Get-Member -Name C | Should Not BeNullOrEmpty
    $Results | Get-Member -Name D | Should BeNullOrEmpty
    $Results | Get-Member -Name E | Should BeNullOrEmpty
  }
}
#endregion
