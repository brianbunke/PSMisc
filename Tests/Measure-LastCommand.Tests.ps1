#Requires -Version 3 -Modules PowerShellGet

Describe -Name 'Measure-LastCommand unit tests' -Tag 'unit' {
    $MLC = (Get-Item "$PSScriptRoot\..\Measure-LastCommand.ps1").FullName

    . $MLC
    $Date = Get-Date

    # Measure-LastCommand calls Get-History and calculates start/end times
    # Mock that behavior!

    # This mock only executes if Get-History is called with the -ID parameter
    Mock -CommandName Get-History -ParameterFilter {$ID} {
        [PSCustomObject]@{
            StartExecutionTime = $Date.AddSeconds(-22)
            EndExecutionTime =   $Date.AddSeconds(-11)
        }
    }
    # This mock executes for all other Get-History calls
    Mock -CommandName Get-History {
        [PSCustomObject]@{
            StartExecutionTime = $Date.AddSeconds(-30)
            EndExecutionTime =   $Date.AddSeconds(-15)
        }
    }

    It 'Exports the function successfully' {
        Get-Command Measure-LastCommand | Should Not BeNullOrEmpty
    }

    $Results1 = Measure-LastCommand
    $Results2 = Measure-LastCommand -ID 1
    $Results3 = Measure-LastCommand -String
    
    It 'Returns expected results' {
        $Results1.Count | Should Be 1
        $Results1 | Should BeOfType TimeSpan
        $Results1.TotalSeconds | Should Be 15

        $Results2.Count | Should Be 1
        $Results2 | Should BeOfType TimeSpan
        $Results2.TotalSeconds | Should Be 11

        $Results3.Count | Should Be 1
        $Results3 | Should BeOfType String
        $Results3 | Should Match '^[0-9]\:[0-9]{2}\:[0-9]{2}\:[0-9]{2}\.[0-9]{3}$'
    }

    It 'Contains PSScriptInfo' {
        # Should have valid PSScriptInfo for PS Gallery publishing
        Test-ScriptFileInfo -Path $MLC -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty
    }

    It 'Contains expected parameters' {
        # Measure-LastCommand:
          # Should be an advanced function
          # Should have two user-created parameters: ID & String
          # Should not have any extra parameters (without rewriting this test)

        # Create dummy function with advanced function parameters for comparison
        function DummyFunction {[CmdletBinding()] param ()}
        
        (Get-Command Measure-LastCommand).Parameters.Keys |
            Where-Object {$_ -notin (Get-Command DummyFunction).Parameters.Keys} |
            Should Be @('ID','String')
    }
}
