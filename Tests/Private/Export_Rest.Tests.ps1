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



#region invoke rest method
Describe 'invoke rest method' {

  It 'no parameter throws error' {
    { Invoke-ODURestMethod } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $BadParam2 = $null; Invoke-ODURestMethod -Url $BadParam1 -ApiKey $BadParam2 } | Should throw
  }

  Context 'test successful' {

    # can't really unit test this; this is an integration test
    BeforeAll { Mock -CommandName 'Invoke-RestMethod' -MockWith { } }

    It 'test successful' {
      { Invoke-ODURestMethod -Url 'SomeValue' -ApiKey 'SomeValue' } | Should Not throw
    }
  }

  Context 'test failed - permission error' {

    # can't really unit test this; this is an integration test
    BeforeAll { Mock -CommandName 'Invoke-RestMethod' -MockWith { throw 'You do not have permission to perform this action. Please contact your Octopus administrator' } }

    It 'test failed' {
      { Invoke-ODURestMethod -Url 'SomeValue' -ApiKey 'SomeValue' } | Should throw
    }
  }

  Context 'test failed - some other error' {

    # can't really unit test this; this is an integration test
    BeforeAll { Mock -CommandName 'Invoke-RestMethod' -MockWith { throw 'did not work' } }

    It 'test failed' {
      { Invoke-ODURestMethod -Url 'SomeValue' -ApiKey 'SomeValue' } | Should throw
    }
  }
}
#endregion


#region new export rest api call
Describe 'test Octopus server credential' {

  It 'no parameter throws error' {
    { Test-ODUOctopusServerCredential } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $BadParam2 = $null; Test-ODUOctopusServerCredential -ServerDomainName $BadParam1 -ApiKey $BadParam2 } | Should throw
  }

  Context 'credential test successful' {

    # can't really unit test this; this is an integration test
    BeforeAll { Mock -CommandName 'Invoke-RestMethod' -MockWith { } }

    It 'test successful' {
      { Test-ODUOctopusServerCredential -ServerDomainName 'SomeValue' -ApiKey 'SomeValue' } | Should Not throw
    }
  }

  Context 'credential test failed' {

    # can't really unit test this; this is an integration test
    BeforeAll { Mock -CommandName 'Invoke-RestMethod' -MockWith { throw 'did not work' } }

    It 'test failed' {
      { Test-ODUOctopusServerCredential -ServerDomainName 'SomeValue' -ApiKey 'SomeValue' } | Should throw
    }
  }
}
#endregion
