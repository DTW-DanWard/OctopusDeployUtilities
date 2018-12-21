
Set-StrictMode -Version Latest

#region Function: Get-ODUExportLatestPath

<#
.SYNOPSIS
Gets latest export full folder path that matches YYYYMMDD-HHMMSS name format
.DESCRIPTION
Gets latest export full folder path that matches YYYYMMDD-HHMMSS name format
Grabs latest export found under: Root folder \ Octo Server Name
but has format name: YYYYMMDD-HHMMSS  or, more specifically: ^\d{8}-\d{6}$
If you copy & rename a folder it won't get returned unless it matches that format.
.EXAMPLE
Get-ODUExportLatestPath
c:\OctoExports\MyOctoServer.octopus.app\20181107-185919
#>
function Get-ODUExportLatestPath {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # get Octopus Server instance root folder
    $OctoServerRootFolderPath = Join-Path -Path (Get-ODUConfigExportRootFolder) -ChildPath (Get-ODUConfigOctopusServer).Name
    if ($false -eq (Test-Path -Path $OctoServerRootFolderPath)) { throw "Root server path not found, bad configuration: $OctoServerRootFolderPath" }

    # get latest that matches format YYYYMMDD-HHMMSS
    $Folder = Get-ChildItem -Path $OctoServerRootFolderPath | Where-Object { $_.Name -match '^\d{8}-\d{6}$' } | Select-Object -Last 1
    if ($null -eq $Folder) { throw "No export folders matching pattern ^\d{8}-\d{6}$ (i.e. YYYYMMDD-HHMMSS) found under Server instance path: $OctoServerRootFolderPath" }

    $Folder.FullName
  }
}
#endregion


#region Function: Get-ODUExportOlderPath

<#
.SYNOPSIS
Gets an older (not latest) export full folder path that matches YYYYMMDD-HHMMSS name format
.DESCRIPTION
Gets an older (not latest) export full folder path that matches YYYYMMDD-HHMMSS name format.
If no value is passed for parameter Hours it returns the most recent export path before the
latest export.  If an Hours value is passed it finds the first export that many hours older
than the most recent export and returns that path.
The folder names that are parsed/returned must match YYYYMMDD-HHMMSS name format or, more
specifically: ^\d{8}-\d{6}$
If you copy & rename a folder it won't get returned unless it matches that format.
.PARAMETER Hours
Minimum number of hours older the export should be compared to latest export
.EXAMPLE
Get-ODUExportOlderPath
c:\OctoExports\MyOctoServer.octopus.app\20181107-185919
.EXAMPLE
Get-ODUExportOlderPath 24
c:\OctoExports\MyOctoServer.octopus.app\20181105-1132512
#>
function Get-ODUExportOlderPath {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateScript({$_ -ge 0})]
    [int]$Hours = 0
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # get Octopus Server instance root folder
    $OctoServerRootFolderPath = Join-Path -Path (Get-ODUConfigExportRootFolder) -ChildPath (Get-ODUConfigOctopusServer).Name
    if ($false -eq (Test-Path -Path $OctoServerRootFolderPath)) { throw "Root server path not found, bad configuration: $OctoServerRootFolderPath" }

    # get latest that matches format YYYYMMDD-HHMMSS
    [object[]]$Folders = Get-ChildItem -Path $OctoServerRootFolderPath | Where-Object { $_.Name -match '^\d{8}-\d{6}$' } | Sort-Object -Descending
    if ($Folders.Count -eq 0) { throw "No export folders matching pattern ^\d{8}-\d{6}$ (i.e. YYYYMMDD-HHMMSS) found under Server instance path: $OctoServerRootFolderPath" }
    if ($Folders.Count -eq 1) { throw "Only one export folder matching pattern ^\d{8}-\d{6}$ (i.e. YYYYMMDD-HHMMSS) found under Server instance path: $OctoServerRootFolderPath" }

    # if no Hours passed we can safely return the path of the second item
    if ($Hours -eq 0) {
      # not returning first (0) item, that's the most recent export
      $Folders[1].FullName
    } else {
      $OlderThanTime = $Folders[1].CreationTime.AddHours(-$Hours)
      # filter down folders
      [object[]]$Folders = $Folders | Where-Object { $_.CreationTime -lt $OlderThanTime } | Select-Object -First 1
      if ($Folders.Count -eq 0) {
        throw "No export folder found older than $Hours hours (or, more specifically, older than $OlderThanTime"
      } else {
        $Folders[0].FullName
      }
    }
  }
}
#endregion


