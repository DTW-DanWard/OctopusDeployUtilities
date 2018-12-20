
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


#region Function: New-ODUExportItemFolder

<#
.SYNOPSIS
Creates folder if doesn't already exist
.DESCRIPTION
Creates folder if doesn't already exist
.PARAMETER FolderPath
Full path to new folder
.EXAMPLE
New-ODUExportItemFolder -FolderPath c:\temp\MyNewFolder
<Creates c:\temp\MyNewFolder if doesn't exist>
#>
function New-ODUExportItemFolder {
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
      $null = New-Item -ItemType Directory -Path $FolderPath
    }
  }
}
#endregion


#region Function: New-ODUFolderForEachApiCall

<#
.SYNOPSIS
Creates a folder for each rest api call in ApiCallInfo under ParentFolder
.DESCRIPTION
Creates a folder for each rest api call in ApiCallInfo under ParentFolder
.PARAMETER ParentFolder
Folder under which to create the new folders
.PARAMETER ApiCalls
Object array of api calls
.EXAMPLE
New-ODUFolderForEachApiCall -ParentFolder c:\Temp -ApiCallInfo <PSObjects with api call info>
#>
function New-ODUFolderForEachApiCall {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ParentFolder,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object[]]$ApiCalls
  )
  process {
    Write-Verbose "$($MyInvocation.MyCommand) :: Parent folder is: $ParentFolder"
    $ApiCalls | ForEach-Object {
      New-ODUExportItemFolder -FolderPath (Join-Path -Path $ParentFolder -ChildPath (Get-ODUFolderNameForApiCall -ApiCall $_))
    }
  }

}
#endregion


#region Function: New-ODURootExportFolder

<#
.SYNOPSIS
Creates datetime stamp folder for current export under main export folder \ <ServerName> and returns path
.DESCRIPTION
Creates datetime stamp folder for current export under main export folder \ <ServerName> and returns path
.PARAMETER MainExportRoot
Root export folder for all exports
.PARAMETER ServerName
Name of Octopus Deploy server instance
.PARAMETER DateTime
DateTime to use for actual export-instance folder name
.EXAMPLE
New-ODURootExportFolder -FolderPath c:\temp\MyNewFolder
<Creates c:\temp\MyNewFolder if doesn't exist>
#>
function New-ODURootExportFolder {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$MainExportRoot,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [datetime]$DateTime

    )
  #endregion
  process {
    # root folder was tested/created when initially set so no need to test if $MainExportRoot exists or create it
    # add $ServerName to path and check if exists
    $Folder = Join-Path -Path $MainExportRoot -ChildPath $ServerName
    # Server-specific folder may not exist, so create if necessary
    if ($false -eq (Test-Path -Path $Folder)) { $null = New-Item -ItemType Directory -Path $Folder }
    # add datetime stamp folder name, this better be unique, don't check if exists
    $Folder = Join-Path -Path $Folder -ChildPath ('{0:yyyyMMdd-HHmmss}' -f $DateTime)
    Write-Verbose "$($MyInvocation.MyCommand) :: Create export root folder: $Folder"
    $null = New-Item -ItemType Directory -Path $Folder
    $Folder
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
