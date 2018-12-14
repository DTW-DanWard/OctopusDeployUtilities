
Set-StrictMode -Version Latest

#region Function: Find-ODUInvalidRestApiTypeName

<#
.SYNOPSIS
For list of Type names, throws error if finds invalid entry, else does nothing
.DESCRIPTION
For list of Type names, throws error if finds invalid entry, else does nothing
.PARAMETER TypeName
Type name to validate
.EXAMPLE
Find-ODUInvalidRestApiTypeName Projects
<does nothing>
Find-ODUInvalidRestApiTypeName Projects, Variables
<does nothing>
Find-ODUInvalidRestApiTypeName Projects, Variables, blahblahblah
<throws error 'blahblahblah' not valid>
#>
function Find-ODUInvalidRestApiTypeName {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$TypeName
  )
  process {
    $ValidTypeNames = Get-ODURestApiTypeNames
    $TypeName | ForEach-Object {
      if ($_ -notin $ValidTypeNames) {
        throw "Not a valid REST API Type name: $_"
      }
    }
  }
}
#endregion


#region Function: Get-ODURestApiTypeNames

<#
.SYNOPSIS
Returns list of Type names used with Octopus Deploy REST API
.DESCRIPTION
Returns list of Type names used with Octopus Deploy REST API
These are the available Type names that can be used with Type and Property
blacklist and whitelist
.EXAMPLE
Get-ODURestApiTypeNames
Authentication
BuiltInRepository
ExternalSecurityGroups
FeaturesConfiguration
...
#>
function Get-ODURestApiTypeNames {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  process {
    (Get-ODUStandardExportRestApiCalls).RestName | Sort-Object
  }
}
#endregion


#region Function: Get-ODUStandardExportRestApiCalls

<#
.SYNOPSIS
Returns PSObjects with Octopus Deploy API call details
.DESCRIPTION
Returns PSObjects with Octopus Deploy API call details
.EXAMPLE
Get-ODUStandardExportRestApiCalls
<returns info>
#>
function Get-ODUStandardExportRestApiCalls {
  [CmdletBinding()]
  param()
  process {
    # Simple REST API calls
    New-ODUExportRestApiCall 'Authentication' '/api/authentication' 'Simple' 'NOT_USED'
    New-ODUExportRestApiCall 'BuiltInRepository' '/api/repository/configuration' 'Simple' 'NOT_USED'
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
    New-ODUExportRestApiCall 'Configuration' '/api/configuration' 'MultiFetch' 'Id'
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
    New-ODUExportRestApiCall 'TenantVariables' '/api/tenantvariables/all' 'MultiFetch' 'TenantId'
    New-ODUExportRestApiCall 'UserRoles' '/api/userroles' 'MultiFetch' 'Name'
    New-ODUExportRestApiCall 'Users' '/api/users' 'MultiFetch' 'Username' -IdToNamePropertyName 'Username'

    # ItemIdOnly REST API calls
    New-ODUExportRestApiCall 'DeploymentProcesses' '/api/deploymentprocesses' 'ItemIdOnly' 'Id' -ExternalIdToResolvePropertyName @('LastSnapshotId', 'ProjectId') -ItemIdOnlyReferencePropertyName 'DeploymentProcessId'
    New-ODUExportRestApiCall 'Variables' '/api/variables' 'ItemIdOnly' 'Id' -ExternalIdToResolvePropertyName @('OwnerId') -ItemIdOnlyReferencePropertyName 'VariableSetId'
  }
}
#endregion


#region Function: Test-ODUValidateRestApiTypeName

<#
.SYNOPSIS
Validates list of values against Type names used with Octopus Deploy REST API
.DESCRIPTION
Validates list of values against Type names used with Octopus Deploy REST API
If all passed values are valid, returns $true, if any one is invalid, returns $false
.PARAMETER TypeName
Type name to validate
.EXAMPLE
Test-ODUValidateRestApiTypeName Projects
$true
Test-ODUValidateRestApiTypeName Projects, Variables
$true
Test-ODUValidateRestApiTypeName Projects, Variables, blahblahblah
$false
#>
function Test-ODUValidateRestApiTypeName {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$TypeName
  )
  process {
    $ValidTypeNames = Get-ODURestApiTypeNames
    $null -eq ($TypeName | Where-Object { $_ -notin $ValidTypeNames })
  }
}
#endregion
