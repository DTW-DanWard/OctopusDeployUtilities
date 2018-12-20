
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
    , @()
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
    # by default the Octopus Deploy REST API includes ALL of the id to name lookup information
    # for every call for LibraryVariableSets, Projects and Variables
    # this info is unnecessary because the post processing already adds this info to the object but
    # it doesn't add ALL the lookup info, just the id->name for the ids actually being used
    # if you are working with an instance with hundreds of servers, many many environments, many
    # roles,  etc. it can quickly add up; for one test instance I worked with ScopeValues was well
    # over 1000 lines extra to every LibraryVariableSet, Project and Variable file
    # so let's filter them out
    @{
      LibraryVariableSets = @('ScopeValues')
      Projects            = @('ScopeValues')
      Variables           = @('ScopeValues')
    }
    # if you want to filter out time-sensitive properties that don't really affect the important config values
    # i.e. you want to make it easier to see changes over time by filtering out properties that are likely
    # to be different like HasLatestCalamari or LastSeen, you should include these items along with the value
    # above
    <#
    @{
      Licenses                  = @('MaintenanceExpiresIn')
      Machines                  = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary')
      OctopusServerNodes        = @('LastSeen')
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
