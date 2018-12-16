
# Octopus Deploy API Type Descriptions

## Intro

Octopus Deploy Utilities (ODU) use the Octopus Deploy REST API to export data.  The best way to learn about the API is to review the Swagger info on your server (url for your server/swaggerui/index.html) or on the [Octopus Deploy demo server](https://demo.octopus.com/swaggerui/index.html).

Note: ODU does not use every possible call in the Swagger API list; there are a number of API calls that don't return any useful information, appear to still be under development, etc.  

## ODU API Call Information - Summary

So, what calls does ODU use and how does it use them?  Run this in PowerShell:
```PowerShell
Get-ODUStandardExportRestApiCalls | Select RestName, RestMethod, ApiFetchType, FileNamePropertyName
```
And you'll see the table below.  There are 4 pieces of information for each item listed here:
1. RestName: in general this matches the Swagger API name and is the name of the folder created for storing data for non-'Simple' types (more below).  It is also the value used when configuring the Type blacklist or whitelist.
2. RestMethod: the API call used for retrieving data.
3. ApiFetchType: type identifying how to use this API (more below).
4. FileNamePropertyName: individual exported item property value to use for file name.

### ODU REST API Call Listing

|RestName|RestMethod|FileNamePropertyName|FileNamePropertyName|
|---|---|---|---|
|Accounts|/api/accounts|MultiFetch|Name|
|ActionTemplates|/api/actiontemplates|MultiFetch|Name|
|Artifacts|/api/artifacts|MultiFetch|Id|
|Channels|/api/channels|MultiFetch|Id|
|CommunityActionTemplates|/api/communityactiontemplates|MultiFetch|Name|
|Configuration|/api/configuration|MultiFetch|Id|
|Deployments|/api/deployments|MultiFetch|Id|
|Environments|/api/environments|MultiFetch|Name|
|Events|/api/events|MultiFetch|Id|
|Feeds|/api/feeds|MultiFetch|Name|
|Interruptions|/api/interruptions|MultiFetch|Id|
|LibraryVariableSets|/api/libraryvariablesets|MultiFetch|Id|
|Lifecycles|/api/lifecycles|MultiFetch|Name|
|MachinePolicies|/api/machinepolicies|MultiFetch|Name|
|Machines|/api/machines|MultiFetch|Name|
|OctopusServerNodes|/api/octopusservernodes|MultiFetch|Name|
|Packages|/api/packages|MultiFetch|Id|
|ProjectGroups|/api/projectgroups|MultiFetch|Name|
|Projects|/api/projects|MultiFetch|Name|
|ProjectTriggers|/api/projecttriggers|MultiFetch|Id|
|Proxies|/api/proxies|MultiFetch|Name|
|Releases|/api/releases|MultiFetch|Id|
|ServerStatus-Extensions|/api/serverstatus/extensions|MultiFetch|Name|
|Subscriptions|/api/subscriptions|MultiFetch|Name|
|TagSets|/api/tagsets|MultiFetch|Name|
|Tasks|/api/tasks|MultiFetch|Id|
|Teams|/api/teams|MultiFetch|Name|
|Tenants|/api/tenants|MultiFetch|Name|
|TenantVariables|/api/tenantvariables/all|MultiFetch|TenantId|
|UserRoles|/api/userroles|MultiFetch|Name|
|Users|/api/users|MultiFetch|Username|
|DeploymentProcesses|/api/deploymentprocesses|ItemIdOnly|Id|
|Variables|/api/variables|ItemIdOnly|Id|
|Authentication|/api/authentication|Simple|NOT_USED|
|BuiltInRepository|/api/repository/configuration|Simple|NOT_USED|
|ExternalSecurityGroups|/api/externalsecuritygroupproviders|Simple|NOT_USED|
|FeaturesConfiguration|/api/featuresconfiguration|Simple|NOT_USED|
|LetsEncrypt|/api/letsencryptconfiguration|Simple|NOT_USED|
|Licenses|/api/licenses/licenses-current|Simple|NOT_USED|
|MachineRoles|/api/machineroles/all|Simple|NOT_USED|
|MaintenanceConfiguration|/api/maintenanceconfiguration|Simple|NOT_USED|
|Permissions|/api/permissions/all|Simple|NOT_USED|
|Reporting|/api/reporting/deployments/xml|Simple|NOT_USED|
|ServerConfiguration|/api/serverconfiguration|Simple|NOT_USED|
|ServerStatus|/api/serverstatus|Simple|NOT_USED|
|SmtpConfiguration|/api/smtpconfiguration|Simple|NOT_USED|
|ServerStatus-Nuget|/api/serverstatus/nuget|Simple|NOT_USED|
|ServerStatus-SystemInfo|/api/serverstatus/system-info|Simple|NOT_USED|
|ServerStatus-Timezones|/api/serverstatus/timezones|Simple|NOT_USED|
|UpgradeConfiguration|/api/upgradeconfiguration|Simple|NOT_USED|
|UserOnboarding|/api/useronboarding|Simple|NOT_USED|


## ODU API Call Information - Details

For the most part, the Octopus Deploy REST APIs are very, *very* consistent (thanks, Octo devs!) and this made coding against them very easy.  However, in practice, splitting them up by one of three types was required.

### ApiFetchType = MultiFetch
MultiFetch represents the bulk of the data we are interested in exporting: Projects, Machines, Environments, etc. and has these characteristics:
1. RestName matches the Swagger name exactly (one exception: ServerStatus-Extensions)
2. RestName is used for the folder name created to store the exported data.
3. When the API is called, the results might have 0, 1 or more items in it.  Each item is stored *in it's own separate file* under the folder.  The item's file name is the value in the property identified in FileNamePropertyName (usually the Id or Name).
4. When the API is called, it might have a portion or all of the results for that type.  ODU might have to make the call multiple times, paging through the results, saving each item it it's own file.


### ApiFetchType = ItemIdOnly
There are two API calls listed as ItemIdOnly: DeploymentProcesses and Variables.  In theory these two types should just be treated as MultiFetch calls (originally they were) but it turns out in practice this can't be done.  If you have an Octopus Deploy instance with a good amount of projects and history, the internal storage/count of DeploymentProcesses and Variables items gets really, *really* large.  How large?  So large that the calls to the DeploymentProcesses and Variables APIs time out - doh!

The work-around to this is to explicitly fetch the currently used DeploymentProcesses and Variables items *by Id*.  I.E. don't fetch all DeploymentProcesses, just the ones being referenced by projects; don't fetch all Variables, just the ones being referenced by projects and included variablesets.  How do we know which Ids are currently being used?  We fetch all the MultiFetch items first and if we see a DeploymentProcesses or Variables being referenced we store which one is being referenced by Id and we export it later by that Id.

Otherwise ItemIdOnly calls are similar to MultiFetch: the RestName matches the Swagger name, items are stored in a folder with the RestName and an item is stored in an individual file with a name based on FileNamePropertyName.


### ApiFetchType = Simple
These calls have admin-type configuration information.  The data in them is retrieved in a single call.  The individual items in the results may not have a unique Id that can be used for saving to a individual file so all items are saved in a single file with the RestName as the file name (this is why FileNamePropertyName = NOT_USED).

Many of these calls *will not work* if you are using a Octopus Deploy-hosted cloud instance - you won't have the privileges.  Many of these calls have data that is unlikely to change.  Any many of these calls have info that is, in my humble opinion, not really useful (time zones, smtp configuration, upgrade configuration?  meh).

This data is still exported and is available via the oduobject call.  However, rather than clutter the main export folder with a bunch of folders for these less-than-useful calls (each folder of which would probably only have 1 file in it), all the Simple results are stored in a folder call **Miscellaneous**.

It is possible, as some point, that specific Simple calls could be promoted to MultiFetch status based on user demand.


## So What Do I Do With This Information?
Now that you have a greater insight into the various Octopus Deploy API calls you can use this information to configure which types to export via the [blacklist and whitelist configuration](TypeWhiteListBlackListConfig.md).
