

Joining data - id->names, deploy process, much more
ODU does a lot more than just export your Octopus Deploy data.

<get from code> - which function

Make coding easier:
 - always add property
 - always create as array (could be empty - most likely)
In docs, show example:
Filter this way:
  .Breadth -contains 'Staging'
  .EnvironmentName -contains 'Staging'
Check if property exists, then check if not null then check if array with count > 0 then containes


See changes from joindata:
$ExportPathNoJoin = oduexport -SkipJoinData -PassThru
$ExportPathJoin = $ExportPathNoJoin + '_Join' 
Copy-Item $ExportPathNoJoin $ExportPathJoin -Container -Recurse -Force
Update-ODUExportJoinData $ExportPathJoin
& (Get-ODUConfigDiffViewer) $ExportPathNoJoin $ExportPathJoin
