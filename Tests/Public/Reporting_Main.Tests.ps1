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



# root folder containing various exports
$SourceDataRootFolder = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath TestData)

#region Get export latest path
Describe 'Get export latest path' {

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUExportLatestPath | Should BeNullOrEmpty
  }

  It 'folder missing for server name root throws error' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigExportRootFolder { $TestDrive }
    function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerNameNotFound' }
    }
    { Get-ODUExportLatestPath } | Should throw
  }

  Context 'server name root folder exists but no exports throws error' {

    It 'server name root folder exists but no exports throws error' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      { Get-ODUExportLatestPath } | Should throw
    }
  }

  Context 'exports folder exists, return path' {

    It 'exports folder exists, return path' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory
      $ExportFolderName = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName
      $null = New-Item -Path $ExportFolder -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      Get-ODUExportLatestPath | Should Be $ExportFolder
    }
  }
}
#endregion


#region Get export older path
Describe 'Get export older path' {

  It 'non-number throws error' {
    { Get-ODUExportOlderPath -Hours 'W' } | Should throw
  }

  It 'negative integer throws error' {
    { Get-ODUExportOlderPath -Hours -5 } | Should throw
  }

  It 'number larger than integer throws error' {
    { Get-ODUExportOlderPath -Hours ([int]::MaxValue + 1) } | Should throw
  }

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Get-ODUExportOlderPath | Should BeNullOrEmpty
  }

  It 'folder missing for server name root throws error' {
    function Confirm-ODUConfig { $true }
    function Get-ODUConfigExportRootFolder { $TestDrive }
    function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerNameNotFound' }
    }
    { Get-ODUExportOlderPath } | Should throw
  }

  Context 'server name root folder exists but no exports throws error' {

    It 'server name root folder exists but no exports throws error' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      { Get-ODUExportOlderPath } | Should throw
    }
  }

  Context 'only one folder exists but does not match datetime stamp format, throws error' {

    It 'only one folder exists but does not match datetime stamp format, throws error' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory
      $ExportFolderName = 'NotDateTimeStamp'
      $ExportFolder = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName
      $null = New-Item -Path $ExportFolder -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      { Get-ODUExportOlderPath } | Should throw
    }
  }

  Context 'only one export folder instance exists, throws error' {

    It 'only one export folder instance exists, throws error' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory
      $ExportFolderName = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName
      $null = New-Item -Path $ExportFolder -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      { Get-ODUExportOlderPath } | Should throw
    }
  }

  Context 'two export folder exists, return path' {

    It 'two export folder exists, return path' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory
      $ExportFolderName1 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder1 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName1
      $null = New-Item -Path $ExportFolder1 -ItemType Directory
      # pause 2 seconds to ensure unique name
      Start-Sleep -Seconds 2
      $ExportFolderName2 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder2 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName2
      $null = New-Item -Path $ExportFolder2 -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      # first folder created will be older, second one will be newer
      Get-ODUExportLatestPath | Should Be $ExportFolder2
      Get-ODUExportOlderPath | Should Be $ExportFolder1
    }
  }

  Context 'two export folder exists but older folder is not greater than N hours, throws error' {

    It 'two export folder exists, return path' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory
      $ExportFolderName1 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder1 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName1
      $null = New-Item -Path $ExportFolder1 -ItemType Directory
      # pause 2 seconds to ensure unique name
      Start-Sleep -Seconds 2
      $ExportFolderName2 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder2 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName2
      $null = New-Item -Path $ExportFolder2 -ItemType Directory

      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      # first folder created will be older but not old enough
      Get-ODUExportLatestPath | Should Be $ExportFolder2
      { Get-ODUExportOlderPath -Hours 1 } | Should throw
    }
  }

  Context 'multiple export folder exists, return path of older folder' {

    It 'multiple export folder exists, return path of older folder' {
      $ExportRootFolder = Join-Path -Path $TestDrive -ChildPath 'ExportRoot'
      $null = New-Item -Path $ExportRootFolder -ItemType Directory
      $ServerRootFolder = Join-Path -Path $ExportRootFolder -ChildPath 'ServerName'
      $null = New-Item -Path $ServerRootFolder -ItemType Directory

      # create first folder with much older name and much older creation time
      $ExportFolderName1 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date '01/01/2000')
      $ExportFolder1 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName1
      $null = New-Item -Path $ExportFolder1 -ItemType Directory
      (Get-Item -Path $ExportFolder1).CreationTime = '01/01/2000 00:00:00'

      # create new two folders normally
      $ExportFolderName2 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder2 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName2
      $null = New-Item -Path $ExportFolder2 -ItemType Directory
      # pause 2 seconds to ensure unique name
      Start-Sleep -Seconds 2
      $ExportFolderName3 = '{0:yyyyMMdd-HHmmss}' -f (Get-Date)
      $ExportFolder3 = Join-Path -Path $ServerRootFolder -ChildPath $ExportFolderName3
      $null = New-Item -Path $ExportFolder3 -ItemType Directory

      # export folder 3 is the most recently created, that means most recent is folder 2 is default
      # older one, however, we'll test -Hours by specifying a value of 1 (which any value will
      # be greater than 2 seconds) so that folder 1 will get returned instead of folder 2
      function Confirm-ODUConfig { $true }
      function Get-ODUConfigExportRootFolder { $ExportRootFolder }
      function Get-ODUConfigOctopusServer { [PSCustomObject]@{ Name = 'ServerName' }
      }
      # first folder created will be older
      Get-ODUExportLatestPath | Should Be $ExportFolder3
      Get-ODUExportOlderPath -Hours 1 | Should Not Be $ExportFolder2
      Get-ODUExportOlderPath -Hours 1 | Should Be $ExportFolder1
    }
  }
}
#endregion


#region Read export from files
Describe 'Read export from files' {

  It 'path does not exist throws error' {
    { Read-ODUExportFromFile -Path (Join-Path -Path $TestDrive -ChildPath FolderNotFound) } | Should throw
  }

  It 'path is a file throws error' {
    $FilePath = Join-Path -Path $TestDrive -ChildPath AFile.txt
    "asdf" > $FilePath
    { Read-ODUExportFromFile -Path $FilePath } | Should throw
  }

  It 'no config returns null' {
    function Confirm-ODUConfig { $false }
    Read-ODUExportFromFile | Should BeNullOrEmpty
  }

  Context 'Export folder does not look like export (missing expected folders) throws error' {

    It 'Export folder does not look like export (missing expected folders) throws error' {
      function Confirm-ODUConfig { $true }
      $TestExportRootPath = Join-Path -Path $TestDrive -ChildPath Export
      $null = New-Item -Path $TestExportRootPath -ItemType Directory
      'Junk1', 'Junk2', 'Junk13' | ForEach-Object {
        $null = New-Item -Path (Join-Path -Path $TestDrive -ChildPath $_) -ItemType Directory
      }
      { Read-ExportFromFile } | Should throw
    }
  }
  # asdf not complete - need testing for actual Read-ODUExportFromFile work, RSJobs a bit complicated to mock...?
}
#endregion
