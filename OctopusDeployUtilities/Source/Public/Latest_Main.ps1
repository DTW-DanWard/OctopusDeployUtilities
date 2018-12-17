
Set-StrictMode -Version Latest

#region Function: Get-ODUExportLatestPath

<#
.SYNOPSIS
Gets latest export full folder path that matches YYYYMMDD-HHMMSS name format
.DESCRIPTION
Gets latest export full folder path that matches YYYYMMDD-HHMMSS name format
Grabs latest export found under: Root folder \ Octo Server Name
but has format name: YYYYMMDD-HHMMSS  or, more specifically: ^\d{8}-\d{6}$
If you copies/renames folder it won't get returned unless it matches that format
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
<returns PSObject with all exported data for that particular export>
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
    if ($null -eq $Path -or ($Path.Trim() -eq '') )  { $Path = (Get-ODUExportLatestPath) }

    # confirm projects type folders found
    # make sure standard export type folders exist under path; if less than half, probably wrong path - don't process
    [string[]]$StandardExportFolders = @('DeploymentProcesses', 'Environments', 'LibraryVariableSets', 'Machines', 'Projects', 'Variables')
    $FoundCount = ($StandardExportFolders | Where-Object { Test-Path -Path (Join-Path -Path $Path -ChildPath $_) } | Measure-Object).Count
    if ($FoundCount -lt ([math]::Floor(($StandardExportFolders.Count) / 2))) {
      throw "This does not appear to be a proper export folder - less than half of the standard folders ($StandardExportFolders) were found at $Path - is this a proper export?"
    }

    $ExportData = [ordered]@{}
    Get-ChildItem -Path $Path -Directory | ForEach-Object {
      $Folder = $_
      $TypeName = $Folder.Name
      [object[]]$TypeData = $null
      $TypeData = Get-ChildItem -Path $Folder.FullName -Recurse -Include ('*' + $JsonExtension) | ForEach-Object {
        Get-Content $_ | ConvertFrom-Json
      }
      $ExportData.$TypeName = $TypeData
    }
    [PSCustomObject]$ExportData
  }
}
#endregion
