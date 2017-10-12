<#PSScriptInfo
.VERSION 1.0.2
.GUID cafa37ba-9b0d-479e-8cb1-b5ca443fd1ab
.AUTHOR Brian Bunke
.DESCRIPTION Returns the elapsed execution time of the previous command (or any from Get-History).
.COMPANYNAME brianbunke
.COPYRIGHT
.TAGS history
.LICENSEURI https://github.com/brianbunke/PSMisc/blob/master/LICENSE
.PROJECTURI https://github.com/brianbunke/PSMisc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
1.0.2 - Update PSGallery script metadata
1.0.1 - Add additional help
1.0.0 - Initial publish
#>

function Measure-LastCommand {
<#
.SYNOPSIS
Returns the elapsed time of the previous command in Get-History.

.DESCRIPTION
Allows you to check the total time of a command after it has already completed.

By default, returns the duration of the last command.
Also accepts the ID of the Get-History entry.

The optional -String parameter returns the total time as a one-line string.

.NOTES
Learned this was possible from @KevinMarquette. Thanks!

.OUTPUTS
System.TimeSpan
System.String

.EXAMPLE
Measure-LastCommand
Review the total time the last command took from start to finish.

.EXAMPLE
Measure-LastCommand -ID 1 -Verbose
Review the total elapsed time for the first command in your current PS session.
-Verbose also echoes the actual command text, for verification.

.EXAMPLE
Measure-LastCommand -String
Review the total time the last command took from start to finish.
Instead of a ten-line TimeSpan object, a short one-line string is returned.

.LINK
http://www.brianbunke.com/blog/2017/01/09/publishing-scripts/
#>
    [CmdletBinding()]
    param (
        # Optionally measure an older command, instead of the most recent
        # Supply the ID number from Get-History
        [ValidateRange(1,[int]::MaxValue)]
        [int]$ID,

        # Formats output in a one-line string, instead of a TimeSpan object
        # Returns as "Days:Hours:Minutes:Seconds.Milliseconds"
        [switch]$String
    )

    If ($ID) {
        $Command = Get-History -Id $ID
    } Else {
        $Command = Get-History -Count 1
    }

    Write-Verbose "Returning the elapsed time of command: $($Command.CommandLine)"

    If ($String) {
        (New-TimeSpan -Start $Command.StartExecutionTime -End $Command.EndExecutionTime).ToString('d\:hh\:mm\:ss\.fff')
    } Else {
        New-TimeSpan -Start $Command.StartExecutionTime -End $Command.EndExecutionTime
    }
}
