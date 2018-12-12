
# Octopus Deploy Utilities

Utilities to help you export, search, compare and unit test your Octopus Deploy configuration.


## Why Export Your Data?

Octopus Deploy is a great product but it has a one limitation: it hides your configuration behind many screens.  This makes it time-consuming to manually search your configuration, review it for quality and consistency, fix problems, etc.  And this manual searching does not scale once you have many projects.  How many clicks are required to check your IIS conditional bindings in just *one* project - and what if you have 20 IIS projects to check?  What if you have 80 projects and you want to make sure all your project-level database password variables are stored encrypted (Sensitive)?  Double-checking your settings can take hours; it's something you really should be doing every so often but all those Octopus Deploy admin screens will slow you down.

Fortunately Octopus Deploy provides a great REST API that can be used for exporting your configuration data.  And once you can export the data, you can do all sorts of awesome stuff:
* *Easily* search across your entire configuration.
* *Easily* see all changes to the entire system over time.
* *Easily* get details on anything you can think of: How many projects do you have?  Which ones are Windows Services?  How many variables do you have; how many are encrypted?  Which projects are using a particular Library Variable Set?
* **Implement standards/best practices in your Octopus Deploy setup and then automatically confirm these standards by unit testing your configuration export.**  You will save countless hours and ensure quality by automating it.
* Compare releases (coming soon - on [road map](docs/OctopusDeployUtilitiesRoadmap.md)).

There is a lot you can do with an export; [read here for greater detail/more examples](docs/WhatCanYouDo.md).  You might want to read the [full rationale here](docs/Rationale.md) for exporting your data.  But trust me: once you've started exporting your configuration data you'll wonder how you've been living without it.


## Why Use *This* Set Of Tools?

Octopus Deploy does not provide a good out-of-the-box solution for getting all your configuration settings so I created Octopus Deploy Utilities.  It has a lot of cool and unexpected features:
* It exports all your data or can selectively export particular types using a whitelist or blacklist.
* It exports all properties for a particular type or can export certain type-specific properties using a whitelist or blacklist.
* **It post-processes your export data to simplify and improve usage.**  For example it automatically adds id -> name lookup information so you can view/work with a variable scope like ```EnvironmentName = 'Production-West'``` instead of ```Environment = 'Environments-37'```.  It also adds deploy process and variable configuration directly to each project file.  And more!
* It's written in [PowerShell Core](https://github.com/PowerShell/PowerShell) so it runs on any OS - but also runs great in Windows PowerShell 5.  No other pre-compiled components required.  (Docker container version is on [road map](docs/OctopusDeployUtilitiesRoadmap.md))
* It stores all data in JSON files so you can work on it with any language.
* It comes with helper tools written in PowerShell.  One tool aggregates all the data in an export into a single object for easy parsing.  Other tools help you test/filter your projects based on type.  Other tools allow you to search your Octopus Deploy configuration and your application code configuration files (web.config, etc.) to see where Octopus Deploy variables are actually being used (coming soon - on [road map](docs/OctopusDeployUtilitiesRoadmap.md)).


## You are Getting Curious...?

So, just what does an [export look like](docs/SampleExport.md) anyway?

I have a [bunch of questions](docs/FAQ.md).


## OK, Let's Get Going Already!

* [Installation & Setup](docs/InstallationSetup.md)
  * [Type whitelist & blacklist configuration](docs/TypeWhiteListBlackListConfig.md)
    * [Type description](docs/TypeDescription.md)
  * [Property whitelist & blacklist configuration](docs/PropertyWhiteListBlackListConfig.md)
* [Getting details & reporting](docs/DetailsAndReporting.md)
* [Unit test your configuration](docs/UnitTesting.md)
* [Octopus Deploy best practices and testing rules](docs/BestPracticesTestingRules.md)
* [Frequently asked questions](docs/FAQ.md)

## More Info

* [What does the post processing step do?](docs/PostProcessing.md)
* [Road map for Octopus Deploy Utilities](docs/OctopusDeployUtilitiesRoadmap.md)
* [Stuff you can do with exports](docs/WhatCanYouDo.md)
* [Rationale for exporting](docs/Rationale.md)
* [License - it's MIT, don't worry](LICENSE)


Looking for a DevOps engineer with a software engineering background?  [I'm looking for work.](http://dtwconsulting.com/)
