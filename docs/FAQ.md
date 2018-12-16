# Frequently Asked Questions

## How does an export work?
Here's the basic flow: when the Octopus Deploy Utilities (hereafter ODU) export is run it:
* gets your server url and profile API key;
* creates a folder with a datetime stamp for a name;
* gets a list of API calls to make, possibly filtered based on your configured [type blacklist or whitelist](TypeWhiteListBlackListConfig.md); 
* for each API call:
  * creates a folder with the name matching the API name;
  * make 1 or more API calls to the server to fetch data;
  * based on your configured [property blacklist or whitelist](PropertyWhiteListBlackListConfig.md) it might remove unwanted properties;
  * stores result data in that folder;
* after export is complete it [post-processes the data](PostProcessing.md), adding names where only ids used to exist, adding variables and deployment processes directly to projects, etc.

If you'd like more detail about the export process please review the source code (it's well-commented).

You can learn more about the Octopus Deploy REST API by reviewing the [Swagger on their demo server](https://demo.octopus.com/swaggerui/index.html).

## Where is the Octopus Deploy Utilities configuration file stored?
To get the path, run this in PowerShell: ```Get-ODUConfigFilePath```

Developer's note: configuration support is provided by the [Configuration module from PowerShellGallery](https://www.powershellgallery.com/packages/Configuration/1.3.1), using User scope, which is why the Configuration.psd1 is stored under c:\Users\\*your_account*


## What does an export look like?
[Check this page](SampleExport.md).


## When Configuring Octopus Deploy Utilities I added my Octopus Server with a Profile API key.  Is that API key stored encrypted?
Yes, but only if you are running on Windows.  ODU uses the standard PowerShell secure string cmdlets which currently only work on Windows machines (as of PowerShell 6.1).



## Are encrypted (Sensitive) values like passwords exported and stored in clear text?
No, don't worry, Sensitive values are not exported at all.  The Octopus REST API doesn't support that - good!  Instead, the variable value will be null and the IsSensitive value will be true.

The JSON for an exported Sensitive variable will look something like:
```JSON
{
  "Id": "a4946c21-d9b7-4e71-b981-ac6a32440dd6",
  "Name": "SalesDbSqlPassword",
  "Value": null,
  ...
  "Type": "Sensitive",
  "IsSensitive": true
}
```


## How can I quickly find out what cmdlets come with Octopus Deploy Utilities?
In PowerShell run: 
```PowerShell
C:\> Get-Command -Module OctopusDeployUtilities
```

To see aliases (shortcuts) that come with ODU type: 
```PowerShell
C:\> Get-Alias odu*
```

If you then want to see the help for an alias or cmdlet type: 
```PowerShell
C:\> Get-Help <cmdlet name> -Full
```


## How do I get the latest full export path?  How can I view it in a text editor?
To get the latest export folder path, run: 
```PowerShell
C:\> Get-ODUExportLatestPath
```

If you configured your [text editor path with Set-ODUConfigTextEditor](SetupUsage.md), you can quickly open this folder:
```PowerShell
C:\> odutext
```


## How do I quickly run a fresh export?
```PowerShell
C:\> # run a new export
C:\> oduexport
```

Make sure you review the [usage info](SetupUsage.md) for more tips.


## When I compare separate exports over time there are fields getting exported that are different in each export - but these fields are kinda useless and are affecting the diff.  How do I fix this?
For example, you might not care about a Machine's HasLatestCalamari value as it might be different over time.  However you are mostly interested in project / variable data changes over time and these HasLatestCalamari changes are false positives.  To fix this, use the [property blacklist](PropertyWhiteListBlackListConfig.md) and specify the type and field(s) you want to filter out (in this case Machine : HasLatestCalamari).


## What is the post-processing that the export process does?
Read this to learn all about [post-processing the data](PostProcessing.md).  If you are curious to see exactly what the post-processing does, you can:
* run an export without the post-processing;
* make a copy of that export folder;
* run the post-processing on the folder copy;
* do a diff of the two folders.

Instructions on how to do this are in that linked page.  You will be surprised at all the work the post-processing does...


## What is the root export folder?  How do I change it?

```PowerShell
C:\> # to get the folder path
C:\> Get-ODUConfigExportRootFolder

C:\> # to change that root to a new path
C:\> Set-ODUConfigExportRootFolder -Path *the_new_root_path*
```

Make sure you manually copy or move any folders from the old location to the new location afterwards.


## Does Octopus Deploy Utilities support multiple servers/configurations?
Not presently; that's on the [road map](OctopusDeployUtilitiesRoadmap.md).

It won't just support separate Octopus Server instances - you might have multiple entries for the same server but with different settings like a different type blacklist or whitelist.  For example one entry might export all info - that entry you export once a week; another entry might ignore unimportant data like Tasks, Packages, etc. and that you run once a day - or maybe several times a day, so you get more granular timestamps for your project & variable data.
