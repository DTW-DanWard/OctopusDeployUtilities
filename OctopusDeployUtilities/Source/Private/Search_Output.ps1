
Set-StrictMode -Version Latest

#region Function: Out-ODUHostStringHighlightMatchText

<#
.SYNOPSIS
Outputs Line of text to host (no new line), highlighting MatchingText if found
.DESCRIPTION
Outputs Line of text to host (no new line), highlighting MatchingText if found.
.PARAMETER Line
Line of text to output
.PARAMETER MatchingText
Text to highlight in Line
.EXAMPLE
Out-ODUHostStringHighlightMatchText 'This is only a test.' 'only'
<writes sentence to host, highlighting 'only'>
#>
function Out-ODUHostStringHighlightMatchText {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Line,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$MatchingText
  )
  #endregion
  process {
    $LineLower = $Line.ToLower()
    $MatchingTextLower = $MatchingText.ToLower()

    $StartIndex = 0
    $FoundIndex = $LineLower.IndexOf($MatchingTextLower, $StartIndex)

    while ($FoundIndex -ne -1) {
      # found an entry
      # first write any text from current StartIndex to FoundIndex (might be nothing if match at beginning)
      Write-Host $Line.Substring($StartIndex, $FoundIndex - $StartIndex) -NoNewline
      # next write matching text in color
      Write-Host $Line.Substring($FoundIndex, $MatchingText.Length) -ForegroundColor Cyan -NoNewline
      # update indexes
      $StartIndex = $FoundIndex + $MatchingText.Length
      $FoundIndex = $LineLower.IndexOf($MatchingTextLower, $StartIndex)
    }
    # write rest of content (might be nothing if matching text at end of line) but not new line
    Write-Host $Line.Substring($StartIndex) -NoNewline
  }
}
#endregion


#region Function: Out-ODUSearchResultsText

<#
.SYNOPSIS
Outputs search results - header text and each section (high-level)
.DESCRIPTION
Outputs search results - header text and each section (high-level)
.PARAMETER SearchResults
PSObject with search results
.EXAMPLE
Out-ODUSearchResultsText $SearchResults
<outputs the search results>
#>
function Out-ODUSearchResultsText {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$SearchResults
  )
  #endregion
  process {
    Write-Output ''
    if ($WriteOutput) {
      Write-Output "Search text: $($SearchResults.SearchText)"
    } else {
      Write-Host "Search text: " -NoNewline
      Write-Host $SearchResults.SearchText -ForegroundColor Cyan
    }

    #region Output matching info from Octopus
    # output library variable set header if results
    if (($null -ne $SearchResults.LibraryVariableSetDefined -and $SearchResults.LibraryVariableSetDefined.Count -gt 0) -or
      ($null -ne $SearchResults.LibraryVariableSetUsed -and $SearchResults.LibraryVariableSetUsed.Count -gt 0)) {
      Write-Output "`nLibrary Variable Set variable results:"
    }

    if ($null -ne $SearchResults.LibraryVariableSetDefined -and $SearchResults.LibraryVariableSetDefined.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.LibraryVariableSetDefined -Exact:($SearchResults.Exact)
    }

    if ($null -ne $SearchResults.LibraryVariableSetUsed -and $SearchResults.LibraryVariableSetUsed.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.LibraryVariableSetUsed -Exact:($SearchResults.Exact)
    }

    # output project header if results
    if (($null -ne $SearchResults.LibraryVariableSetDefined -and $SearchResults.LibraryVariableSetDefined.Count -gt 0) -or
      ($null -ne $SearchResults.LibraryVariableSetUsed -and $SearchResults.LibraryVariableSetUsed.Count -gt 0)) {
      Write-Output "`n`nProject-level variable results:"
    }

    if ($null -ne $SearchResults.ProjectDefined -and $SearchResults.ProjectDefined.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.ProjectDefined -Exact:($SearchResults.Exact)
    }

    if ($null -ne $SearchResults.ProjectUsed -and $SearchResults.ProjectUsed.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.ProjectUsed -Exact:($SearchResults.Exact)
    }
    #endregion
  }
}
#endregion


#region Function: Out-ODUSearchResultsTextSection

<#
.SYNOPSIS
Outputs the search results for a single section
.DESCRIPTION
Outputs Line of text to host (no new line), highlighting MatchingText if found.
.PARAMETER SearchText
Search text
.PARAMETER Section
Search results section to output
.PARAMETER Exact
Partial or exact match
.EXAMPLE
Out-ODUSearchResultsTextSection 'only' $SectionResults
<writes section results>
#>
function Out-ODUSearchResultsTextSection {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SearchText,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Section,
    [Parameter(Mandatory = $false)]
    [switch]$Exact
  )
  #endregion
  process {

    $Column1Width = 20
    $Column2Width = 50

    $ContainerName = ''
    $HeaderRow = "$('Name'.PadRight($Column1Width))  $('Value'.PadRight($Column2Width))  Scope"
    # loop through all containers, output container name only once
    $Section | ForEach-Object {
      $Item = $_
      if ($ContainerName -ne $Item.ContainerName) {
        $ContainerName = $Item.ContainerName
        Write-Output ''
        if ($WriteOutput) {
          Write-Output $ContainerName
          Write-Output $HeaderRow
        } else {
          Write-Host $ContainerName -ForegroundColor Green
          Write-Host $HeaderRow -ForegroundColor Yellow
        }
      }

      # loop through all variable matches in container
      $Item.Variable | ForEach-Object {
        $Variable = $_

        # variable value could be null because it's empty or because it's Sensitive (and thus not exported)
        $VariableValue = ''
        if ($null -ne $Variable.Value) {
          $VariableValue = $Variable.Value.Trim()
        } elseif ($true -eq $Variable.IsSensitive) {
          $VariableValue = '[Sensitive]'
        }
        $VariableValue = $VariableValue.PadRight($Column2Width)

        # ScopeBreadth might not exist if no Scope values set; determine value first
        $VariableScopeBreadth = ''
        if ($null -ne $Variable.Scope -and ($null -ne (Get-Member -InputObject $Variable.Scope -Name 'Breadth' -MemberType NoteProperty))) {
          $VariableScopeBreadth = $Variable.Scope.Breadth
        }

        if ($WriteOutput) {
          Write-Output ($Variable.Name.PadRight($Column1Width) + "  " + $VariableValue + "  " + $VariableScopeBreadth)
        } else {
          # if variable name matches search text highlight it
          if (($Exact -and ($Variable.Name -eq $SearchText)) -or (!$Exact -and ($Variable.Name -match $SearchText))) {
            Out-ODUHostStringHighlightMatchText -Line $Variable.Name.Trim().PadRight($Column1Width + 2) -MatchingText $SearchText
          } else {
            Write-Host ($Variable.Name.PadRight($Column1Width) + "  ") -NoNewline
          }

          Out-ODUHostStringHighlightMatchText -Line $VariableValue -MatchingText $SearchText

          Write-Output "  $VariableScopeBreadth"
        }
      }
    }
  }
}
#endregion
