
# Getting Details About Your Export

## Getting a Single Object
Octopus Deploy Utilities saves all your Octopus Deploy configuration data as JSON files.  These days JSON files are easy to parse with any language - and PowerShell is no exception.  PowerShell provides a handy cmdlet `ConvertFrom-Json` for taking a JSON file and converting it to an object.  For example, if you wanted to get an object that you could use for a single file in a particular export, an Environment file, you could run a command like below and see the output:

```PowerShell
C:\> Get-Content -Path C:\OctoExports\MyOctoServer.octopus.app\20181213-183336\Environments\TestEnv.json | ConvertFrom-Json
Id                         : Environments-21
Name                       : Test-Env
Description                : Test-Env environment description
SortOrder                  : 1
UseGuidedFailure           : False
AllowDynamicInfrastructure : False
Links                      : @{Self=/api/environments/Environments-21; Machines=/api/environments/Environments-21/machines{?skip,take,partialName,roles,isDisabled,healthStatuses,commStyles,tenantIds,tenantTags
                             };
                             SinglyScopedVariableDetails=/api/environments/Environments-21/singlyScopedVariableDetails}
MachineIds                 : { Machines-325 }
MachineNames               : { TestWeb4}
```

From there you can manipulate the object, check it's properties, etc.  And that's all well and good for a single object... but having to write that out for every file in an export gets tiring in a hurry.

## Get All Data in an Export with oduobject

ODU provides a handy function called oduobject that returns all the data in a particular export in a single object.

```PowerShell
C:\> # no parameter? get all the data in a single object from the latest export
C:\> oduobject
C:\> # sorry, there is so much data it's not worth it to show it here
C:\> # but I can show you this:
C:\> (oduobject | Get-Member -MemberType NoteProperty).Count
25
C:\> # there are 25 separate properties on the data object
C:\>
C:\> # if you don't want the latest export but want an older one, you can pass in a path:
C:\> oduobject C:\OctoExports\MyOctoServer.octopus.app\20181210-103023
```

Please note that last example: if you don't want the latest export but want an older one, you can pass in a path.  Also note: oduobject is an alias for Read-ODUExportFromFiles.

How does oduobject work? For each sub-folder (say Environments, Machines, Projects, etc.) in an export, it gathers all the JSON files under that subfolder, converts them to objects and put them in an array under a property with the same name as the folder.  So environment files under Environments folder get converted to objects and then are stored under an Environments property.  Pretty simple!

Let's see some examples:
```PowerShell
C:\> # there's no need to re-read all those files each time so let's read once and reuse
C:\> $Export = oduobject
C:\> 
C:\> $Export.Environments.Count
13
C:\> $Export.Environments  # this should list all the data but...
C:\> # again, there's too much data to display so I'm omitting it
C:\> # normally it would show these properties for 13 environment objects
C:\> #   Id, Name, Description, SortOrder, UseGuidedFailure, AllowDynamicInfrastructure, Links, MachineIds, MachineNames
C:\> 
```

## Learn PowerShell and Use Your Imagination

At this point it's up to you to look at the contents of an export, find some data in the JSON file and practice accessing / measuring / reporting that data.  And use your imagination!  Here are some examples:

```PowerShell
C:\> # get copy to reuse
C:\> $Export = oduobject
C:\> # list each Team and it's members
C:\> $Export.Teams | Select Name, MemberUserNames
C:\> # lots of details here...
C:\> 
C:\> # what's the average Team size?
C:\> $Export.Teams.MemberUserNames.Count / $Export.Teams.Count
7.4
C:\> 
C:\> # how many variables total? don't forget about Measure-Object
C:\> $Export.Projects.VariableSet.Variables | Measure-Object
C:\> # lots of details here...
C:\> 
C:\> # list all the project-level variables across all projects
C:\> $Export.Projects.VariableSet.Variables | Select Name, Value, @{n = 'Scope'; e = { $_.Scope.Breadth } }
C:\> # lots of details here...
C:\> 
C:\> # list each project name followed by just it's project-level variables
C:\> $Export.Projects | % { "`nProject: $($_.Name)"; $_.VariableSet.Variables | Select Name, Value, @{n = 'Scope'; e = { $_.Scope.Breadth } } }


```

asdf add example above: adding project variable and libraryset variables
***NEED TO ADD ACTUAL LIBRARY VARIABLES TO SET!


(oduobject).Projects.VariableSet.Variables | 
  ? { $_.Name -match 'password|pwd' -and $_.IsSensitive -eq $false

## Helper Functions for Filtering

asdf filtering IIS / WIndows Services

asdf function for getting value of a property


What about creating custom reports about data *not* in Deployment History? 
   A list of all users and their teams? A list of all sensitive variable names across all projects?  
   How about a list of all variables named '*Passward*' that AREN'T sensitive?  Yeah, I would want that list, too!

How many projects?  How many projects that are IIS?  Windows Services?


A list of all users and their teams? A list of all sensitive variable names across all projects?  


How about a list of all variables named '*Passward*' that AREN'T sensitive?  Yeah, I would want that list, too!

asdf


Filter this way:
  .Breadth -contains 'Staging'
  .EnvironmentName -contains 'Staging'
