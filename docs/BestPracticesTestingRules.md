
# Best practices / Suggested Rules

## NOT DONE!  COMING SOON!

asdf

Rough notes below - read at your own risk!

Use project-level variables for deploy process instead of hard-codes
PackageName
ServiceName
Displayname...

Use variables in deploy process settings / IIS
  As soon as you have more than a handle of services...
Don't hard code values in process steps
Don’t hard code name of Site or application name in IIS installation
SiteName project variable
Use in install #{SiteName} for both site name and app pool
Then can do rules:
Make sure project-level variables defined
Check for project-level variable SiteName (and value not empty)/default
Check process settings SiteName and AppPool both equal to “#{SiteName}”

Don't hide anything in process steps
  AppPool_AutoStart:              true
  AppPool_Enable32BitAppOnWin64:  true
  AppPool_ManagedRuntimeVersion:  v4.0
  AppPool_ManagedPipelineMode:    Integrated
  AppPool_IdentityType:           ApplicationPoolIdentity
  AppPool_LoadUserProfile:        false

Make info easier to see, allows easy clone from template...
Create Octo template project with all settings
  clone and then start filling in variables
  save time and ensure consistency



****Get implemented rules from old project - readme.txt



Passwords
  if name match *Password*, *Pwd* - make sure IsSensitive
  Conversely, maybe you ought to check that all your password variables have Pwd extension
  What about variables with no pwd and not secure? Perhaps rules based on length,


Global library variable sets:
  name space variables
  make sure variables defined at project level do NOT implement name space
  ConnectionStrings
    correct format

Environments/Deployment targets
Naming conventions for projects, variable names & values, package names, machines, environments, etc.
  Test-ValidMachineName

Services:
Name convention - company prefix for service name
Display name empty? Display name matches service name?  Does NOT match?

Teams:
Users should/should NOT be member of particular groups:
  make sure no one accidentally added to admin groups!

Misc:
Projects should use a particular lifecycle
Lifecycles have retention policies defined, set at particular value
Projects part of particular group (not default)



certain projects based on what project group they are in

