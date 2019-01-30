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

#region Function: Read-ExportFromFile
# Reads all export files from one export into single object; simplified version of Read-ODUExportFromFile
# used for testing. No validation of parameters, directory structure, etc.
function Read-ExportFromFile {
  param([string]$Path)
  $ExportData = [ordered]@{}
  Get-ChildItem -Path $Path -Directory | ForEach-Object {
    $Folder = $_
    $TypeName = $Folder.Name
    $Data = [System.Collections.ArrayList]@()
    (Get-ChildItem -Path $Folder.FullName -Recurse -Include ('*' + $JsonExtension)).foreach( {
        $Content = Get-Content -Path $_ -Raw
        if ($null -ne $Content) {
          $null = $Data.Add((ConvertFrom-Json -InputObject $Content))
        }
      })
    $ExportData.$TypeName = $Data
  }
  [PSCustomObject]$ExportData
}
#endregion


# root folder containing various exports
$SourceDataRootFolder = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath TestData)

#region Join/post-process/join-data data - high level
Describe 'Post-process/join-data: - high level' {

  BeforeAll {
    # source path of standard export to post-process
    $SourceExportFolderName = 'Export-NoPostProcessing1'
    $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
    $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    function New-ODUIdToNameLookup { }
    function Update-ODUExportAddExternalNameForId { }
    function Update-ODUExportAddMachinesToEnvironment { }
    function Update-ODUExportAddScopeNamesToVariable { }
    function Update-ODUExportIncludedVariableSetsAddVariable { }
    function Update-ODUExportProjectAddDeploymentProcess { }
    function Update-ODUExportProjectAddVariableSet { }
    function Update-ODUExportProjectAddIncludedLibraryVariableSet { }

  }

  BeforeEach {
    if ($true -eq (Test-Path -Path $TestExportRootPath)) {
      Remove-Item -Path $TestExportRootPath -Recurse -Force
    }
    $null = New-Item -Path $TestExportRootPath -ItemType Directory
    Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
  }

  It 'sample export found and contains data' {
    $Export = Read-ExportFromFile $TestExportPath
    $Export.Projects.Count | Should BeGreaterThan 0
  }

  It 'throws error if no path' {
    { Update-ODUExportJoinData } | Should throw
  }

  It 'throws error if bad path' {
    { Update-ODUExportJoinData -Path (Join-Path -Path $TestExportRootPath -ChildPath ExportDoesNotExist) } | Should throw
  }

  It 'produces output and does not throw error for valid export' {
    $Output = Update-ODUExportJoinData -Path $TestExportPath
    $Output.Count | Should BeGreaterThan 0
  }

  It 'produces output and does not throw error for valid export run multiple times on same' {
    $Output = Update-ODUExportJoinData -Path $TestExportPath
    $Output = Update-ODUExportJoinData -Path $TestExportPath
    $Output.Count | Should BeGreaterThan 0
  }

  It 'produces no output with -Quiet and does not throw error for valid export' {
    Update-ODUExportJoinData -Path $TestExportPath -Quiet | Should BeNullOrEmpty
  }
}
