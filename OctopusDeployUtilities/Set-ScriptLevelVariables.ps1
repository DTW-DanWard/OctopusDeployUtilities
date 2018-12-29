
Set-StrictMode -Version Latest

Write-Verbose "$($MyInvocation.MyCommand) :: Creating script-level variables"

# script-level variables
# web site url
$script:ProjectUrl = 'https://github.com/DTW-DanWard/OctopusDeployUtilities'

# Different ways of calling the Octopus Deploy API to fetch data
# Simple      make single call, save all results to single file
#             used for admin-type calls, results are saved in single file named after api in folder Miscellaneous
# MultiFetch  make call to get TotalResults, Number of Pages, etc. info, need to call API in loop until all items retrieved
#             used for most user-specific data calls; data saved one item per file in folder with same name as API call
# ItemIdOnly  fetch item ONLY by it's Id; certain versioned items (variables, deployment processes) have so many instances
#             that call to fetch the TotalResults values time out or hit out of memory exceptions; for these we have to
#             manually collect the Ids that are referenced then explicitly fetch by Id
Set-Variable ApiFetchType_Simple -Value 'Simple' -Option ReadOnly -Scope Script
Set-Variable ApiFetchType_MultiFetch -Value 'MultiFetch' -Option ReadOnly -Scope Script
Set-Variable ApiFetchType_ItemIdOnly -Value 'ItemIdOnly' -Option ReadOnly -Scope Script
Set-Variable ApiFetchTypeList -Value @($ApiFetchType_Simple, $ApiFetchType_MultiFetch, $ApiFetchType_ItemIdOnly) -Option ReadOnly -Scope Script

# define alias/function mappings
$AliasesToExport = @{
  odudiff   = 'Compare-ODUExportMostRecentWithOlder'
  oduexport = 'Export-ODUOctopusDeployConfig'
  oduobject = 'Read-ODUExportFromFile'
  odutext   = 'Open-ODUExportTextEditor'
  oduvar    = 'Find-ODUVariable'
}
Set-Variable OfficialAliasExports -Value $AliasesToExport -Scope Script

# version of configuration details
$script:ConfigVersion = '1.0.0'

# default text for settings still having placeholders - not configured by user yet
Set-Variable Undefined -Value 'UNDEFINED' -Option ReadOnly -Scope Script

Set-Variable JsonExtension -Value '.json' -Option ReadOnly -Scope Script

# name of file in root of export that contains Id to name lookup values
Set-Variable IdToNameLookupFileName -Value ('IdToNameLookup' + $JsonExtension) -Option ReadOnly -Scope Script

# this is a workaround for PoshRSJob dev vs. prod use
# when running some PoshRSJob jobs we need to pass in the name of the current module so that
# the module can be re-imported in the job
# problem is - how do we know whether to import the installed version versus the dev copy in our
# local repo?  to figure this out we check the current $PSScriptRoot and if it appears
# under a path in PSModulePath, then we are using the installed version, else we are running dev mode.
# if we are running the installed version, the name of the module to import is just the module
# name itself, if dev, it's the full path to the module psd1 (located in same folder as this)
# it would be cleaner/nicer to be able to use BuildHelper tools here but those are not used at run-time
# so just hard-code for now... (could search current folder for non-Configuration PSD1 files... meh)
$script:InstalledModule = $false
$ThisModuleNameTemp = 'OctopusDeployUtilities'
$env:PSModulePath.Split(';') | ForEach-Object {
  $Path = $_
  if ($PSScriptRoot -like ($Path + '*')) {
    $script:InstalledModule = $true
  }
}
if ($false -eq $InstalledModule) {
  $ThisModuleNameTemp = Join-Path -Path $PSScriptRoot -ChildPath ($ThisModuleNameTemp + '.psd1')
}
Set-Variable ThisModuleName -Value $ThisModuleNameTemp -Option ReadOnly -Scope Script
