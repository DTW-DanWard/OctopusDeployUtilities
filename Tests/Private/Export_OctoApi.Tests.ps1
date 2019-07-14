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


#region Find invalid rest api type name
Describe 'find invalid rest api type name' {

  BeforeAll {
    $GoodValue1 = 'GoodValue1'
    $GoodValue2 = 'GoodValue2'
    $GoodValue3 = 'GoodValue3'
    function Get-ODURestApiTypeName { @($GoodValue1, $GoodValue2, $GoodValue3) }
  }

  It 'single bad value throws error' {
    { Find-ODUInvalidRestApiTypeName -TypeName 'BadValue' } | Should throw
  }

  It 'multiple bad values throws error' {
    { Find-ODUInvalidRestApiTypeName -TypeName @('BadValue1', 'BadValue2') } | Should throw
  }

  It 'bad value with good values throws error' {
    { Find-ODUInvalidRestApiTypeName -TypeName @('BadValue1', $GoodValue1, $GoodValue1) } | Should throw
  }

  It 'single good value does not throw error' {
    { Find-ODUInvalidRestApiTypeName -TypeName $GoodValue1 } | Should Not throw
  }

  It 'multiple good values does not throw error' {
    { Find-ODUInvalidRestApiTypeName -TypeName @($GoodValue1, $GoodValue2) } | Should Not throw
  }
}
#endregion


#region Get filtered export rest api call
Describe 'get filtered export rest api call' {

  Context 'both blacklist and whitelist have values throws error' {

    BeforeAll {
      function Get-ODUConfigTypeBlacklist { 'value1' }
      function Get-ODUConfigTypeWhitelist { 'value2' }
    }

    It 'both blacklist and whitelist have values throws error' {
      { Get-ODUFilteredExportRestApiCall } | Should throw
    }
  }

  Context 'filtered list does not contain blacklist items' {

    BeforeAll {
      $BlackList1 = 'Authentication'
      $BlackList2 = 'ExternalSecurityGroups'
      function Get-ODUConfigTypeBlacklist { @($BlackList1, $BlackList2) }
      function Get-ODUConfigTypeWhitelist { }
    }

    It 'filtered list does not contain blacklist items' {
      $FilteredObjects = Get-ODUFilteredExportRestApiCall
      $FilteredObjects.RestName -notcontains $BlackList1 | Should Be $true
      $FilteredObjects.RestName -notcontains $BlackList2 | Should Be $true
    }
  }

  Context 'filtered list only contains whitelist items' {

    BeforeAll {
      $WhiteList1 = 'Authentication'
      $WhiteList2 = 'ExternalSecurityGroups'
      function Get-ODUConfigTypeBlacklist { }
      function Get-ODUConfigTypeWhitelist { @($WhiteList1, $WhiteList2) }
    }

    It 'filtered list only contains whitelist items' {
      $FilteredObjects = Get-ODUFilteredExportRestApiCall
      $FilteredObjects.RestName -contains $WhiteList1 | Should Be $true
      $FilteredObjects.RestName -contains $WhiteList2 | Should Be $true
      $FilteredObjects.Count | Should Be 2
    }
  }

  Context 'unfiltered list has original items' {

    BeforeAll {
      $script:AllRestApiCalls = Get-ODUStandardExportRestApiCall
      function Get-ODUConfigTypeBlacklist { }
      function Get-ODUConfigTypeWhitelist { }
    }

    It 'filtered list does not contain blacklist items' {
      $FilteredObjects = Get-ODUFilteredExportRestApiCall
      $FilteredObjects.Count | Should Be $AllRestApiCalls.Count
      Compare-Object -ReferenceObject ($FilteredObjects.RestName) -DifferenceObject ($AllRestApiCalls.RestName) | Should BeNullOrEmpty
    }
  }
}
#endregion


