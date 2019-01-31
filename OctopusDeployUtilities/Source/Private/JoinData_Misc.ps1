
Set-StrictMode -Version Latest


#region Function: Add-ODUOrUpdateMember

<#
.SYNOPSIS
Adds or updates a property & value to a PsObject
.DESCRIPTION
Adds or updates a property & value to a PsObject
If property doesn't already exists, adds it with value; if does, updates value
.PARAMETER InputObject
PSObject to update
.PARAMETER PropertyName
Name of property to add or update
.PARAMETER Value
New value
.EXAMPLE
Add-ODUOrUpdateMember ...
<...>
#>
function Add-ODUOrUpdateMember {
  #region Function parameters
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [object]$InputObject = $(throw "$($MyInvocation.MyCommand) : missing parameter InputObject"),
    [ValidateNotNullOrEmpty()]
    [string]$PropertyName = $(throw "$($MyInvocation.MyCommand) : missing parameter PropertyName"),
    $Value
  )
  #endregion
  process {
    if ($null -eq (Get-Member -InputObject $InputObject -MemberType NoteProperty -Name $PropertyName)) {
      Add-Member -InputObject $InputObject -MemberType NoteProperty -Name $PropertyName -Value $Value
    } else {
      $InputObject.$PropertyName = $Value
    }
  }
}
#endregion
