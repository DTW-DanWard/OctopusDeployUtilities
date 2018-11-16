
#region Function: Add-ODUConfigOctopusServer

<#
.SYNOPSIS
Sets Octopus Server configuration (root url and API key)
.DESCRIPTION
Sets Octopus Server configuration (root url and API key)
See this for more info about API key: https://octopus.com/docs/api-and-integration/api/how-to-create-an-api-key

Note: this function is Add- not Set- because (eventually) ODU will support multiple Octo setups in the configuration
.PARAMETER Url
Root url of Octopus server
.PARAMETER ApiKey
API Key for a specific user account to use for exports
.EXAMPLE
Add-ODUConfigOctopusServer -Url https://MyOctoServer.octopus.app -ApiKey 'API-123456789012345678901234567'
<validates then sets url and api key for Octo server>
#>
function Add-ODUConfigOctopusServer {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}\/?$")]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^API\-[a-z0-9]{27}$")]
    [string]$ApiKey
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # asdf if config settings already exist, ask to overwrite????

    # if $Url ends with trailing /, remove it
    if ($Url.EndsWith('/')) { $Url = $Url.Substring(0, $Url.Length - 1) }

    # quick validation of Url / API key - refactor this
    try {
      # use machine roles api to test - should be fast, simple call
      Invoke-WebRequest -Uri ($Url + "/api/machineroles/all") -Headers @{ 'X-Octopus-ApiKey' = $ApiKey } > $null
    } catch {
      throw "Error occurred testing Octopus Deploy credentials with $Url and $ApiKey - are these correct?  Error was: $_"
    }

    #region Get default Name from Url - with explanation
    # future versions will support multiple Octopus Server configurations, at that time having a
    # specific name for the configuration will be important; for now, only one is supported so
    # we will hide the Name parameter from this/all functions and just use the url domain name by default
    # first, remove http:// or https:// protocol
    $Name = $Url.Substring($Url.IndexOf('//') + 2)
    # next, get domain name (content) before first / (if it even exists)
    $Name = ($Name -split '/')[0]
    #endregion

    # Encrypt ONLY if this IsWindows; PS versions 5 and below are only Windows, 6 has explicit variable
    $ApiKeySecure = $ApiKey
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
      $ApiKeySecure = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force | ConvertFrom-SecureString
    }

    Write-Verbose 'Creating Octopus Server configuration section'
    $OctoServer = @{ }
    Write-Verbose "Octopus server Name: $Name"
    $OctoServer.Name = $Name
    Write-Verbose "Octopus server Url: $Url"
    $OctoServer.Url = $Url
    Write-Verbose "Octopus API Key - first 7 characters: $($ApiKey.Substring(0,7))..."
    $OctoServer.ApiKey = $ApiKeySecure
    $OctoServer.TypeBlackList = Get-ODUConfigDefaultTypeBlackList
    $OctoServer.TypeWhiteList = Get-ODUConfigDefaultTypeWhiteList
    $OctoServer.PropertyBlackList = Get-ODUConfigDefaultPropertyBlackList
    $OctoServer.PropertyWhiteList = Get-ODUConfigDefaultPropertyWhiteList
    $OctoServer.LastPurgeCompareFolder = $Undefined
    $OctoServer.Search = @{
      CodeRootPaths     = $Undefined
      CodeSearchPattern = $Undefined
    }
    Write-Verbose 'Adding Octopus Server settings to configuration'
    $Config = Get-ODUConfig
    $Config.OctopusServers += $OctoServer
    Save-ODUConfig -Config $Config
  }
}
#endregion


#region Function: Get-ODUConfigDiffViewer

<#
.SYNOPSIS
Gets path for diff viewer on local machine
.DESCRIPTION
Gets path for diff viewer on local machine
.EXAMPLE
Get-ODUConfigDiffViewer
<path to diff viewer>
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


#region Function: Get-ODUConfigExportRootFolder

<#
.SYNOPSIS
Returns export root folder path
.DESCRIPTION
Returns export root folder path
.EXAMPLE
Get-ODUConfigExportRootFolder
<export root folder path>
#>
function Get-ODUConfigExportRootFolder {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    (Get-ODUConfig).ExportRootFolder
  }
}
#endregion


#region Function: Get-ODUConfigFilePath

<#
.SYNOPSIS
Gets path to configuration file
.DESCRIPTION
Gets path to configuration file
.EXAMPLE
Get-ODUConfigFilePath
<path to file Configuration.psd1>
#>
function Get-ODUConfigFilePath {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    # Because the configuration stores the API encrypted, the configuration is stored using User scope.
    Join-Path -Path (Get-ConfigurationPath -Scope User -Version ([version]$ConfigVersion)) -ChildPath 'Configuration.psd1'
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
      Write-Verbose "Path is not valid: $Path"
      throw "Path is not valid: $Path"
    } else {
      $Config = Get-ODUConfig
      $Config.ExternalTools.DiffViewerPath = $Path
      Write-Verbose "Saving configuration with DiffViewerPath: $Path"
      Save-ODUConfig -Config $Config
    }
  }
}
#endregion


#region Function: Set-ODUConfigExportRootFolder

<#
.SYNOPSIS
Sets path for export root folder
.DESCRIPTION
Sets path for export root folder
.PARAMETER Path
Path to export root folder
.EXAMPLE
Set-ODUConfigExportRootFolder -Path c:\OctoExports
<sets root path for exports>
#>
function Set-ODUConfigExportRootFolder {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  process {

    try {
      # try to create export folder first before creating config, if errors creating folder then exit without updating configuration
      if ($false -eq (Test-Path -Path $Path)) {
        # must explicitly stop if there's an error; don't create config unless this is valid
        Write-Verbose "Creating root export folder: $Path"
        New-Item -Path $Path -ItemType Directory -ErrorAction Stop > $null
      }

      # this function is run to initialize the settings for the project so if settings files doesn't currently exist it should be created
      # however, it's possible for a user to update an existing instance to change the root export path, so only initialize config if first time
      # use Test-ODUConfigFilePath instead of Confirm-ODUConfig; won't throw error if no config
      if ($false -eq (Test-ODUConfigFilePath)) {
        Write-Verbose 'Initializing configuration'
        Initialize-ODUConfig
      }

      $Config = Get-ODUConfig
      # store old value for now in case need to alert user
      $OldExportRootFolder = $Config.ExportRootFolder
      # update root folder and save
      $Config.ExportRootFolder = $Path
      Write-Verbose "Saving configuration with ExportRootFolder: $Path"
      Save-ODUConfig -Config $Config

      # if 'old' value isn't undefined (system initialized before) then export root folder has been set before
      # if so, and if new value is different, give use reminder to move files
      if ($OldExportRootFolder -ne $Undefined -and $OldExportRootFolder -ne $Path) {
        Write-Verbose 'Old configuration already found with different setting, user is updating export root folder'
        Write-Output "Root export location changed from $OldExportRootFolder to $Path; make sure to move any old exports to new location."
      }
    } catch {
      throw "An error occurred creating export root folder; invalid path? $Path :: $_"
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
      Write-Verbose "Path is not valid: $Path"
      throw "Path is not valid: $Path"
    } else {
      $Config = Get-ODUConfig
      $Config.ExternalTools.TextEditorPath = $Path
      Write-Verbose "Saving configuration with TextEditorPath: $Path"
      Save-ODUConfig -Config $Config
    }
  }
}
#endregion
