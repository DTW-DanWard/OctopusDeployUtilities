
Set-StrictMode -Version Latest

#region Function: Compare-ODUExportMostRecentWithOlder

<#
.SYNOPSIS
Opens diff viewer to compare most recent export with older export
.DESCRIPTION
Opens diff viewer to compare most recent export with older export.
If no value is passed for parameter Hours it compare the most recent export with the export
that occured just before it.  If an Hours value is passed it finds the first export that many
hours older than the most recent export and compares with that.
The folder names that are parsed/returned must match YYYYMMDD-HHMMSS name format or, more
specifically: ^\d{8}-\d{6}$
If you copy & rename a folder it won't get returned unless it matches that format.
.PARAMETER Hours
Minimum number of hours older the export should be compared to latest export
.EXAMPLE
Compare-ODUExportMostRecentWithOlder
<opens the 2 most recent exports in your diff viewer>
.EXAMPLE
Compare-ODUExportMostRecentWithOlder 24
<opens the most recent export along with the first export older that is more than 24 hours
older than the most recent export in your diff viewer>
#>
function Compare-ODUExportMostRecentWithOlder {
  [CmdletBinding()]
  param(
    [ValidateScript({$_ -ge 0})]
    [int]$Hours = 0
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    $DiffEditorPath = Get-ODUConfigDiffViewer
    $ExportLatestPath = Get-ODUExportLatestPath
    $ExportOlderPath = Get-ODUExportOlderPath -Hours $Hours

    if ($DiffEditorPath -eq $Undefined) {
      throw 'Diff viewer path not defined yet; set full path to diff viewer with: Set-ODUConfigDiffViewer'
    } elseif ($false -eq (Test-Path -Path $DiffEditorPath)) {
      throw "Diff viewer not found at defined path; please set with Set-ODUConfigDiffViewer. Path: $DiffEditorPath"
    } else {
      # no need to check if $ExportLatestPath or $ExportOlderPath are valid; if they doesn't exist, exception would have been thrown
      & $DiffEditorPath $ExportOlderPath $ExportLatestPath
    }
  }
}
#endregion


#region Function: Open-ODUExportTextEditor

<#
.SYNOPSIS
Opens latest export in text editor
.DESCRIPTION
Opens latest export in text editor.  Assumes:
 - User has set path for text editor via Set-ODUConfigTextEditor.
 - That path is valid.
 - An export exists.
An alias for this function exists: odutext
 .EXAMPLE
Open-ODUExportTextEditor
<opens latest export in text editor>
.EXAMPLE
odutext
<opens latest export in text editor>
#>
function Open-ODUExportTextEditor {
  [CmdletBinding()]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    $TextEditorPath = Get-ODUConfigTextEditor
    $ExportLatestPath = Get-ODUExportLatestPath

    if ($TextEditorPath -eq $Undefined) {
      throw 'Text editor path not defined yet; set full path to text editor with: Set-ODUConfigTextEditor'
    } elseif ($false -eq (Test-Path -Path $TextEditorPath)) {
      throw "Text editor not found at defined path; please set with Set-ODUConfigTextEditor. Path: $TextEditorPath"
    } else {
      # no need to check if $ExportLatestPath is valid; if path doesn't exist, Get-ODUExportLatestPath threw exception
      & $TextEditorPath $ExportLatestPath
    }
  }
}
#endregion