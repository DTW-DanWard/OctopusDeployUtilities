
Set-StrictMode -Version Latest

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
