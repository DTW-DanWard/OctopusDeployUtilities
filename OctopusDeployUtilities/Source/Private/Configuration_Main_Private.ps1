
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
