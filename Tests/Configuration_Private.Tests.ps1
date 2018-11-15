Set-StrictMode -Version Latest

#region Set module/script-level variables
$ScriptLevelVariables = Join-Path -Path $env:BHModulePath -ChildPath 'Set-ScriptLevelVariables.ps1'
. $ScriptLevelVariables
#endregion


#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. $PSScriptRoot\Get-SourceScriptFilePath.ps1
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Configuration not initialized
Describe 'Configuration: not initialized' {

  # ensure config file does not exist
  Mock -CommandName 'Get-ODUConfigFilePath' -MockWith { 'Test:\No\File\Found.txt' }

  Mock -CommandName 'Save-ODUConfig' -MockWith { }

  It 'Confirm-ODUConfig throws error' { { Confirm-ODUConfig } | Should throw  }

  It 'Get-ODUConfig returns $null' { Get-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfigOctopusServer throws error' { { Get-ODUConfigOctopusServer } | Should throw }

  It 'Get-ODUConfigDecryptApiKey throws error' { { Get-ODUConfigDecryptApiKey } | Should throw }

  It 'Initialize-ODUConfig returns $null but behind the scenes Save-ODUConfig returns an initialize configuration' {
    Initialize-ODUConfig | Should BeNullOrEmpty
  }

  It 'Test-ODUConfigFilePath returns $false' { Test-ODUConfigFilePath | Should Be $false }

}
#endregion


#region Configuration export root folder initialized
Describe 'Configuration: export root folder initialized' {

  # ensure config file DOES exist
  $ExportRootFolder = Join-Path -Path $TestDrive 'ExportRoot'
  $ConfigFolderPath = Join-Path -Path $TestDrive 'Configuration'
  $ConfigFilePath = Join-Path -Path $ConfigFolderPath 'Configuration.psd1'

  New-Item -Path $ExportRootFolder -ItemType Directory > $null
  New-Item -Path $ConfigFolderPath -ItemType Directory > $null

  $ConfigString = @"
@{
ExportRootFolder = $ExportRootFolder
OctopusServers = @()
ExternalTools = @{
  DiffViewerPath = 'UNDEFINED'
  TextEditorPath = 'UNDEFINED'
}
ParallelJobsCount = 1
}
"@
  Set-Content -Path $ConfigFilePath -Value $ConfigString
  Mock -CommandName 'Get-ODUConfigFilePath' -MockWith { $ConfigFilePath }

  $Config = @{
    ExportRootFolder  = $ExportRootFolder
    OctopusServers    = @()
    ExternalTools     = @{
      DiffViewerPath = 'UNDEFINED'
      TextEditorPath = 'UNDEFINED'
    }
    ParallelJobsCount = 1
  }

  Mock -CommandName 'Save-ODUConfig' -MockWith { }

  Mock -CommandName 'Get-ODUConfig' -MockWith { $Config }

  It 'Test-ODUConfigFilePath returns $true' { Test-ODUConfigFilePath | Should Be $true }

  It 'Confirm-ODUConfig returns $true' { Confirm-ODUConfig | Should Be $true }

  It 'Initialize-ODUConfig returns $null and does nothing' { Initialize-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfig returns a hashtable' { Get-ODUConfig | Should BeOfType [hashtable] }

  It 'Get-ODUConfig returns value for ExportRootFolder' { (Get-ODUConfig).ExportRootFolder | Should Be $ExportRootFolder }

  It 'Get-ODUConfigOctopusServer throws error' { { Get-ODUConfigOctopusServer } | Should throw }

  It 'Get-ODUConfigDecryptApiKey throws error' { { Get-ODUConfigDecryptApiKey } | Should throw }
}
#endregion


#region Configuration Octopus Server initialized
Describe 'Configuration: Octopus Server initialized' {

  # ensure config file DOES exist
  $ExportRootFolder = Join-Path -Path $TestDrive 'ExportRoot'
  $ConfigFolderPath = Join-Path -Path $TestDrive 'Configuration'
  $ConfigFilePath = Join-Path -Path $ConfigFolderPath 'Configuration.psd1'

  New-Item -Path $ExportRootFolder -ItemType Directory > $null
  New-Item -Path $ConfigFolderPath -ItemType Directory > $null

  $OctoServerName = 'test.com'
  $OctoServerUrl = 'https://test.com'
  $OctoServerApiKey = 'API-1234567890'
  # encrypt key they test decrypt with Get-ODUConfigDecryptApiKey
  $OctoServerApiKeyEncrypted = $OctoServerApiKey
  if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
    $OctoServerApiKeyEncrypted = ConvertTo-SecureString -String $OctoServerApiKey -AsPlainText -Force | ConvertFrom-SecureString
  }

  $ConfigString = @"
@{
ExportRootFolder = $ExportRootFolder
OctopusServers = @(
  @{
    Name = $OctoServerName
    Url = $OctoServerUrl
    ApiKey = $OctoServerApiKeyEncrypted
    TypeBlackList = @('CommunityActionTemplates','Deployments','Events','Interruptions','Releases','Reporting','Tasks','Packages')
    TypeWhiteList = @()
    PropertyBlackList = @{ }
    PropertyWhiteList = @{ }
    LastPurgeCompareFolder = 'UNDEFINED'
    Search = @{
      CodeSearchPattern = 'UNDEFINED'
      CodeRootPaths = 'UNDEFINED'
    }
  }
)
ExternalTools = @{
  DiffViewerPath = 'UNDEFINED'
  TextEditorPath = 'UNDEFINED'
}
ParallelJobsCount = 1
}
"@
  Set-Content -Path $ConfigFilePath -Value $ConfigString
  Mock -CommandName 'Get-ODUConfigFilePath' -MockWith { $ConfigFilePath }

  $Config = @{
    ExportRootFolder  = $ExportRootFolder
    OctopusServers    = @(
      @{
        Name                   = $OctoServerName
        Url                    = $OctoServerUrl
        ApiKey                 = $OctoServerApiKeyEncrypted
        TypeBlackList          = @('CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'Releases', 'Reporting', 'Tasks', 'Packages')
        TypeWhiteList          = @()
        PropertyBlackList      = @{ }
        PropertyWhiteList      = @{ }
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
    ParallelJobsCount = 1
  }

  Mock -CommandName 'Save-ODUConfig' -MockWith { }

  Mock -CommandName 'Get-ODUConfig' -MockWith { $Config }

  It 'Test-ODUConfigFilePath returns $true' { Test-ODUConfigFilePath | Should Be $true }

  It 'Confirm-ODUConfig returns $true' { Confirm-ODUConfig | Should Be $true }

  It 'Initialize-ODUConfig returns $null and does nothing' { Initialize-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfig returns a hashtable' { Get-ODUConfig | Should BeOfType [hashtable] }

  It 'Get-ODUConfig returns value for ExportRootFolder' { (Get-ODUConfig).ExportRootFolder | Should Be $ExportRootFolder }

  It 'Get-ODUConfigOctopusServer returns a hashtable' { Get-ODUConfigOctopusServer | Should BeOfType [hashtable] }

  It 'Get-ODUConfigOctopusServer.Url returns correct value' { (Get-ODUConfigOctopusServer).Url | Should Be $OctoServerUrl }

  It 'Get-ODUConfigDecryptApiKey returns correct value' { Get-ODUConfigDecryptApiKey | Should Be $OctoServerApiKey }
}
#endregion
