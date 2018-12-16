
Set-StrictMode -Version Latest

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
