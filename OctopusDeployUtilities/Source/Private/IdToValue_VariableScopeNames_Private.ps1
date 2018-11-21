
Set-StrictMode -Version Latest

#region Function: Update-ODUExportAddScopeNamesToVariables

<#
.SYNOPSIS
Adds scope names to variables
.DESCRIPTION
Adds scope names to variables
.PARAMETER Path
Path to export folder that contains folders exported values
.EXAMPLE
Update-ODUExportAddScopeNamesToVariables -Path c:\Exports\MyOctoServer.com\20181120-103152
<adds scope names to variables>
#>
function Update-ODUExportAddScopeNamesToVariables {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  #endregion
  process {
    if ($false -eq (Test-Path -Path $Path)) { throw "No export found at: $Path" }

    [string]$LookupPath = Join-Path -Path $Path -ChildPath $IdToNameLookupFileName
    if ($false -eq (Test-Path -Path $LookupPath)) { throw "Export Id to name lookup file not found: $LookupPath" }
    $IdToNameLookup = Get-Content -Path $LookupPath | ConvertFrom-Json

    # for this we only process the Variables data
    $RestApiCall = Get-ODUStandardExportRestApiCalls | Where-Object { $_.RestName -eq 'Variables' }
    $ItemExportFolder = Join-Path -Path $Path -ChildPath ($RestApiCall.RestName)

    if (($null -ne $RestApiCall.ExternalIdToResolvePropertyName) -and ($RestApiCall.ExternalIdToResolvePropertyName.Count -gt 0)) {
      # loop through all files under item folder
      Get-ChildItem -Path $ItemExportFolder -Recurse | ForEach-Object {
        $ExportFilePath = $_.FullName
        $ExportItem = Get-Content -Path $ExportFilePath | ConvertFrom-Json

        $ExportItem.Variables | Where-Object { $null -ne (Get-Member -InputObject $_.Scope -Type NoteProperty) } | ForEach-Object {
          $Variable = $_

          [string[]]$Breadth = @()
          # if re-running this on files that have already been processed then *-Name properties will already exist
          # along with Breadth property so filter them out from this list
          (Get-Member -InputObject $Variable.Scope -Type NoteProperty).Name | Where-Object { $_ -notmatch '.*Name$' -and $_ -ne 'Breadth' } | ForEach-Object {
            $ScopePropertyName = $_
            [string[]]$ScopePropertyValue = @()

            $Variable.Scope.$ScopePropertyName | ForEach-Object {
              $ScopePropertyNameIdValue = $_
              # do not create new project / do lookups for Roles  - these are just text and get added as-is to Breadth
              if ($ScopePropertyName -eq 'Role') {
                $ScopePropertyDisplayName = $ScopePropertyNameIdValue
              } else {
                $ScopePropertyDisplayName = Get-ODUIdToNameLookupValue -Lookup $IdToNameLookup -Key $ScopePropertyNameIdValue
              }
              $ScopePropertyValue += $ScopePropertyDisplayName
              $Breadth += $ScopePropertyDisplayName
            }
            # again, don't add <scope property>Name lookup values for roles
            if ($ScopePropertyName -ne 'Role') {
              Add-ODUOrUpdateMember -InputObject $Variable.Scope -PropertyName ($ScopePropertyName + 'Name') -Value ([string[]]($ScopePropertyValue | Sort-Object))
            }
          }
          Add-ODUOrUpdateMember -InputObject $Variable.Scope -PropertyName 'Breadth' -Value ([string[]]($Breadth | Sort-Object))
        }
        Out-ODUFileJson -FilePath $ExportFilePath -Data $ExportItem
      }
    }
  }
}
