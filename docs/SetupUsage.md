
Setup

1. Get the utility
Install Module ...

OR Clone and Import-Module .\OctopusDeployUtilities\OctopusDeployUtilities.psd1

2. Add your Octo server
Set-ODUConfigExportRootFolder C:\Temp\Temp
Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app'  'API-ABCDEFGH01234567890ABCDEFGH'

3. Configure external tools
Set-ODUConfigTextEditor -Path ((Get-Command code.cmd).Source)

Set-ODUConfigDiffViewer -Path 'C:\Program Files\ExamDiff Pro\ExamDiff.exe'
Set-ODUConfigDiffViewer -Path 'C:\Program Files (x86)\KDiff3\kdiff3.exe'


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

