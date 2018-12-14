
# Why Export Your Octopus Deploy Configuration Data?

## Introduction

Octopus Deploy is a great product; there's a reason it is popular.  The interfaces are clean and straightforward, making initial project entry relatively easy.  But the downside of those clean interfaces is that it can make finding and reviewing settings - especially across multiple projects at the same time - a bit of a pain.  I worked at a company managing an Octopus Deploy instance with 180 projects and *many* thousands of variables; you could spend all day clicking to review settings across projects.

For example, let's say you like to install your Windows Service projects to a specific custom installation folder under D:\Applications and that, during installation, Octopus Deploy should purge all the contents of the folder *before* starting the deploy.  That's pretty standard.  How do you confirm this is done correctly for a single project in Octopus Deploy?
 - Open the project (click Jump to project, enter name, Enter)
 - Click Process
 - Click the particular deploy service step
 - Click Configure Features and manually confirm Custom Installation Directory is checked, click Cancel to close Window
 - Manually review Custom Install Directory status text for the path and the text "directory will be purged before deployment"

Now imagine you need to confirm this setting for all 40 projects you have - that's a lot of clicking.  But **now** imagine you haven't checked it in a few weeks and you want to make sure no one has changed it for any preexisting projects **AND** it's been done correctly for all newly added projects... ugh!

If you had x-ray vision and could look directly inside the project configuration settings on the Octopus Deploy server itself, you'd see these (and more) in the project deploy process settings:
```JSON
"DeploymentProcess" {
  ...
  "Steps": [
    {
      ...
      "Actions": [
        {
          ...
          "Properties": {
            ...
            "Octopus.Action.Package.CustomInstallationDirectory": "D:\\Applications\\TestService",
            "Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment": "True"
          }
        }
      ]
    }
  ]
}
```

By exporting an Octopus Deploy configuration you get that x-ray vision!  What's more, you can easily search for these settings across **all** your projects and even write code that programmatically checks these settings for you!  No more manually checking!


## If Automation is the Future, Configuration Validation is Required

As we speed up the overall code/infrastructure deployment process - via automated builds & code testing, automated deployments, infrastructure as code, etc. - automating the configuration *and validation* of your deployment system becomes another critical task.  This is **especially** true considering most if not all of your configuration was probably entered by hand via the GUI.  Manually reviewing your whole configuration every now and then just isn't sufficient.  And you don't want to wait to discover a problem *after* a project has been deployed to production.


## Changes Over Time

What changes have been made to your Octopus Deploy setup over the past week?
* What projects has been added?
* What variables modified?
* Have any new deployment targets been added?
* **Has an account you don't recognize been recently added to the Administrators team?**  (That got your attention).

Wouldn't you like to be able to easily tell what's changed recently?  With Octopus Deploy's web interface, it's impossible to easily see these changes.  But if you can export the data, it's easy: just occasionally manually run an export (or schedule an export to run automatically) and then diff the two export folders with any diff tool.  Done!


## Use Your Imagination
With the data in easily usable JSON files, you can do anything:
* Search across all the projects using just a text editor like VS Code, Atom or Sublime.  Or write your own search tool.
* Compare similar projects to see where they are different.
* Get data/reporting on anything you can think of.  What's the average number of variables per project?  Sure, that's easy to find out.
* Programmatically compare two exports instead of manually comparing with a diff tool.

Still need more convincing?  See some detailed examples in [what can you do with exports](WhatCanYouDo.md).  And maybe review [best practices and testing rules](BestPracticesTestingRules.md) to get a feel for the benefits of automated testing.

If you are ready to start, check out [setup & usage](SetupUsage.md).
