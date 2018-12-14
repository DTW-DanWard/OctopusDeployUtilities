
# What Does an Export Look Like Anyway?

## Export Folder Structure

An export is stored in a date-time stamp folder name.  Here's an example of the contents:

![Sample export folder](SampleExport_Explorer.png)

Each folder contains all the exported contents of a particular REST API call; items exported from Accounts API (/api/accounts) are in the Accounts folder, etc.  One exception to that is the Miscellaneous folder which contains the output of all 'Simple' REST API requests; see [type descriptions](TypeDescription.md) for more information.

All exported content is stored in JSON files.  So, what does a particular JSON look like?

## Sample Export File - Environment

```JSON
{
  "Id": "Environments-8",
  "Name": "Staging",
  "Description": "Staging environment",
  "SortOrder": 1,
  "UseGuidedFailure": false,
  "AllowDynamicInfrastructure": false,
  "Links": {
    "Self": "/api/environments/Environments-8",
    "Machines": "/api/environments/Environments-8/machines{?skip,take,partialName,roles,isDisabled,healthStatuses,commStyles,tenantIds,tenantTags}",
    "SinglyScopedVariableDetails": "/api/environments/Environments-8/singlyScopedVariableDetails"
  },
  "MachineIds": [
    "Machines-44",
    "Machines-38",
    "Machines-62",
    "Machines-20",
    "Machines-11",
    "Machines-81",
    "Machines-31",
    "Machines-32",
    "Machines-20",
    "Machines-16"
  ],
  "MachineNames": [
    "STGAUTH01",
    "STGAUTH02",
    "STGMAP01",
    "STGMAP02",
    "STGMAP03",
    "STGMAP04",
    "STGSERV01",
    "STGSERV02",
    "STGWEB01",
    "STGWEB02"
  ]
}
```

Now, if you are familiar with the Environments API call, or you checked out the [Swagger docs](https://demo.octopus.com/swaggerui/index.html), you might notice something peculiar.  The MachineIds and MachineNames *are not* a part of the actual data returned by the Environments API call.  What gives?

This is the magic of the [post-processing](PostProcessing.md) step - it makes the exported data **much** more useful for you.  In the case of Environment data, the post-processing goes and looks through all the Machines, finds ones that list the particular Environment in the machine's EnvironmentIds field and then grabs that machine id **and its name** and adds that info to the Environment JSON.  This is super handy!  Do you want to search through every machine just to find out which machines are in a particular environment?  Of course not - so ODU does it for you!

This post-processing does a lot of magic!  If you are wondering what info gets added to a JSON file during post-processing you can usually find the fields that appear after the first Links instance in the file.  Again, you can learn more about [post-processing](PostProcessing.md).

Now, let's look at a much more complex example.

## Sample Export File - Project

asdf Project - Grab old copy and clean

Included VariableSet, deploy process, name matches