#region Function: Read-ODUExportFromFiles

<#
.SYNOPSIS
Given a specific export instance folder path returns PSObject with all values of export contained as properties
.DESCRIPTION
Given a specific export instance folder path returns PSObject with all values of export contained as properties
PSObject type layout matches folder names
If FolderPath not passed, uses value from Get-ODUExportLatestPath
.PARAMETER Path
Path for export
.EXAMPLE
Read-ODUExportFromFiles
<returns PSObject with all exported data from latest export>
.EXAMPLE
Read-ODUExportFromFiles c:\OctoExports\MyOctoServer.octopus.app\20181107-185919
<returns PSObject with all exported data for that particular export folder>
#>
function Read-ODUExportFromFiles {
  [CmdletBinding()]
  param(
    [ValidateScript( {
        if (($null -ne $_) -and (! (Test-Path -Path $_))) { throw "Path does not exist: $_" }
        if (($null -ne $_) -and (! (Test-Path -Path $_ -PathType Container))) { throw "Path must be a folder, not a file: $_" }
        return $true
      })]
    [string]$Path
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # if no path passed, use latest
    if ($null -eq $Path -or ($Path.Trim() -eq '') ) { $Path = (Get-ODUExportLatestPath) }

    # confirm projects type folders found
    # make sure standard export type folders exist under path; if less than half, probably wrong path - don't process
    [string[]]$StandardExportFolders = @('DeploymentProcesses', 'Environments', 'LibraryVariableSets', 'Machines', 'Projects', 'Variables')
    $FoundCount = ($StandardExportFolders | Where-Object { Test-Path -Path (Join-Path -Path $Path -ChildPath $_) } | Measure-Object).Count
    if ($FoundCount -lt ([math]::Floor(($StandardExportFolders.Count) / 2))) {
      throw "This does not appear to be a proper export folder - less than half of the standard folders ($StandardExportFolders) were found at $Path - is this a proper export?"
    }

    $ExportData = [ordered]@{}
    [int]$Throttle = Get-ODUConfigBackgroundJobsMax
    # just in case a sneaky user manually edited the config file to go higher than 9
    if ($Throttle -gt 9) { $Throttle = 9 }
    $Jobs = Get-ChildItem -Path $Path -Directory | Start-RSJob -Throttle $Throttle -ScriptBlock {
      Param($Directory)
      # return results in hash table with Directory name and objects
      $Results = @{ Name = $Directory.Name }
      Write-Verbose "Reading folder $TypeName"
      $Data = [System.Collections.ArrayList]@()
      (Get-ChildItem -Path $Directory.FullName -Recurse -Include ('*' + $JsonExtension)).foreach({
        $Content = Get-Content -Path $_ -Raw
        if ($null -ne $Content) {
          $null = $Data.Add((ConvertFrom-Json -InputObject $Content))
        }
      })
      # add Data to results object and return
      $Results.Data = $Data
      $Results
    }
    $null = Wait-RSJob -Job $Jobs

    # there could be errors; collect all of them first and remove jobs before throwing errors or
    # other jobs will never get removed
    [object[]]$Errors = $null
    $Jobs | ForEach-Object {
      $Job = $_
      if ($Job.HasErrors) {
        $Errors += Select-Object -InputObject $Job -ExpandProperty Error
      } else {
        $TypeData = Receive-RSJob -Job $Job
        $ExportData.($TypeData.Name) = $TypeData.Data
      }
      $null = Remove-RSJob -Job $Job
    }
    if (($null -ne $Errors) -and ($Errors.Count -gt 0)) {
      $Errors | ForEach-Object { throw $_ }
    }
    [PSCustomObject]$ExportData
  }
}
#endregion
