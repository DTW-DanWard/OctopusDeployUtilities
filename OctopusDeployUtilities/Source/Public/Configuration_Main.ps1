
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
Add-ODUConfigOctopusServer -Url https://MyOctoServer.octopus.app -ApiKey 'API-ABCDEFGH01234567890ABCDEFGH'
<validates then sets url and api key for Octo server>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
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

    # quick validation of Url / API key; use machines roles api to test (simple and fast)
    try { Test-ODUOctopusServerCredentials -ServerDomainName $Url -ApiKey $ApiKey } catch { throw $_ }

    #region Get default Name from Url - with explanation
    # future versions will support multiple Octopus Server configurations, at that time having a
    # specific name for the configuration will be important; for now, only one is supported so
    # we will hide the Name parameter from this/all functions and just use the url domain name by default
    # get domain name by splitting on /, will be 3rd element of array
    $Name = ($Url -split '/')[2]
    #endregion

    $ApiKeySecure = Convert-ODUEncryptApiKey -ApiKey $ApiKey

    # get newly created Octopus Server configuration using name, url and apikey
    $NewOctopusServer = Get-ODUConfigOctopusServerSection -Name $Name -Url $Url -ApiKey $ApiKeySecure

    # check if config settings already exist, ask to overwrite
    $CurrentOctopusServer = Get-ODUConfigOctopusServer
    if ($null -ne ($CurrentOctopusServer)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Octopus Deploy server settings already exist"
      # if settings are the same as before just return without making any changes
      if ($Url -eq $CurrentOctopusServer.Url -and ($ApiKey -eq (Convert-ODUDecryptApiKey -ApiKey ($CurrentOctopusServer.ApiKey)))) {
        Write-Verbose "$($MyInvocation.MyCommand) :: Settings same as before"
        return
      }
      Write-Host "These are your current settings: " -NoNewline
      Write-Host $CurrentOctopusServer.Url -ForegroundColor Cyan -NoNewline
      Write-Host " :: " -NoNewline
      Write-Host "$((Convert-ODUDecryptApiKey -ApiKey ($CurrentOctopusServer.ApiKey)).Substring(0,8))..." -ForegroundColor Cyan
      $Prompt = Read-Host -Prompt "Overwrite these? (Yes/No)"
      if ($Prompt -ne 'yes') {
        Write-Verbose "$($MyInvocation.MyCommand) :: Do not overwrite settings"
        return
      } else {
        # update the other settings so not lost
        $NewOctopusServer.TypeBlacklist = $CurrentOctopusServer.TypeBlacklist
        $NewOctopusServer.TypeWhitelist = $CurrentOctopusServer.TypeWhitelist
        $NewOctopusServer.PropertyBlacklist = $CurrentOctopusServer.PropertyBlacklist
        $NewOctopusServer.PropertyWhitelist = $CurrentOctopusServer.PropertyWhitelist
        $NewOctopusServer.LastPurgeCompareFolder = $CurrentOctopusServer.LastPurgeCompareFolder
        $NewOctopusServer.Search = $CurrentOctopusServer.Search
      }
    }

    Write-Verbose "$($MyInvocation.MyCommand) :: Adding/updating Octopus Server settings in configuration"
    $Config = Get-ODUConfig
    # add as an array, overwrite existing array
    $Config.OctopusServers = , $NewOctopusServer
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration"
    Save-ODUConfig -Config $Config
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
c:\OctoExports
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
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
C:\Users\myaccount\AppData\Local\powershell\DTWConsulting.com\OctopusDeployUtilities\1.0.0\Configuration.psd1
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
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
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
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
        $null = New-Item -Path $Path -ItemType Directory -ErrorAction Stop
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
