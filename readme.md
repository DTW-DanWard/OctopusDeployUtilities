
# Octopus Deploy Utilities

Utilities to help you export, search, compare and unit test your Octopus Deploy configuration.


## Why Export Your Data?

Octopus Deploy is a great product but it has a one limitation: it hides your configuration behind many screens.  This makes it time-consuming to search your configuration, review it for quality and consistency... and this manual work does not scale if you have many projects.  How many clicks are required to check your IIS conditional bindings in one project?  What if you have 20 projects and you want to make sure they are all configured the same?  What if you have 80 projects and you want to make sure all your project-level password variables are stored encrypted (Sensitive)?  Have fun clicking the next hour... but shouldn't you double-check the settings *again* next week?

Fortunately Octopus Deploy provides a great REST API that can be used for exporting your configuration data.  And once you can export the data, you can do all sorts of awesome stuff:
* *Easily* see all changes to the entire system over time.
* *Easily* search across your entire configuration.
* *Easily* get details on anything you can think of: How many projects do you have?  Which ones are Windows Services? How many variables do you have; how many are encrypted?  Which projects are using a particular Library Variable Set?
* **Implement standards/best practices in your Octopus Deploy setup and then automatically confirm these standards by unit testing your configuration export.**  You will save countless hours and ensure quality by automating it.
* **Compare releases** (coming soon - on road map).

There is a lot you can do with an export; [read here for greater detail/more examples](docs/WhatCanYouDo.md).  You might want to read the [full rationale here](docs/Rationale.md) for exporting your data.  But trust me: once you've started exporting your configuration data you'll wonder how you've been living without it.

## Why Use This Set Of Tools?
Octopus Deploy does not provide an out-of-the-box solution for getting all your configuration settings so I created this one.  It has a lot of cool and unexpected features:
* It exports all your data or can selectively export particular types using a whitelist or blacklist.
* It exports all properties for a particular type or can export certain properties using a whitelist or blacklist.
* It post-processes your export data to simplify and improve usage.  For example it automatically adds id -> name lookup information so you can view/work with something like ```EnvironmentName = 'Production-West'``` instead of ```Environment = 'Environments-37'```.  It also adds deploy process and variable configuration directly to each project file.  And more!
* It's written in [PowerShell Core](https://github.com/PowerShell/PowerShell) so it runs on any OS - but also runs great in Windows PowerShell 5.
* It stores all data in JSON files so you can work on it with any language.
* It comes with helper tools written in PowerShell.  One tool aggregates all the data in an export into a single object for easy parsing.  Other tools help you test/filter your projects based on type.  Other tools allow you to search your Octopus Deploy configuration and your application code configuration files (web.config, etc.) to see where Octopus Deploy variables are actually being used (coming soon - on road map).


## OK, Let's Get Going Already!

* [Installation & Setup](docs/InstallationSetup.md)
* [Type whitelist & blacklist configuration](docs/TypeWhiteListBlackListConfig.md)
* [Property whitelist & blacklist configuration](docs/PropertyWhiteListBlackListConfig.md)
* [Getting details & reporting](docs/DetailsAndReporting.md)
* [Unit test your configuration](docs/UnitTesting.md)


## More Info

* [Octopus Deploy best practices and testing rules](docs/BestPracticesTestingRules.md)
* [Octopus Deploy Utilities road map](docs/OctopusDeployUtilitiesRoadmap.md)
* [Rationale for exporting](docs/Rationale.md)
* [Stuff you can do with exports](docs/WhatCanYouDo.md)
* [License - it's MIT, don't worry](LICENSE)


Looking for a DevOps engineer with a software engineering background?  [I'm looking for work](http://dtwconsulting.com/)
