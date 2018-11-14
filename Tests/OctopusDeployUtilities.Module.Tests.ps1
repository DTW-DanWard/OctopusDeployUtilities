

# This file does not have tests for any specific file:
#  - it has tests across all Source files in the module;
#  - it has tests for the module itself (functions/aliases exported, etc.)


$SourceRootPath = Join-Path -Path $env:BHModulePath -ChildPath 'Source'

# get all source file paths
[string[]]$SourceScripts = $null
Get-ChildItem -Path $SourceRootPath -Filter *.ps1 -Recurse | ForEach-Object {
  $SourceScripts += $_.FullName
}


#region Confirming all Source functions in the module have help defined
$SourceScripts | ForEach-Object {
  $SourceScript = $_
  Describe "Source script: $SourceScript" { }
  $Functions = ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $SourceScript -Raw), [ref]$null, [ref]$null)).FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
  Describe 'Confirm all functions have help defined: Synopsis, Description, Parameters & Example' {

    It 'confirms help section exists for each function' {
      $Functions | Where-Object { $null -eq $_.GetHelpContent() } | Select-Object Name | Should BeNullOrEmpty
    }

    It 'confirms Synopsis field has content for each function' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and (($null -eq $_.GetHelpContent().Synopsis) -or ($_.GetHelpContent().Synopsis -eq '')) } | Select-Object Name | Should BeNullOrEmpty
    }

    It 'confirms Description field has content for each function' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and (($null -eq $_.GetHelpContent().Description) -or ($_.GetHelpContent().Description -eq '')) } | Select-Object Name | Should BeNullOrEmpty
    }

    # if a function does not have a parameter section defined at all, we can't even call .Body.ParamBlock.Parameters.Count
    # so let's first check if parameters are defined in help while no param is defined in code
    It 'confirms if any Parameters defined in help then param defined in function' {
      $Functions | ForEach-Object {
        if (($_.GetHelpContent().Parameters.Keys.Count -gt 0) -and ($null -eq (Get-Member -Name Parameters -InputObject $_.Body.ParamBlock))) { $_.Name }
      } | Should BeNullOrEmpty
    }

    # at this point, either parameters are defined in BOTH help & function or neither, values might not be the same but
    # at least we can safely check Help parameters key count without throwing an error to filter out functions with no
    # parameter defined anywhere; we'll use this Keys.Count -gt 0 in our remaining parameters tests
    It 'confirms Parameter count in help matches defined parameter count on function' {
      $Functions | Where-Object { $_.GetHelpContent().Parameters.Keys.Count -gt 0 } | ForEach-Object {
        if ($_.GetHelpContent().Parameters.Keys.Count -ne $_.Body.ParamBlock.Parameters.Count) { $_.Name }
      } | Should BeNullOrEmpty
    }

    It 'confirms Parameter name(s) in help matches defined parameter name(s) on function' {
      $Functions | Where-Object { $_.GetHelpContent().Parameters.Keys.Count -gt 0 } | ForEach-Object {
        $Function = $_
        # only do if parameters actually defined on function (else .Name will fail with null error)
        if ($Function.Body.ParamBlock.Parameters.Count -gt 0) {
          # use string expansion to get values as strings;
          $HelpParameters = "$($Function.GetHelpContent().Parameters.Keys | Sort-Object)"
          $DefinedParameters = "$($Function.Body.ParamBlock.Parameters.Name.VariablePath.UserPath | Sort-Object)"
          if ($HelpParameters -ne $DefinedParameters) { $_.Name }
        }
      } | Should BeNullOrEmpty
    }

    It 'confirms Parameter(s) have content for each function' {
      $Functions | Where-Object { $_.GetHelpContent().Parameters.Keys.Count -gt 0 } | ForEach-Object {
        $Function = $_
        # only do if parameters actually defined on function (else .Name will fail with null error)
        if ($Function.Body.ParamBlock.Parameters.Count -gt 0) {
          $EmptyContentFound = $false
          $Function.GetHelpContent().Parameters.Keys | ForEach-Object {
            $ParamName = $_
            # making EmptyContentFound script scope to avoid stupid PSScriptAnalyzer error
            if ($Function.GetHelpContent().Parameters[$ParamName] -eq '') { $script:EmptyContentFound = $true }
          }
          if ($EmptyContentFound -eq $true) { $_.Name + ':' + $ParamName }
        }
      } | Should BeNullOrEmpty
    }

    It 'confirms at least one Example field for each function' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and ($_.GetHelpContent().Examples.Count -eq 0) } | Select-Object Name | Should BeNullOrEmpty
    }

    It 'confirms Example field(s) have content' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and ($_.GetHelpContent().Examples.Count -gt 0) } | ForEach-Object {
        $Function = $_
        $EmptyContentFound = $false
        $Function.GetHelpContent().Examples | ForEach-Object {
          # making EmptyContentFound script scope to avoid stupid PSScriptAnalyzer error
          if ($_ -eq '') { $script:EmptyContentFound = $true }
        }
        if ($EmptyContentFound -eq $true) { $_.Name }

      } | Should BeNullOrEmpty
    }
  }
}
#endregion


#region Confirm which functions/aliases are exported
Describe 'Confirm module public information is correct' {
  $Module = Import-Module $env:BHPSModuleManifest -Force -PassThru
  [string[]]$OfficialListFunctions = @('')
  [string[]]$OfficialListAliases = @('')

  It 'confirms the module name matches the project name' {
    $Module.Name | Should Be $env:BHProjectName
  }

  It 'confirms exported function count is correct' {
    ([object[]](Get-Command -Module $env:BHProjectName -Type Function)).Count | Should Be ($OfficialListFunctions.Count)
  }
  It 'confirms all exported functions are in the official list' {
    ([object[]](Get-Command -Module $env:BHProjectName -Type Function)).Name | Where-Object { $_ -notin $OfficialListFunctions} | Should BeNullOrEmpty
  }

  It 'confirms exported alias count is correct' {
    ([object[]](Get-Command -Module $env:BHProjectName -Type Alias)).Count | Should Be ($OfficialListAliases.Count)
  }
  It 'confirms all exported aliases are in the official list' {
    ([object[]](Get-Command -Module $env:BHProjectName -Type Alias)).Name | Where-Object { $_ -notin $OfficialListAliases} | Should BeNullOrEmpty
  }
}
#endregion
