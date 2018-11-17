
Set-StrictMode -Version Latest

# script-level variables
# web site url
$script:ProjectUrl = 'https://github.com/DTW-DanWard/OctopusDeployUtilities'

# Different ways of calling the Octopus Deploy API to fetch data
# Simple      make single call, save all results to single file
#             used for admin-type calls, results are saved in single file named after api in folder Miscellaneous
# MultiFetch  make call to get TotalResults, Number of Pages, etc. info, need to call API in loop until all items retrieved
#             used for most user-specific data calls; data saved one item per file in folder with same name as API call
# ItemIdOnly  fetch item ONLY by it's Id; certain versioned items (variables, deployment processes) have so many instances
#             that call to fetch the TotalResults values time out or hit out of memory exceptions; for these we have to
#             manually collect the Ids that are referenced then explicitly fetch by Id
Set-Variable ApiFetchTypeList -Option ReadOnly -Value @('Simple', 'MultiFetch', 'ItemIdOnly') -Scope Script

# version of configuration details
$script:ConfigVersion = '1.0.0'
# default text for settings still having placeholders - not configured by user yet
Set-Variable Undefined -Option ReadOnly -Value 'UNDEFINED' -Scope Script
