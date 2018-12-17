
# Commands At A Glance

## Table of Contents
* [Installation](#installation)
* [Type black/white lists](#type-black/white-list)
* [Export](#export)
* [Text Editor](#text-editor)
* [Diff Viewer](#diff-viewer)
* [Variable Search](#variable-search)



## Export

|Command|Purpose|Example|
|---|---|---|
|oduexport|Runs a fresh export; alias of Export-ODUOctopusDeployConfig.|oduexport|
|Export-ODUOctopusDeployConfig|Runs a fresh export.|Export-ODUOctopusDeployConfig|


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
|Compare-ODUExportMostRecentWithOlder|Opens latest export in your diff viewer.|Open-ODUExportTextEditor<BR>Open-ODUExportTextEditor 48|
