@{ ModuleVersion    = '0.0.1'

  # Script module or binary module file associated with this manifest.
  RootModule        = 'OctopusDeployUtilities.psm1'

  # Supported PSEditions
  # CompatiblePSEditions = @()

  # ID used to uniquely identify this module
  GUID              = '9a5b87bd-b196-48bd-8e9d-a451d6b4a06a'

  # Author of this module
  Author            = 'Dan Ward'

  # Company or vendor of this module
  CompanyName       = 'DTWConsulting.com'

  # Copyright statement for this module
  Copyright         = '(c) Dan Ward. All rights reserved.'

  # Description of the functionality provided by this module
  Description       = 'Octopus Deploy Utilities: export, search, compare and unit test your setup'

  # Minimum version of the PowerShell engine required by this module
  PowerShellVersion = '3.0'

  # Name of the PowerShell host required by this module
  # PowerShellHostName = ''

  # Minimum version of the PowerShell host required by this module
  # PowerShellHostVersion = ''

  # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # DotNetFrameworkVersion = ''

  # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # CLRVersion = ''

  # Processor architecture (None, X86, Amd64) required by this module
  # ProcessorArchitecture = ''

  # Modules that must be imported into the global environment prior to importing this module
  RequiredModules = @('Configuration')

  # Assemblies that must be loaded prior to importing this module
  # RequiredAssemblies = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module.
  # ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  # TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  # NestedModules = @()

  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  # Note: if you want to dynamically export functions stored in files using Export-ModuleMember, you can't define FunctionsToExport here
  # or this will override your Export-ModuleMember calls
  FunctionsToExport = '*'

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport   = @()

  # Variables to export from this module
  VariablesToExport = '*'

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport   = '*'

  # DSC resources to export from this module
  # DscResourcesToExport = @()

  # List of all modules packaged with this module
  # ModuleList = @()

  # List of all files packaged with this module
  # FileList = @()

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData       = @{

    PSData = @{

      # Tags applied to this module. These help with module discovery in online galleries.
      Tags       = @('Octopus', 'Deploy', 'configuration', 'export', 'search', 'compare', 'unit', 'test', 'json')

      # A URL to the license for this module.
      LicenseUri = 'https://github.com/DTW-DanWard/OctopusDeployUtilities/blob/master/LICENSE'

      # A URL to the main website for this project.
      ProjectUri = 'https://github.com/DTW-DanWard/OctopusDeployUtilities'

      # A URL to an icon representing this module.
      # IconUri = ''

      # ReleaseNotes of this module
      # ReleaseNotes = ''

    } # End of PSData hashtable

  } # End of PrivateData hashtable

  # HelpInfo URI of this module
  # HelpInfoURI = ''

  # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
  # DefaultCommandPrefix = ''
}


