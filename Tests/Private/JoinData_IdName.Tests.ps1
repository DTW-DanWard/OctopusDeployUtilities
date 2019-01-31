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


#region Function: Get-ODUIdToNameLookupValue
# Get Id to Name lookup value; simplified version used for testing. No validation of parameters, etc.
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


#region Function: Update-ODUExportAddExternalNameForId
# Add external name for id; simplified version of Update-ODUExportAddExternalNameForId used for testing.
# No validation of parameters, directory structure, etc.
function Update-ODUExportAddExternalNameForId {
  param([string]$Path)
  [string]$LookupPath = Join-Path -Path $Path -ChildPath $IdToNameLookupFileName
  $IdToNameLookup = ConvertFrom-Json -InputObject (Get-Content -Path $LookupPath -Raw)

  # when fetching lookup data, drive off rest api call info (instead of existing folders) as need Name and ExternalIdToResolvePropertyName fields
  # note: there's no lookup data for Simple rest api calls, so skip them
  Get-ODUStandardExportRestApiCall | Where-Object { $_.ApiFetchType -ne $ApiFetchType_Simple } | ForEach-Object {
    $RestApiCall = $_
    if (($null -ne $RestApiCall.ExternalIdToResolvePropertyName) -and ($RestApiCall.ExternalIdToResolvePropertyName.Count -gt 0)) {
      $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)
      # loop through all files under item folder
      Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
        $ExportFilePath = $_.FullName
        $ExportItem = ConvertFrom-Json -InputObject (Get-Content -Path $ExportFilePath -Raw)

        # for the item, loop through all external id property names
        $RestApiCall.ExternalIdToResolvePropertyName | ForEach-Object {
          $ExternalIdToResolvePropertyName = $_

          # create new project name with name values - take 'Id'/'Ids' suffix and replace with 'Name'
          $ExternalNamePropertyName = $ExternalIdToResolvePropertyName.SubString(0, $ExternalIdToResolvePropertyName.LastIndexOf('Id')) + 'Name'
          # external id might be a single value or an array, can tell by looking at name suffix: is 'Id' or 'Ids'
          if ($ExternalIdToResolvePropertyName -match "Id$") {
            # singular
            $ExternalId = $ExportItem.$ExternalIdToResolvePropertyName
            $ExternalDisplayName = Get-ODUIdToNameLookupValue -Lookup $IdToNameLookup -Key $ExternalId
            # while it seems we should only have one Add-Member call after the if statement, we can't; we need two separate
            # variables for $ExternalDisplayName and $ExternalDisplayNames; one is an array, one isn't, if we only had one variable for
            # the value the variable type would unexpectedly get changed to an array while processing data and stay that way
            # changing the stored structure for all future values
            Add-ODUOrUpdateMember -InputObject $ExportItem -PropertyName $ExternalNamePropertyName -Value $ExternalDisplayName
          } else {
            # make it plural
            $ExternalNamePropertyName += 's'
            [string[]]$ExternalDisplayNames = @()
            $ExportItem.$ExternalIdToResolvePropertyName | ForEach-Object {
              $ExternalId = $_
              $ExternalDisplayNames += (Get-ODUIdToNameLookupValue -Lookup $IdToNameLookup -Key $ExternalId)
            }
            # if there are values, sort before adding - only sort if values else sort changes empty array to null
            if ($ExternalDisplayNames.Count -gt 0) { $ExternalDisplayNames = $ExternalDisplayNames | Sort-Object }
            # see note above about why there are two separate Add-Member calls
            Add-ODUOrUpdateMember -InputObject $ExportItem -PropertyName $ExternalNamePropertyName -Value $ExternalDisplayNames
          }
        }
        Out-ODUFileJson -FilePath $ExportFilePath -Data $ExportItem
      }
    }
  }
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




# asdf delete functions not used above
