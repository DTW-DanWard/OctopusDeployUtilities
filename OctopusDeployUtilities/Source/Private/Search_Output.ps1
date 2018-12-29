
Set-StrictMode -Version Latest

#region Function: Out-ODUHostStringHighlightMatchText

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
    if ($null -ne $SearchResults.LibraryVariableSetDefined -and $SearchResults.LibraryVariableSetDefined.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.LibraryVariableSetDefined
    }

    if ($null -ne $SearchResults.LibraryVariableSetUsed -and $SearchResults.LibraryVariableSetUsed.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.LibraryVariableSetUsed
    }

    if ($null -ne $SearchResults.ProjectDefined -and $SearchResults.ProjectDefined.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.ProjectDefined
    }

    if ($null -ne $SearchResults.ProjectUsed -and $SearchResults.ProjectUsed.Count -gt 0) {
      Out-ODUSearchResultsTextSection -SearchText $SearchResults.SearchText -Section $SearchResults.ProjectUsed
    }
    #endregion
  }
}
#endregion


#region Function: Out-ODUSearchResultsTextSection

function Out-ODUSearchResultsTextSection {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SearchText,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [object]$Section
  )
  #endregion
  process {

    $Column1Width = 30
    $Column2Width = 40

    $ContainerName = ''
    # loop through all containers, output container name only once
    $Section | ForEach-Object {
      $Item = $_
      if ($ContainerName -ne $Item.ContainerName) {
        $ContainerName = $Item.ContainerName
        Write-Output ''
        if ($WriteOutput) {
          Write-Output $ContainerName
        } else {
          Write-Host $ContainerName -ForegroundColor Green
        }
      }
      # loop through all variable matches in container
      $Item.Variable | ForEach-Object {
        $Variable = $_
        if ($WriteOutput) {
          Write-Output ($Variable.Name.PadRight($Column1Width) + "  " + $Variable.Value.PadRight($Column2Width) + "  " + $Variable.ScopeNames.Breadth)
        } else {
          # if variable name matches search text highlight it
          if (($Exact -and ($Variable.Name -eq $SearchText)) -or (!$Exact -and ($Variable.Name -match $SearchText))) {
            Out-ODUHostStringHighlightMatchText -Line $Variable.Name.Trim().PadRight($Column1Width + 2) -MatchingText $SearchText
          } else {
            Write-Host ($Variable.Name.PadRight($Column1Width) + "  ") -NoNewline
          }
          # variable value could be null (ood; would have thought it would be empty string); so gr
          $VariableValue = "".PadRight($Column2Width)
          if ($null -ne $Variable.Value) {
            $VariableValue = $Variable.Value.Trim().PadRight($Column2Width)
          }
          Out-ODUHostStringHighlightMatchText -Line $VariableValue -MatchingText $SearchText
          Write-Host '  '
          if ($null -ne $Variable.Scope -and ($null -ne (Get-Member -InputObject $Variable.Scope -Name 'Breadth' -MemberType NoteProperty))) {
            Write-Host $Variable.Scope.Breadth
          }
        }
      }
    }
  }
}
#endregion
