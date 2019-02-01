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


#region Configuration not initialized
Describe 'Configuration: not initialized' {

  BeforeAll {
    # ensure config file does not exist
    Mock -CommandName 'Save-ODUConfig' -MockWith { }
    function Test-ODUConfigFilePath { $false }
    function Get-ODUConfigFilePath { 'Test:\No\File\Found.txt' }
  }

  It 'Confirm-ODUConfig throws error' { { Confirm-ODUConfig } | Should throw }

  It 'Get-ODUConfig returns $null' { Get-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfigOctopusServer throws error' { { Get-ODUConfigOctopusServer } | Should throw }

  It 'Initialize-ODUConfig returns $null but behind the scenes Save-ODUConfig returns an initialize configuration' {
    Initialize-ODUConfig | Should BeNullOrEmpty
  }

  It 'Test-ODUConfigFilePath returns $false' { Test-ODUConfigFilePath | Should Be $false }

}
#endregion


#region Configuration export root folder initialized
Describe 'Configuration: export root folder initialized' {

  BeforeAll {
    # ensure config file DOES exist
    $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
    $ConfigFolderPath = Join-Path -Path $TestDrive -ChildPath 'Configuration'
    $ConfigFilePath = Join-Path -Path $ConfigFolderPath -ChildPath 'Configuration.psd1'

    $null = New-Item -Path $ExportRootFolder -ItemType Directory
    $null = New-Item -Path $ConfigFolderPath -ItemType Directory

    $Config = @{
      ExportRootFolder  = $ExportRootFolder
      OctopusServers    = @()
      ExternalTools     = @{
        DiffViewerPath = 'UNDEFINED'
        TextEditorPath = 'UNDEFINED'
      }
      BackgroundJobsMax = 1
    }
    Export-Metadata -Path $ConfigFilePath -InputObject $Config -AsHashtable

    Mock -CommandName 'Save-ODUConfig' -MockWith { }
    Mock -CommandName 'Get-ODUConfig' -MockWith { $Config }
    function Test-ODUConfigFilePath { $true }

    function Get-ODUConfigFilePath { $ConfigFilePath }
  }

  It 'Test-ODUConfigFilePath returns $true' { Test-ODUConfigFilePath | Should Be $true }

  It 'Confirm-ODUConfig returns $true' { Confirm-ODUConfig | Should Be $true }

  It 'Initialize-ODUConfig returns $null and does nothing' { Initialize-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfig returns a hashtable' { Get-ODUConfig | Should BeOfType [hashtable] }

  It 'Get-ODUConfig returns value for ExportRootFolder' { (Get-ODUConfig).ExportRootFolder | Should Be $ExportRootFolder }

  It 'Get-ODUConfigOctopusServer returns null' { Get-ODUConfigOctopusServer | Should BeNullOrEmpty }
}
#endregion


#region Configuration Octopus Server initialized
Describe 'Configuration: Octopus Server initialized' {

  BeforeAll {
    # ensure config file DOES exist
    $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
    $ConfigFolderPath = Join-Path -Path $TestDrive -ChildPath 'Configuration'
    $ConfigFilePath = Join-Path -Path $ConfigFolderPath -ChildPath 'Configuration.psd1'

    $null = New-Item -Path $ExportRootFolder -ItemType Directory
    $null = New-Item -Path $ConfigFolderPath -ItemType Directory

    $OctoServerName = 'test.com'
    $OctoServerUrl = 'https://test.com'
    $OctoServerApiKey = 'API-ABCDEFGH01234567890ABCDEFGH'

    # encryption tests only run on Windows
    $script:Windows = $false
    # encrypt key they test decrypt with Convert-ODUDecryptText
    $OctoServerApiKeyEncrypted = $OctoServerApiKey
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
     $script:Windows = $true
      $OctoServerApiKeyEncrypted = ConvertTo-SecureString -String $OctoServerApiKey -AsPlainText -Force | ConvertFrom-SecureString
    }

    $Config = @{
      ExportRootFolder  = $ExportRootFolder
      OctopusServers    = @(
        @{
          Name                   = $OctoServerName
          Url                    = $OctoServerUrl
          ApiKey                 = $OctoServerApiKeyEncrypted
          TypeBlacklist          = @('CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'Releases', 'Reporting', 'Tasks', 'Packages')
          TypeWhitelist          = @()
          PropertyBlacklist      = @{ }
          PropertyWhitelist      = @{ }
          LastPurgeCompareFolder = 'UNDEFINED'
          Search                 = @{
            CodeSearchPattern = 'UNDEFINED'
            CodeRootPaths     = 'UNDEFINED'
          }
        }
      )
     ExternalTools     = @{
       DiffViewerPath = 'UNDEFINED'
        TextEditorPath = 'UNDEFINED'
      }
      BackgroundJobsMax = 1
    }
    Export-Metadata -Path $ConfigFilePath -InputObject $Config -AsHashtable

    # simple mock for now
    Mock -CommandName 'Save-ODUConfig' -MockWith { }
    Mock -CommandName 'Get-ODUConfig' -MockWith { $Config }
  }

  function Convert-ODUDecryptText { $OctoServerApiKey }

  function Test-ODUConfigFilePath { $true }

  function Get-ODUConfigFilePath { $ConfigFilePath }

  It 'Test-ODUConfigFilePath returns $true' { Test-ODUConfigFilePath | Should Be $true }

  It 'Confirm-ODUConfig returns $true' { Confirm-ODUConfig | Should Be $true }

  It 'Initialize-ODUConfig returns $null and does nothing' { Initialize-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfig returns a hashtable' { Get-ODUConfig | Should BeOfType [hashtable] }

  It 'Get-ODUConfig returns value for ExportRootFolder' { (Get-ODUConfig).ExportRootFolder | Should Be $ExportRootFolder }

  It 'Get-ODUConfigOctopusServer returns a hashtable' { Get-ODUConfigOctopusServer | Should BeOfType [hashtable] }

  It 'Get-ODUConfigOctopusServer.Url returns correct value' { (Get-ODUConfigOctopusServer).Url | Should Be $OctoServerUrl }

  $ItParams = @{ Skip = $(! $Windows) }
  It @ItParams 'Convert-ODUDecryptText returns correct value' { Convert-ODUDecryptText -Text ((Get-ODUConfigOctopusServer).ApiKey) | Should Be $OctoServerApiKey }
}
#endregion
