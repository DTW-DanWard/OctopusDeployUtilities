
# Commands At A Glance

Note: if you want addition information about any particular command, review the docs on this site and/or type this in PowerShell:
```PowerShell
C:\> Get-Help <Command> -Full
```

## Table of Contents
* [Installation](#installation)
* [Configure black/white lists](#configure-black-and-white-lists)
* [Export](#export)
* [Text Editor](#text-editor)
* [Diff Viewer](#diff-viewer)
* [Reporting](#reporting)
* [Variable Search](#variable-search)



## Installation
|Command|Purpose|Example|
|---|---|---|
|Set-ODUConfigExportRootFolder|Sets root folder used for all exports.|Set-ODUConfigExportRootFolder c:\OctoExports|
|Get-ODUConfigExportRootFolder|Gets root folder used for all exports.|Get-ODUConfigExportRootFolder|
|Add-ODUConfigOctopusServer|Sets Octopus Server configuration (root url and API key).|Add-ODUConfigOctopusServer -Url https://MyOctoServer.octopus.app -ApiKey 'API-ABCDEFGH01234567890ABCDEFGH'|
|Get-ODUConfigFilePath|Gets path to Octopus Deploy Utilities configuration file.|Get-ODUConfigFilePath|
|Get-ODUConfigBackgroundJobsMax|Gets max number of background jobs to use.|Get-ODUConfigBackgroundJobsMax<BR># returns 5|
|Set-ODUConfigBackgroundJobsMax|Sets max number of background jobs to use.|Set-ODUConfigBackgroundJobsMax 3|


## Configure Black and White Lists
|Command|Purpose|Example|
|---|---|---|
|Get-ODURestApiTypeName|Returns list of Type names used with Octopus Deploy REST API.|Get-ODURestApiTypeName|
|Get-ODUStandardExportRestApiCall|Returns PSObjects with Octopus Deploy API call details.|Get-ODUStandardExportRestApiCall|
|Get-ODUConfigTypeBlacklist|Gets type blacklist.|Get-ODUConfigTypeBlacklist|
|Get-ODUConfigTypeWhitelist|Gets type whitelist.|Get-ODUConfigTypeWhitelist|
|Set-ODUConfigTypeBlacklist|Sets type blacklist.|Set-ODUConfigTypeBlacklist -List @('Deployments', 'Events', 'Interruptions')|
|Set-ODUConfigTypeWhitelist|Sets type whitelist.|Set-ODUConfigTypeWhitelist -List @('Deployments', 'Events', 'Interruptions')|
|Get-ODUConfigPropertyBlacklist|Gets property blacklist.|Get-ODUConfigPropertyBlacklist|
|Get-ODUConfigPropertyWhitelist|Gets property whitelist.|Get-ODUConfigPropertyWhitelist|
|Set-ODUConfigPropertyBlacklist|Sets property blacklist.|Set-ODUConfigPropertyBlacklist @{ Licenses = @('MaintenanceExpiresIn'); Machines = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary') }|
|Set-ODUConfigPropertyWhitelist|Sets property whitelist.|Set-ODUConfigPropertyWhitelist @{ Licenses = @('MaintenanceExpiresIn'); Machines = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary') }|


## Export
|Command|Purpose|Example|
|---|---|---|
|oduexport|Runs a fresh export; alias of Export-ODUOctopusDeployConfig.|oduexport|
|Export-ODUOctopusDeployConfig|Runs a fresh export.|Export-ODUOctopusDeployConfig|
|Update-ODUExportJoinData|Runs data post-processing on a export folder.  Note: this is done automatically by the export process.|Update-ODUExportJoinData C:\OctoExports\MyOctoServer.octopus.app\20181213-183336|
|Get-ODUExportLatestPath|Gets full path of most recent export.|Get-ODUExportLatestPath|
|Get-ODUExportOlderPath|Gets full path of an export from *before* most recent.|# gets export full path from before most recent<BR>Get-ODUExportOlderPath<BR><BR># gets export full path from first export that occurred more than 48 hours before the latest<BR>Get-ODUExportOlderPath 48|


## Text Editor
|Command|Purpose|Example|
|---|---|---|
|Set-ODUConfigTextEditor|Sets the path to your text editor. Supply full path.|# use Sublime text<BR>Set-ODUConfigTextEditor 'C:\Program Files\Sublime Text 3\sublime_text.exe'<BR><BR># use VS Code<BR>Set-ODUConfigTextEditor ((Get-Command code.cmd).Source)|
|Get-ODUConfigTextEditor|Gets the path to your text editor.|Get-ODUConfigTextEditor|
|odutext|Opens latest export in your text editor; alias of Open-ODUExportTextEditor.|odutext|
|Open-ODUExportTextEditor|Opens latest export in your text editor.|Open-ODUExportTextEditor|


## Diff Viewer
|Command|Purpose|Example|
|---|---|---|
|Set-ODUConfigDiffViewer|Sets the path to your diff viewer. Supply full path.|# use KDiff3<BR>Set-ODUConfigDiffViewer 'C:\Program Files (x86)\KDiff3\kdiff3.exe'|
|Get-ODUConfigDiffViewer|Gets the path to your diff viewer.|Get-ODUConfigDiffViewer|
|odudiff|Opens your diff viewer comparing most recent export with an older one; alias of Compare-ODUExportMostRecentWithOlder.|# diff 2 most recent exports<BR>odudiff<BR><BR># diff most recent with one 48 hours older than most recent<BR>odudiff 48<BR>|
|Compare-ODUExportMostRecentWithOlder|Opens your diff viewer comparing most recent export with an older one.|Open-ODUExportTextEditor<BR>Open-ODUExportTextEditor 48|


## Reporting
|Command|Purpose|Example|
|---|---|---|
|oduobject|Returns PSObject containing all values of an export.  If no path parameter returns latest.  Alias of Read-ODUExportFromFile.|# returns object with latest export<BR>oduobject<BR><BR># returns object with data for that path<BR>oduobject C:\OctoExports\MyOctoServer.octopus.app\20181213-183336|
|Read-ODUExportFromFile|Returns PSObject containing all values of an export.|Read-ODUExportFromFile|
|Test-ODUProjectDeployIISSite|Returns true if Project contains at least one deploy steps for an IIS Site (Octopus.IIS).|Test-ODUProjectDeployIISSite $Project|
|Test-ODUProjectDeployWindowsService|Returns true if Project contains at least one deploy steps for a Windows Service (Octopus.WindowsService).|Test-ODUProjectDeployWindowsService $Project|
|Select-ODUProjectDeployActionProperty|Retrieves deploy action property from a project.|# get custom installation directory setting for project<BR>Select-ODUProjectDeployActionProperty $Project 'Octopus.Action.Package.CustomInstallationDirectory'<BR>D:\Applications\TestService

## Variable Search
|Command|Purpose|Example|
|---|---|---|
|oduvar|Search for text in variable name and/or value.  Alias of Find-ODUVariable.|# Search for 'Sales' in all variable names and values<BR>oduvar Sales<BR><BR># Search, matching whole exact variable name and/or value<BR>oduvar Sales -Exact<BR><BR># search, return results via standard output and save to file<BR>oduvar Sales -WriteOutput > SearchResults.txt|
|Find-ODUVariable|Search for text in variable name and/or value.|# Search for 'Sales' in all variable names and values<BR>Find-ODUVariable Sales|
