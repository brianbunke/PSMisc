function Get-ScriptingGuysBlogPost {
    <#
    .SYNOPSIS
    Get a list of posts from the "Hey, Scripting Guy!" blog.

    .DESCRIPTION
    Parses the "Hey, Scripting Guy!" RSS feed for results.

    Can search by tag and/or page through results to gather a large collection.

    There are _A TON_ of blog posts; paging through everything will take forever.

    .EXAMPLE
    Get-ScriptingGuysBlogPost -Tag pester
    Returns a list of all posts tagged "pester".

    .OUTPUTS
    [PSCustomObject]

    .NOTES
    I'd love to know if there are more RSS parameters I can leverage here!
    Kind of got lucky stumbling into paging and tags.

    Brian Bunke / brianbunke

    .LINK
    https://github.com/brianbunke/PSMisc
    
    .LINK
    http://www.brianbunke.com
    #>
    [CmdletBinding(
        #DefaultParameterSetName = 'SetA'
    )]
    [OutputType([PSCustomObject])]

    param (
        # Limit results to posts with the specified tag
        # Supports only one tag at a time
        [Parameter(
            #ParameterSetName = 'SetA'
        )]
        [string]$Tag,

        # Return all results by digging through pages, 10 posts at a time
        # WARNING: Doing this with no tag will take a long time!
        [switch]$All
    )

    # Create an empty list to append results into
    $ResultList = New-Object System.Collections.Generic.List[object]

    $BaseURI = 'https://blogs.technet.microsoft.com/heyscriptingguy'

    If ($Tag) {
        $BaseURI = "$BaseURI/tag/$Tag"
    }

    # Run this for loop until a break
    for ($i = 1; $i -gt 0; $i++) {
        Write-Verbose "Processing page $i"

        Try {
            # Get 10 results from page $i
            $iwr = Invoke-WebRequest -Uri "$BaseURI/feed?paged=$i" -UseBasicParsing -ErrorAction SilentlyContinue
        } Catch {
            Write-Verbose "Invoke-WebRequest found no results on page $i"
            break
        }

        If ($iwr) {
            [xml]$xml = $iwr.Content

            ForEach ($post in $xml.rss.channel.item) {
                [PSCustomObject]@{
                    Title       = $post.title
                    Link        = $post.link
                    Date        = $post.pubDate -as [DateTime]
                    Description = $post.description.'#cdata-section'
                } | Add-ArrayObject $ResultList
            }
        } Else {
            Write-Verbose "Invoke-WebRequest found no results on page $i"
            break
        }

        If (-not $All) {
            # Break if the -All parameter is not active
            break
        }
    }
    
    # Return all results
    $ResultList
}
