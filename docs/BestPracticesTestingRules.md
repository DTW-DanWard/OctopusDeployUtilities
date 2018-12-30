
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

**This might seem like a lot of work but** it's not if you also do recommendation #2 below.  If you do #2 you'll **also** benefit from MUCH faster and consistent project setup.


### Suggested Rules
If you set up your projects this way, here are some *minimum* recommended unit-testing rules.
* Confirm project deploy step individual value is a variable.  For example for a Windows Service project display name step has a value of #{DisplayName}.
* Confirm project variable exists at project-level.  For example for a Windows Service make sure variable DisplayName exists
* Confirm project variable at project-level has a value that *isn't* `UNDEFINED`.  (more below in next best practice)


## 2. Create Template Projects with Default Variable Deploy Settings and Best Practice Settings and Clone Projects Instead of Creating from Scratch

That long title pretty much describes it - create one or more base 'template' projects that implement all your default / best practice steps and create new projects by cloning these projects.  You would need one for each type of project you deploy (IIS, Windows Service, etc.).

For example, to set up a project template for deploying Windows Services:
* Create a base template project named Template-WinService.
* Create project-level variables for all the deploy step settings that you change (ServiceName, DisplayName, ExecutablePath, etc.).
  * For a value of these new variables, set to `UNDEFINED`.
* In deploy settings enable whatever standard features you use.
* Use those project-level variables in the deploy settings.
* In standard project settings, or any place else, set your standard values (a particular included library set? a particular project group? release versioning? etc.).

To set up a new project for a Windows Service, the process is fast:
* Clone Template-WinService and give new name
* Fill in values in project-level variables.  You know you're done when all the `UNDEFINED` values are gone.
* Go back and change any other settings - if necessary.  Maybe you are already done!

If you have resources who are new to Octopus Deploy or who just don't work often with it, they might miss some important settings when setting up.  Or they might miss standards that they don't know about.  Cloning a project for them to edit will save everyone a lot of time.

Also, if someone misses replacing an `UNDEFINED` value, it will be very visible after deployment in the process list, the IIS site names listing, etc.

### Suggested Rules
If you set up template projects, you could use these rules:
* Check all variables in your normal (implemented, non-template) projects making sure *none* of them has a value `UNDEFINED`.  Of course you'll need to exclude checking variables in your actual Template-* projects.
* Perhaps all template projects should be in their own project group Templates; confirm that with a rule.  Having them in their own group will make excluding them from the rule above - and other rules like it - easier.


## 3. Use the Same Name / Identifier **EVERYWHERE**

This seems so obvious and yet I've seen a number of organizations that just don't do this!  For every application, come up with a specific name that does *not* include spaces or any special characters that might break the name anywhere (underscores and periods are probably safe).  And then use this name **exactly as-is** everywhere to identify this application!  Where?  Some examples:
* The repository name.
* The solution and project file names.
* The project name in the build system.
* The package name.
* The project name in the deploy system.
* Custom install folder name.
* Logging: log folder name and log file prefix or as the identifier in a logging system.
* IIS project: the site name and app pool name.
* Windows Service: executable name, service name and display name.
* Application name passed in SQL connection strings.

I'm sure there's a lot more locations missing here.

