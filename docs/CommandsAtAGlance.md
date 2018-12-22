
# Commands At A Glance

## Table of Contents
* [Installation](#installation)
* [Configure black/white lists](#configure-black-and-white-lists)
* [Export](#export)
* [Text Editor](#text-editor)
* [Diff Viewer](#diff-viewer)
* [Reporting](#reporting)
* [Variable Search](#variable-search)



asdf

## Installation
|Command|Purpose|Example|
|---|---|---|
|FILL_IN|FILL_IN|FILL_IN|
|Set-ODUConfigExportRootFolder|FILL_IN|FILL_IN|
|Get-ODUConfigExportRootFolder|FILL_IN|FILL_IN|
|Add-ODUConfigOctopusServer|FILL_IN|FILL_IN|
|Get-ODUConfigFilePath|FILL_IN|FILL_IN|
|Update-ODUExportJoinData|FILL_IN|FILL_IN|
|Get-ODUConfigBackgroundJobsMax|Gets max number of background jobs to use|Get-ODUConfigBackgroundJobsMax<BR> # returns 5|
|Set-ODUConfigBackgroundJobsMax|Sets max number of background jobs to use|Set-ODUConfigBackgroundJobsMax 3|


## Configure Black and White Lists
|Command|Purpose|Example|
|---|---|---|
|Get-ODURestApiTypeNames|FILL_IN|FILL_IN|
|Get-ODUStandardExportRestApiCalls|FILL_IN|FILL_IN|
|Get-ODUConfigTypeBlacklist|FILL_IN|FILL_IN|
|Get-ODUConfigTypeWhitelist|FILL_IN|FILL_IN|
|Set-ODUConfigTypeBlacklist|FILL_IN|FILL_IN|
|Set-ODUConfigTypeWhitelist|FILL_IN|FILL_IN|
|Get-ODUConfigPropertyBlacklist|FILL_IN|FILL_IN|
|Get-ODUConfigPropertyWhitelist|FILL_IN|FILL_IN|
|Set-ODUConfigPropertyBlacklist|FILL_IN|FILL_IN|
|Set-ODUConfigPropertyWhitelist|FILL_IN|FILL_IN|


## Export
|Command|Purpose|Example|
|---|---|---|
|oduexport|Runs a fresh export; alias of Export-ODUOctopusDeployConfig.|oduexport|
|Export-ODUOctopusDeployConfig|Runs a fresh export.|Export-ODUOctopusDeployConfig|
|Update-ODUExportJoinData|FILL_IN|FILL_IN|
|Get-ODUExportLatestPath|Gets full path of most recent export.|Get-ODUExportLatestPath|
|Get-ODUExportOlderPath|Gets full path of an export from *before* most recent.|Get-ODUExportOlderPath<BR># gets export full path from before most recent<BR>Get-ODUExportOlderPath 48<BR># gets export full path from first export that occurred more than 48 hours before the latest|


## Text Editor
|Command|Purpose|Example|
|---|---|---|
|Set-ODUConfigTextEditor|Sets the path to your text editor. Supply full path.|# use Sublime text<BR>Set-ODUConfigTextEditor 'C:\Program Files\Sublime Text 3\sublime_text.exe'<BR># use VS Code<BR>Set-ODUConfigTextEditor ((Get-Command code.cmd).Source)|
|Get-ODUConfigTextEditor|Gets the path to your text editor.|Get-ODUConfigTextEditor|
|odutext|Opens latest export in your text editor; alias of Open-ODUExportTextEditor.|odutext|
|Open-ODUExportTextEditor|Opens latest export in your text editor.|Open-ODUExportTextEditor|


## Diff Viewer
|Command|Purpose|Example|
|---|---|---|
|Set-ODUConfigDiffViewer|Sets the path to your diff viewer. Supply full path.|# use KDiff3<BR>Set-ODUConfigDiffViewer 'C:\Program Files (x86)\KDiff3\kdiff3.exe'|
|Get-ODUConfigDiffViewer|Gets the path to your diff viewer.|Get-ODUConfigDiffViewer|
|odudiff|Opens your diff viewer comparing most recent export with an older one; alias of Compare-ODUExportMostRecentWithOlder.|# diff 2 most recent exports<BR>odudiff<BR># diff most recent with one 48 hours older than most recent<BR>odudiff 48<BR>|
|Compare-ODUExportMostRecentWithOlder|Opens your diff viewer comparing most recent export with an older one.|Open-ODUExportTextEditor<BR>Open-ODUExportTextEditor 48|


## Reporting
|Command|Purpose|Example|
|---|---|---|
|oduobject|FILL_IN|FILL_IN|
|Read-ODUExportFromFiles|FILL_IN|FILL_IN|
|Test-ODUProjectDeployIISSite|FILL_IN|FILL_IN|
|Test-ODUProjectDeployWindowsService|FILL_IN|FILL_IN|
|Select-ODUProjectDeployActionProperty|FILL_IN|FILL_IN|


## Variable Search
|Command|Purpose|Example|
|---|---|---|
|FILL_IN|FILL_IN|FILL_IN|
