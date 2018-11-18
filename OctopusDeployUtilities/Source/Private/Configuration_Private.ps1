
Set-StrictMode -Version Latest

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
      Write-Verbose "$($MyInvocation.MyCommand) :: No configuration file found"
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
      Write-Verbose "$($MyInvocation.MyCommand) :: Calling Import-Configuration with Version $ConfigVersion"
      Import-Configuration -Version ([version]$ConfigVersion)
    }
  }
}
#endregion


#region Function: Convert-ODUDecryptApiKey

<#
.SYNOPSIS
Decrypts an encrypted value
.DESCRIPTION
Decrypts an encrypted value
.PARAMETER ApiKey
Value to decrypt
.EXAMPLE
Convert-ODUDecryptApiKey '....'
API-........
#>
function Convert-ODUDecryptApiKey {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey
  )
  process {
    # Decrypt ONLY if this IsWindows; PS versions 5 and below are only Windows, 6 has explicit variable
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
      Write-Verbose "$($MyInvocation.MyCommand) :: Decrypting ApiKey"
      $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( ($ApiKey | ConvertTo-SecureString) ))
    }
    $ApiKey
  }
}
#endregion


#region Function: Get-ODUConfigDefaultTypeBlacklist

<#
.SYNOPSIS
Returns object array of default types for blacklist
.DESCRIPTION
Returns object array of default types for blacklist
.EXAMPLE
Get-ODUConfigDefaultTypeBlacklist
...
#>
function Get-ODUConfigDefaultTypeBlacklist {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  process {
    # here's the rationale for the default type black list selection below:
    # These types have a LOT of values and generally aren't important for reviewing the configuration:
    #   Deployments, Events, Packages, Releases, Tasks
    # These types don't work on cloud version and are not really important:
    #   LetsEncrypt, Licenses, MaintenanceConfiguration, OctopusServerNodes, ServerConfiguration, ServerStatus-Extensions, ServerStatus-SystemInfo
    # These are generally not important... but I'm on the fence with CommunityActionTemplates
    #   CommunityActionTemplates, Interruptions, Reporting

    # asdf re-add: CommunityActionTemplates
    @('CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'LetsEncrypt', 'Licenses', 'MaintenanceConfiguration', 'OctopusServerNodes', 'Packages', 'Releases', 'Reporting', 'ServerConfiguration', 'ServerStatus-Extensions', 'ServerStatus-SystemInfo', 'Tasks')
  }
}
#endregion


#region Function: Get-ODUConfigDefaultTypeWhitelist

<#
.SYNOPSIS
Returns object array of default types for whitelist
.DESCRIPTION
Returns object array of default types for whitelist
.EXAMPLE
Get-ODUConfigDefaultTypeWhitelist
...
#>
function Get-ODUConfigDefaultTypeWhitelist {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  process {
    @()
  }
}
#endregion


#region Function: Get-ODUConfigDefaultPropertyBlacklist

<#
.SYNOPSIS
Returns hashtable default values for property blacklist
.DESCRIPTION
Returns hashtable default values for property blacklist
.EXAMPLE
Get-ODUConfigDefaultPropertyBlacklist
...
#>
function Get-ODUConfigDefaultPropertyBlacklist {
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


#region Function: Get-ODUConfigDefaultPropertyWhitelist

<#
.SYNOPSIS
Returns hashtable default values for property whitelist
.DESCRIPTION
Returns hashtable default values for property whitelist
.EXAMPLE
Get-ODUConfigDefaultPropertyWhitelist
...
#>
function Get-ODUConfigDefaultPropertyWhitelist {
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
TypeBlacklist                  {CommunityActionTemplates, Deployments, Events, Interruptions...}
TypeWhitelist                  {}
PropertyBlacklist              {}
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
    Write-Verbose "$($MyInvocation.MyCommand) :: Getting config"
    $Config = Get-ODUConfig
    if ($Config.OctopusServers.Count -eq 0) {
      Write-Verbose "$($MyInvocation.MyCommand) :: No Octopus Server configured"
      $null
    } else {
      Write-Verbose "$($MyInvocation.MyCommand) :: Retrieving Octopus Server configuration"
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

    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration with Save-ODUConfig"
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
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration with Export-Configuration, scope user, version $ConfigVersion, company $($MyInvocation.MyCommand.Module.CompanyName) and name $($MyInvocation.MyCommand.Module.Name)"
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
