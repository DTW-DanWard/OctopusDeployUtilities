
# Getting Details About Your Export

There are a lot of details in here but it's all good stuff.  Make sure you read to the end - it covers included helper functions for helping you find / filter your data.

## Learn PowerShell
PowerShell is great for filtering and reporting on data, especially walking/parsing through large complex sets of objects (like an Octopus Deploy export).  If you don't know PowerShell I highly recommend you start learning before attempting anything too complex in reporting - otherwise you might get frustrated.  One example you try will work while another will fail; they will both look very similar and it won't be clear what's going on.  There is a lot of built-in magic in PowerShell that is incredibly useful in walking through objects - fallback member resolution being the most important.

If you are looking for a great resource to learn from, I highly recommend [PowerShell in Action](https://www.manning.com/books/windows-powershell-in-action-third-edition).  You don't need to read the whole thing, just the first 5 chapters and you should be good to go.  

FYI, if you aren't familiar with the term 'fallback member resolution' but you understand the code below then don't worry - you know what it is.

```PowerShell
C:\> # get the FullName of the first item in the temp folder
C:\> (dir c:\temp)[0].FullName
C:\>
C:\> # get the FullName of EVERY item in the temp folder
C:\> (dir c:\temp).FullName
C:\>
C:\> # fallback resolution in a nutshell:
C:\> #   (dir c:\temp) returns an array of objects (assuming folder isn't empty)
C:\> #   (dir c:\temp)[0] returns the first object in the array
C:\> #   (dir c:\temp)[0].FullName looks for a property named FullName on that object; it finds it and returns it
C:\> #   
C:\> #   Now the more complex version using fallback member resolution:
C:\> #   (dir c:\temp) returns an array objects
C:\> #   (dir c:\temp).FullName looks for a property named FullName on that object - an array does NOT have a FullName
C:\> #      property so PowerShell then checks to see if the object reference in question (dir c:\temp) is some type of
C:\> #      object that can be enumerated; in this case, it's an array - it can be enumerated - so PowerShell then attempts
C:\> #      to look for a member named FullName on each object in the array; in this case it find that member and returns
C:\> #      the value for each object in the array
```



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

How does oduobject work? For each sub-folder (say Environments, Machines, Projects, etc.) in an export, it gathers all the JSON files *under* that sub-folder, converts them to objects and put them in an array under a property with the same name as the folder.  So environment JSON files under Environments folder get converted to objects and then are stored under an Environments property.  Pretty simple!

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

## Some Basics

Here are some more basic examples.

```PowerShell
C:\> # get copy to reuse
C:\> $Export = oduobject
C:\> # list each Team and it's members
C:\> # like all properties hanging directly off the $Export object, Teams is an array
C:\> # so calling .Teams returns every item in the array
C:\> $Export.Teams | Select Name, MemberUserNames
C:\> # lots of details here...
C:\> 
C:\> # what's the average Team size?
C:\> # note: the .Teams.MemberUserNames is using fallback member resolution
C:\> # there is no property (or method) MemberUserNames on the Teams array but there is
C:\> # on the individual Team item in the array; turns out, MemberUserNames is itself
C:\> # a reference to an array and we are calling the Count method on it
C:\> # I warned you this could get a little confusing... :-)
C:\> $Export.Teams.MemberUserNames.Count / $Export.Teams.Count
7.4
C:\> 
C:\> # how many variables total? more fallback member resolution
C:\> # this time use Measure-Object instead of calling .Count
C:\> $Export.Projects.VariableSet.Variables | Measure-Object
C:\> # (lots of details returned here...)
C:\> 
C:\> # list all the project-level variables across all projects
C:\> $Export.Projects.VariableSet.Variables | Select Name, Value, @{n = 'Scope'; e = { $_.Scope.Breadth } }
C:\> # (lots of details returned here...)
C:\> 
C:\> # list each project name followed by just it's project-level variables
C:\> $Export.Projects | % { "`nProject: $($_.Name)"; $_.VariableSet.Variables | Select Name, Value, @{n = 'Scope'; e = { $_.Scope.Breadth } } }
```


## Project-Level Variables vs Included Library Set Variables
Up until this point all of the variable examples have focused on searching across project-level variables.  If you want to search/filter on included library variable set variables there are some things to know.

### Post-processing Adds Project-Level Variables to a new VariableSet Property (or, VariableSet.Variables for the actual values)
For each project, Post-processing will take a project's project-level variables and add them to the project via the new property VariableSet.  This has a single value, not an array.  There are a number of properties on the VariableSet object, most are not useful with the exception of Variables - that's where the actual project-level variable instances are.  So, some examples:

```PowerShell
C:\> # get copy to reuse
C:\> $Export = oduobject
C:\> # projects are stored under the Projects property; .Projects returns an array
C:\> $Export.Projects.Count
19
C:\> # this returns the first item in that array and for that item gets the VariableSet object
C:\> $Export.Projects[0].VariableSet
Id          : variableset-Projects-5
OwnerId     : Projects-5
Version     : 0
Variables   : { ...omitted for brevity... }
ScopeValues : @{Environments=System.Object[]; Machines=System.Object[]; Actions=System.Object[];
              Roles=System.Object[]; Channels=System.Object[]; TenantTags=System.Object[]}
Links       : @{Self=/api/variables/variableset-Projects-5}
OwnerName   : Some Project Name
C:\> 
C:\> # like I said, most of the info on the VariableSet isn't useful, except that Variables property
C:\> $Export.Projects[0].VariableSet.Variables
C:\> # (lists all the project-level variables for the project...)
C:\> 
C:\> # so again, to beat a dead horse (terrible expression!), fallback member resolution can be used
C:\> # to return ALL project-level variables across all projects
C:\> $Export.Projects.VariableSet.Variables
C:\> # (lists all the project-level variables for ALL projects...)
```

### Post-processing ALSO Adds Included Library Variable Set Variables to the Project
Included Library variable sets also get added to the project but are little more tricky as there can be zero, one or more included library variable sets on a project.  So in this case the property added to project - IncludedLibraryVariableSets - is itself an array.  The IncludedLibraryVariableSets array contains VariableSet objects which, we know from above, store their variables on the Variables property.  So some examples to help make it clear:

```PowerShell
C:\> # this returns all included library variable sets for a project
C:\> $Export.Projects[0].IncludedLibraryVariableSets
C:\> # (lots of details...)
C:\> 
C:\> # it's an array; this project has two included library variable sets
C:\> $Export.Projects[0].IncludedLibraryVariableSets.Count
2
C:\> # these are the variables in the first included library variable set
C:\> $Export.Projects[0].IncludedLibraryVariableSets.VariableSet.Variables
C:\> # (lots of details...)
C:\> 
C:\> # these are ALL the variables for ALL the included library variable sets - fallback time
C:\> $Export.Projects.IncludedLibraryVariableSets.VariableSet.Variables
C:\> # (lots more details...)
```

### Tips on Using Each - And Another Thing to Know
If you are interested in looking / evaluating / searching / reporting at a particular project level, you probably want to check both the projects's VariableSet and IncludedLibraryVariableSets contents.  However, if you want to search across *all* projects searching for a particular variable (local and global) and it's usage, you probably do NOT want to check the contents of a *project's* IncludedLibraryVariableSets.  Why?  You'll have multiple hits at the project level when checking included library variable sets.

Imagine you have an Included Library Variable Set named *ConnectionStrings* and this contains a variable *SalesDbCnString*.  Included Library Variable Set *ConnectionStrings* is included in 30 projects.  If you were to search for *SalesDbCnString*, at a project-level, through every IncludedLibraryVariableSets you'd get 30 matches.  And none of these is the source variable!  So where is the source?

Under the **export's** LibraryVariableSets property:

```PowerShell
C:\> # these are the included library variable sets defined in your Octopus Deploy configuration
C:\> $Export.LibraryVariableSets
C:\> # (lots of details...)
C:\> 
C:\> # let's see the actual variables for the first included library variable set in the configuration
C:\> $Export.LibraryVariableSets[0].VariableSet.Variables
C:\> # (lots of details...)
C:\> 
C:\> # and now, finally, all the variables across all the included library variable sets via fallback
C:\> $Export.LibraryVariableSets.VariableSet.Variables
C:\> # (lots of details...)
```

Is that clear?  Man I hope so; I am really sick of typing *included library variable sets*.  :-|



## Variable Scope and Breadth

This next bit is a copy of the [post processing](PostProcessing.md) section *Adds Scope Names to Variables*.  However it is very important to know for reporting on variables with regard to scope so I'm including it here.

The default Octopus Deploy export of a variable is OK but could be better.  Here's an example without processing:
```JSON
{
  "Name": "TempImagePath",
  "Value": "D:\\Cache\\Images",
  "Scope": {
    "Environment": [ "Environments-7", "Environments-16" ],
    "Machine": [ "Machines-42" ],
    "Role": [ "WebClientFacing" ]
  },
  ...
}
```

We don't know what those environment and machine ids map to (roles don't require a lookup).  Post-processing adds the name values for the ids:

```JSON
{
  "Name": "TempImagePath",
  "Value": "D:\\Cache\\Images",
  "Scope": {
    "Environment": [ "Environments-15", "Environments-16" ],
    "EnvironmentName": [ "Prod-EU-1", "Prod-EU-2" ],
    "Machine": [ "Machines-42" ],
    "MachineName": [ "Staging-Web-3" ],
    "Role": [ "WebClientFacing" ],
    "Breadth": [ "Prod-EU-1", "Prod-EU-2", "Staging-Web-3" "WebClientFacing", ]
  },
  ...
}
```

#### Breadth???
*Do you see that other change the post-processing made?*  It also added a property Breadth that aggregates all the other name values and roles!  This make it much, *much* easier when writing code to search and report on Octopus Deploy variables.  For an Octopus Deploy variable export, a particular property like Environment, Machine or Role will only exist if a value has been set for that property type.  That means if you want to check a variable if it has a particular setting, you have to check first to see if the property exists on that variable, making your search / unit testing code ugly.  However, with Breadth *always* available you don't have to worry.

Here's single, **short** line of PowerShell that gets the latest export and returns **all project-level variables, their values and their scope**:
```PowerShell
C:\> (oduobject).Projects.VariableSet.Variables | Select Name, Value, @{n='Scope'; e = { $_.Scope.Breadth } }
```

Here's single, **short** line of PowerShell that gets the latest export and searches across **all project-level variables** in **all projects** and returns the variables that have a scope that specifies environment Prod-EU-2:
```PowerShell
C:\> (oduobject).Projects.VariableSet.Variables | ? { $_.Scope.Breadth -contains 'Prod-EU-2' }
```

## Helper Functions for Selecting & Filtering

Octopus Deploy Utilities comes with a few help filtering utilities out of the box.

### Test-ODUProjectDeployIISSite and Test-ODUProjectDeployWindowsService

Want to be able to quickly find IIS Site and / or Windows Service projects?  Use Test-ODUProjectDeployIISSite and / or Test-ODUProjectDeployWindowsService; these check a project's deploy process configuration to see if it deploys an IIS site and / or a Windows Service.  Or, to get real specific (now that you can view the project details in the JSON), they check a project's DeploymentProcess.Steps.Actions.ActionType for either *Octopus.IIS* or *Octopus.WindowsService*, respectively.

```PowerShell
C:\> # how many projects deploy an IIS site
C:\> ($Export.Projects | ? { Test-ODUProjectDeployIISSite $_ }).Count
26
C:\> # how many projects deploy a Windows Service
C:\> ($Export.Projects | ? { Test-ODUProjectDeployWindowsService $_ }).Count
72
```

There is a lot of room for growth with regard to filtering functions for ODU.  Please submit any contributions you have!


### Get Any Deploy Process Property with Select-ODUProjectDeployActionProperty

**This one is super handy!**  If you look at the deploy process Properties there are a lot of values in there.  *A lot*.  And, depending on the configuration options you set for a project (say, enabling Custom Installation Directory), that list of properties will vary from project to project.  And walking that object notation to get to those Properties can get pretty ugly.  It gets even more ugly if you are running your PowerShell with `Set-StrictMode` (which you should) as if you attempt to access a property and it's not there, an error gets thrown.

But don't worry about any of that - just use `Select-ODUProjectDeployActionProperty`.  If you pass in a particular Property name it will return the value - if it exists - and return $null if it doesn't.  Some examples:

```PowerShell
C:\> # what's the app pool name for project 0
C:\> Select-ODUProjectDeployActionProperty ($Export.Projects[0]) 'Octopus.Action.IISWebSite.WebApplication.ApplicationPoolName'
MyAppPool
C:\> 
C:\> # does project 0 specify that a custom install folder should be purged?
C:\> Select-ODUProjectDeployActionProperty ($Export.Projects[0]) 'Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment'
True
C:\> 
C:\> # and what is the name of that custom install folder?
C:\> Select-ODUProjectDeployActionProperty ($Export.Projects[0]) 'Octopus.Action.Package.CustomInstallationDirectory'
D:\Applications\MyWebSite
```

Cool stuff.  Again: I think there is a lot of room for growth for filtering & selection functions so please contribute your own creations!
