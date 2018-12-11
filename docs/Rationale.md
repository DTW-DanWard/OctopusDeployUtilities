
# Why Export Your Octopus Deploy Configuration Data?

## Introduction - and an Example

Octopus Deploy is a great product; there's a reason it is popular.  The interfaces are clean and straightforward, making initial project entry relatively easy.  But the downside of those clean interfaces is that it can make finding and reviewing settings - especially across multiple projects at the same time - a bit of a pain.  I worked at a company managing an Octopus Deploy instance with 180 projects and *many* thousands of variables; you could spend all day clicking to review settings across projects.

For example, let's say you like to install your Windows Service projects to a specific custom installation folder under D:\Applications and that, during installation, Octopus Deploy should purge all the contents of the folder *before* starting the deploy.  That's pretty standard.  How do you confirm this is done correctly for a single project in Octopus Deploy?
 - Open the project (click Jump to project, enter name, Enter)
 - Click Process
 - Click the particular deploy service step
 - Click Configure Features and manually confirm Custom Installation Directory is checked, click Cancel to close Window
 - Manually review Custom Install Directory status text for the path and the text "directory will be purged before deployment"

Now imagine you need to confirm this setting for all 40 projects you have - that's a lot of clicking.  But **now** imagine you haven't checked it in a few weeks and you want to make sure no one has changed it for a preexisting project **AND** it's been done correctly for all newly added projects... ugh!

If you had x-ray vision and could look directly inside the project configuration settings on the server, you'd see these (and more) in the deploy process settings:
```JSON
  "Properties": {
    "Octopus.Action.Package.CustomInstallationDirectory": "D:\\Applications\\TestService",
    "Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment": "True"
  }
```

## Automation is the Future

By exporting an Octopus Deploy configuration you get that x-ray vision!  What's more, you can easily search for these settings across **all** your projects and even write code that programmatically checks these settings for you!  No more manually checking!

As we speed up the overall code/infrastructure deployment process - via automated builds, code testing, deployments, infrastructure as code, etc. - automating the configuration and validation of your deployment system becomes another critical task.  This is **especially** true considering most if not all of your configuration was probably entered by hand via the GUI.  Manually reviewing your whole configuration every now and then just isn't sufficient.


## Changes over Time

What changes have been made to your Octopus Deploy setup over the past week?  What projects has been added - what variables modified?  Any new deployment targets?  Has someone you don't know been accidentally added to the Administrators Team? (I bet that last one got your attention).


asdf continue here



-------------

 but it has a one limitation: it hides your configuration behind many screens.  This makes it time-consuming to search your configuration, review it for quality and consistency... and this manual work does not scale if you have many projects.  How many clicks are required to check your IIS conditional bindings in one project?  What if you have 20 projects and you want to make sure they are all configured the same?  What if you have 80 projects and you want to make sure all your project-level password variables are stored encrypted (Sensitive)?  Have fun clicking the next hour... but shouldn't you double-check the settings *again* next week?

Fortunately Octopus Deploy provides a great REST API that can be used for exporting your configuration data.  And once you can export the data, you can do all sorts of awesome stuff:
* *Easily* see all changes to the entire system over time.
* *Easily* search across your entire configuration.
* *Easily* get details on anything you can think of: How many projects do you have?  Which ones are Windows Services? How many variables do you have; how many are encrypted?  Which projects are using a particular Library Variable Set?
* **Implement standards/best practices in your Octopus Deploy setup and then automatically confirm these standards by unit testing your configuration export.**  You will save countless hours and ensure quality by automating it.
* **Compare releases** (coming soon - on road map).
