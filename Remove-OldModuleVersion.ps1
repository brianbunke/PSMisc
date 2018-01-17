function Remove-OldModuleVersion {
<#
.SYNOPSIS
Removes old versions of modules downloaded from the PS Gallery.

.DESCRIPTION
I got really tired of having duplicate results in Get-Module. This script
searches module folders for instances of multiple versions, keeps the newest,
and terminates the rest with extreme prejudice.
    
This script DOES NOT check the newest published version on the PS Gallery.
It keeps the newest version you have downloaded, and removes the rest.

Defaults to "$env:HOMEDRIVE\Program Files\WindowsPowerShell\Modules\",
but can be targeted to different directories if desired.

The default PS Gallery directory requires admin rights to modify.
The script will warn and suggest on the first deletion error.

.EXAMPLE
Remove-OldModuleVersion -WhatIf
Checks default folder "$env:HOMEDRIVE\Program Files\WindowsPowerShell\Modules\".
-WhatIf reports on folders that would have been deleted.
No data is actually deleted with the -WhatIf flag active.
    
.EXAMPLE
Remove-OldModuleVersion -Verbose
Checks default folder "$env:HOMEDRIVE\Program Files\WindowsPowerShell\Modules\"
and removes all module versions except for the newest version of each.
-Verbose provides additional info on module discovery and processing.

.EXAMPLE
Remove-OldModuleVersion -ModuleDir 'Q:\Modules\','X:\CorpShare\'
Removes all outdated module versions for modules in a non-default folder.
Assumes that modules are stored at that location, instead of further down.
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact='Medium')]
    param (
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({Test-Path $_})]
        [Alias('FullName')]
        [object[]]
        $ModuleDir = "$env:HOMEDRIVE\Program Files\WindowsPowerShell\Modules\"
    )

    BEGIN {
        $ModuleList = New-Object System.Collections.ArrayList
    }

    PROCESS {
        $ModuleDir | ForEach-Object {
            $GetModuleList = Get-ChildItem $_ -Directory

            If ($GetModuleList.Count -gt 1) {
                # .AddRange if more than one directory
                $ModuleList.AddRange($GetModuleList) | Out-Null
            } ElseIf ($GetModuleList.Count -eq 1) {
                # .Add if only one event
                $ModuleList.Add($GetModuleList) | Out-Null
            }
        }
    }

    END {
        ForEach ($Module in $ModuleList) {
            Write-Verbose "- Processing module '$Module'"

            If (($ChildVersions = Get-ChildItem $Module.FullName -Directory).Count -gt 1) {
                $ChildVersions = $ChildVersions |
                    Select-Object FullName,@{n='Version';e={[version]$_.BaseName}} |
                    Sort-Object Version -Descending

                for ($i = 1; $i -lt $ChildVersions.Count; $i++) {
                    If ($ChildVersions[$i].Version -eq $null) {
                        Write-Verbose "$($ChildVersions[$i].FullName) is not a version subdirectory; skipping"
                    } Else {
                        If ($PSCmdlet.ShouldProcess("$($ChildVersions[$i].FullName)","Remove old module version")) {
                            Write-Verbose "Removing old module version '$($ChildVersions[$i].FullName)'"

                            Try {
                                $ChildVersions[$i].FullName | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction Stop
                            } Catch {
                                # Is PowerShell running as Administrator?
                                # http://superuser.com/questions/749243/detect-if-powershell-is-running-as-administrator
                                $Admin = ([Security.Principal.WindowsPrincipal] `
                                            [Security.Principal.WindowsIdentity]::GetCurrent()
                                            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                                
                                # Sorry for the negative booleans :)
                                # If you're not in an admin window,
                                If (-not $Admin) {
                                    # If you haven't been warned yet,
                                    If (-not $Warned) {
                                        # Suggest running as admin (only on the first error)
                                        Write-Warning 'Error while deleting. You may need to relaunch PowerShell in an admin window.'
                                        Write-Warning 'By default, the PowerShell Gallery install directory requires admin rights to modify.'
                                        Write-Warning 'If error persists in admin window, manually delete the offending file/folder.'
                                        $Warned = $true
                                    }

                                    # Pass the error for user review
                                    Write-Error $_
                                # If you are in an admin window,
                                } Else {
                                    # If you haven't been warned yet,
                                    If (-not $Warned) {
                                        # Abandon hope all ye who enter here
                                        Write-Warning 'Error while deleting. You may need to manually delete the offending file/folder.'
                                        $Warned = $true
                                    }

                                    # Pass the error for user review
                                    Write-Error $_
                                } #if $Admin
                            } #try/catch delete
                        } #WhatIf
                    } #if not versioned
                } #for loop
            } #if >1 version
        } #foreach module
    } #end
} #weeeee that was fun
