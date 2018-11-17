
Set-StrictMode -Version Latest

#region Function: Invoke-ODURestMethod

<#
.SYNOPSIS
Calls url with API key in header and returns results
.DESCRIPTION
Calls url with API key in header and returns results
.PARAMETER Url
Full url of REST API to call
.PARAMETER ApiKey
Unencrypted ApiKey to pass in REST API call headers
.EXAMPLE
Invoke-ODURestMethod -Url https://MyOctoServer.octopus.app -ApiKey 'API-123456789012345678901234567'
<calls Url passing in ApiKey and returns results>
#>
function Invoke-ODURestMethod {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey
  )
  #endregion
  process {
    Write-Verbose "$($MyInvocation.MyCommand) :: Calling Url $Url with API Key (first 7 characters) $($ApiKey.Substring(0,7))"
    Invoke-RestMethod -Method Get -Uri $Url -Headers @{ 'X-Octopus-ApiKey' = $ApiKey }
  }
}
#endregion
