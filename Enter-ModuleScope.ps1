function Enter-ModuleScope {
<#
.SYNOPSIS
Enter a module's private scope for troubleshooting purposes.

.DESCRIPTION
Enter-ModuleScope allows you to interactively call private
functions or module-scoped variables ($script:abc in .psm1).

This can be useful for module troubleshooting purposes.

.NOTES
Personally, I learned about this from Snover in April 2018:
https://twitter.com/jsnover/status/986940804097826816

.EXAMPLE
Get-Module Pester | Enter-ModuleScope
Module> Get-Command -Module Pester
Module> Get-Help Test-NullOrWhiteSpace 
Module> Test-NullOrWhiteSpace 'foo'
Module> exit

Enters the Pester module's private scope. Shows a full list of public
and private commands, not just the publicly exported commands.
Check syntax and run any private command.
Use "exit" to return to your normal prompt.

.LINK
https://github.com/brianbunke/PSMisc/
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [PSModuleInfo]$Module
    )

    # Would like to know the best way to use the module name in the prompt
    # Hardcoded until I find something that doesn't pollute the interactive session
    & $Module {function prompt {"Module> "}; $host.EnterNestedPrompt()}
}
