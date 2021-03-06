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


#region Function: Add-ODUOrUpdateMember
# Add or update member to object; simplified version used for testing. No validation of parameters, etc.
function Add-ODUOrUpdateMember {
  param([object]$InputObject, [string]$PropertyName, $Value)
  if ($null -eq (Get-Member -InputObject $InputObject -MemberType NoteProperty -Name $PropertyName)) {
    Add-Member -InputObject $InputObject -MemberType NoteProperty -Name $PropertyName -Value $Value
  } else {
    $InputObject.$PropertyName = $Value
  }
}
#endregion


#region Function: Get-ODUIdToNameLookup
# Quickly create PSObject with values; simplified version used for testing. No validation of parameters, etc.
function Get-ODUIdToNameLookup {
  param([string]$Path)
  $IdToNameLookup = @{ }
  # when fetching lookup data, drive off rest api call info (instead of existing folders) as need Name field
  # note: there's no lookup data for Simple rest api calls, so skip them
  Get-ODUStandardExportRestApiCall | Where-Object { $_.ApiFetchType -ne $ApiFetchType_Simple } | ForEach-Object {
    $RestApiCall = $_
    $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
    Get-ChildItem -Path $ItemExportFolder -File -Recurse | ForEach-Object {
      $ExportItem = ConvertFrom-Json -InputObject (Get-Content -Path $_.FullName -Raw)
      if ($null -ne $ExportItem) {
        # if item has BOTH Id and IdToNamePropertyName properties, capture it
        $PropertyName = $RestApiCall.IdToNamePropertyName
        if ( ($null -ne (Get-Member -InputObject $ExportItem -Name Id)) -and ($null -ne (Get-Member -InputObject $ExportItem -Name $PropertyName)) ) {
          $Id = $ExportItem.Id
          $IdToNameLookup.$Id = $ExportItem.$PropertyName
        }
      }
    }
  }
  $IdToNameLookup
}
#endregion


#region Function: Get-ODUIdToNameLookupValue
# Looks through object properties, returns value for lookup; simplified version used for testing. No validation of parameters, etc.
function Get-ODUIdToNameLookupValue {
  param([object]$Lookup, $Key)
  # if null/empty key passed, return $null
  # if key passed but not found on lookup, return <key>_NOT_FOUND
  # else return value
  $Result = $null
  if ($null -ne $Key -and $Key.Trim() -ne '') {
    $Result = $Key + '_NOT_FOUND'
    if ($null -ne (Get-Member -InputObject $Lookup -Name $Key)) {
      $Result = $Lookup.$Key
    }
  }
  $Result
}
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

#region Update projects add deployment process
Describe 'Update projects add deployment process' {

  BeforeAll {
    # source path of standard export to post-process
    $SourceExportFolderName = 'Export-NoPostProcessing1'
    $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
    $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    $null = New-Item -Path $TestExportRootPath -ItemType Directory
    Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
    # create lookup file
    Out-ODUFileJson -FilePath (Join-Path -Path $TestExportPath -ChildPath $IdToNameLookupFileName) -Data (ConvertTo-Json -InputObject (Get-ODUIdToNameLookup -Path $TestExportPath) -Depth 100)
  }

  It 'no parameter throws error' {
    { Update-ODUExportProjectAddDeploymentProcess } | Should throw
  }

  It 'null parameter throws error' {
    { $BadPath = $null; Update-ODUExportProjectAddDeploymentProcess -Path $BadPath } | Should throw
  }

  It 'bad path throws error' {
    { Update-ODUExportProjectAddDeploymentProcess -Path (Join-Path -Path $TestExportRootPath -ChildPath FolderNotFound) } | Should throw
  }

  It 'before update variable does not have scope Breadth' {
    $Export = Read-ExportFromFile -Path $TestExportPath
    $Export.Projects[0] | Get-Member -Name DeploymentProcess -MemberType NoteProperty | Should BeNullOrEmpty
  }

  It 'after update variable has scope Breadth' {
    Update-ODUExportProjectAddDeploymentProcess -Path $TestExportPath
    $Export = Read-ExportFromFile -Path $TestExportPath
    $Export.Projects[0] | Get-Member -Name DeploymentProcess -MemberType NoteProperty | Should Not BeNullOrEmpty
  }
}
#endregion


#region Update projects add library variable sets
Describe 'Update projects add library variable sets' {

  BeforeAll {
    # source path of standard export to post-process
    $SourceExportFolderName = 'Export-NoPostProcessing1'
    $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
    $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    $null = New-Item -Path $TestExportRootPath -ItemType Directory
    Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
    # create lookup file
    Out-ODUFileJson -FilePath (Join-Path -Path $TestExportPath -ChildPath $IdToNameLookupFileName) -Data (ConvertTo-Json -InputObject (Get-ODUIdToNameLookup -Path $TestExportPath) -Depth 100)
  }

  It 'no parameter throws error' {
    { Update-ODUExportProjectAddIncludedLibraryVariableSet } | Should throw
  }

  It 'null parameter throws error' {
    { $BadPath = $null; Update-ODUExportProjectAddIncludedLibraryVariableSet -Path $BadPath } | Should throw
  }

  It 'bad path throws error' {
    { Update-ODUExportProjectAddIncludedLibraryVariableSet -Path (Join-Path -Path $TestExportRootPath -ChildPath FolderNotFound) } | Should throw
  }

  It 'before update variable does not have scope Breadth' {
    $Export = Read-ExportFromFile -Path $TestExportPath
    $Export.Projects[0] | Get-Member -Name IncludedLibraryVariableSets -MemberType NoteProperty | Should BeNullOrEmpty
  }

  It 'after update variable has scope Breadth' {
    Update-ODUExportProjectAddIncludedLibraryVariableSet -Path $TestExportPath
    $Export = Read-ExportFromFile -Path $TestExportPath
    $Export.Projects[0] | Get-Member -Name IncludedLibraryVariableSets -MemberType NoteProperty | Should Not BeNullOrEmpty
  }
}
#endregion


#region Update projects add variable set
Describe 'Update projects add variable set' {

  BeforeAll {
    # source path of standard export to post-process
    $SourceExportFolderName = 'Export-NoPostProcessing1'
    $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
    $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
    $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
    $null = New-Item -Path $TestExportRootPath -ItemType Directory
    Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
    # create lookup file
    Out-ODUFileJson -FilePath (Join-Path -Path $TestExportPath -ChildPath $IdToNameLookupFileName) -Data (ConvertTo-Json -InputObject (Get-ODUIdToNameLookup -Path $TestExportPath) -Depth 100)
  }

  It 'no parameter throws error' {
    { Update-ODUExportProjectAddVariableSet } | Should throw
  }

  It 'null parameter throws error' {
    { $BadPath = $null; Update-ODUExportProjectAddVariableSet -Path $BadPath } | Should throw
  }

  It 'bad path throws error' {
    { Update-ODUExportProjectAddVariableSet -Path (Join-Path -Path $TestExportRootPath -ChildPath FolderNotFound) } | Should throw
  }

  It 'before update variable does not have scope Breadth' {
    $Export = Read-ExportFromFile -Path $TestExportPath
    $Export.Projects[0] | Get-Member -Name VariableSet -MemberType NoteProperty | Should BeNullOrEmpty
  }

  It 'after update variable has scope Breadth' {
    Update-ODUExportProjectAddVariableSet -Path $TestExportPath
    $Export = Read-ExportFromFile -Path $TestExportPath
    $Export.Projects[0] | Get-Member -Name VariableSet -MemberType NoteProperty | Should Not BeNullOrEmpty
  }
}
#endregion
