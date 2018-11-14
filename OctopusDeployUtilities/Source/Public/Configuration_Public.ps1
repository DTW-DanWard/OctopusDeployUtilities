

# Because the configuration stores the API encrypted, the configuration is stored using User scope.

function Get-ODUConfigFilePath {
  Join-Path -Path (Get-StoragePath -Scope User -Version ([version]$ConfigVersion)) -ChildPath 'Configuration.psd1'
}


function Set-ODUConfigExternalTools {
  [CmdletBinding()]
  param(
    [string]$TextEditorPath,
    [string]$DiffViewerPath
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    
    $Config = Get-ODUConfig
    # asdf need logic for allowing either but not necessary both - but should be at least one

    # asdf need to test paths

    $Config.ExternalTools.TextEditorPath = $TextEditorPath
    $Config.ExternalTools.DiffViewerPath = $DiffViewerPath
    Save-ODUConfig -Config $Config
  }
}


function Get-ODUConfigExternalTools {
  [CmdletBinding()]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    (Get-ODUConfig).ExternalTools
  }
}


function Set-ODUConfigExportRootFolder {
  [CmdletBinding()]
  param(
    [string]$ExportRootFolder
  )
  process {

    try {
      # try to create export folder first before creating config, if errors creating folder then exit without updating configuration
      if ($false -eq (Test-Path -Path $ExportRootFolder)) {
        # must explicitly stop if there's an error; don't create config unless this is valid
        New-Item -Path $ExportRootFolder -ItemType Directory -ErrorAction Stop > $null
      }

      # this function is run to initialize the settings for the project so if settings files doesn't currently exist it should be created
      # however, it's possible for a user to update an existing instance to change the root export path, so only initialize config if first time
      if ($false -eq (Confirm-ODUConfig -CheckFileOnly)) {
        Initialize-ODUConfig
      } else {
        # asdf check if pre-existing folder value and if that folder exists and has content, write message to user to copy/move files
      }

      # update root folder
      $Config = Get-ODUConfig
      $Config.ExportRootFolder = $ExportRootFolder
      Save-ODUConfig -Config $Config

    } catch {
      Write-Host "`nAn error occurred creating export root folder; is this valid? " -ForegroundColor Cyan -NoNewline
      Write-Host "$ExportRootFolder`n"
    }
  }
}


function Get-ODUConfigExportRootFolder {
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    (Get-ODUConfig).ExportRootFolder
  }
}


function Add-ODUConfigOctopusServer {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    
    $Config = Get-ODUConfig
    
    # asdf if config settings already exist, ask to overwrite????
    # asdf validate server url format
    # asdf url remove trailing / if present
    # asdf validate server url and credentials - test swagger or /api or something

    # Encrypt ONLY if this IsWindows; PS versions 5 and below are only Windows, 6 has explicit variable
    $ApiKeySecure = $ApiKey
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
      $ApiKeySecure = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force | ConvertFrom-SecureString
    }

    $OctoServer = @{ }
    $OctoServer.Name = $Name
    $OctoServer.Url = $Url
    # $OctoServer.ApiKey = $ApiKey
    $OctoServer.ApiKey = $ApiKeySecure
    # asdf values (in this case, empty array) to separate function
    $OctoServer.TypeWhiteList = @()
    # asdf move these to separate function with explanation
    $OctoServer.TypeBlackList = 'CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'Releases', 'Reporting', 'Tasks', 'Packages'
    # Use this list (check latest export proto to see if updated)
    # 'CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'LetsEncrypt', 'Licenses', 'MaintenanceConfiguration', 'Packages', 'Releases', 'Reporting', 'ServerConfiguration', 'ServerStatus-Extensions', 'ServerStatus-SystemInfo', 'Tasks'
    # Explanation
    # Skip these type by default
    # These types have a LOT of values:
    #   Events, Deployments, Releases, Tasks, Packages
    # Don't work on cloud version and not really important
    #   LetsEncrypt, Licenses, MaintenanceConfiguration, ServerConfiguration, ServerStatus-Extensions, ServerStatus-SystemInfo
    # Not important:
    #   CommunityActionTemplates, Interruptions, Reporting



    $OctoServer.PropertyWhiteList = @{ }
    $OctoServer.PropertyBlackList = @{ }
    $OctoServer.LastPurgeCompareFolder = $Undefined
    $OctoServer.Search = @{
      CodeRootPaths     = $Undefined
      CodeSearchPattern = $Undefined
    }
    $Config.OctopusServers += $OctoServer
    Save-ODUConfig -Config $Config
  }
}



function asdf {
  Get-ODUConfigOctopusServer
}
