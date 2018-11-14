# Generic module deployment.

# ASSUMPTIONS:

# folder structure of:
# - RepoFolder
#   - This PSDeploy file
#   - ModuleName
#     - ModuleName.psd1

# Nuget key in $ENV:NugetApiKey

# Set-BuildEnvironment from BuildHelpers module has populated ENV:BHProjectName

# only run on build server on branch master; don't run if !deploy in commit message
if ($env:BHBuildSystem -ne 'Unknown' -and $env:BHBranchName -eq 'master' -and $env:BHCommitMessage -match '!deploy') {
  Deploy Module {
    By PSGalleryModule {
      FromSource $ENV:BHProjectName
      To PSGallery
      WithOptions @{
        ApiKey = $ENV:NugetApiKey
      }
    }
  }
}
