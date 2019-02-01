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


#region Encrypt and decrypt
Describe -Tag 'Integration' 'encrypt and decrypt tests (native Windows functionality)' {

  BeforeAll {
    $script:SkipTest = @{}
    if (($PSVersionTable.PSVersion.Major -ge 6) -and ($false -eq $IsWindows)) {
      $script:SkipTest = @{ Skip = $true}
    }
  }

  It 'encrypting without text input is error' {
    { Convert-ODUEncryptText } | Should throw
  }

  # note: this will not work on non-Windows machines
  It @SkipTest 'encrypted text is different than text input' {
    $TestPlainText = 'ThisIsSampleText'
    Convert-ODUEncryptText -Text $TestPlainText | Should Not Be $TestPlainText
  }

  It 'decrypting without text input is error' {
    { Convert-ODUDecryptText } | Should throw
  }

  It 'encrypting then decrypting text produces same text' {
    $TestPlainText = 'ThisIsSampleText'
    Convert-ODUDecryptText -Text (Convert-ODUEncryptText -Text $TestPlainText) | Should Be $TestPlainText
  }
}
#endregion


#region Test config file path valid
Describe 'Test config file path valid' {

  Context 'valid path' {

    BeforeAll {
      # test drive root as valid path
      function Get-ODUConfigFilePath { $TestDrive }
    }

    It 'path exists' { Test-ODUConfigFilePath | Should Be $true }
  }

  Context 'invalid path' {

    BeforeAll {
      # test drive root plus file that doesn't exist
      function Get-ODUConfigFilePath { (Join-Path -Path $TestDrive -ChildPath NoFile.txt) }
    }

    It 'path does not exist' { Test-ODUConfigFilePath | Should Be $false }
  }
}
#endregion
