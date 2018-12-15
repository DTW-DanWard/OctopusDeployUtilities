
# Data Export Post-Processing

## Why Post-Processing
When data is first exported from an Octopus Deploy API call, it's not nearly as helpful as it could be - there's a lot of data that missing.  Here's a portion of a JSON file for a project directly exported from Octopus Deploy:

```JSON
{
  "Id": "Projects-5",
  "Name": "MyCo.WebMainCopy",
  "VariableSetId": "variableset-Projects-5",
  "DeploymentProcessId": "deploymentprocess-Projects-5",
  "ClonedFromProjectId": "Projects-4",
  "IncludedLibraryVariableSetIds": [
    "LibraryVariableSets-7"
  ],
  "ProjectGroupId": "ProjectGroups-9",
  "LifecycleId": "Lifecycles-6",
  ...
}
```

This leaves a lot to be desired.  What project was this cloned from?  I don't know what *Projects-4* is.  What's the actual name of included variable set?  The project group?  The lifecycle?  But there are much bigger questions: what are the steps in *deploymentprocess-Projects-5*?  What are the variables in *variableset-Projects-5* and *LibraryVariableSets-7*?  We can do better.

And Octopus Deploy Utilities does!  After an export it performs the post-processing steps below.

## Post-Processing Steps Summary

### Creates Id to Name Lookup
Searches through every file in the export, gathering the unique identifier (say *Projects-23* or *Environments-12*) and the display name (say *QueueProcessor* or *TestEnv*) for each item.  These values are stored in file IdToNameLookup.json in the export root.

### Adds External Name Values for Ids
Looks for Id references to other items (example ```"ClonedFromProjectId": "Projects-4"```) and adds a new property with the display name (adds ```"ClonedFromProjectrName" = "MyCo.WebMain"```).

### Adds Scope Names to Variables - Including Aggregate Breadth Property
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

We don't know what those environment and machine ids map to (roles don't require a lookup).  Post-processing adds the name values for the ids::

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
(oduobject).Projects.VariableSet.Variables | Select Name, Value, @{n='Scope'; e = { $_.Scope.Breadth } }
```

Here's single, **short** line of PowerShell that gets the latest export and searches across **all project-level variables** in **all projects** and returns the variables that have a scope that specifies environment Prod-EU-2:
```PowerShell
(oduobject).Projects.VariableSet.Variables | ? { $_.Scope.Breadth -contains 'Prod-EU-2' }
```
This simplicity is pretty awesome!  If you are writing unit testing this will be incredibly helpful.


### Adds Machines to Environments
By default an Octopus Deploy export of an environment does *not* contain the machine ids of the machines in that environment.  Post-processing adds both the machine ids along with the display names.


### Adds Deploy Processes, Variables and Included Variable Sets to Projects
By default an Octopus Deploy export of a project is missing a lot of details.  Post-processing adds the deploy steps, the variables and any/all included library variable sets to the project.


## Post-Processing - Before and After
For a more detailed review of the post-processing steps you can review the code but there's a better option: you can run an export sans post-processing, copy the export to a new folder, post-process the new copy and then diff the before and after.

Here are the steps to do that.

```PowerShell
# this runs a export (saving data to a new folder), doesn't do the post-processing on it and returns the path of the export
$ExportPathNoJoin = oduexport -SkipJoinData -PassThru
# now let's copy that export folder to a new folder
$ExportPathJoin = $ExportPathNoJoin + '_Join' 
Copy-Item $ExportPathNoJoin $ExportPathJoin -Container -Recurse -Force
# and run the post-processing on that new folder
Update-ODUExportJoinData $ExportPathJoin
# at this point you can diff those two folders
# if you set up the path to your diff tool in ODU, this should work:
& (Get-ODUConfigDiffViewer) $ExportPathNoJoin $ExportPathJoin
```