#region new export rest api call
Describe 'new export rest api call' {

  It 'no parameter throws error' {
    { New-ODUExportRestApiCall } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $BadParam2 = $BadParam3 = $BadParam4 = $null; New-ODUExportRestApiCall -RestName $BadParam1 -RestMethod $BadParam2 -ApiFetchType $BadParam3 -FileNamePropertyName $BadParam4 } | Should throw
  }

  It 'invalid ApiFetchType throws error' {
    { New-ODUExportRestApiCall -RestName 'value1' -RestMethod 'value2' -ApiFetchType 'value3' -FileNamePropertyName 'value4' } | Should throw
  }

  It 'valid data returns object - required params' {
    $RestName = 'value1'
    $RestMethod = 'value2'
    $ApiFetchType = 'Simple' # must be a value in ApiFetchTypeList
    $FileNamePropertyName = 'value4'

    $Object = New-ODUExportRestApiCall -RestName $RestName -RestMethod $RestMethod -ApiFetchType $ApiFetchType -FileNamePropertyName $FileNamePropertyName
    $Object | Should Not BeNullOrEmpty
    $Object.RestName | Should Be $RestName
    $Object.RestMethod | Should Be $RestMethod
    $Object.ApiFetchType | Should Be $ApiFetchType
    $Object.FileNamePropertyName | Should Be $FileNamePropertyName
  }

  It 'valid data returns object - required & optional params' {
    $RestName = 'value1'
    $RestMethod = 'value2'
    $ApiFetchType = 'Simple' # must be a value in ApiFetchTypeList
    $FileNamePropertyName = 'value4'
    $IdToNamePropertyName = 'Name1'
    $ExternalIdToResolvePropertyName = @('A', 'B', 'C')
    $ItemIdOnlyReferencePropertyName = 'Name2'

    $Object = New-ODUExportRestApiCall -RestName $RestName -RestMethod $RestMethod -ApiFetchType $ApiFetchType -FileNamePropertyName $FileNamePropertyName `
      -IdToNamePropertyName $IdToNamePropertyName -ExternalIdToResolvePropertyName $ExternalIdToResolvePropertyName -ItemIdOnlyReferencePropertyName $ItemIdOnlyReferencePropertyName
    $Object | Should Not BeNullOrEmpty
    $Object.RestName | Should Be $RestName
    $Object.RestMethod | Should Be $RestMethod
    $Object.ApiFetchType | Should Be $ApiFetchType
    $Object.FileNamePropertyName | Should Be $FileNamePropertyName
    $Object.IdToNamePropertyName | Should Be $IdToNamePropertyName
    $Object.ExternalIdToResolvePropertyName | Should Be $ExternalIdToResolvePropertyName
    $Object.ItemIdOnlyReferencePropertyName | Should Be $ItemIdOnlyReferencePropertyName
  }
}
#endregion


#region Test validate rest api type name
Describe 'Test validate rest api type name' {

  BeforeAll {
    $GoodValue1 = 'GoodValue1'
    $GoodValue2 = 'GoodValue2'
    $GoodValue3 = 'GoodValue3'
    function Get-ODURestApiTypeName { @($GoodValue1, $GoodValue2, $GoodValue3) }
  }

  It 'no parameter throws error' {
    { Test-ODUValidateRestApiTypeName } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Test-ODUValidateRestApiTypeName -TypeName $BadParam1 } | Should throw
  }

  It 'single bad value returns false' {
    Test-ODUValidateRestApiTypeName -TypeName 'BadValue' | Should Be $false
  }

  It 'multiple bad values returns false' {
    Test-ODUValidateRestApiTypeName -TypeName @('BadValue1', 'BadValue2') | Should Be $false
  }

  It 'bad value with good values returns false' {
    Test-ODUValidateRestApiTypeName -TypeName @('BadValue1', $GoodValue1, $GoodValue1) | Should Be $false
  }

  It 'single good value returns true' {
    Test-ODUValidateRestApiTypeName -TypeName $GoodValue1 | Should Be $true
  }

  It 'multiple good values returns true' {
    Test-ODUValidateRestApiTypeName -TypeName @($GoodValue1, $GoodValue2) | Should Be $true
  }
}
#endregion
