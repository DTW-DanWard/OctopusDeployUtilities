
Set-StrictMode -Version Latest

# make sure BuildHelpers is installed and loaded; it will be when this is called from
# standard build process but do it just in case manually testing a single file's tests individually
$ModuleName = 'BuildHelpers'
if ($null -eq (Get-Module -Name $ModuleName -ListAvailable)) { Install-Module -Name $ModuleName -Force }
# make sure BH variables loaded, need to specify default project folder one level up
if ($false -eq (Test-Path env:BHBranchName)) { Set-BuildEnvironment -Path ..}


#region Function: Get-SourceScriptFilePath

<#
.SYNOPSIS
For <source>.Tests.ps1 script gets full path to corresponding source file <source>.ps1
.DESCRIPTION
Get full path for a source file for a given .Tests.ps1 file.  Assumes:
 - Script in <source>.Tests.ps1 is directly calling this function.
 - This function located in file in root of Tests folder which is in project root.
 - Source code is found under Source folder which is located under <module name> folder
   and this <module name> folder contains the .psd1 file.
 - There is only 1 .psd1 file in the module.
 - There is only 1 source file matching the .Tests.ps1 name
#>
function Get-SourceScriptFilePath {
  # get current test script name (the script calling this function)
  $TestScriptName = Split-Path -Path $MyInvocation.PSCommandPath -Leaf
  # source script is test script name minus .Tests
  $SourceScriptName = $TestScriptName -replace '\.Tests', ''

  # Source folder is located under Module folder
  $SourceFolderPath = Join-Path -Path $env:BHModulePath -ChildPath 'Source'
  # confirm Source path is good
  if ($false -eq (Test-Path -Path $SourceFolderPath)) {
    throw "Source path not found: $SourceFolderPath"
  }

  # now find $SourceScriptName under Source; make sure exactly one found
  [object[]]$SourceFile = Get-ChildItem -Path $SourceFolderPath -Include $SourceScriptName -Recurse
  if ($null -eq $SourceFile -or $SourceFile.Count -eq 0) {
    throw "No corresponding source file $SourceScriptName found found for $TestScriptName"
  } elseif ($SourceFile.Count -gt 1) {
    throw -Message "Multiple source files named $SourceScriptName found found for $TestScriptName"
  }
  # return the full path
  $SourceFile[0].FullName
}
#endregion