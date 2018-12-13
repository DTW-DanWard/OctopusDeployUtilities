
# Setup and Usage
Setup and usage notes for Octopus Deploy Utilities.


## Table of Contents
* [Pre-installation](#pre-installation)
* [Installation](#installation)
* [Primary settings](#primary-settings)
* [Manual exports](#manual-exports)
* [Type blacklist and whitelist settings](#type-blacklist-and-whitelist-settings)
* [Property blacklist and whitelist settings](#property-blacklist-and-whitelist-settings)
* [External tools settings](#external-tools-settings)
* [Schedule exports](#schedule-exports)
* [Open latest export in text editor](#open-latest-export-in-text-editor)
* [Search for variables](#search-for-variables)



## Pre-installation
The Octopus Deploy REST API requires a unique API key for your account to authenticate your requests.  You need to generate this key within the Octopus Server UI and supply it when registering the server with ODU.

### Get the API Key
* Log into your Octopus Deploy Server.
* At the top-right, click on your account name and select **Profile**.
* In the left nav, click on **My API Keys**.
* At the right, click **NEW API KEY**.
* Enter a purpose (say, "Octopus Deploy Utilities") and **GENERATE NEW**.
* Copy the API key to clipboard and paste temporarily to a text editor; you'll use it shortly.  The API key should begin with API-

## Installation
Get the Octopus Deploy Utilities module.  Easiest way is to install it; open a PowerShell Windows *running as Administrator* and type:
```
Install-Module OctopusDeployUtilities
```
Installing it has the additional benefit that you never need to manually import the module afterwards.


Or you can clone or download the module from GitHub.  In that case you need to manually import the module each time you use it (or add the import statement to your $profile).
```
Import-Module <path to where you cloned or downloaded>\OctopusDeployUtilities\OctopusDeployUtilities.psd1
```

## Primary Settings
Once the module is loaded the first thing you need to set a root folder under which exports will get stored.  This step initializes the ODU settings.  For example:
```
Set-ODUConfigExportRootFolder c:\OctoExports
```

Once the root export folder has been set you can now register your Octopus Deploy Server.  Register your server with the url (including http/https) and your API key from Pre-installation.  For example:
```
Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app' 'API-ABCDEFGH01234567890ABCDEFGH'
```

## Manual Exports
At this point you can run an export without needing to change anything else.  Running ```oduexport``` will do this.  Here's an example:
```
C:\> oduexport
Exporting data...
  Data exported to: C:\OctoExports\MyOctoServer.octopus.app\20181213-183336
Creating Id to name lookup
Adding external names for ids in exported data
Adding scope names to variables
Adding machine information to environments
Adding deployment processes to projects
Adding variable sets to projects
Adding included library variable sets to projects
C:\>
```

You can now check out the export folder (in this case: C:\OctoExports\MyOctoServer.octopus.app\20181213-183336).  I recommend opening that folder in a modern text editor like VS Code, Atom or Sublime Text (not notepad).  Using a good text editor will allow you to browse and search more easily.


## Type Blacklist And Whitelist Settings



## Property Blacklist And Whitelist Settings



## External Tools Settings



## Schedule Exports



## Open Latest Export in Text Editor



## Search for Variables


---------------




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

