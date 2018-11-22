
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
c:\OctoExports\MyOctoServer.com\20181107-185919
#>
function Get-ODUExportLatestPath {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    # get Octopus Server instance root folder
    $OctoServerRootFolderPath = Join-Path -Path (Get-ODUConfigExportRootFolder) -ChildPath (Get-ODUConfigOctopusServer).Name
    if ($false -eq (Test-Path -Path $OctoServerRootFolderPath)) { throw "Root server path not found, bad configuration: $OctoServerRootFolderPath" }

    # get latest that matches format YYYYMMDD-HHMMSS
    $Folder = Get-ChildItem -Path $OctoServerRootFolderPath | Where-Object { $_.Name -match '^\d{8}-\d{6}$' } | Select-Object -First 1
    if ($null -eq $Folder) { throw "No export folders matching pattern ^\d{8}-\d{6}$ (i.e. YYYYMMDD-HHMMSS) found under Server instance path: $OctoServerRootFolderPath" }

    $Folder.FullName
  }
}
#endregion
