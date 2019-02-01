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

  It 'no parameter throws error' {
    { Format-ODUSanitizeFileName } | Should throw
  }

  It 'null parameter throws error' {
    { $BadValue = $null; Format-ODUSanitizeFileName -FileName $BadValue } | Should throw
  }

  It 'empty file name throws error' {
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


#region New export item folder
Describe 'New export item folder' {

  It 'no parameter throws error' {
    { New-ODUExportItemFolder } | Should throw
  }

  It 'null parameter throws error' {
    { $BadPath = $null; New-ODUExportItemFolder -FolderPath $BadPath } | Should throw
  }

  It 'path that does not exist will be created' {
    $NewFolder = Join-Path -Path $TestDrive -ChildPath FolderNotFound1
    Test-Path -Path $NewFolder | Should Be $false
    New-ODUExportItemFolder -FolderPath $NewFolder
    Test-Path -Path $NewFolder | Should Be $true
  }

  It 'path that does not exist will be created and will be a folder' {
    $NewFolder = Join-Path -Path $TestDrive -ChildPath FolderNotFound2
    Test-Path -Path $NewFolder | Should Be $false
    New-ODUExportItemFolder -FolderPath $NewFolder
    Test-Path -Path $NewFolder -PathType Container | Should Be $true
  }

  It 'path that already exists will be ignored, still exists' {
    $NewFolder = Join-Path -Path $TestDrive -ChildPath FolderNotFound1
    # folder created in earlier test
    Test-Path -Path $NewFolder | Should Be $true
    New-ODUExportItemFolder -FolderPath $NewFolder
    Test-Path -Path $NewFolder -PathType Container | Should Be $true
  }
}
#endregion


#region New folder for each Api Call
Describe 'New folder for each Api Call' {

  It 'no parameters throws error' {
    { New-ODUFolderForEachApiCall } | Should throw
  }

  It 'null parameters throws error' {
    { $BadParam1 = $BadParam2 = $null; New-ODUFolderForEachApiCall -ParentFolder $BadParam1 -ApiCalls $BadParam2} | Should throw
  }

  It 'valid params get folders created' {
    function Get-ODUFolderNameForApiCall { param([object]$ApiCall) $ApiCall.RestName }

    $RootFolder = Join-Path -Path $TestDrive -ChildPath RootFolder
    $null = New-ODUExportItemFolder -FolderPath $RootFolder
    $Names = 'Val1','Val2'
    [object[]]$ApiCalls = $Names | ForEach-Object {
      [PSCustomObject]@{ RestName = $_ }
    }
    New-ODUFolderForEachApiCall -ParentFolder $RootFolder -ApiCalls $ApiCalls
    # verify each created
    $Names | ForEach-Object {
      Test-Path -Path (Join-Path -Path $RootFolder -ChildPath $_) | Should Be $true
    }
  }
}
#endregion




#region Out file Json
Describe 'Out file Json' {

  It 'no parameters throws error' {
    { Out-ODUFileJson } | Should throw
  }

  It 'null parameters throws error' {
    { $BadParam1 = $BadParam2 = $null; Out-ODUFileJson -FilePath $BadParam1 -Data $BadParam2} | Should throw
  }

  It 'valid params get file created' {
    $JsonFilePath = Join-Path -Path $TestDrive -ChildPath File.json
    $Property = 'ABC'
    $Value = 123
    $SomeObject = [PSCustomObject]@{ $Property = $Value }
    Out-ODUFileJson -FilePath $JsonFilePath -Data $SomeObject
    # get object from file and test property value
    $SomeObjectRestored = ConvertFrom-Json -InputObject (Get-Content -Path $JsonFilePath -Raw)
    $SomeObjectRestored.$Property | Should Be $Value
  }
}
#endregion
