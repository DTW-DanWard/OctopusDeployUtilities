
# ODU Type Export Blacklist / Whitelist

There are a lot of different data types that can be exported from Octopus Deploy.  But, believe me, you probably don't want to export **all** of them.  Why?
* Some types just aren't important.
* Some are huge, like Events, Deployments, Releases and ServerTasks.  Do you want your export to run for a few minutes or 30+ minutes?
* Some you might not be able to access to, especially if you are using a Octopus Deploy-hosted cloud instance.

So which types do you want to blacklist or whitelist?  Check out the [type description](TypeDescription.md) information but for now try an export with the default values.  **By default Octopus Deploy Utilities does not export every type - just a subset!**  Large types like Events, Deployments, etc. are in the default blacklist along with types that are unimportant and likely to cause an error with a cloud-hosted instance.

### Blacklist or Whitelist

ODU exports specifics types checking your configuration for values in either the blacklist **or** the whitelist.
* If you have *blacklist* settings it exports all types *EXCEPT* the ones in the blacklist.
* If you have *whitelist* settings it exports *ONLY* the types in the whitelist.

Unless you have a small and very specific list of types you want to export (i.e. whitelist) you should probably use the blacklist - that is how ODU is configured by default.  You can test this with some PowerShell:

```PowerShell
C:\> (Get-ODUConfigTypeWhitelist).Count
0
C:\> (Get-ODUConfigTypeBlacklist).Count
15
C:\> Get-ODUConfigTypeBlacklist
CommunityActionTemplates
Deployments
Events
...(more)...
```

### What is the Default Blacklist?
These types are in the default blacklist: CommunityActionTemplates, Deployments, Events, Interruptions, LetsEncrypt, Licenses, MaintenanceConfiguration, OctopusServerNodes, Packages, Releases, Reporting, ServerConfiguration, ServerStatus-Extensions, ServerStatus-SystemInfo and Tasks.


### Setting Blacklist or Whitelist
The functions `Get-ODUConfigTypeBlacklist` and `Get-ODUConfigTypeWhitelist` return the settings for the black / white lists.  How do you set them?  With `Set-ODUConfigTypeBlacklist` and `Set-ODUConfigTypeWhitelist`.  Again: you can have either a type blacklist *or* whitelist - **not both**.  If you call `Set-ODUConfigTypeBlacklist` it will reset any whitelist settings you have and vice versa.

Both `Set-ODUConfigTypeBlacklist` and `Set-ODUConfigTypeWhitelist` take an array of strings.  Below are some examples.  But first: know that you can back up your configuration file first!  You can find the path to this file by calling: `Get-ODUConfigFilePath`.  If you have difficulties you can't fix delete this file and re-run the [set root folder and register Octopus Server](SetupUsage.md#set-root-folder-and-register-octopus-server).

```PowerShell
C:\> # temporarily store the default blacklist that comes with the standard configuration
C:\> $BL = Get-ODUConfigTypeBlacklist
C:\> # add a new type to the blacklist
C:\> $BL += 'Feeds'
C:\> # update the blacklist in configuration
C:\> Set-ODUConfigTypeBlacklist $BL
C:\> # you could now test with: oduexport
C:\> oduexport
C:\> # <ignoring output>
C:\>
C:\> # now let's export ONLY Environments and Machines via whitelist
C:\> Set-ODUConfigTypeWhitelist @('Environments','Machines')
C:\> # and test again with: oduexport
C:\> oduexport
C:\> # <ignoring output>
C:\> # that ran fast! so little to export
C:\>
C:\> # now let's remove Feeds from the original list and set the blacklist back
C:\> $BL = $BL | ? { $_ -ne 'Feeds' }
C:\> Set-ODUConfigTypeBlacklist $BL
C:\>
C:\> # what happens if you lost that variable $BL and want to set back to the default?
C:\> # or, put another way, you just want to set a specific array of values:
C:\> Set-ODUConfigTypeBlacklist @('CommunityActionTemplates', 'Deployments', 'Events', 'Interruptions', 'LetsEncrypt', 'Licenses', 'MaintenanceConfiguration', 'OctopusServerNodes', 'Packages', 'Releases', 'Reporting', 'ServerConfiguration', 'ServerStatus-Extensions', 'ServerStatus-SystemInfo', 'Tasks')
C:\>
```

Again, for emphasis: you can always back up your configuration file first!  You can find the path to this file by calling: `Get-ODUConfigFilePath`.  If you have difficulties you can't fix delete this file and re-run the [set root folder and register Octopus Server](SetupUsage.md#set-root-folder-and-register-octopus-server).
