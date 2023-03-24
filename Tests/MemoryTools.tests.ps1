#Pester Tests
<#
Show-MemoryUsage can't be tested because it doesn't write anything to the pipeline
This has not been tested with Pester 5.x
#>

Import-Module $PSScriptRoot\..\MemoryTools.psd1 -Force

InModuleScope MemoryTools {

    BeforeAll {
        $Script:mod = Get-Module MemoryTools
        #create a sample object like something imported from a CSV file
        #or other command
        $computerObject = New-Object -TypeName PSObject -Property @{
            Computername = $env:computername
            Location     = 'Chicago'
            OS           = 'Windows Server 2016'
        }

        #test with CimSessions
        $testSessions = New-CimSession -ComputerName $env:computername, $env:computername
    }

    Describe 'Module' -Tags module {

        It 'Should have an 7 functions' {
            $Script:mod.ExportedFunctions.count | Should -Be 7
        }
        It 'Should have 6 aliases' {
            $script:mod.ExportedAliases.count | Should -Be 6
        }
        It 'Should have 4 Format ps1xml files' {
            $script:mod.ExportedFormatFiles.count | Should -Be 4
        }
        It "Should have an integer value for `$MemoryToolsOK" {
            ($MemoryToolsOK).GetType().Name | Should -Be 'Int32'
        }

        It "Should have an integer value for `$MemoryToolsWarning" {
            ($MemoryToolsWarning).GetType().Name | Should -Be 'Int32'
        }

        It "Should have an external help file" {
            "$PSScriptRoot\..\en-us\*help.xml" | Should -Exist
        }

        It "Should have an license file" {
            "$PSScriptRoot\..\license*" | Should -Exist
        }
        It "Should have a README file" {
            "$PSScriptRoot\..\readme.md" | Should -Exist
        }
        It "Should have a Changelog file" {
            "$PSScriptRoot\..\changelog.*" | Should -Exist
        }

    } #describe module

    Describe 'Get-MemoryUsage' -Tags Functions, dev {

    <#
     I am mocking the results with known values. The tested command will actually
     use the localhost but the result will be mocked.
    #>
        BeforeAll {
            Mock Get-CimInstance {
                $data = [PSCustomObject]@{
                    PSComputername         = 'WinTest'
                    FreePhysicalMemory     = 4194304
                    TotalVisibleMemorySize = 8298776
                    Caption                = 'Windows Server 2016 Standard'
                }
                Return $Data
            } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }
            $script:try = Get-MemoryUsage -Computername $env:computername
        }

        It 'should run with defaults and without error' {
            { Get-MemoryUsage -ErrorAction stop } | Should -Not -Throw
        }
        It 'Should show status as OK' {
            $try.status | Should -Be 'OK'
        }

        It 'Should filter on Status' {
            (Get-MemoryUsage -Computername $env:computername -Status 'OK' | Measure-Object).count | Should -Be 1
            (Get-MemoryUsage -Computername $env:computername -Status 'Critical' | Measure-Object).count | Should -Be 0
        }
        It 'Should show computername as WinTest' {
            $try.computername | Should -Be 'WinTest'
        }
        It 'Should show total as 8' {
            $try.TotalGB | Should -Be 8
        }
        It 'Should show PctFree as 51' {
            $try.pctFree -as [int] | Should -Be 51
        }
        It 'Should show Free as 4' {
            $try.FreeGB | Should -Be 4
        }
        It 'Should have a type of MyMemoryUsage' {
            $try.PSObject.TypeNames[0] | Should -Be 'MyMemoryUsage'
        }
        It 'Should accept pipelined input' {
            { 'localhost' | Get-MemoryUsage -ErrorAction stop } | Should -Not -Throw

            ('localhost', 'localhost', 'localhost' | Get-MemoryUsage | Measure-Object).count | Should -Be 3

            ($computerobject, $computerobject | Get-MemoryUsage | Measure-Object).count | Should -Be 2

        }

        It 'Should error with a bad computername' {
            { Get-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should -Throw
        }

        It 'Should accept CIMSessions as a parameter value' {
            (Get-MemoryUsage -CimSession $testSessions | Measure-Object).Count | Should -Be 2
        }

        It 'Should accept CIMSessions from the pipeline' {
            ($testSessions | Get-MemoryUsage | Measure-Object).Count | Should -Be 2
        }

    }

    Describe 'Test-MemoryUsage' -Tags Functions {

        BeforeAll {
            Mock Get-CimInstance {
                $data = [PSCustomObject]@{
                    PSComputername         = 'WinTest'
                    FreePhysicalMemory     = 4194304
                    TotalVisibleMemorySize = 8298776
                    Caption                = 'Windows Server 2016 Standard'
                }
                Return $Data
            } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }

        }

        Context 'Test-MemoryUsage: Percent' {
            BeforeAll {
                $script:r = Test-MemoryUsage -Computername $env:computername
            }
            It 'Should run with defaults and without error' {
                { Test-MemoryUsage -ErrorAction Stop } | Should -Not -Throw
            }

            It "Should have a Test value of $True" {
                $r.Test | Should -Be $True
            }
            It 'Should have a value >= 50 ' {
                $r.PctFree | Should -BeGreaterThan 50
            }
            It 'Should accept pipelined input' {
                { 'localhost' | Test-MemoryUsage -ErrorAction stop -Quiet } | Should -Not -Throw

                ('localhost', 'localhost', 'localhost' | Test-MemoryUsage -Quiet | Measure-Object).count | Should -Be 3

                ($computerobject, $computerobject | Test-MemoryUsage | Measure-Object).count | Should -Be 2

            }
            It 'Should error with a bad computername' {
                { Test-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should -Throw
            }

        }

        Context 'Test-MemoryUsage: Free' {
            BeforeAll {
                $script:r = Test-MemoryUsage -Computername $env:computername -FreeGB 4
            }

            It "Should have a Test value of $True" {
                $r.test | Should -Be $True
            }
            It 'Should have a FreeGB value of 4' {
                $r.FreeGB | Should -Be 4
            }
        }

        Context 'Test-MemoryUsage: Total' {
            BeforeAll {
                $script:r = Test-MemoryUsage -Computername $env:computername -TotalGB 8
            }

            It "Should have a Test value of $True" {
                $r.test | Should -Be $True
            }
            It 'Should have a TotalGB value of 8' {
                $r.TotalGB | Should -Be 8
            }
        }

        Context 'Test-MemoryUsage: Used' {
            BeforeAll {
                $script:r = Test-MemoryUsage -Computername $env:computername -UsedGB 4
            }

            It "Should have a Test value of $True" {
                $r.test | Should -Be $True
            }
            It 'Should have a UsedGB value of 4' {
                $r.UsedGB | Should -Be 4
            }

        }
    }

    Describe 'Get-MemoryPerformance' -Tags Functions {

        BeforeAll {
            $script:r = Get-MemoryPerformance

        }
        It 'Should run with defaults and without error' {
            { Get-MemoryPerformance -ErrorAction Stop } | Should -Not -Throw
        }


        It "Should have a computername equal to `$env:computername" {
            $r.computername | Should -Be $env:COMPUTERNAME
        }

        It 'should have a datetime of today' {
            $today = (Get-Date)
            $r.datetime.hour | Should -Be $today.Hour
            $r.datetime.Day | Should -Be $today.Day
            $r.datetime.month | Should -Be $today.Month
        }

        It 'should have available bytes' {
            $r.AvailableBytes | Should -BeGreaterThan 0
        }

        It 'Should accept pipelined input' {
            { 'localhost' | Get-MemoryPerformance -ErrorAction stop } | Should -Not -Throw
            ('localhost', 'localhost', 'localhost' | Get-MemoryPerformance | Measure-Object).count | Should -Be 3
            ($computerobject, $computerobject | Get-MemoryPerformance | Measure-Object).count | Should -Be 2
        }

        It 'Should error with a bad computername' {
            { Get-MemoryPerformance -Computername 'F00' -ErrorAction stop } | Should -Throw
        }

    }

    Describe 'Get-PhysicalMemory' -Tags Functions {
        BeforeAll {

            Mock Get-CimInstance {
                $data = @(
                    [PSCustomObject]@{
                        PSComputername       = 'WinTest'
                        Manufacturer         = 0420
                        Capacity             = 16GB
                        FormFactor           = 12
                        ConfiguredClockSpeed = 2133
                        ConfiguredVoltage    = 1200
                        DeviceLocator        = 'ChannelA-DIMM0'
                    },
                    [PSCustomObject]@{
                        PSComputername       = 'WinTest'
                        Manufacturer         = 0420
                        Capacity             = 16GB
                        FormFactor           = 12
                        ConfiguredClockSpeed = 2133
                        ConfiguredVoltage    = 1200
                        DeviceLocator        = 'ChannelA-DIMM1'
                    })
                Return $Data
            } -ParameterFilter { $ClassName -eq 'Win32_PhysicalMemory' }

            $script:r = Get-PhysicalMemory -Computername $env:computername
        }

        It 'Should run without error' {
            { Get-PhysicalMemory -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should return 2 objects' {
            $r.count | Should -Be 2
        }
        It 'Should -Be a physicalMemoryUnit object' {
            $r[0].PSObject.typenames[0] | Should -Be 'physicalMemoryUnit'
        }
        It 'Should have a computername of WinTest' {
            $r[0].Computername | Should -Be 'WinTest'
        }

        It 'Should have a form value of SODIMM' {
            $r[0].Form | Should -Be 'SODIMM'
        }

        It 'Should have a capacity value of 16' {
            $r[0].CapacityGB | Should -Be 16
        }
        It 'Should have a clock speed of 2133' {
            $r[0].ClockSpeed | Should -Be 2133
        }

        It 'Should accept pipelined input' {
            { 'localhost' | Get-PhysicalMemory -ErrorAction stop } | Should -Not -Throw

            ($computerobject, $computerobject | Get-PhysicalMemory | Measure-Object).count | Should -Be 4
        }

        It 'Should error with a bad computername' {
            { Get-PhysicalMemory -Computername 'F00' -ErrorAction stop } | Should -Throw
        }
    }

    Describe 'Get-TopProcessMemory' -Tags Functions {
        BeforeAll {
            $script:r = Get-TopProcessMemory -Computername $env:computername

        }
        It 'Should run without error' {
            { Get-TopProcessMemory -ErrorAction Stop } | Should -Not -Throw
        }


        It 'Should return 5 objects by default' {
            $r.count | Should -Be 5
        }
        It 'Should -Be a topProcessMemoryUnit object' {
            $r[0].PSObject.typenames[0] | Should -Be 'topProcessMemoryUnit'
        }

        It 'Should have an owner value' {
            ($r.owner | Measure-Object).Count | Should -BeGreaterThan 0
        }

        It 'Should have a computername property' {
            $r[0].computername | Should -Be $env:computername
        }

        It 'Should have a CreationDate property that is a [datetime]' {
            $r[0].CreationDate.GetType().Name | Should -Be 'datetime'
        }

        It 'Should return a specified number of processes' {
            (Get-TopProcessMemory -Top 7).Count | Should -Be 7
        }
        It 'Should accept multiple computernames' {
            $t = Get-TopProcessMemory -Computername $env:computername, $env:computername
            $t.count | Should -Be 10
        }

        It 'Should accept input by pipeline' {
            ($env:computername, $env:computername | Get-TopProcessMemory).Count | Should -Be 10
        }

        It 'Should accept input by property name via the pipeline' {
            ($computerobject | Get-TopProcessMemory).Count | Should -Be 5
        }

        It 'Should accept CIMSessions via the pipeline' {
            ($testSessions | Get-TopProcessMemory).count | Should -Be 10
        }
    }

    AfterAll {
        #clean up
        $testSessions | Remove-CimSession
    }

} #in module
