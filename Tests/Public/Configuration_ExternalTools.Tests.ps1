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

#region Configuration external tools initialized
Describe 'Configuration: get external tools - not initialized' {

  BeforeAll {
    function Confirm-ODUConfig { $false }
  }

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUConfigDiffViewer | Should BeNullOrEmpty
    Get-ODUConfigTextEditor | Should BeNullOrEmpty
  }
}
#endregion


#region Configuration external tools initialized
Describe 'Configuration: get external tools - initialized' {

  BeforeAll {
    # ensure config file DOES exist
    $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
    $ConfigFolderPath = Join-Path -Path $TestDrive -ChildPath 'Configuration'
    $ConfigFilePath = Join-Path -Path $ConfigFolderPath -ChildPath 'Configuration.psd1'

    $null = New-Item -Path $ExportRootFolder -ItemType Directory
    $null = New-Item -Path $ConfigFolderPath -ItemType Directory

    $DiffViewerPath = Join-Path -Path $TestDrive -ChildPath 'ADiffViewer.exe'
    $TextEditorPath = Join-Path -Path $TestDrive -ChildPath 'ATextEditor.exe'

    $Config = @{
      ExportRootFolder  = $ExportRootFolder
      OctopusServers    = @()
      ExternalTools     = @{
        DiffViewerPath = $DiffViewerPath
        TextEditorPath = $TextEditorPath
      }
      BackgroundJobsMax = 1
    }
    Export-Metadata -Path $ConfigFilePath -InputObject $Config -AsHashtable

    function Get-ODUConfigFilePath { $ConfigFilePath }
    function Confirm-ODUConfig { $true }
    function Get-ODUConfig { $Config }
  }

  It 'Get-ODUConfigDiffViewer returns correct value' { Get-ODUConfigDiffViewer | Should Be $DiffViewerPath }

  It 'Get-ODUConfigTextEditor returns correct value' { Get-ODUConfigTextEditor | Should Be $TextEditorPath }
}
#endregion


#region Set config diff viewer
Describe 'set config diff viewer' {

  It 'no parameter throws error' {
    { Set-ODUConfigDiffViewer } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Set-ODUConfigDiffViewer -Path $BadParam1 } | Should throw
  }

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Set-ODUConfigDiffViewer -Path (Get-Random -Minimum 1 -Maximum 9) | Should BeNullOrEmpty
  }

  It 'invalid path param throws error' {
    function Confirm-ODUConfig { $true }
    { Set-ODUConfigDiffViewer -Path (Join-Path -Path $TestDrive -ChildPath NotFound) } | Should throw
  }

  It 'valid path works' {
    function Confirm-ODUConfig { $true }
    # does not have to be an exe, just a valid file path, so create a text file
    $ValidPath = Join-Path -Path $TestDrive -ChildPath AFile.txt
    "asdf" > $ValidPath
    function Get-ODUConfig { @{ ExternalTools = @{ DiffViewerPath = $ValidPath } } }
    function Save-ODUConfig { param([hashtable]$Config) }
    Mock 'Save-ODUConfig'
    $Config = Get-ODUConfig
    Set-ODUConfigDiffViewer -Path $ValidPath
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.ExternalTools.DiffViewerPath -eq $ValidPath }
  }
}
#endregion


#region Set config text editor
Describe 'set config text editor' {

  It 'no parameter throws error' {
    { Set-ODUConfigTextEditor } | Should throw
  }

  It 'null parameter throws error' {
    { $BadParam1 = $null; Set-ODUConfigTextEditor -Path $BadParam1 } | Should throw
  }

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Set-ODUConfigTextEditor -Path (Get-Random -Minimum 1 -Maximum 9) | Should BeNullOrEmpty
  }

  It 'invalid path param throws error' {
    function Confirm-ODUConfig { $true }
    { Set-ODUConfigTextEditor -Path (Join-Path -Path $TestDrive -ChildPath NotFound) } | Should throw
  }

  It 'valid path works' {
    function Confirm-ODUConfig { $true }
    # does not have to be an exe, just a valid file path, so create a text file
    $ValidPath = Join-Path -Path $TestDrive -ChildPath AFile.txt
    "asdf" > $ValidPath
    function Get-ODUConfig { @{ ExternalTools = @{ DiffViewerPath = $ValidPath } } }
    function Save-ODUConfig { param([hashtable]$Config) }
    Mock 'Save-ODUConfig'
    $Config = Get-ODUConfig
    Set-ODUConfigTextEditor -Path $ValidPath
    Assert-MockCalled -CommandName 'Save-ODUConfig' -ParameterFilter { $Config.ExternalTools.DiffViewerPath -eq $ValidPath }
  }
}
#endregion
