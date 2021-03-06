
Set-StrictMode -Version Latest

# install any external dependencies required for run-time usage
. $PSScriptRoot\Install-ExternalRuntimeDependencies.ps1

$SourceRootPath = Join-Path -Path $PSScriptRoot -ChildPath 'Source'
# dot source all ps1 scripts under Source; note: no pester test files stored under Source
Get-ChildItem -Path $SourceRootPath -Filter *.ps1 -Recurse | ForEach-Object {
  . $_.FullName
}

# use Zachary Loeber AST method to get names of public functions instead of storing/assuming function per file
# https://www.the-little-things.net/blog/2015/10/03/powershell-thoughts-on-module-design/
$PublicSourceRootPath = Join-Path -Path $SourceRootPath -ChildPath 'Public'
[string[]]$PublicFunctionNames = $null
Get-ChildItem -Path $PublicSourceRootPath -Filter *.ps1 -Recurse | Where-Object { ($null -ne (Get-Content $_.FullName)) -and ((Get-Content $_.FullName).Trim() -ne '') } | ForEach-Object {
  ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object {
    $PublicFunctionNames += $_.Name
  }
}

# script-level variables
$ScriptLevelVariables = Join-Path -Path $PSScriptRoot -ChildPath 'Set-ScriptLevelVariables.ps1'
. $ScriptLevelVariables

# export public function names and aliases
# first create aliases
$OfficialAliasExports.Keys | ForEach-Object {
  Write-Verbose "$($MyInvocation.MyCommand) :: Creating alias: $_  ->  $($OfficialAliasExports.$_)"
  New-Alias -Name $_ -Value ($OfficialAliasExports.$_)
}

# export Public functions and aliases; need to cast as string array
Export-ModuleMember -Function $PublicFunctionNames -Alias (([string[]]$OfficialAliasExports.Keys))
