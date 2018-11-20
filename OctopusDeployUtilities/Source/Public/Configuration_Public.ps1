
Set-StrictMode -Version Latest

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
    [ValidatePattern("^API\-[a-z0-9]{10}[a-z0-9]+$")]
    [string]$ApiKey
    # my API key is "API-" plus 27 alphanumeric characters - but I don't know if all are and it's not published
    # so let's just validate that it's at least 10 characters
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

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

    #region Creating Octopus Server configuration section
    # this should be refactored
    Write-Verbose "$($MyInvocation.MyCommand) :: Creating Octopus Server configuration section"
    $OctoServer = @{ }
    Write-Verbose "$($MyInvocation.MyCommand) :: Octopus server Name: $Name"
    $OctoServer.Name = $Name
    Write-Verbose "$($MyInvocation.MyCommand) :: Octopus server Url: $Url"
    $OctoServer.Url = $Url
    Write-Verbose "$($MyInvocation.MyCommand) :: Octopus API Key - first 7 characters: $($ApiKey.Substring(0,7))..."
    $OctoServer.ApiKey = $ApiKeySecure
    $OctoServer.TypeBlacklist = Get-ODUConfigDefaultTypeBlacklist
    $OctoServer.TypeWhitelist = Get-ODUConfigDefaultTypeWhitelist
    $OctoServer.PropertyBlacklist = Get-ODUConfigDefaultPropertyBlacklist
    $OctoServer.PropertyWhitelist = Get-ODUConfigDefaultPropertyWhitelist
    $OctoServer.LastPurgeCompareFolder = $Undefined
    $OctoServer.Search = @{
      CodeRootPaths     = $Undefined
      CodeSearchPattern = $Undefined
    }
    #endregion

    # check if config settings already exist, ask to overwrite
    $OctopusServer = Get-ODUConfigOctopusServer
    if ($null -ne ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings already exist"
      # if settings are the same as before just return without making any changes
      if ($Url -eq $OctopusServer.Url -and ($ApiKey -eq (Convert-ODUDecryptApiKey -ApiKey ($OctopusServer.ApiKey)))) {
        Write-Verbose "$($MyInvocation.MyCommand) :: Settings same as before"
        return
      }
      Write-Host "These settings already exist: " -NoNewline
      Write-Host $OctopusServer.Url -ForegroundColor Cyan -NoNewline
      Write-Host " :: " -NoNewline
      Write-Host "$((Convert-ODUDecryptApiKey -ApiKey ($OctopusServer.ApiKey)).Substring(0,7))" -ForegroundColor Cyan
      $Prompt = Read-Host -Prompt "Overwrite? (Yes/No)"
      if ($Prompt -ne 'yes') {
        Write-Verbose "$($MyInvocation.MyCommand) :: Do not overwrite settings"
        return
      }
    }

    Write-Verbose "$($MyInvocation.MyCommand) :: Adding Octopus Server settings to configuration"
    $Config = Get-ODUConfig
    # add as an array, overwrite existing array
    $Config.OctopusServers = , $OctoServer
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration"
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


#region Function: Get-ODUConfigPropertyBlacklist

<#
.SYNOPSIS
Gets values for property black list
.DESCRIPTION
Gets values for property black list
.EXAMPLE
Get-ODUConfigPropertyBlacklist
<property black list - could be null>
#>
function Get-ODUConfigPropertyBlacklist {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet return $null
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      return
    }
    # else return
    Write-Verbose "$($MyInvocation.MyCommand) :: Returning values"
    $OctopusServer.PropertyBlacklist
  }
}
#endregion


#region Function: Get-ODUConfigPropertyWhitelist

<#
.SYNOPSIS
Gets values for property white list
.DESCRIPTION
Gets values for property white list
.EXAMPLE
Get-ODUConfigPropertyWhitelist
<property white list - could be null>
#>
function Get-ODUConfigPropertyWhitelist {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet return $null
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      return
    }
    # else return
    Write-Verbose "$($MyInvocation.MyCommand) :: Returning values"
    $OctopusServer.PropertyWhitelist
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


