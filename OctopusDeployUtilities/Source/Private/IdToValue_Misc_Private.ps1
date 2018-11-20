

function Add-ODUOrUpdateMember {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$InputObject,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PropertyName,
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
