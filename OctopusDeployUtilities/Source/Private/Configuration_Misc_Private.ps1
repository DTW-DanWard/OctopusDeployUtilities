
Set-StrictMode -Version Latest

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
