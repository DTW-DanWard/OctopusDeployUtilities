
Set-StrictMode -Version Latest

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
    # need to prepend with comma to ensure returns an array as PowerShell changes empty arrays to null when returning from function
    # https://stackoverflow.com/questions/18476634/powershell-doesnt-return-an-empty-array-as-an-array
    ,@()
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
      ServerStatus              = @('MaintenanceExpires','MaximumAvailableVersion','MaximumAvailableVersionCoveredByLicense')
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
