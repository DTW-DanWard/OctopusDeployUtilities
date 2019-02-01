
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
Invoke-ODURestMethod -Url https://MyOctoServer.octopus.app -ApiKey 'API-ABCDEFGH01234567890ABCDEFGH'
<calls Url passing in ApiKey and returns results>
#>
function Invoke-ODURestMethod {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Url = $(throw "$($MyInvocation.MyCommand) : missing parameter RestName"),
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $(throw "$($MyInvocation.MyCommand) : missing parameter RestName")
  )
  #endregion
  process {
    Write-Verbose "$($MyInvocation.MyCommand) :: Calling Url $Url with API Key (first 7 characters) $($ApiKey.Substring(0,8))..."
    try {
      Invoke-RestMethod -Method Get -Uri $Url -Headers @{ 'X-Octopus-ApiKey' = $ApiKey }
    } catch {
      $Err = $_
      # a user may not have access to a particular api which is not the end of the world - it's
      # not worth throwing a terminating exception so just write error so user can see
      if (($Err.ToString()) -match "You do not have permission to perform this action. Please contact your Octopus administrator") {
        Write-Verbose "$($MyInvocation.MyCommand) :: Error calling $Url"
        Write-Verbose "$($MyInvocation.MyCommand) :: Error was $Err"
        throw "Error occurred calling: $Url  You may not have permission to access this API; you should exclude this type from exports by adding it to the type blacklist.  See the docs. Error was: $Err"
      } else {
        throw $Err
      }
    }
  }
}
#endregion


#region Function: Test-ODUOctopusServerCredential

<#
.SYNOPSIS
Calls simple, safe test url and discards results, if url or ApiKey is incorrect, throws error
.DESCRIPTION
Calls simple, safe test url and discards results, if url or ApiKey is incorrect, throws error
.PARAMETER ServerDomainName
Protocol and domain name
.PARAMETER ApiKey
Unencrypted ApiKey to pass with REST API call
.EXAMPLE
Test-ODUOctopusServerCredential -Url https://MyOctoServer.octopus.app -ApiKey 'API-ABCDEFGH01234567890ABCDEFGH'
<no results, those values are valid>
#>
function Test-ODUOctopusServerCredential {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$ServerDomainName = $(throw "$($MyInvocation.MyCommand) : missing parameter RestName"),
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = $(throw "$($MyInvocation.MyCommand) : missing parameter RestName")
  )
  #endregion
  process {
    # use machines roles api to test (simple and fast)
    $null = Invoke-RestMethod -Method Get -Uri ($ServerDomainName + "/api/machineroles/all") -Headers @{ 'X-Octopus-ApiKey' = $ApiKey }
  }
}
#endregion