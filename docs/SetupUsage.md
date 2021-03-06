
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
Get the Octopus Deploy Utilities module.  Easiest way is to install it; open a PowerShell Windows **running as Administrator** and type:
```PowerShell
C:\> Install-Module OctopusDeployUtilities
```
Installing it has the additional benefit that you never need to manually import the module afterwards.

Note: installing OctopusDeployUtilities also installs these modules:
* [Configuration](https://www.powershellgallery.com/packages/Configuration/1.3.1) - provides configuration support;
* [PoshRSJob](https://www.powershellgallery.com/packages/PoshRSJob/1.7.4.4) - speeds up exports via parallel jobs.


The other option is you can clone or download the module from GitHub.  In that case you need to manually import the module each time you use it (or add the import statement to your $profile).
```PowerShell
C:\> # you only need to Import-Module if you didn't Install it
C:\> # if you ran Install-Module skip this
C:\> Import-Module <path to where you cloned or downloaded>\OctopusDeployUtilities\OctopusDeployUtilities.psd1
```

## Set Root Folder and Register Octopus Server
Once the module is loaded the first thing you need to set a root folder under which exports will get stored.  This step initializes the ODU settings.  For example:
```PowerShell
C:\> Set-ODUConfigExportRootFolder c:\OctoExports
```
Don't worry about the warning `Warning: user path c:\Users\yourname\AppData\Local\powershell cannot be found`.  That occurs because it's the first time the PowerShell Configuration module has been run on your machine.

Once the root export folder has been set you can now register your Octopus Deploy Server.  Register your server with the url (including http/https) and your API key from Pre-installation.  For example:
```PowerShell
C:\> Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app' 'API-ABCDEFGH01234567890ABCDEFGH'
```

When you enter the `Add-ODUConfigOctopusServer` command it first attempts to communicate with your Octopus Deploy server, calling a sample REST API on your server.  If that sample works correctly, the server and API key are stored in the configuration file (API key is encrypted on Windows machines).  However if that test call *fails* it means Octopus Deploy Utilities could not communicate correctly with your server.  In this case see the bottom of this document for [tips debugging your setup](#debug-server-communication-setup).


## Run Your First Manual Export
At this point you can run an export without needing to change anything else.  Running `oduexport` will do this.  Here's an example:
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

ODU has some handy shortcuts.  For example you can always open the latest export in a text editor by typing: `odutext`  In order for this to work you need to tell ODU the full path to your text editor using Get-ODUConfigTextEditor.  For example:
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

## Max Number of Background Jobs
Certain processes (export, most notably) are run using multiple background jobs to complete more quickly.  The max number of background jobs can be configured with a value of 1 - 9; the default value is 5.  The value can be set or fetched with `Set-ODUConfigBackgroundJobsMax` and `Get-ODUConfigBackgroundJobsMax`, respectively.

**NOTE:** setting this number to 9 **DOES NOT NECESSARILY** speed up your exports - in fact it probably will slow them down!  Testing on my machine shows that 5, the default, tends to be the sweet spot.


## How to Review All These Settings

There are two ways to review all these settings you've made:
1. For every `Set-` function you called there's a corresponding `Get-` function.  For example: `Set-ODUConfigExportRootFolder` has `Get-ODUConfigExportRootFolder`.  You can find all these functions and more by typing:

```PowerShell
C:\> # see the ODU public functions:
C:\> Get-Command -Module OctopusDeployUtilities
C:\> # see the ODU aliases (shortcuts) that exist for some of the functions:
C:\> Get-Alias odu*
```

2. You can review the ODU config file itself; you can find it's path with `Get-ODUConfigFilePath`.  Be careful - if you manually edit this file, you might break ODU!

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
  * If you are using PowerShell Core:     `pwsh.exe`
  * If you are using Windows PowerShell:  `powershell.exe`
* Add arguments:
  * If you installed the module: -c "oduexport"
  * If you cloned & manually import the module: -c "Import-Module C:\path\to\OctopusDeployUtilities\OctopusDeployUtilities\OctopusDeployUtilities.psd1; oduexport"


## Debug Server Communication Setup

Normally you register your Octopus Deploy server with a call like this:
```PowerShell
C:\> Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app' 'API-ABCDEFGH01234567890ABCDEFGH'
```

If your Octopus Deploy install is *not* installed to the root of the web server but is down a level, you can specify that:
```PowerShell
C:\> Add-ODUConfigOctopusServer 'https://MyOctoServer.octopus.app/OctoRoot' 'API-ABCDEFGH01234567890ABCDEFGH'
```

If neither of these work, take a closer look at the server url.  Make sure you **don't** add the `/app` at the end of the server name.

Here's a sample you can try running on your machine to test your REST API directly.
```PowerShell
C:\> # set the server name - no trailing slash!
C:\> $Server = 'https://MyOctoServer.octopus.app'
C:\> $ApiKey = 'API-ABCDEFGH01234567890ABCDEFGH'
C:\>
C:\> # try calling a REST API directly
C:\> Invoke-RestMethod -Uri ($Server + "/api/machineroles/all") -Headers @{ 'X-Octopus-ApiKey' = $ApiKey }
C:\> # there might be results or it might return nothing - depends on your setup
C:\> # but it should NOT throw an error
C:\>
C:\> # if Invoke-RestMethod doesn't throw an error, this should work:
C:\> Add-ODUConfigOctopusServer $Server $ApiKey
```
