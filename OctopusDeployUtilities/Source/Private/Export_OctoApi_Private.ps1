
Set-StrictMode -Version Latest

#region Description of REST API call properties
<#
These names are not pretty but they have been named so as to (hopefully) be not confusing:
RestName                          name of REST API call (Accounts, Projects, etc.), used in display and
                                  type/property white/black lists
RestMethod                        relative api call to use (/api/accounts, /api/projects)
ApiFetchType                      type of fetch: Simple, MultiFetch or ItemIdOnly (described below)
FileNamePropertyName              when saving the item just fetched from server, this value is the name of
                                  a property on the item that will be unique and is best to use for the file name
                                     for Simple fetches, this will be 'NOT_USED" as the RestName is ultimately used
                                     for all others it will be either the item Id or Name property
IdToNamePropertyName              name of property on the item to use for Id -> name lookups; when you want
                                  to resolve "Projects-18" to it's proper name of "AuthorizationServer"
                                  this is the name of the property to use to provide the proper name
                                  most of the time this is the Name property but there are a few exceptions
ExternalIdToResolvePropertyName   for an item, these are the names of properties that reference an external item
                                  we will look up these id values and get the proper names for the items
ItemIdOnlyReferencePropertyName   for items fetched by ItemIdOnly, this is the name of the id property used by the other
                                  items to refer to this item
                                  for example, Variables is fetched by ItemIdOnly and other items refer to it by
                                  a local property (in those other items) named VariableSetId


# asdf describe: Simple MultiFetch ItemIdOnly

#>
#endregion



#region Function: New-ODUExportRestApiCall

<#
.SYNOPSIS
Creates single PSObject with Octopus Deploy REST API call information
.DESCRIPTION
Creates single PSObject with Octopus Deploy REST API call information
Helper function for Get-ODUStandardExportRestApiCallInfo
.PARAMETER RestName
Proper name of REST method
.PARAMETER RestMethod
REST API call
.PARAMETER ApiFetchType
Item fetch type
.PARAMETER FileNamePropertyName
Property name to use when saving file
.PARAMETER IdToNamePropertyName
Property name to use for Name value in Id -> Name lookup
.PARAMETER ExternalIdToResolvePropertyName
Property name containing external item references
.PARAMETER ItemIdOnlyReferencePropertyName
For items referenced/fetched by ItemIdOnly, the name of the property
.EXAMPLE
New-ODUExportRestApiCall 'Artifacts' '/api/artifacts' 'MultiFetch' 'Id'
<creates and returns PSObject with Artifacts info>
#>
function New-ODUExportRestApiCall {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RestName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RestMethod,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { $_ -in $ApiFetchTypeList})]
    [string]$ApiFetchType,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FileNamePropertyName,
    [string]$IdToNamePropertyName = 'Name',
    [string[]]$ExternalIdToResolvePropertyName,
    [string]$ItemIdOnlyReferencePropertyName
  )
  process {
    [PSCustomObject]@{
      RestName                        = $RestName
      RestMethod                      = $RestMethod
      ApiFetchType                    = $ApiFetchType
      FileNamePropertyName            = $FileNamePropertyName
      IdToNamePropertyName            = $IdToNamePropertyName
      ExternalIdToResolvePropertyName = $ExternalIdToResolvePropertyName
      ItemIdOnlyReferencePropertyName = $ItemIdOnlyReferencePropertyName
    }
  }
}
#endregion


#region Function: Get-ODUStandardExportRestApiCallInfo

