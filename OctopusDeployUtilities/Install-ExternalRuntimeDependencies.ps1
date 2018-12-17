
# This script installs external run-time dependencies, namely the Configuration module which is used in standard usage.

# Please note: build.ps1 also installs Configuration and a number of other dependencies required by the build process
# but most end-users will not be performing builds.

'Configuration' | ForEach-Object {
  $ProgressPreference = 'SilentlyContinue'
  if ($null -eq (Get-Module -Name $_ -ListAvailable)) { Install-Module -Name $_ -Force -AllowClobber }
  Import-Module -Name $_
}
