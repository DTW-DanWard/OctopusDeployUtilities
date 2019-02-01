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

#region Find variable in export
Describe 'Find variable in export' {

  It 'no parameter throws error' {
    { Find-ODUVariableInExport } | Should throw
  }

  It 'null parameter throws error' {
    { $BadValue1 = $BadValue2 = $null; Find-ODUVariableInExport -Export $BadValue1 -SearchText $BadValue2 } | Should throw
  }

  Context 'search export' {

    BeforeAll {
      # source path of standard export to post-process
      $SourceExportFolderName = 'Export-PostProcessed1'
      $script:SourceExportFolder = Join-Path -Path $SourceDataRootFolder -ChildPath $SourceExportFolderName
      $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
      $script:TestExportPath = Join-Path -Path $TestExportRootPath -ChildPath $SourceExportFolderName
      $null = New-Item -Path $TestExportRootPath -ItemType Directory
      Copy-Item -Path $SourceExportFolder -Destination $TestExportRootPath -Recurse -Container -Force
      # read export for use with searching
      $script:Export = Read-ExportFromFile -Path $TestExportPath
    }

    It 'search for junk text finds none' {
      $Results = Find-ODUVariableInExport -Export $Export -SearchText abcxyz
      $Results.LibraryVariableSetDefined | Should BeNullOrEmpty
      $Results.LibraryVariableSetUsed | Should BeNullOrEmpty
      $Results.ProjectDefined | Should BeNullOrEmpty
      $Results.ProjectUsed | Should BeNullOrEmpty
    }

    It 'search for text found in library set variable name' {
      $Results = Find-ODUVariableInExport -Export $Export -SearchText ConnStr
      $Results.LibraryVariableSetDefined | Should Not BeNullOrEmpty
    }

    It 'search for text found in library set variable value' {
      $Results = Find-ODUVariableInExport -Export $Export -SearchText uid
      $Results.LibraryVariableSetUsed | Should Not BeNullOrEmpty
    }

    It 'search for text found in project variable name' {
      $Results = Find-ODUVariableInExport -Export $Export -SearchText ReplyEmail
      $Results.ProjectDefined | Should Not BeNullOrEmpty
    }

    It 'search for text found in project variable value' {
      $Results = Find-ODUVariableInExport -Export $Export -SearchText 'Sales@MyCo.com'
      $Results.ProjectUsed | Should Not BeNullOrEmpty
    }

    It 'exact search for text' {
      $Results = Find-ODUVariableInExport -Export $Export -SearchText 'DB.User' -Exact
      $Results.ProjectDefined | Should Not BeNullOrEmpty
    }
  }
}
#endregion