**If you are currently *manually* managing applications and/or infrastructure but you want to start *programmatically* managing these, having a single, consistent identifier is absolutely critical!**  You do not want to have to waste your time creating and populating some type of naming lookup system so you can map a single application across various systems with all the exceptions because people were too lazy to consistently name the application.  "The repo name is this, in the build system it's name is that, in deploy it's a little different, but it's *installed* with *this* name, on those IIS servers the site name is this but on *these* IIS servers it's this, and the app pools sometimes are this but...."  (That was my last job; I can't even.).

With regards to Octopus Deploy: every project could have a project-level variable `ApplicationName` and this one variable could be reused everywhere possible in your deploy settings: package id name, install folder name - all the places listed above.  The value for the `ApplicationName` variable could be the hard-coded text that you want to use.  However, if you want to get clever, you *could* have the value of `ApplicationName` be `#{Octopus.Project.Name}` - that's a built-in variable that returns the Octopus Deploy project name, which ensures that the Octopus Deploy project name itself *has* to be exact correct value it is supposed to be.  (If not, certain things like package id will definitely fail).

Additionally, it can be helpful to have a short prefix on all your application names (and package ids, and display names, etc.).  Perhaps that prefix identifies your organization, maybe it's application subset type (and you only have a few different types), etc.  Having a consistent prefix can be really handy for identifying your applications amongst others running on that server: all sites/services are automatically sorted/displayed together, querying is easy: `Get-Service MyCo.*`


### Suggested Rules
* Check each project has a project-level variable ApplicationName.
* Check the ApplicationName value is either `#{Octopus.Project.Name}` or some text that matches your naming conventions (see next best practice).
* Check all deploy settings (package id, install folder name, service display name, etc.) and other locations to make sure #{ApplicationName} is the value.


## 4. Validate Naming Conventions
When you are managing multiple environments with hundreds or thousands of servers, naming conventions for those servers are important!  But naming conventions for other types of names are important, too.  Here are some data types for which you might want to implement rules to help maintain your naming conventions:
* Project variable ApplicationName (especially if used across multiple settings).
* Environments and deployment targets.
* Project names - prefix for grouping?
* Package names
* Connection strings: particular naming convention or prefix (especially if using included library variable set).
* Passwords: all have particular prefix or suffix like Password or Pwd?  Example: SalesDbAcctPwd

Depending on your organization/requirements, there could be *a lot* of naming standard rules to implement.


## 5. Prefix your Library Variable Set Variables
Once you have a lot of variables and included library variable sets, it can be hard to know where an item is defined and used.  (Unless you use the [ODU variable search utility oduvar](SearchingVariables.md).  One easy thing you can do to help is add a prefix to your library variable set names.

For example, assume you have a library variable set for all of your connection strings.  This library variable set could be named `ConnStr` and every variable in the set could have `ConnStr.` as a prefix.  A sales database connection string might be named `ConnStr.Sales`.

### Suggested Rules
* Make sure every variable in each library variable set has a prefix that matches the library variable set name.
* Make sure no other variables (project level or other library variable set) use this prefix in a name!  (Using in a value is OK!)


## 6. Password-Related Rules
As mentioned above, having a naming convention for your password variable names can be really helpful: like maybe a suffix of `Password` or `Pwd`.

### Suggested Rules
* All variables that match *Password or *Pwd are encrypted (IsSensitive = true).
* All variables that are encrypted have the password suffix (find new password entries that don't match the standard).

But what about variables that were created that store a password that *isn't* encrypted and the variable name *doesn't* have the password suffix - how do you find those?  Those can be harder to find, but it's not impossible.  Depending on the algorithm/settings you use for generating passwords, you might be able to create a rule that looks for variable whose contents match a certain pattern and that have a specific length.


## 7. Other Random Rules
A bunch of random thoughts/rules for your consideration:

* Teams: make sure only known users are in certain admin groups.
* Connection strings: ensure you are using the same connection string pattern consistently with all the correct elements present.  This can also help lead to smaller, easer to read values:
  * Short version: `server=#{Database.Server};database=SalesDb;uid=#{Database.User};pwd=#{Database.Password};app=#{ApplicationName}`
  * Instead of: `Data Source=#{Database.Server};Initial Catalog=SalesDb;User Id=#{Database.User};Password=#{Database.Password};Application Name=#{ApplicationName}`
* Included library variables sets: make sure all projects included any **required** library variable sets.
* Other settings: ensure correct custom project life cycle, confirm correct custom life cycle retention policies, etc.
* Project variables: make sure every project implements any custom variables you have that should be found in every project (`IsProductionReady`, etc.).
* Project group: make sure every project is in a specific group and not general catch-all group.
* Deploy settings name consistency: as mentioned earlier, try to use a single value everywhere (project-level variable ApplicationName).  Use it for IIS site names, application pool names, etc.

Obviously you will have a lot of rules that are specific to your organization and how you use Octopus Deploy.  But again - if you have any general rules, ideas, etc. please contribute!
