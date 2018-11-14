
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
      Import-Configuration -Version ([version]$ConfigVersion)
    }
  }
}


<#
.SYNOPSIS
Tests if configuration file exists
.DESCRIPTION
Tests if configuration file exists; returns $true if it does, $false otherwise
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



<#
.SYNOPSIS
Confirms configuration has been created; tell user which function to call if not
.DESCRIPTION
Confirms configuration has been created; tell user which function to call if not
.PARAMETER CheckFileOnly
If specified, checks if file is found but does not produce Host output if not (only returns $false)
.EXAMPLE
Confirm-ODUConfig
$true
(config already existed)
.EXAMPLE
Confirm-ODUConfig
$false
<plus content written to host - gasp!>
#>
function Confirm-ODUConfig {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [switch]$CheckFileOnly
  )
  process {
    if ($false -eq (Test-ODUConfigFilePath)) {
      if ($false -eq $CheckFileOnly) {
        Write-Host "`nOctopus Deploy Utilities not initialized yet; run: " -ForegroundColor Cyan -NoNewline
        Write-Host "Set-ODUConfigExportRootFolder"
        Write-Host "See instructions here: $ProjectUrl`n"
      }
      $false
    } else {
      $true
    }
  }
}


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

    Save-ODUConfig -Config $Config
  }
}


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
    [hashtable]$Config
  )
  process {
    # want to use Configuration as-is from PSGallery but there's a bug
    # https://github.com/PoshCode/Configuration/issues/8
    # work around: if specify Scope User, need to specify CompanyName and Name, which need to
    # match values in PSD1 (in case bug ever fixed)
    $Config | Export-Configuration -Scope User -Version ([version]$ConfigVersion) -CompanyName $MyInvocation.MyCommand.Module.CompanyName -Name $MyInvocation.MyCommand.Module.Name
  }
}


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
    $Config = Get-ODUConfig
    if ($Config.OctopusServers.Count -eq 0) {
      Write-Host "`nOctopus Server has not been registered yet; run: " -ForegroundColor Cyan -NoNewline
      Write-Host "Add-ODUConfigOctopusServer`n"
      Write-Host "See instructions here: $ProjectUrl`n"
    } else {
      $Config.OctopusServers[0]
    }
  }
}


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
      $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( ($ApiKey | ConvertTo-SecureString) ))
    }
    $ApiKey
  }
}
