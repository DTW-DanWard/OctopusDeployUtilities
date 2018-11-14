param(
  [string]$Task = 'Default'
)

# adapted from Warren F's (ramblingcookiemonster) excellent PowerShell build/deploy utilties

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

'Configuration', 'InvokeBuild', 'BuildHelpers', 'Pester', 'PSScriptAnalyzer', 'PSDeploy' | ForEach-Object {
  $ProgressPreference = 'SilentlyContinue'
  if ($null -eq (Get-Module -Name $_ -ListAvailable)) { Install-Module -Name $_ -Force -AllowClobber }
  Import-Module -Name $_
}

# delete build help environment variables if they already exist
Get-Item env:BH* | Remove-Item
# now re/set build environment variables
Set-BuildEnvironment

Invoke-Build -File .\InvokeBuild.ps1 -Task $Task -Result Result
if ($Result.Error) {
  exit 1
} else {
  exit 0
}