#region Function: Get-ODUConfigTypeBlacklist

<#
.SYNOPSIS
Gets values for type black list
.DESCRIPTION
Gets values for type black list
.EXAMPLE
Get-ODUConfigTypeBlacklist
<type black list - could be null>
#>
function Get-ODUConfigTypeBlacklist {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet return $null
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      return
    }
    # else return
    Write-Verbose "$($MyInvocation.MyCommand) :: Returning values"
    $OctopusServer.TypeBlacklist
  }
}
#endregion


#region Function: Get-ODUConfigTypeWhitelist

<#
.SYNOPSIS
Gets values for type white list
.DESCRIPTION
Gets values for type white list
.EXAMPLE
Get-ODUConfigTypeWhitelist
<type white list - could be null>
#>
function Get-ODUConfigTypeWhitelist {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet return $null
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      return
    }
    # else return
    Write-Verbose "$($MyInvocation.MyCommand) :: Returning values"
    $OctopusServer.TypeWhitelist
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
        Write-Verbose "$($MyInvocation.MyCommand) :: Creating root export folder: $Path"
        New-Item -Path $Path -ItemType Directory -ErrorAction Stop > $null
      }

      # this function is run to initialize the settings for the project so if settings files doesn't currently exist it should be created
      # however, it's possible for a user to update an existing instance to change the root export path, so only initialize config if first time
      # use Test-ODUConfigFilePath instead of Confirm-ODUConfig; won't throw error if no config
      if ($false -eq (Test-ODUConfigFilePath)) {
        Write-Verbose "$($MyInvocation.MyCommand) :: Initializing configuration"
        Initialize-ODUConfig
      }

      $Config = Get-ODUConfig
      # store old value for now in case need to alert user
      $OldExportRootFolder = $Config.ExportRootFolder
      # update root folder and save
      $Config.ExportRootFolder = $Path
      Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration with ExportRootFolder: $Path"
      Save-ODUConfig -Config $Config

      # if 'old' value isn't undefined (system initialized before) then export root folder has been set before
      # if so, and if new value is different, give use reminder to move files
      if ($OldExportRootFolder -ne $Undefined -and $OldExportRootFolder -ne $Path) {
        Write-Verbose "$($MyInvocation.MyCommand) :: Old configuration already found with different setting, user is updating export root folder"
        Write-Output "Root export location changed from $OldExportRootFolder to $Path; make sure to move any old exports to new location."
      }
    } catch {
      throw "An error occurred creating export root folder; invalid path? $Path :: $_"
    }
  }
}
#endregion


#region Function: Set-ODUConfigPropertyBlacklist

<#
.SYNOPSIS
Sets value for property black list
.DESCRIPTION
Sets value for property black list
.PARAMETER TypePropertyListLookup
Hashtable of types|prperty names to not export
.EXAMPLE
Set-ODUConfigPropertyBlacklist -TypePropertyListLookup @{ Licenses = @('MaintenanceExpiresIn'); Machines = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary') }
<sets property black list - don't export those particular properties on those types>
#>
function Set-ODUConfigPropertyBlacklist {
  [CmdletBinding()]
  param(
    [hashtable]$TypePropertyListLookup
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # validate type name values
    Find-ODUInvalidRestApiTypeName -TypeName ($TypePropertyListLookup.Keys)


    Write-Verbose "$($MyInvocation.MyCommand) :: Getting Octopus server configuration"
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet throw error
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      throw "Octopus Deploy server not configured; run: Add-ODUConfigOctopusServer - See instructions here: $ProjectUrl"
    }

    $Config = Get-ODUConfig
    # reset property whitelist - can't have blacklist and whitelist at same time
    Write-Verbose "$($MyInvocation.MyCommand) :: Reset whitelist and set blacklist"
    $Config.OctopusServers[0].PropertyWhitelist = @{}
    $Config.OctopusServers[0].PropertyBlacklist = $TypePropertyListLookup
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration"
    Save-ODUConfig -Config $Config
  }
}
#endregion


#region Function: Set-ODUConfigPropertyWhitelist