<#
.SYNOPSIS
Returns PSObjects with Octopus Deploy API call details
.DESCRIPTION
Returns PSObjects with Octopus Deploy API call details
.EXAMPLE
Get-ODUStandardExportRestApiCallInfo
<returns info>
#>
function Get-ODUStandardExportRestApiCallInfo {
  [CmdletBinding()]
  param()
  process {
    # Simple REST API calls
    New-ODUExportRestApiCall 'Authentication' '/api/authentication' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'BuiltInRepository' '/api/repository/configuration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'Configuration' '/api/configuration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'ExternalSecurityGroups' '/api/externalsecuritygroupproviders' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'FeaturesConfiguration' '/api/featuresconfiguration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'LetsEncrypt' '/api/letsencryptconfiguration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'Licenses' '/api/licenses/licenses-current' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'MachineRoles' '/api/machineroles/all' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'MaintenanceConfiguration' '/api/maintenanceconfiguration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'Permissions' '/api/permissions/all' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'Reporting' '/api/reporting/deployments/xml' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'ServerConfiguration' '/api/serverconfiguration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'ServerStatus' '/api/serverstatus' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'SmtpConfiguration' '/api/smtpconfiguration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'ServerStatus-Nuget' '/api/serverstatus/nuget' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'ServerStatus-SystemInfo' '/api/serverstatus/system-info' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'ServerStatus-Timezones' '/api/serverstatus/timezones' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'UpgradeConfiguration' '/api/upgradeconfiguration' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'UserOnboarding' '/api/useronboarding' 'Simple' 'NOT_USED'


    # MultiFetch REST API calls
    New-ODUExportRestApiCall 'Accounts' '/api/accounts' 'MultiFetch' 'Name' -ExternalIdToResolvePropertyName @('EnvironmentIds', 'TenantIds')
    New-ODUExportRestApiCall 'ActionTemplates' '/api/actiontemplates' 'MultiFetch' 'Name' -ExternalIdToResolvePropertyName @('CommunityActionTemplateId')
    New-ODUExportRestApiCall 'Artifacts' '/api/artifacts' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'Channels' '/api/channels' 'MultiFetch' 'Id' -ExternalIdToResolvePropertyName @('LifecycleId', 'ProjectId')
    New-ODUExportRestApiCall 'CommunityActionTemplates' '/api/communityactiontemplates' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Deployments' '/api/deployments' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'Environments' '/api/environments' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Events' '/api/events' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'Feeds' '/api/feeds' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Interruptions' '/api/interruptions' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'LibraryVariableSets' '/api/libraryvariablesets' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'Lifecycles' '/api/lifecycles' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'MachinePolicies' '/api/machinepolicies' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Machines' '/api/machines' 'MultiFetch' 'Name' -ExternalIdToResolvePropertyName @('MachinePolicyId')
    New-ODUExportRestApiCall 'OctopusServerNodes' '/api/octopusservernodes' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Packages' '/api/packages' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'ProjectGroups' '/api/projectgroups' 'MultiFetch' 'Name' -ExternalIdToResolvePropertyName @('EnvironmentIds', 'RetentionPolicyId')
    New-ODUExportRestApiCall 'Projects' '/api/projects' 'MultiFetch' 'Name' -ExternalIdToResolvePropertyName @('ClonedFromProjectId', 'IncludedLibraryVariableSetIds', 'LifecycleId', 'ProjectGroupId')
    New-ODUExportRestApiCall 'ProjectTriggers' '/api/projecttriggers' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'Proxies' '/api/proxies' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Releases' '/api/releases' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'ServerStatus-Extensions' '/api/serverstatus/extensions' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Subscriptions' '/api/subscriptions' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'TagSets' '/api/tagsets' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Tasks' '/api/tasks' 'MultiFetch' 'Id'
    New-ODUExportRestApiCall 'Teams' '/api/teams' 'MultiFetch' 'Name' -ExternalIdToResolvePropertyName @('EnvironmentIds', 'MemberUserIds', 'ProjectGroupIds', 'ProjectIds', 'TenantIds', 'UserRoleIds')
    New-ODUExportRestApiCall 'Tenants' '/api/tenants' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'TenantVariables' '/api/tenantvariables/all' 'MultiFetch' 'TenantName'
    New-ODUExportRestApiCall 'UserRoles' '/api/userroles' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Users' '/api/users' 'MultiFetch' 'Username' -IdToNamePropertyName 'Username'

    # ItemIdOnly REST API calls
    New-ODUExportRestApiCall 'DeploymentProcesses' '/api/deploymentprocesses' 'ItemIdOnly' 'Id' -ExternalIdToResolvePropertyName @('LastSnapshotId', 'ProjectId') -ItemIdOnlyReferencePropertyName 'DeploymentProcessId'
    New-ODUExportRestApiCall 'Variables' '/api/variables' 'ItemIdOnly' 'Id' -ExternalIdToResolvePropertyName @('OwnerId') -ItemIdOnlyReferencePropertyName 'VariableSetId'
  }
}
#endregion