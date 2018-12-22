
Set-StrictMode -Version Latest

#region Function: Export-ODUOctopusDeployConfig

<#
.SYNOPSIS
Exports Octopus Deploy configuration from a server and saves in local JSON files.
.DESCRIPTION
Exports Octopus Deploy configuration from a server to a unique datetimestamp folder.
Fetches from server and saves to folder based on settings entered by user via the
Set-ODUConfig* functions.
.PARAMETER Quiet
Suppress status output
.PARAMETER SkipJoinData
Skip running join data process (id->name lookup, add deploy process to projects, etc.)
.PARAMETER PassThru
Returns string path to export; also suppresses status output (sets Quiet = $true)
.EXAMPLE
Export-ODUOctopusDeployConfig
asdf
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Export-ODUOctopusDeployConfig {
  [CmdletBinding()]
  param(
    [switch]$Quiet,
    [switch]$SkipJoinData,
    [switch]$PassThru
  )
  process {
    # if user specified PassThru, disable output (enable Quiet) so only path returned
    if ($PassThru) { $Quiet = $true }

    # export data and capture export folder instance
    if (! $Quiet) { Write-Output "Exporting data..." }
    [string]$CurrentExportRootFolder = Export-ODUOctopusDeployConfigMain
    if (! $Quiet) { Write-Output "  Data exported to: $CurrentExportRootFolder" }

    if (! $SkipJoinData) { Update-ODUExportJoinData -Path $CurrentExportRootFolder -Quiet:$Quiet }

    if ($PassThru) { Write-Output $CurrentExportRootFolder }
  }
}
#endregion


#region Function: Export-ODUJob

<#
.SYNOPSIS
Processes a single ExportJobDetail - DO NOT USE THIS FUNCTION DIRECTLY
.DESCRIPTION
DO NOT USE THIS FUNCTION DIRECTLY - it is only public so that it can be processed by
background jobs so it can run in parallel.  In general you should NOT be directly
calling this function unless you plan on manually constructing the ExportJobDetail
object, which is a lot of work.

That said, this function processes a single ExportJobDetail:
 - fetches content for a single url;
 - captures ItemIdOnly value references;
 - filters propertes on the exported data;
 - saves data to file.
Data might be 0, 1 or multiple items.
Returns hashtable of ItemIdOnly reference values.  That is: if a property listed in
ItemIdOnlyReferencePropertyNames is found on the object, the value for that property is
captured and returned at the end of the function call.
.PARAMETER ExportJobDetail
Information about the export: ApiCall info, Url, ApiKey to use in call, folder to save to
.PARAMETER ItemIdOnlyReferencePropertyNames
ItemIdOnly property names to look for in data that is retrieved; return values for these if found
.EXAMPLE
Export-ODUJob
<...>
.LINK
https://github.com/DTW-DanWard/OctopusDeployUtilities
#>
function Export-ODUJob {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$ExportJobDetail,
    [string[]]$ItemIdOnlyReferencePropertyNames
  )
  process {
    $ExportItems = Invoke-ODURestMethod -Url $ExportJobDetail.Url -ApiKey $ExportJobDetail.ApiKey

    [hashtable]$ItemIdOnlyReferenceValues = @{}
    if ($null -ne $ExportItems) {

      # simple references have a single item which does not have ItemIdOnly references; just save it
      # same is true of items fetched by IdOnly
      if (($ExportJobDetail.ApiCall.ApiFetchType -eq $ApiFetchType_Simple) ) {
        $FilePath = Join-Path -Path ($ExportJobDetail.ExportFolder) -ChildPath ((Format-ODUSanitizedFileName -FileName (Get-ODUExportItemFileName -ApiCall $ExportJobDetail.ApiCall -ExportItem $ExportItems)) + $JsonExtension)
        Write-Verbose "$($MyInvocation.MyCommand) :: Saving content to: $FilePath"
        Out-ODUFileJson -FilePath $FilePath -Data (Remove-ODUFilterPropertiesFromExportItem -RestName ($ExportJobDetail.ApiCall.RestName) -ExportItem $ExportItems)
      } else {
        # this is for TenantVariables, which returns multiple values that should be stored in multiple files
        # BUT, for whatever really dumb reason, Octo API does not provide this info in the standard TotalResults / .Items format
        # so we have this dumb workaround here - try to get the items as-is without the .Items property
        [object[]]$ExportItemsToProcess = $ExportItems
        if ($null -ne (Get-Member -InputObject $ExportItems -Name Items)) {
          $ExportItemsToProcess = $ExportItems.Items
        }
        $ExportItemsToProcess | ForEach-Object {
          $ExportItem = $_
          # inspect exported item for ItemIdOnly id references
          $ItemIdOnlyReferenceValuesOnItem = Get-ODUItemIdOnlyReferenceValues -ExportJobDetail $ExportJobDetail -ExportItem $ExportItem -ItemIdOnlyReferencePropertyNames $ItemIdOnlyReferencePropertyNames
          # transfer values to main hash table
          $ItemIdOnlyReferenceValuesOnItem.Keys | ForEach-Object {
            if (! $ItemIdOnlyReferenceValues.Contains($_)) { $ItemIdOnlyReferenceValues.$_ = @() }
            $ItemIdOnlyReferenceValues.$_ += $ItemIdOnlyReferenceValuesOnItem.$_
          }

          $FilePath = Join-Path -Path ($ExportJobDetail.ExportFolder) -ChildPath ((Format-ODUSanitizedFileName -FileName (Get-ODUExportItemFileName -ApiCall $ExportJobDetail.ApiCall -ExportItem $ExportItem)) + $JsonExtension)
          Write-Verbose "$($MyInvocation.MyCommand) :: Saving content to: $FilePath"
          Out-ODUFileJson -FilePath $FilePath -Data (Remove-ODUFilterPropertiesFromExportItem -RestName ($ExportJobDetail.ApiCall.RestName) -ExportItem $ExportItem)
        }
      }
    }
    $ItemIdOnlyReferenceValues
  }
}
#endregion
