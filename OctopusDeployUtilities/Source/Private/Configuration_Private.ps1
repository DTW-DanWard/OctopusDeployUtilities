
#region Function: Confirm-ODUConfig

<#
.SYNOPSIS
Confirms configuration has been created; tell user which function to call if not
.DESCRIPTION
Confirms configuration has been created; tell user which function to call if not.
Key point: this throws an exception (with useful info) as opposed to simply
returning $true or $false.  If you want the simple bool test, use Test-ODUConfigFilePath
.EXAMPLE
Confirm-ODUConfig
$true
(config already existed)
.EXAMPLE
Confirm-ODUConfig
<error thrown>
$false
#>
function Confirm-ODUConfig {
  [CmdletBinding()]
  [OutputType([bool])]
  param()
  process {
    if ($false -eq (Test-ODUConfigFilePath)) {
      Write-Verbose 'No configuration file found'
      throw "Octopus Deploy Utilities not initialized; run: Set-ODUConfigExportRootFolder - See instructions here: $ProjectUrl"
      $false
    } else {
      $true
    }
  }
}
#endregion


#region Function: Get-ODUConfig

<#
.SYNOPSIS
Returns configuration if exists
.DESCRIPTION
Returns configuration if exists, $null otherwise
.EXAMPLE
Get-ODUConfig
<hash table with configuration>
#>
function Get-ODUConfig {
  [CmdletBinding()]
  param()
  process {
    if ($true -eq (Test-ODUConfigFilePath)) {
      Write-Verbose "Calling Import-Configuration with Version $ConfigVersion"
      Import-Configuration -Version ([version]$ConfigVersion)
    }
  }
}
#endregion


#region Function: Get-ODUConfigDecryptApiKey

<#
.SYNOPSIS
Returns decrypted API key for Octopus user account
.DESCRIPTION
Returns decrypted API key for Octopus user account
.EXAMPLE
Get-ODUConfigDecryptApiKey
API-........
#>
function Get-ODUConfigDecryptApiKey {
  [CmdletBinding()]
  [OutputType([string])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    # initial version supports only 1 server configuration so simply use that
    # this function is not public, there should be no need to check if registered by this point
    # should not have gotten this far if no server registered yet, just use first
    $ServerConfig = Get-ODUConfigOctopusServer

    # Decrypt ONLY if this IsWindows; PS versions 5 and below are only Windows, 6 has explicit variable
    $ApiKey = $ServerConfig.ApiKey
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
      Write-Verbose 'Decrypting ApiKey'
      $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( ($ApiKey | ConvertTo-SecureString) ))
    }
    $ApiKey
  }
}
#endregion


#region Function: Get-ODUConfigDefaultTypeBlackList

