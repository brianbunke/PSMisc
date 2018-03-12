function Resolve-ShortLink {
    <#
    .SYNOPSIS
    Resolve the actual destination of a short link (bit.ly, goo.gl, etc.)

    .DESCRIPTION
    Uses .NET's [System.Net.WebRequest] to record a link's redirect location.
    Thanks to http://community.idera.com/powershell/powertips/b/tips/posts/uncover-tiny-urls

    .EXAMPLE
    Resolve-ShortLink -Uri http://goo.gl/l6MS
    Returns the full blogspot.com URI path from the goo.gl redirect.

    .EXAMPLE
    'https://youtu.be/dQw4w9WgXcQ' | Resolve-ShortLink
    Also accepts one or multiple links via the pipeline, returning the destination of each.

    .INPUTS
    [string]

    .OUTPUTS
    [string]
    #>
    [CmdletBinding()]
    [OutputType([String])]

    param (
        # The full URI (http://goo.gl/l6MS) of the short link
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [Uri[]]$Uri
    )

    BEGIN {
    } #BEGIN

    PROCESS {
        ForEach ($u in $Uri) {
            Write-Verbose "Processing $u"

            # Construct the request
            $request = [System.Net.WebRequest]::Create($u)
            $request.AllowAutoRedirect = $false

            Try {
                # Contact the URI and capture the response
                $response = $request.GetResponse()

                # Output the "Location" of the response's redirect
                $response.GetResponseHeader("Location")
            } Catch {
                Write-Error $_
            }
        } #ForEach
    } #PROCESS

    END {
    } #END
}
