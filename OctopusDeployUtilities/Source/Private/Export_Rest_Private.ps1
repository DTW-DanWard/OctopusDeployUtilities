
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
    Write-Verbose "$($MyInvocation.MyCommand) :: Calling Url $Url with API Key (first 7 characters) $($ApiKey.Substring(0,8))..."
    try {
      Invoke-RestMethod -Method Get -Uri $Url -Headers @{ 'X-Octopus-ApiKey' = $ApiKey }
    } catch {
      $Err = $_
      # a user may not have access to a particular api which is not the end of the world - it's
      # not worth throwing an unhandled error so instead, if it appears to be a missing permission
      # error, write to host (gasp!) with helpful info and return $null else re-throw error
      if (($Err.ToString()) -match "You do not have permission to perform this action. Please contact your Octopus administrator") {
        Write-Verbose "$($MyInvocation.MyCommand) :: Error calling $Url"
        Write-Verbose "$($MyInvocation.MyCommand) :: Error was $Err"
        Write-Host "`nError occurred calling: $Url" -ForegroundColor Cyan
        Write-Host "It appears you don't have permission to access this API. You might want to exclude" -ForegroundColor Cyan
        Write-Host "this type from exports by including it in a call to Set-ODUConfigTypeBlacklist" -ForegroundColor Cyan
        Write-Host "Make sure that you don't lose any existing types by checking Get-ODUConfigTypeBlacklist first." -ForegroundColor Cyan
        Write-Host "Error was: $Err" -ForegroundColor Cyan
      } else {
        throw $Err
      }
    }
  }
}
#endregion


#region Function: Invoke-ODURestMethod

<#
.SYNOPSIS
Calls url with API key in header and returns results
.DESCRIPTION
Calls url with API key in header and returns results
.PARAMETER ServerDomainName
Protocol and domain name
.PARAMETER ApiKey
Unencrypted ApiKey to pass with REST API call
.EXAMPLE
Invoke-ODURestMethod -Url https://MyOctoServer.octopus.app -ApiKey 'API-ABCDEFGH01234567890ABCDEFGH'
<calls Url passing in ApiKey and returns results>
#>
function Test-ODUOctopusServerCredentials {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerDomainName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey
  )
  #endregion
  process {
    # use machines roles api to test (simple and fast)
    Invoke-RestMethod -Method Get -Uri ($ServerDomainName + "/api/machineroles/all") -Headers @{ 'X-Octopus-ApiKey' = $ApiKey } > $null
  }
}
#endregion