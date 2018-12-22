
Set-StrictMode -Version Latest

#region Function: Get-ODUConfigDiffViewer

<#
.SYNOPSIS
Gets path for diff viewer on local machine
.DESCRIPTION
Gets path for diff viewer on local machine
.EXAMPLE
Get-ODUConfigDiffViewer
<path to diff viewer>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Get-ODUConfigDiffViewer {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    (Get-ODUConfig).ExternalTools.DiffViewerPath
  }
}
#endregion


#region Function: Get-ODUConfigTextEditor

<#
.SYNOPSIS
Gets path for text editor on local machine
.DESCRIPTION
Gets path for text editor on local machine
.EXAMPLE
Get-ODUConfigTextEditor
<path to text editor>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Get-ODUConfigTextEditor {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    (Get-ODUConfig).ExternalTools.TextEditorPath
  }
}
#endregion


#region Function: Set-ODUConfigDiffViewer

<#
.SYNOPSIS
Sets path for diff viewer on local machine
.DESCRIPTION
Sets path for diff viewer on local machine
.PARAMETER Path
Path to diff viewer
.EXAMPLE
Set-ODUConfigDiffViewer -Path 'C:\Program Files\ExamDiff Pro\ExamDiff.exe'
<sets path to diff viewer>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Set-ODUConfigDiffViewer {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    if ($false -eq (Test-Path -Path $Path)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Path is not valid: $Path"
      throw "Path is not valid: $Path"
    } else {
      $Config = Get-ODUConfig
      $Config.ExternalTools.DiffViewerPath = $Path
      Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration with DiffViewerPath: $Path"
      Save-ODUConfig -Config $Config
    }
  }
}
#endregion


#region Function: Set-ODUConfigTextEditor

<#
.SYNOPSIS
Sets path for text editor on local machine
.DESCRIPTION
Sets path for text editor on local machine
.PARAMETER Path
Path to text editor
.EXAMPLE
Set-ODUConfigTextEditor -Path ((Get-Command code.cmd).Source)
<sets path for VS Code - if you have it installed>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Set-ODUConfigTextEditor {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    if ($false -eq (Test-Path -Path $Path)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Path is not valid: $Path"
      throw "Path is not valid: $Path"
    } else {
      $Config = Get-ODUConfig
      $Config.ExternalTools.TextEditorPath = $Path
      Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration with TextEditorPath: $Path"
      Save-ODUConfig -Config $Config
    }
  }
}
#endregion
