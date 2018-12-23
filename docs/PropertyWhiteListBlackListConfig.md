
# ODU Property Export BlackList / WhiteList

Octopus Deploy Utilities also supports blacklists and whitelists.  What does that mean?  **For a particular type** you can specify whether you want all properties to be stored (no blacklist or whitelist), only certain properties to be stored (whitelist) or all properties except a certain list (blacklist).  *Why* would you want to configure this?  Turns out there are a few good reasons.

## Smaller, Cleaner Exports
Depending on what you are looking for in an export, Octopus Deploy's REST API might delivery more than you want.  Simplest example: every object that is exported comes with a `Links` property.  This property contains pre-constructed urls that allow you to programmatically query the REST API to bring back additional data about that particular object.  With ODU, you are checking out the exports as a whole and not interrogating the API yourself, so Links is probably not important to you.

But here's a better, more complex example: certain types - LibraryVariableSets, Projects, Variables - include a property for every single object called ScopeValues.  ScopeValues is a lookup that provides a mapping for every possible Scope-related Id in your system to a proper name.  This lookup allows you to view project and variable settings that have only the id (say `Environments-8`) in the Scope but easily determine the name you know it by (`Prod-East`).  That sounds good... except the ScopeValues has **every** id -> name look in the entire system, for every LibraryVariableSets, Projects, Variables object, *even if those Scope ids aren't used in the object!*  If you have any number of environments, machines, etc. that Scope lookup very quickly balloons to be **huge**.  I've seen the JSON for an exported Project with only 5 variables in it *also* include a ScopeValues lookup section that was over 1200 lines long in the JSON file!  All that extra junk content takes spaces, slows the ODU post-processing step and slows the oduobject creation process every time as it needs to process all that extra junk data.

And it is junk data because the ODU post-processing step automatically adds the Id -> lookup values directly to the Scope object and it ONLY adds the actual values you use, not every possible lookup in the system.

For that reason, by default, Octopus Deploy Utilities has a blacklist set that filters out ScopesValues from those 3 types.


## Removing Time-Sensitive Values

For some Octopus Deploy type exports certain properties are included that will change over time regardless of your configuration.  These changes probably aren't important but, if you are diff'ing older exports, they will ruin your diff because the values are, in fact, different.

Simple example with that pesky Links property again: a particular Links url might included the logo *and it's version* in the url:

  "Logo": "/api/projects/Projects-22/logo?cb=2018.9.`0`"

  "Logo": "/api/projects/Projects-22/logo?cb=2018.9.`4`"

These actual values were taken from a cloud-hosted instance.  The Octopus Deploy cloud instances upgrade automatically without your knowledge over time - **that's a good thing** - but it introduces these differences in your exports.

Turns out there are a lot of properties that might change over time and you don't really care (and don't want your diffs to be affected):
* Do you care if a particular machine has the latest calamari?  It's just going to get updated anyhow during your next deploy.
* Do you care when an OctopusServerNode was last seen?
* How about how many packages are in Nuget?  That's *always* going to change so knowing it provides zero value.

Removing these unimportant but changing values will help simplify your diffs.

## How to Set the Property BlackList or WhiteList

You do it with `Get-ODUConfigPropertyBlacklist` and `Set-ODUConfigPropertyBlacklist`, as you might expect, but the structure is more complicated than the type blacklist and whitelist (which was a simple array).  For properties ODU uses a single hashtable where each key on the hashtable is the specific name of a type and each value on the hash table is an array listing the properties for that type.

Here's a property blacklist example that filters out ScopeValues from the aforementioned types LibraryVariableSets, Projects, Variables:
```PowerShell
C:\> $HT = @{
      LibraryVariableSets = @('ScopeValues')
      Projects            = @('ScopeValues')
      Variables           = @('ScopeValues')
     }
C:\>
C:\> Set-ODUConfigPropertyBlacklist $HT
```

`The above example is the default property blacklist setup for ODU.  If you ever want to reset to the defaults, use the code above!`


## Filtering Out Properties That Change Over Time

As mentioned, certain properties will change over time but these particular values aren't important.  It would be nice to remove them from the export.  Here's an example of how to do that:
```PowerShell
C:\> $HT = @{
       Licenses                  = @('MaintenanceExpiresIn')
       Machines                  = @('HasLatestCalamari', 'HealthStatus', 'StatusSummary')
       OctopusServerNodes        = @('LastSeen')
       ServerStatus              = @('MaintenanceExpires','MaximumAvailableVersion','MaximumAvailableVersionCoveredByLicense')
       'ServerStatus-Nuget'      = @('TotalPackages')
       'ServerStatus-SystemInfo' = @('ThreadCount', 'Uptime', 'WorkingSetBytes')
     }
C:\>
C:\> Set-ODUConfigPropertyBlacklist $HT
C:\> # note: there could be more properties than these, these are just the ones I've noticed
C:\> # also: if you want to add the ScopeValue entries to this hashtable, go ahead
```
