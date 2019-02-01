
[![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/OctopusDeployUtilities)  [![Build status](https://ci.appveyor.com/api/projects/status/ql47p2y1relp1dng/branch/master?svg=true)](https://ci.appveyor.com/project/DTW-DanWard/octopusdeployutilities/branch/master)  ![Test Coverage](https://img.shields.io/badge/coverage-48%25-red.svg?maxAge=60)


# Octopus Deploy Utilities

Utilities to help you export, search, report, see changes over time and unit test your Octopus Deploy configuration.  All your configuration data in local JSON files.  Test your deployment configuration *before* deploying to production!


## Why Export Your Data?

Octopus Deploy is a great product but it has a one limitation: it hides your configuration information behind many screens in a web application where you can't directly access the data.  This makes it time-consuming to manually search your configuration, review it for quality and consistency, get reporting details, fix problems, etc.  And this does not scale:
* How many clicks are required to check your IIS conditional bindings in just *one* project - and what if you have 20 IIS projects to check?
* You have 80 projects and you want to confirm every project-level password variable is stored encrypted (Sensitive)?
* You just want to get a report of every Team and who is in it.

Checking your settings can take hours; it's something you really should be doing every so often but all those Octopus Deploy admin screens will slow you down.

Fortunately Octopus Deploy provides a great REST API that can be used for exporting your configuration data.  And once you can export the data, you can do all sorts of awesome stuff:
* *Easily* search across your entire configuration.
* *Easily* see all changes to the entire system over time.
* *Easily* get details on anything you can think of: How many projects do you have?  Which ones are Windows Services?  How many variables do you have; which ones are encrypted?  Which projects are using a particular Library Variable Set?
* **Implement standards/best practices in your Octopus Deploy setup and then automatically confirm compliance with these standards by unit testing your configuration export.**  You will save countless hours and ensure quality by automating it.
* Compare releases (coming soon - on [road map](docs/OctopusDeployUtilitiesRoadmap.md)).

There is a lot you can do with an export; you might want to read the [full rationale here](docs/Rationale.md) for exporting your data.  But trust me: once you've started exporting your configuration data you'll wonder how you've been living without it.


## Why Use *This* Set Of Tools?

Octopus Deploy does not provide a good out-of-the-box solution for getting all your configuration settings so I created **Octopus Deploy Utilities**.  ODU has a lot of cool and unexpected features:
* It exports all your data or can selectively export particular types using a whitelist or blacklist.  Properties for a particular type can also be whitelisted or blacklisted.
* **It post-processes your export data to simplify and improve usage.**  For example it automatically adds id -> name lookup information so you can view/work with its user-friendly name, i.e. `EnvironmentName = 'Production-West'` instead of only by Id, i.e. `Environment = 'Environments-37'`.  It also adds the deploy process and all variable values **directly** to each project file.  And a lot more!
* It is written in [PowerShell Core](https://github.com/PowerShell/PowerShell) so it runs on any OS - but also runs great in Windows PowerShell 5.  (Docker container version is on the [road map](docs/OctopusDeployUtilitiesRoadmap.md)).
* It exports all data to local JSON files so you can process the data with any language.
* It comes with fun helper tools written in PowerShell.
  * Aggregates all data in an export into a single object for easy parsing.
  * Search your variables by name or value across all projects & included variable sets.
  * Test/filter your projects based on deploy process type.
  * And more!

## You are Getting Curious...?

So, just what does an [export look like](docs/SampleExport.md) anyway?  Also, I have a [bunch of questions (FAQ)](docs/FAQ.md).

### Quick Tease

With Octopus Deploy Utilities you can do some **crazy stuff *really* easily**.

```PowerShell
C:\> # get an object that has all the data from the latest export
C:\> $Export = oduobject
C:\>
C:\> # for that export, return all project-level variables *across all projects*, getting the names, values and scope
C:\> $Export.Projects.VariableSet.Variables | Select Name, Value, @{n = 'Scope'; e = { $_.Scope.Breadth } }
C:\> # (lots of variable output here...)
C:\>
C:\> # now return all project-level variables that are explicitly scoped for your EU production environment
C:\> $Export.Projects.VariableSet.Variables | ? { $_.Scope.Breadth -contains 'Prod-EU' }
C:\> # (lots of variable output here...)
C:\>
C:\> # how many projects deploy a Windows Service?
C:\> ($Export.Projects | ? { Test-ODUProjectDeployWindowsService $_ }).Count
72
C:\> # what is the name of custom install folder for the first project?
C:\> Select-ODUProjectDeployActionProperty ($Export.Projects[0]) 'Octopus.Action.Package.CustomInstallationDirectory'
D:\Applications\WebAuth
C:\>
C:\> # what are all the teams and who is a member of each team?
C:\> $Export.Teams | Select Name, MemberUserNames
C:\> # (lots of team/member output here...)
C:\>
C:\> # what are the names of the projects that DO NOT include the 'Important' library variable set?
C:\> $Export.Projects | ? { $_.IncludedLibraryVariableSetNames -notcontains 'Important' } | Select Name
C:\> # (project names here...)
```

Imagine the powerful **Pester** unit tests you could easily write!  Here's an excerpt:

```PowerShell
# make sure there aren't any variables with 'password' or 'pwd' in their name that AREN'T encrypted
It 'Confirm no plaintext *password* or *pwd* variables' { $Export.Projects.VariableSet.Variables |
  ? { $_.Name -match 'password|pwd' -and $_.IsSensitive -eq $false } | Should BeNullOrEmpty }

# make sure only the people we know are administrators
It 'Confirm only dave, janet and lee are admins' {
  Compare-Object -ReferenceObject @('dave','janet','lee')
    -DifferenceObject (($Export.Teams | ? Name -eq 'Octopus Administrators').MemberUserNames) | Should BeNullOrEmpty }

# WOW!
```
(Pester is a test and mock framework that comes with PowerShell.)


## OK, Let's Get Going Already!

* [Setup & usage](docs/SetupUsage.md)
  * [Type whitelist & blacklist configuration](docs/TypeWhiteListBlackListConfig.md)
    * [Type description](docs/TypeDescription.md)
  * [Property whitelist & blacklist configuration](docs/PropertyWhiteListBlackListConfig.md)
* [Viewing Changes Over Time](docs/ViewingChangesOverTime.md)
* [Getting details & reporting](docs/DetailsAndReporting.md) is crucial for understanding how to walk through an export object
* [Searching through variables by name or value](docs/SearchingVariables.md)
* [Unit test your configuration](docs/UnitTesting.md)
* [Octopus Deploy best practices and testing rules](docs/BestPracticesTestingRules.md)
* [Commands at a glance](docs/CommandsAtAGlance.md)
* [Frequently asked questions](docs/FAQ.md)

## More Info

* [What does the post-processing step do?](docs/PostProcessing.md)
* [Road map for Octopus Deploy Utilities](docs/OctopusDeployUtilitiesRoadmap.md)
* [Change log](docs/ChangeLog.md)
* [Rationale for exporting](docs/Rationale.md)
* [License - it's MIT, don't worry](LICENSE)


Hey - are you looking to hire a DevOps engineer with a software engineering background who can create crazy solutions like this?  [I'm looking for work.](http://dtwconsulting.com/)

