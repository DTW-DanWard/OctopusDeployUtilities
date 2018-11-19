
Set-StrictMode -Version Latest

#region Function: Format-ODUSanitizedFileName

<#
.SYNOPSIS
Removes questionable characters from string so can be used as file name
.DESCRIPTION
Removes questionable characters from string so can be used as file name
Whitelisted characters: a-z 0-9 space dash
Trims as well
.PARAMETER FileName
File name to review and clean
.EXAMPLE
Format-ODUSanitizedFileName -FileName " Test#File  /4QQ "
<returns (no quotes): "TestFile 4QQ"
#>
function Format-ODUSanitizedFileName {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FileName
  )
  #endregion
  process {
    # clean out characters non alpha-numeric, space, dash
    $FileName = $FileName -replace '[^a-z0-9 -]', ''
    # replace any multiple spaces with a single space
    $FileName = $FileName -replace ' +', ' '
    # and trim spaces as well
    $FileName.Trim()
  }
}
#endregion



#region Function: New-ODUIExportItemFolder

<#
.SYNOPSIS
Creates folder if doesn't already exist
.DESCRIPTION
Creates folder if doesn't already exist
.PARAMETER FolderPath
Full path to new folder
.EXAMPLE
New-ODUIExportItemFolder -FolderPath c:\temp\MyNewFolder
<Creates c:\temp\MyNewFolder if doesn't exist>
#>
function New-ODUIExportItemFolder {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FolderPath
  )
  #endregion
  process {
    if ($false -eq (Test-Path -Path $FolderPath)) {
      New-Item -ItemType Directory -Path $FolderPath > $null
    }
  }
}
#endregion


#region Function: Out-ODUFileJson

<#
.SYNOPSIS
Converts PSObject data to JSON and saves in file
.DESCRIPTION
Converts PSObject data to JSON and saves in file
.PARAMETER FilePath
Path to file to save
.PARAMETER Data
Data to save
.EXAMPLE
Out-ODUFileJson -FilePath c:\temp\MyFile.json  $MyPSObject
<Converts $MyPSObject to JSON format and saves to file>
#>
function Out-ODUFileJson {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FilePath,
    $Data
  )
  #endregion
  process {
    # simply convert to JSON and export as-is
    $Data | ConvertTo-Json -Depth 100 | Out-File -FilePath $FilePath
  }
}
#endregion
