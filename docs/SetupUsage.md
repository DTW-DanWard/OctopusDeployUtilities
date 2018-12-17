
# Setup and Basic Usage
Setup and usage notes for Octopus Deploy Utilities.


## Table of Contents
* [Pre-installation](#pre-installation)
* [Installation](#installation)
* [Set root folder & register Octopus Server](#set-root-folder-and-register-octopus-server)
* [Run your first manual export](#run-your-first-manual-export)
* [Set your text editor and diff viewer paths](#set-your-text-editor-and-diff-viewer-paths)
* [Type blacklist and whitelist settings](#type-blacklist-and-whitelist-settings)
* [Property blacklist and whitelist settings](#property-blacklist-and-whitelist-settings)
* [How to review all these settings](#how-to-review-all-these-settings)
* [Schedule exports](#schedule-exports)




## Pre-installation


### Windows PowerShell v5 or PowerShell Core
If you are running on Windows and aren't on v5, it's time to upgrade; do it!  Octopus Deploy Utilities has not been tested on PowerShell pre-v5 and it definitely will fail on older versions (ODU uses fallback member resolution).

If you aren't on Windows or you want to use the latest and greatest, get [PowerShell Core](https://github.com/PowerShell/PowerShell).  Note: *Windows* PowerShell is not going to be upgraded past v5 so you really should start using PowerShell Core now.


### Get an Octopus Deploy API Key for your Server
The Octopus Deploy REST API requires a unique API key for your account to authenticate your requests.  You need to generate this key within the Octopus Server UI and supply it when registering the server with ODU.

* Log into your Octopus Deploy Server.
* At the top-right, click on your account name and select **Profile**.
* In the left nav, click on **My API Keys**.
* At the right, click **NEW API KEY**.
* Enter a purpose (say, "Octopus Deploy Utilities") and **GENERATE NEW**.
* Copy the API key to clipboard and paste temporarily to a text editor; you'll use it shortly.  The API key should begin with API-

## Installation
Get the Octopus Deploy Utilities module.  Easiest way is to install it; open a PowerShell Windows *running as Administrator* and type:
```PowerShell
C:\> Install-Module OctopusDeployUtilities
```
Installing it has the additional benefit that you never need to manually import the module afterwards.


The other option is you can clone or download the module from GitHub.  In that case you need to manually import the module each time you use it (or add the import statement to your $profile).
```PowerShell
C:\> Import-Module <path to where you cloned or downloaded>\OctopusDeployUtilities\OctopusDeployUtilities.psd1
```

## Set Root Folder and Register Octopus Server
Once the module is loaded the first thing you need to set a root folder under which exports will get stored.  This step initializes the ODU settings.  For example:
```PowerShell
C:\> Set-ODUConfigExportRootFolder c:\OctoExports
```

Once the root export folder has been set you can now register your Octopus Deploy Server.  Register your server with the url (including http/https) and your API key from Pre-installation.  For example:
```PowerShell
C:\> Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app' 'API-ABCDEFGH01234567890ABCDEFGH'
```

## Run Your First Manual Export
At this point you can run an export without needing to change anything else.  Running ```oduexport``` will do this.  Here's an example:
```PowerShell
C:\> oduexport
Exporting data...
  Data exported to: C:\OctoExports\MyOctoServer.octopus.app\20181213-183336
Post-processing data...
  Creating Id to name lookup
  Adding external names for ids in exported data
  Adding scope names to variables
  Adding machine information to environments
  Adding deployment processes to projects
  Adding variable sets to projects
  Adding included library variable sets to projects
  Post-processing complete

C:\>
```

You can now check out the export folder (in this case: C:\OctoExports\MyOctoServer.octopus.app\20181213-183336).  I recommend opening that folder in a modern text editor like VS Code, Atom or Sublime Text (not notepad).  Using a good text editor will allow you to browse and search more easily.

Or [see this for an example](SampleExport.md) of an export.


## Set Your Text Editor and Diff Viewer Paths

ODU has some handy shortcuts.  For example you can always open the latest export in a text editor by typing: ```odutext```  In order for this to work you need to tell ODU the full path to your text editor using Get-ODUConfigTextEditor.  For example:
```PowerShell
C:\> # use PowerShell to get the path to VS Code
C:\> Set-ODUConfigTextEditor ((Get-Command code.cmd).Source)
```

Once you've configured this you can quickly open your most recent export:
```PowerShell
C:\> odutext
```

You can also tell ODU the path to your diff viewer, allows you to open a diff viewer comparing your most recent export with older exports.  To set this:
```PowerShell
C:\> # set the diff viewer to Exam Diff Pro (my favorite diff viewer)
C:\> Set-ODUConfigDiffViewer 'C:\Program Files\ExamDiff Pro\ExamDiff.exe'
C:\> 
C:\> # but KDiff3 is pretty sweet, too, so perhaps this is your option:
C:\> Set-ODUConfigDiffViewer 'C:\Program Files (x86)\KDiff3\kdiff3.exe'
```
Once you've configured this you quickly open up your exports in a diff viewer to see changes over time:
```PowerShell
C:\> # opens your diff viewer comparing the two most recent exports (most recent on right-side, of course)
C:\> odudiff
C:\> 
C:\> # opens diff of most recent export and first export that is 48 hours older than the most recent export
C:\> odudiff 48
```

## Type Blacklist And Whitelist Settings

By default **NOT** all Octopus Deploy data types are exported - but the default blacklist settings are probably a good starting place for you.  Learn how to [configure the type blacklist or whitelist](TypeWhiteListBlackListConfig.md) and more about the different Octopus Deploy [REST API data types](TypeDescription.md).


## Property Blacklist And Whitelist Settings

By default all properties for a particular type are saved in the JSON file.  However, if you want you can control which type-specific properties are saved by configuring the [property blacklist or whitelist](PropertyWhiteListBlackListConfig.md).

Filtering out certain property types is a good way to filter out pieces of data that are time-sensitive (likely to be different) but not important.  These differences can be annoying if you want to compare changes to your system over time by diff'ing one export with a later one.

Note: you should check out an export first to get a feel for the properties before starting to filter them.


## How to Review All These Settings

There are two ways to review all these settings you've made:
1. For every ```Set-``` function you called there's a corresponding ```Get-``` function.  For example: ```Set-ODUConfigExportRootFolder``` has ```Get-ODUConfigExportRootFolder```.  You can find all these functions and more by typing:

```PowerShell
C:\> # see all the main functions:
C:\> Get-Command -Module OctopusDeployUtilities
C:\> # see all the aliases (shortcuts) for these functions:
C:\> Get-Alias odu*
```

2. You can review the ODU config file itself; you can find it's path with ```Get-ODUConfigFilePath```.  Be careful - if you manually edit this file, you might break ODU!

If you configured your text editor above you can open your ODU config file this way:

```PowerShell
C:\> & (Get-ODUConfigTextEditor) (Get-ODUConfigFilePath)
```



## Schedule Exports
To schedule exports: on Windows, use Task Scheduler; on Unix, use cron.

### Windows Task Scheduler
* Open Task Scheduler
* Create a new Task
* Add a new Action
* Program/script value:
  * If you are using PowerShell Core:     ```pwsh.exe```
  * If you are using Windows PowerShell:  ```powershell.exe```
* Add arguments:
  * If you installed the module: -c "oduexport"
  * If you cloned & manually import the module: -c "Import-Module C:\path\to\OctopusDeployUtilities\OctopusDeployUtilities\OctopusDeployUtilities.psd1; oduexport"
