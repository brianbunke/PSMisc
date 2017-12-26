$Text = @'
function asdf {
    <#
    .SYNOPSIS


    .DESCRIPTION


    .EXAMPLE


    .INPUTS


    .OUTPUTS


    .NOTES


    .LINK
    
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        DefaultParameterSetName = 'SetA'
    )]
    [OutputType([String])]

    param (
        # TODO: Parameter help
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'SetA'
        )]
        [ValidateScript({
            $_ -eq 'test'
        })]
        [ValidateSet('one','two')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [ValidateRange(0,5)]
        [ValidateCount(0,5)]
        [Alias('OtherName')]
        $Test
    )

    BEGIN {
    } #BEGIN

    PROCESS
        ForEach () {
            # -WhatIf wrapper
            If ($PSCmdlet.ShouldProcess(
                "Target",
                "Operation"
            )) {

            }
        } #ForEach
    } #PROCESS

    END {
    } #END
}

'@

$Splat = @{
    Title       = 'bb Advanced Function'
    Description = 'Common use adv func'
    Author      = 'brianbunke'
    Text        = $Text
}

New-IseSnippet @Splat
