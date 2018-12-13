
# Setup and Usage

## Table of Contents
* [Installation](#installation)
* [Primary settings](#primary-settings)
* [Type blacklist and whitelist settings](#type-blacklist-and-whitelist-settings)
* [Property blacklist and whitelist settings](#property-blacklist-and-whitelist-settings)
* [External tools settings](#external-tools-settings)
* [Manual exports](#manual-exports)
* [Schedule exports](#schedule-exports)
* [Open latest export in text editor](#open-latest-export-in-text-editor)
* [Search for variables](#search-for-variables)






## Installation



## Primary Settings



## Type Blacklist And Whitelist Settings



## Property Blacklist And Whitelist Settings



## External Tools Settings



## Manual Exports



## Schedule Exports



## Open Latest Export in Text Editor



## Search for Variables


---------------


1. Get the utility
Install Module ...

OR Clone and Import-Module .\OctopusDeployUtilities\OctopusDeployUtilities.psd1

2. Add your Octo server
Set-ODUConfigExportRootFolder C:\Temp\Temp
Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app'  'API-ABCDEFGH01234567890ABCDEFGH'

How to review these settings?

Run export immediately


3. Configure external tools
Set-ODUConfigTextEditor -Path ((Get-Command code.cmd).Source)

Set-ODUConfigDiffViewer -Path 'C:\Program Files\ExamDiff Pro\ExamDiff.exe'
Set-ODUConfigDiffViewer -Path 'C:\Program Files (x86)\KDiff3\kdiff3.exe'

How to review these settings?

4. Filter your export type information black/white

link to more info about types


5. Filter properties black white


6. Run export manually


7. Schedule export
Windows:
Non-Windows: use cron



Usage

run export

open latest export in a text editor

search for variables

