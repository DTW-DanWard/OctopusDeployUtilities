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
Describe 'Configuration: external tools initialized' {

  # ensure config file DOES exist
  $ExportRootFolder = Join-Path -Path $TestDrive 'ExportRoot'
  $ConfigFolderPath = Join-Path -Path $TestDrive 'Configuration'
  $ConfigFilePath = Join-Path -Path $ConfigFolderPath 'Configuration.psd1'

  $null = New-Item -Path $ExportRootFolder -ItemType Directory
  $null = New-Item -Path $ConfigFolderPath -ItemType Directory

  $DiffViewerPath = Join-Path -Path $TestDrive 'ADiffViewer.exe'
  $TextEditorPath = Join-Path -Path $TestDrive 'ATextEditor.exe'

  $Config = @{
    ExportRootFolder = $ExportRootFolder
    OctopusServers = @()
    ExternalTools = @{
      DiffViewerPath = $DiffViewerPath
      TextEditorPath = $TextEditorPath
    }
    BackgroundJobsMax = 1
  }
  Export-Metadata -Path $ConfigFilePath -InputObject $Config -AsHashtable

  function Get-ODUConfigFilePath { $ConfigFilePath }
  function Confirm-ODUConfig { $true }
  function Get-ODUConfig { $Config }

  It 'Get-ODUConfigDiffViewer returns correct value' { Get-ODUConfigDiffViewer | Should Be $DiffViewerPath }

  It 'Get-ODUConfigTextEditor returns correct value' { Get-ODUConfigTextEditor | Should Be $TextEditorPath }
}
#endregion
