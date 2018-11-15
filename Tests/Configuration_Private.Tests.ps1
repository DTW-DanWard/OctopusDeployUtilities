Set-StrictMode -Version Latest

#region Set module/script-level variables
$ScriptLevelVariables = Join-Path -Path $env:BHModulePath -ChildPath 'Set-ScriptLevelVariables.ps1'
. $ScriptLevelVariables
#endregion


#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. $PSScriptRoot\Get-SourceScriptFilePath.ps1
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Configuration not initialized
Describe 'Configuration: not initialized' {

  # ensure config file does not exist
  Mock -CommandName 'Get-ODUConfigFilePath' -MockWith { 'Test:\No\File\Found.txt' }

  Mock -CommandName 'Save-ODUConfig' -MockWith { }

  It 'Confirm-ODUConfig throws error' { { Confirm-ODUConfig } | Should throw  }

  It 'Get-ODUConfig returns $null' { Get-ODUConfig | Should BeNullOrEmpty }

  It 'Get-ODUConfigDecryptApiKey throws error' { { Get-ODUConfigDecryptApiKey } | Should throw }
  
  It 'Get-ODUConfigOctopusServer throws error' { { Get-ODUConfigOctopusServer } | Should throw }

  It 'Initialize-ODUConfig returns $null but behind the scenes Save-ODUConfig returns an initialize configuration' { 
    Initialize-ODUConfig | Should BeNullOrEmpty
  }

  It 'Test-ODUConfigFilePath returns $false' { Test-ODUConfigFilePath | Should Be $false }

}
#endregion



#region Configuration only export root folder initialized
Describe 'Configuration: only export root folder initialized' {

# ensure config file DOES exist
$ExportRootFolder = 'TestDrive:\ExportRoot'
New-Item -Path $ExportRootFolder -ItemType directory > $null
New-Item -Path 'TestDrive:\Configuration' -ItemType directory > $null
$ConfigFilePath = Join-Path -Path $TestDrive "Configuration\Configuration.psd1"
$ConfigString = @"
@{
ExportRootFolder = $ExportRootFolder
OctopusServers = @()
ExternalTools = @{
  DiffViewerPath = 'UNDEFINED'
  TextEditorPath = 'UNDEFINED'
}
ParallelJobsCount = 1
}
"@
Set-Content -Path $ConfigFilePath -Value $ConfigString
Mock -CommandName 'Get-ODUConfigFilePath' -MockWith { $ConfigFilePath }

$Config = @{
  ExportRootFolder = $ExportRootFolder
  OctopusServers = @()
  ExternalTools = @{
    DiffViewerPath = 'UNDEFINED'
    TextEditorPath = 'UNDEFINED'
  }
  ParallelJobsCount = 1
}

Mock -CommandName 'Save-ODUConfig' -MockWith { }

Mock -CommandName 'Get-ODUConfig' -MockWith { $Config }

It 'Confirm-ODUConfig returns $true' { Confirm-ODUConfig | Should Be $true  }

It 'Get-ODUConfig returns a hashtable' { Get-ODUConfig | Should BeOfType [hashtable] }

It 'Get-ODUConfig returns value for ExportRootFolder' { (Get-ODUConfig).ExportRootFolder | Should Be $ExportRootFolder }

It 'Get-ODUConfigDecryptApiKey throws error' { { Get-ODUConfigDecryptApiKey } | Should throw }

It 'Get-ODUConfigOctopusServer throws error' { { Get-ODUConfigOctopusServer } | Should throw }

It 'Initialize-ODUConfig returns $null and does nothing' { Initialize-ODUConfig | Should BeNullOrEmpty }

It 'Initialize-ODUConfig returns $null and does nothing' { Initialize-ODUConfig | Should BeNullOrEmpty }

It 'Test-ODUConfigFilePath returns $true' { Test-ODUConfigFilePath | Should Be $true }

}
#endregion





# do in steps: 
# nothing set
# root export set, nothing else
# then octo server
# then individual tools
#  nested contexts?

# asdf need testsmock for partially configured system
# no external tools, etc.




Describe 'Configuration initialized' {

  Mock -CommandName 'Test-ODUConfigFilePath' -MockWith { $true }

  # asdf need mock for configured system
  

  It 'Confirm-ODUConfig returns $true' {
    Confirm-ODUConfig | Should Be $true
  }

  # asdf need test for:
  #   Get-ODUConfig - returns hashtable, has some config values
}


#endregion
