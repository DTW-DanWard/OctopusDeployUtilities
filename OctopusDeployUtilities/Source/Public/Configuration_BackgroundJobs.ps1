Set-StrictMode -Version Latest

#region Function: Get-ODUConfigBackgroundJobsMax

<#
.SYNOPSIS
Gets the max number of background jobs
.DESCRIPTION
Gets the max number of background jobs.  Certain processes (export, most notably) can
run using multiple background jobs to complete more quickly.  Note: this value is
limited to 1-9.  Also note: increasing this number to 9 DOES NOT necessarily speed up
your exports - it might slow them down!  Testing on my machine shows that 5, the default,
is the sweet spot.
.EXAMPLE
Get-ODUConfigBackgroundJobsMax
5
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Get-ODUConfigBackgroundJobsMax {
  [CmdletBinding()]
  [OutputType([int])]
  param()
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }
    (Get-ODUConfig).BackgroundJobsMax
  }
}
#endregion


#region Function: Set-ODUConfigBackgroundJobsMax

<#
.SYNOPSIS
Sets the max number of background jobs
.DESCRIPTION
Sets the max number of background jobs.  Certain processes (export, most notably) can
run using multiple background jobs to complete more quickly.  Note: this value is
limited to 1-9.  Also note: increasing this number to 9 DOES NOT necessarily speed up
your exports - it might slow them down!  Testing on my machine shows that 5, the default,
is the sweet spot.
.PARAMETER Path
Path to diff viewer
.EXAMPLE
Set-ODUConfigBackgroundJobsMax
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Set-ODUConfigBackgroundJobsMax {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 9)]
    [int]$BackgroundJobsMax
  )
  process {
    if ($false -eq (Confirm-ODUConfig)) { return }

    $Config = Get-ODUConfig
    $Config.BackgroundJobsMax = $BackgroundJobsMax
    Write-Verbose "$($MyInvocation.MyCommand) :: Saving configuration with BackgroundJobsMax: $BackgroundJobsMax"
    Save-ODUConfig -Config $Config
  }
}
#endregion
