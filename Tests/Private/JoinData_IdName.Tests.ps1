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


#region Function: New-ODUExportRestApiCall
# Quickly create PSObject with values; simplified version used for testing. No validation of parameters, etc.
function New-ODUExportRestApiCall {
  param(
    [string]$RestName,
    [string]$RestMethod,
    [string]$ApiFetchType,
    [string]$FileNamePropertyName,
    [string]$IdToNamePropertyName = 'Name',
    [string[]]$ExternalIdToResolvePropertyName,
    [string]$ItemIdOnlyReferencePropertyName
  )
  [PSCustomObject]@{
    RestName                        = $RestName
    RestMethod                      = $RestMethod
    ApiFetchType                    = $ApiFetchType
    FileNamePropertyName            = $FileNamePropertyName
    IdToNamePropertyName            = $IdToNamePropertyName
    ExternalIdToResolvePropertyName = $ExternalIdToResolvePropertyName
    ItemIdOnlyReferencePropertyName = $ItemIdOnlyReferencePropertyName
  }
}
#endregion


#region Function: Out-ODUFileJson
# Save file; simplified version used for testing. No validation of parameters, etc.
function Out-ODUFileJson {
  param([string]$FilePath, $Data)
  # simply convert to JSON and export as-is
  $Data | ConvertTo-Json -Depth 100 | Out-File -FilePath $FilePath
}
#endregion


# root folder containing various exports
$SourceDataRootFolder = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath TestData)

#region Get Id to Name lookup
Describe 'Get Id to Name lookup' {

  BeforeAll {
    # source path of standard export to post-process
    $SourceExportFolderName = 'Export-NoPostProcessing1'
    $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
    $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    $null = New-Item -Path $TestExportRootPath -ItemType Directory
    Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
  }

  It 'no parameter throws error' {
    { Get-ODUIdToNameLookup } | Should throw
  }

  It 'null parameter throws error' {
    { $BadPath = $null; Get-ODUIdToNameLookup -Path $BadPath } | Should throw
  }

  It 'bad path throws error' {
    { Get-ODUIdToNameLookup -Path (Join-Path -Path $TestExportRootPath -ChildPath FolderNotFound) } | Should throw
  }

  It 'confirm lookup value matches' {
    $Lookup = Get-ODUIdToNameLookup -Path $TestExportPath
    $Lookup.'Lifecycles-1' | Should Be 'Default Lifecycle'
  }
}
#endregion


#region New Id to Name lookup
Describe 'New Id to Name lookup' {

  BeforeAll {
    # source path of standard export to post-process
    $SourceExportFolderName = 'Export-NoPostProcessing1'
    $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
    $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    $null = New-Item -Path $TestExportRootPath -ItemType Directory
    Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
    $script:LookupFile = (Join-Path -Path $TestExportPath -ChildPath $IdToNameLookupFileName)
  }

  It 'no parameter throws error' {
    { New-ODUIdToNameLookup } | Should throw
  }

  It 'null parameter throws error' {
    { $BadPath = $null; New-ODUIdToNameLookup -Path $BadPath } | Should throw
  }

  It 'bad path throws error' {
    { New-ODUIdToNameLookup -Path (Join-Path -Path $TestExportRootPath -ChildPath FolderNotFound) } | Should throw
  }

  It 'folder with few/none of expected sub-folders throws error' {
    $TestExportEmptyPath = Join-Path -Path $TestDrive -ChildPath ExportTestFewFolders
    $null = New-Item -Path $TestExportEmptyPath -ItemType Directory
    # only %20 of listed folders are expected folder names in an export, below threshold of 50%
    'A','B','C','D','Projects' | ForEach-Object { $null = New-Item -Path (Join-Path -Path $TestExportEmptyPath -ChildPath $_) -ItemType Directory }
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    { New-ODUIdToNameLookup -Path $TestExportEmptyPath } | Should throw
  }

  It 'lookup file does not exist before call' {
    Test-Path -Path $script:LookupFile | Should Be $false
  }

  It 'lookup file exists after call' {
    New-ODUIdToNameLookup -Path $TestExportPath
    Test-Path -Path $LookupFile | Should Be $true
  }
}
#endregion
