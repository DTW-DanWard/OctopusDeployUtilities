
# Unit Testing Your Octopus Deploy Configuration

## Intro
I worked at a company managing the migration from an old, custom deploy system to Octopus Deploy.  There were 180+ services and thousand *and thousands* of variables.  Believe me when I tell you that organization and standards are critically important when setting up and maintaining your deployment system.  If you only have 3 projects with a handful of variables that never get edited then this might not seem important to you.  But as you grow it becomes *very* important; manually reviewing all your settings constantly for unexpected changes is just not an option.

My advice is to create [good solid standards and best practices](BestPracticesTestingRules.md) for your settings, document and share those standards *and* make sure they are maintained with [reporting](DetailsAndReporting.md) or unit testing.

And just what is unit testing with regard to Octopus Deploy configuration?  It's a way of writing reporting that alerts you if a setting is incorrect.  Let's walk through an example.

### Learn Pester
If you are looking for a resource to learn Pester I highly recommend [The Pester Book](https://leanpub.com/pesterbook).  For testing your Octopus Deploy data you will learn most of what you need in the first 22 pages.


## Example: Custom Installation Folder
Let's say you have a standard that when all of your applications are deployed they get installed to a server in a custom folder.  Maybe you have some monitoring software that keeps an eye on that folder, maybe you have some special file system permissions... It doesn't matter the reason why but it's important that it be always be set.  You could check your projects and confirm they are correct but it's a pain if you have a lot projects and it's a *waste of time* if you need to check every week because new projects have been added and older projects have been modified.

So you look at the contents of one of your exports in a text editor and you learn that under deploy steps there's a set of properties and one of these is **Octopus.Action.Package.CustomInstallationDirectory**.  If you enable a custom installation directory for a project in Octopus this property gets added with a value of the custom installation directory path.  You *could* use a text editor like VS Code to search across all the projects to try to find this setting but that's not really much better than checking the Octopus web interface directly.

So you write a quick report with ODU to retrieve it.  We use the function `Select-ODUProjectDeployActionProperty` and pass it a project and a deploy setting property name; if the property is set it returns the value, if it doesn't it returns `$null`.  We are interested in the $null ones.

```PowerShell
C:\> # get an object that has all the data from the latest export
C:\> $Export = oduobject
C:\>
C:\> # loop through projects and return the projects with NO custom install folder (i.e. it returns $null)
C:\> $Export.Projects | Where { $null -eq (Select-ODUProjectDeployActionProperty $_ 'Octopus.Action.Package.CustomInstallationDirectory') }
C:\>
C:\> # this might return project without that setting - if there are any - but the key thing to note
C:\> # is it returns the ENTIRE project object when really all you care about is the name
C:\> # so let's just get the name
C:\> $Export.Projects | Where { $null -eq (Select-ODUProjectDeployActionProperty $_ 'Octopus.Action.Package.CustomInstallationDirectory') } | Select Name
```

That last line is a simple report or query: tell me the names of the projects that don't have custom installation folder set.

If you were to write a unit test for this, basically you are writing that same query but telling the unit test that there *shouldn't* be any results.  If there are, it's an error!  Here's an excerpt of a unit test file:

```PowerShell
# make sure there aren't any projects without custom installation folder set
It 'Confirm no projects missing: CustomInstallationDirectory' { $Export.Projects | Where { $null -eq (Select-ODUProjectDeployActionProperty $_ 'Octopus.Action.Package.CustomInstallationDirectory') } | Select Name } | Should BeNullOrEmpty }
```
If an project exists without the setting its name will get piped into `Should BeNullOrEmpty` that that will throw an error saying something like "was expecting null but got `MyNewProject` instead.  That error message - with just the project name - is nice, short and specific.  That should be a goal for your tests *and* error messages; readability really helps maintainability.


## Example: Custom Installation Folder - Revisited

A golden rule regarding unit tests: you get out of them what you put into them.  This most likely means a lot of work up front and ongoing maintenance as you encounter new issues - and come up with standards and rules to prevent these issues from re-occurring.

That first rule we implemented for custom installation folder was nice but it's *just the start*.  Here are some additional rules that might come to mind after you create the first rule:
* Is there a particular root folder that you are installing all of your applications under?  I.E. do they all go in a sub-folder under, say, D:\Applications?
* What is the name of the sub-folder being installed to (D:\Applications\AppFolder)?
* Should that AppFolder name always have a special prefix?  Have or avoid certain characters?
* Maybe that AppFolder name should always match the Octopus Project name for consistency?
* Wait, maybe other values in the project settings should also just match the project name for consistency...?  IIS site/app pool name?  Windows Service Display Name?

And that's how it gets started.  The more you realize how consistent or inconsistent your configuration is, the more you realize you can write rules to find the exceptions so you can fix them.  Validating your entire configuration becomes a question of running a fresh export and then running your unit tests.  And, of course, you can automate both those steps, saving you a lot of time and giving you (some?) peace of mind.


### We Broke Prod

In spite of all your rules stuff will still sneak through the cracks.  Here's an actual example from my experience of when an application deployed to prod and broke stuff.  (OK, it was just *one* server and that server was out of the load balancer pool... but still it was no fun.)
* Developers added new Octopus Deploy project-level variable, scoped only to dev environments.  That project variable matched to a new configuration setting in the application's config file.
* The default value in the app config file worked on dev machines and on staging but, turns out, not on production.
* Developers did not notify DevOps (me!) of the new variable and I missed it.  That project had over 100 Octopus Deploy project variables plus a huge included library variable set.  Needle in the haystack... and I'm human, I screwed up.
* Project is deployed to staging, variable replacement doesn't occur BUT default value in file happens to work fine so QA passes it.
* Project is deployed to production and KA-BOOM!  (OK, less dramatic than that).

Doh!  However, using exports the problem was really easily to find: the last time this project was deployed to production it worked fine so I diff'd an export from that time frame to the latest export.  The new project variable - with its *dev-environment-only* scope - stood out like a sore thumb.  We quickly added the staging and production-scoped values to that project in Octopus Deploy, updated the release and redeployed.  All done!

From that particular experience we got 2 takeaways:
* Always double check the project-level variables for dev-scoped-only variables before deployments.  (Easy to do with the diffs, easier with some PowerShell).
* Create a unit test rule that does this for you automatically and then never worry.


## Pester Unit Test Skeleton

The exact rules you implement are going to be specific to your organization.  I've put some thoughts in the [standards and best practices](BestPracticesTestingRules.md) doc - and please feel free to contribute your own!  But ultimately your Pester file is going to look fairly different from everyone elses.

Here's a short excerpt to get you thinking about how you might structure your tests:

```PowerShell

$Export = oduobject

Describe "Octopus Deploy export configuration tests" {

  Context Machines {
    # HERE: Machines-specific rules - naming conventions for machines? etc.
  }

  Context Teams {
    # HERE: Teams-specific rules - who is an admin? etc.
  }

  Context Projects {

    BeforeAll {
      # get latest project data
      $Projects_All = $Export.Projects
    }

    # HERE: all rules to run on all projects, no matter what type, using source $Projects_All


    Context Projects.WindowsService {
      BeforeAll {
        # get projects for Windows Services
        $Projects_WindowsService = $Projects_All | Where-Object { $true -eq (Test-ODUProjectDeployWindowsService -Project $_)}
      }

      # HERE: rules for Windows Service projects using source $Projects_WindowsService
    }


    Context Projects.IIS {
      BeforeAll {
        # get projects for Windows Services
        $Projects_IIS = $Projects_All | Where-Object { $true -eq (Test-ODUProjectDeployIISSite -Project $_)}
      }

      # HERE: rules for IIS projects using source $Projects_IIS
    }


    # at this point it's up to you

    # maybe you have specific rules for certain projects based on what project group they are in?
    Context Projects.GroupFinance {
      BeforeAll {
        # get Finance projects
        $Projects_GroupFinance = $Projects_All | Where-Object { $_.ProjectGroupName -eq 'Finance'}
      }

      # HERE: rules for finance projects using source $Projects_GroupFinance
    }


    # What about tests based on a projects LifeCycle?  That's LifecycleName
    # maybe every project at your organization uses a custom LifeCycle and so nothing should be set
    # to 'Default Lifecycle'

    # at this point you get the idea...
  }
}
```
