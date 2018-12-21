
# This script installs external run-time dependencies.

# Please note: build.ps1 also installs dependencies required by the build process but most end-users will not
# be performing builds.

'Configuration', 'PoshRSJob' | ForEach-Object {
  $ProgressPreference = 'SilentlyContinue'
  if ($null -eq (Get-Module -Name $_ -ListAvailable)) { Install-Module -Name $_ -Force -AllowClobber }
  # Configuration needs to be manually imported but
  # do NOT import module PoshRSJob; it will work fine without being imported but
  # more importantly, if you -Force import OctopusDeployUtilities module again (code change in dev),
  # tab autocompletion stops in the console.  go figure.
  if (($_ -ne 'PoshRSJob') -and ($null -eq (Get-Module -Name $_))) { Import-Module -Name $_ }
}