<#
.SYNOPSIS
Returns object array of default types for blacklist
.DESCRIPTION
Returns object array of default types for blacklist
.EXAMPLE
Get-ODUConfigDefaultTypeBlackList
...
#>
function Get-ODUConfigDefaultTypeBlackList {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  process {
    # here's the rationale for the default type black list selection below:
    # These types have a LOT of values and generally aren't important for reviewing the configuration:
    #   Deployments, Events, Packages, Releases, Tasks
    # These types don't work on cloud version and are not really important:
    #   LetsEncrypt, Licenses, MaintenanceConfiguration, ServerConfiguration, ServerStatus-Extensions, ServerStatus-SystemInfo
    # These are generally not important... but I'm on the fence with CommunityActionTemplates
    #   CommunityActionTemplates, Interruptions, Reporting

    # asdf re-add: CommunityActionTemplates
    @('CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'LetsEncrypt', 'Licenses', 'MaintenanceConfiguration', 'Packages', 'Releases', 'Reporting', 'ServerConfiguration', 'ServerStatus-Extensions', 'ServerStatus-SystemInfo', 'Tasks')
  }
}
#endregion


#region Function: Get-ODUConfigDefaultTypeWhiteList

<#
.SYNOPSIS
Returns object array of default types for whitelist
.DESCRIPTION
Returns object array of default types for whitelist
.EXAMPLE
Get-ODUConfigDefaultTypeWhiteList
...
#>
function Get-ODUConfigDefaultTypeWhiteList {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  process {
    @()
  }
}
#endregion


#region Function: Get-ODUConfigDefaultPropertyBlackList

<#
.SYNOPSIS
Returns hashtable default values for property blacklist
.DESCRIPTION
Returns hashtable default values for property blacklist
.EXAMPLE
Get-ODUConfigDefaultPropertyBlackList
...
#>
function Get-ODUConfigDefaultPropertyBlackList {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param()
  process {
    @{}
    # if you want to filter out time-sensitive properties that don't really affect the important config values
    # i.e. you want to make it easier to see changes over time by filtering out properties that are likely
    # to be different like HasLatestCalamari or LastSeen, then comment the above line and uncomment this section
    <#
    @{
      Licenses                  = @('MaintenanceExpiresIn')
      Machines                  = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary')
      OctopusServerNodes        = @('LastSeen')
      Projects                  = @('Links')
      ServerStatus              = @('MaximumAvailableVersion','MaximumAvailableVersionCoveredByLicense')
      'ServerStatus-Nuget'      = @('TotalPackages')
      'ServerStatus-SystemInfo' = @('ThreadCount', 'Uptime', 'WorkingSetBytes')
    }

    #>

  }
}
#endregion


#region Function: Get-ODUConfigDefaultPropertyWhiteList

<#
.SYNOPSIS
Returns hashtable default values for property whitelist
.DESCRIPTION
Returns hashtable default values for property whitelist
.EXAMPLE
Get-ODUConfigDefaultPropertyWhiteList
...
#>
function Get-ODUConfigDefaultPropertyWhiteList {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param()
  process {
    @{}
  }
}
#endregion





#region Function: Get-ODUConfigOctopusServer

<#
.SYNOPSIS
Get configuration settings for Octopus Server
.DESCRIPTION
Get configuration settings for Octopus Server
.EXAMPLE
Get-ODUConfigOctopusServer
Name                           Value
----                           -----
Name                           Main
Url                            https://my.octoserver.com
ApiKey                         010dfdf30ddf011423425365d1118c7a00c.....
TypeBlackList                  {CommunityActionTemplates, Deployments, Events, Interruptions...}
TypeWhiteList                  {}
PropertyBlackList              {}
...
#>
function Get-ODUConfigOctopusServer {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    # initial implementation supports only 1 server configuration so simply return that
    # but need to make sure one does exist
    Write-Verbose 'Getting config'
    $Config = Get-ODUConfig
    if ($Config.OctopusServers.Count -eq 0) {
      Write-Verbose 'No Octopus Server configured'
      throw "Octopus Server has not been registered yet; run: Add-ODUConfigOctopusServer - See instructions here: $ProjectUrl"
    } else {
      Write-Verbose 'Retrieving Octopus Server configuration'
      $Config.OctopusServers[0]
    }
  }
}
#endregion


#region Function: Initialize-ODUConfig

<#
.SYNOPSIS
Initializes configuration settings with blank/undefined values and saves
.DESCRIPTION
Initializes configuration settings with blank/undefined values and saves
.EXAMPLE
Initialize-ODUConfig
<saves configuration with empty/null/undefined vales>
#>
function Initialize-ODUConfig {
  [CmdletBinding()]
  param()
  process {
    $Config = @{}
    $Config.ExportRootFolder = $Undefined
    $Config.OctopusServers = @()
    $Config.ExternalTools = @{
      TextEditorPath = $Undefined
      DiffViewerPath = $Undefined
    }
    $Config.ParallelJobsCount = 5

    Write-Verbose 'Saving configuration with Save-ODUConfig'
    Save-ODUConfig -Config $Config
  }
}
#endregion


#region Function: Save-ODUConfig

<#
.SYNOPSIS
Saves hashtable of configuration settings to file
.DESCRIPTION
Saves hashtable of configuration settings to file.
Because the configuration stores the API encrypted, the configuration is stored using User scope.
.PARAMETER Config
Configuration data
.EXAMPLE
Save-ODUConfig $Config
<saves configuration info to file>
#>
function Save-ODUConfig {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [hashtable]$Config
  )
  process {
    # Because the configuration stores the API encrypted, the configuration is stored using User scope.
    # want to use Configuration as-is from PSGallery but there's a bug
    # https://github.com/PoshCode/Configuration/issues/8
    # work around: if specify Scope User, need to specify CompanyName and Name, which need to
    # match values in PSD1 (in case bug ever fixed)
    Write-Verbose "Saving configuration with Export-Configuration, scope user, version $ConfigVersion, company $($MyInvocation.MyCommand.Module.CompanyName) and name $($MyInvocation.MyCommand.Module.Name)"
    $Config | Export-Configuration -Scope User -Version ([version]$ConfigVersion) -CompanyName $MyInvocation.MyCommand.Module.CompanyName -Name $MyInvocation.MyCommand.Module.Name
  }
}
#endregion


#region Function: Test-ODUConfigFilePath

<#
.SYNOPSIS
Tests if configuration file exists (returns $true or $false)
.DESCRIPTION
Tests if configuration file exists; returns $true if it does, $false otherwise.
Use this to test if configuration initialized without throwing exception like
Confirm-ODUConfig does.
.EXAMPLE
Test-ODUConfigFilePath
$true
(already existed)
#>
function Test-ODUConfigFilePath {
  [CmdletBinding()]
  [OutputType([bool])]
  param()
  process {
    Test-Path -Path (Get-ODUConfigFilePath)
  }
}
#endregion