<#
.SYNOPSIS
Sets value for property white list
.DESCRIPTION
Sets value for property white list
.PARAMETER TypePropertyListLookup
Hashtable of types|prperty names to not export
.EXAMPLE
Set-ODUConfigPropertyBlacklist -TypePropertyListLookup @{ Licenses = @('MaintenanceExpiresIn'); Machines = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary') }
<sets property black list - ONLY export those particular properties on those types>
#>
function Set-ODUConfigPropertyWhitelist {
  [CmdletBinding()]
  param(
    [hashtable]$TypePropertyListLookup
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # validate type name values
    Find-ODUInvalidRestApiTypeName -TypeName ($TypePropertyListLookup.Keys)

    Write-Verbose "$($MyInvocation.MyCommand) :: Getting Octopus server configuration"
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet throw error
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      throw "Octopus Deploy server not configured; run: Add-ODUConfigOctopusServer - See instructions here: $ProjectUrl"
    }

    $Config = Get-ODUConfig
    # reset property blacklist - can't have blacklist and whitelist at same time
    Write-Verbose "$($MyInvocation.MyCommand) :: Reset blacklist and set whitelist"
    $Config.OctopusServers[0].PropertyBlacklist = @{}
    $Config.OctopusServers[0].PropertyWhitelist = $TypePropertyListLookup
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration"
    Save-ODUConfig -Config $Config
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


#region Function: Set-ODUConfigTypeBlacklist

<#
.SYNOPSIS
Sets value for type name blacklist
.DESCRIPTION
Sets value for type name blacklist
.PARAMETER TypeName
List of names of types to not export
.EXAMPLE
Set-ODUConfigTypeBlacklist -List @('Deployments', 'Events', 'Interruptions')
<sets type black list to those values>
#>
function Set-ODUConfigTypeBlacklist {
  [CmdletBinding()]
  param(
    [string[]]$TypeName
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # validate type name values
    Find-ODUInvalidRestApiTypeName -TypeName $TypeName

    Write-Verbose "$($MyInvocation.MyCommand) :: Getting Octopus server configuration"
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet throw error
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      throw "Octopus Deploy server not configured; run: Add-ODUConfigOctopusServer - See instructions here: $ProjectUrl"
    }

    $Config = Get-ODUConfig
    # reset type whitelist - can't have blacklist and whitelist at same time
    Write-Verbose "$($MyInvocation.MyCommand) :: Reset whitelist and set blacklist"
    $Config.OctopusServers[0].TypeWhitelist = @()
    $Config.OctopusServers[0].TypeBlacklist = $TypeName
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration"
    Save-ODUConfig -Config $Config
  }
}
#endregion


#region Function: Set-ODUConfigTypeWhitelist

<#
.SYNOPSIS
Sets value for type name whitelist
.DESCRIPTION
Sets value for type name whitelist
.PARAMETER TypeName
List of names of types to ONLY export
.EXAMPLE
Set-ODUConfigTypeWhitelist -List @('Deployments', 'Events', 'Interruptions')
<sets type white list to those values>
#>
function Set-ODUConfigTypeWhitelist {
  [CmdletBinding()]
  param(
    [string[]]$TypeName
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # validate type name values
    Find-ODUInvalidRestApiTypeName -TypeName $TypeName

    Write-Verbose "$($MyInvocation.MyCommand) :: Getting Octopus server configuration"
    $OctopusServer = Get-ODUConfigOctopusServer
    # if not configured yet throw error
    if ($null -eq ($OctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings not configured"
      throw "Octopus Deploy server not configured; run: Add-ODUConfigOctopusServer - See instructions here: $ProjectUrl"
    }

    $Config = Get-ODUConfig
    # reset type blacklist - can't have blacklist and whitelist at same time
    Write-Verbose "$($MyInvocation.MyCommand) :: Reset blacklist and set whitelist"
    $Config.OctopusServers[0].TypeBlacklist = @()
    $Config.OctopusServers[0].TypeWhitelist = $TypeName
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration"
    Save-ODUConfig -Config $Config
  }
}
#endregion
