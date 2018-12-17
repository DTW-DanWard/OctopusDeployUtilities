
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
