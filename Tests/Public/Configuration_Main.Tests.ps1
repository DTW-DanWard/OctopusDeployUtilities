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


#region Configuration export root folder accessible
Describe 'Configuration: export root folder initialized' {

  # ensure config file DOES exist
  $ExportRootFolder = Join-Path -Path $TestDrive 'ExportRoot'
  $ConfigFolderPath = Join-Path -Path $TestDrive 'Configuration'
  $ConfigFilePath = Join-Path -Path $ConfigFolderPath 'Configuration.psd1'

  $null = New-Item -Path $ExportRootFolder -ItemType Directory
  $null = New-Item -Path $ConfigFolderPath -ItemType Directory

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

  function Confirm-ODUConfig { $true }
  function Get-ODUConfig { $Config }

  It 'Get-ODUConfigExportRootFolder returns correct value' { Get-ODUConfigExportRootFolder | Should Be $ExportRootFolder }
}
#endregion
