
# Best practices / Suggested Unit Testing Rules

## Intro
I worked at a company managing the migration from an old, custom deploy system to Octopus Deploy.  With 180+ services and thousand *and thousands* of variables, you quickly pick up some best practices.

These worked for us but might not work for you.  Some might seem silly, some awesome.  Please contribute your own!

## 1. Don't Store Any Hard-coded Values in your Deploy Process Steps - Use Project-Level Variables
Octopus Deploy has a nice, clean interface.  The downside of this is you can spend **a lot** of time navigating admin screens to get to a particular setting just to review it to make sure it's correct.  Try this: count the number of clicks / amount of scrolling required to view an IIS project's condition bindings or a Windows Service's Display Name.  Now pretend you have to check 20 projects.  Or 120.

Setting up exports and unit testing can help with verification; here's another: in an Octopus Deploy project deploy process don't store any actual hard-coded values, use project-level variables.  What does this mean?
1. Create a project-level variable for anything that needs to set in the deploy process.
2. Reference that variable in the deploy steps using the standard #{VariableName} notation.

Examples?
* Got a project that deploys a package?  Create a project-level variable called PackageId and reference #{PackageId}.
* Windows Service?  You need project-level variables ServiceName, DisplayName, maybe Description, also ExecutablePath, ServiceAccount, StartMode (if you aren't doing Automatic).
* IIS Site?  You'll need variables HostName, AppPoolName and a bunch more.
* Does the project install to a custom folder?  Create project variable InstallFolder and use just #{InstallFolder} in the settings.
  * The ultimate destination for a project's install folder will probably be under a root folder, i.e. MyWebProject is installed to `D:\Applications\MyWebProject`.  In that likely case, the project-level variable InstallFolder will have a *value* of something like `#{RootInstallFolder}\MyWebProject` where `#{RootInstallFolder}` comes from a included library variable set.

Instead of having to navigate a bunch of screens you can pretty much review just the project-level variables and see everything to need.  It'll make your unit testing rules for deploy steps much easier.

This might seem like a lot of work but it's not if you also do recommendation #2 below.  If you do #2 you'll **also** benefit from MUCH faster and consistent project setup.


### Suggested Rules
If you set up your projects this way, here are some *minimum* recommended unit-testing rules.
* Confirm project deploy step individual value is a variable.  For example for a Windows Service project display name step has a value of #{DisplayName}.
* Confirm project variable exists at project-level.  For example for a Windows Service make sure variable DisplayName exists
* Confirm project variable at project-level has a value that *isn't* `UNDEFINED`.  (more below)


## 2. Create Template Projects with Default Variable Deploy Settings and Clone Projects Instead of Creating from Scratch

That long title pretty much describes it - create one or more base 'template' projects that implement all your default / best practice steps and create new projects by cloning these projects.  You would need one for each type of project you deploy (IIS, Windows Service, etc.).

For example, to set up a project template:
* Create a base template project named Template-WinService.
* Create project-level variables for all the deploy step settings that you change (ServiceName, DisplayName, ExecutablePath, etc.).
  * For a value of these new variables, set to `UNDEFINED`.
* In deploy settings enable whatever standard features you use.
* Use those project-level variables in the deploy settings.
* In standard project settings, or any place else, set your standard values (a particular included library set? a particular project group? release versioning? etc.).

Now to set up, the process is fast:
* Clone Template-WinService and give new name
* Fill in values in project-level variables.  You know you're done when all the `UNDEFINED` values are gone.
* Go back and change any other settings - if necessary.  Maybe you are already done!

If you have resources who are new to Octopus or who just don't work often with it, they might miss some important settings when setting up.  Or they might miss standards that they don't know about.  Cloning a project for them to edit will save everyone a lot of time.

Also, if someone misses replacing an `UNDEFINED` value, it will be very visible after deployment in the process list, the IIS site names listing, etc.

### Suggested Rules
If you set up template projects, you could use these rules:
* Check all variables in your normal (implemented, non-template) projects making sure *none* of them has a value `UNDEFINED`.  Of course you'll need to exclude checking variables in your actual Template-* projects.
* Perhaps all template projects should be in their own project group Templates; confirm that with a rule.  Having them in their own group will make excluding them from the rule above - and other rules like it - easier.


## 3. Prefix your Library Variable Set Variables
Once you have a lot of variables and included library variable sets, it can be hard to know where an item is defined and used.  (Unless you use the [ODU variable search utility oduvar](SearchingVariables.md).  One easy thing you can do to help is add a prefix to your library variable set names.

For example, assume you have a library variable set for connection strings.  This library variable set could be named `ConnStr` and every variable in the set could have `ConnStr.` as a prefix.  A sales database connection string might be named `ConnStr.Sales`.

### Suggested Rules
* Make sure every variable in each library variable set has a prefix that matches the library variable set name.
* Make sure no other variables (project level or other library variable set) use this prefix in a name!  (Using in a value is OK!)


## 4. Validate Naming Conventions
When you are managing multiple environments with hundreds or thousands of servers, naming conventions for those servers are important!  But naming conventions for other types of names are important, too.  Here are some data types for which you might want to implement rules to help maintain your naming conventions:
* Environments and deployment targets.
* Project names - prefix for grouping?
* Package names

Depending on your organization/requirements, there could be a lot of naming standard rules to implement.



asdf - continue here


IIS projects
Check process settings SiteName and AppPool both equal to #{SiteName}



Passwords
  if name match *Password*, *Pwd* - make sure IsSensitive
  Conversely, maybe you ought to check that all your password variables have Pwd extension
  What about variables with no pwd and not secure? Perhaps rules based on length,


Services:
Name convention - company prefix for service name
Display name empty? Display name matches service name?  Does NOT match?

Teams:
Users should/should NOT be member of particular groups:
  make sure no one accidentally added to admin groups!
certain permissions?

Misc:
Projects should use a particular lifecycle
Lifecycles have retention policies defined, set at particular value
Projects part of particular group (not default)
certain projects based on what project group they are in


***Get implemented rules from old project - readme.txt

***Search examples from readme, reporting, unit testing pages


