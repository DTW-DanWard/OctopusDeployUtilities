

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
