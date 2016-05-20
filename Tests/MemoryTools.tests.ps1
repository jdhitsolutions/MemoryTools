#Pester Tests

#Show-MemoryUsage can't be tested because it doesn't write anything to the pipeline

Import-Module ..\MemoryTools

inModuleScope MemoryTools {

Describe "MemoryTools Module" {

    $mod = Get-Module MemoryTools
    It "Should have an 5 functions" {
       $mod.ExportedFunctions.count | Should Be 5
    }
    It "Should have 5 aliases" {
       $mod.ExportedAliases.count | Should Be 5
    }
    It "Should have Format ps1xml files" {
        $mod.ExportedFormatFiles.count | Should BeGreaterThan 0
    }
    
} #describe module

  
Describe "MemoryTools Functions" -Tags Functions  {
    Mock Get-CimInstance {
        $data = [pscustomobject]@{
        PSComputername = "WinTest"
        FreePhysicalMemory = 4194304
        TotalVisibleMemorySize = 8298776
        }
        Return $Data
    } -ParameterFilter {$Classname -eq "Win32_OperatingSystem" -AND $Computername -eq "WinTest"}

    $try = Get-MemoryUsage -computername WinTest
    Context "Get-MemoryUsage " {
    It "should run with defaults and without error" {
        {Get-MemoryUsage -ErrorAction stop } | Should not Throw
    }
    It "Should show status as OK" {
        $try.status | Should be "OK"
    }
    It "Should show computername as WinTest" {
        $try.computername | should be "WinTest"
    }
    It "Should show total as 8" {
        $try.TotalGB | Should be 8
    }
    It "Should show PctFree as 51" {
        $try.pctFree -as [int] | Should be 51
    }
    It "Should show Free as 4" {
        $try.FreeGB | Should be 4
    }
    It "Should have a type of MyMemoryUsage" {
        $try.psobject.TypeNames[0] | should be "MyMemoryUsage"
    }
    It "Should accept pipelined input" {
        { "localhost" | Get-MemoryUsage -ErrorAction stop } | Should Not Throw
    
        ("localhost","localhost","localhost" | Get-MemoryUsage | measure-object).count | Should be 3
      
    }
    It "Should error with a bad computername" {
        { Get-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should Throw
    }
    } #Get-MemoryUsage

        
    Context "Test-MemoryUsage: Percent"  {
        $r = Test-Memoryusage -Computername WinTest
        It "Should run with defaults and without error" {
            {Test-MemoryUsage -ErrorAction Stop} | Should Not Throw
        }    

        It "Should have a Test value of $True" {        
            $r.Test | Should Be $True
        }
        It "Should have a value >= 50 " {
            $r.PctFree | should begreaterthan 50
        }
       It "Should accept pipelined input" {
            { "localhost" | Test-MemoryUsage -ErrorAction stop -quiet} | Should Not Throw
    
            ("localhost","localhost","localhost" | Test-MemoryUsage -quiet | measure-object).count | Should be 3
      
            }
           It "Should error with a bad computername" {
            { Test-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should Throw
        }      
       
    } #Test-MemoryUsage

    Context "Test-MemoryUsage: Free" {
        $r = Test-Memoryusage -Computername WinTest -freeGB 4
        
        It "Should have a Test value of $True" {
            $r.test | should be $True
        }
        It "Should have a FreeGB value of 4" {
            $r.FreeGB | Should Be 4
        }
    }
    
    Context "Test-MemoryUsage: Total" {
        $r = Test-Memoryusage -Computername WinTest -TotalGB 8
        
        It "Should have a Test value of $True" {
            $r.test | should be $True
        }
        It "Should have a TotalGB value of 8" {
            $r.TotalGB | Should Be 8
        }
    }
    
      Context "Test-MemoryUsage: Used" {
        $r = Test-Memoryusage -Computername WinTest -UsedGB 4
        
        It "Should have a Test value of $True" {
            $r.test | should be $True
        }
        It "Should have a UsedGB value of 4" {
            $r.UsedGB | Should Be 4
        }

    }

    Context "Get-MemoryPerformance" {
        It "Should run with defaults and without error" {
            {Get-MemoryPerformance -ErrorAction Stop} | Should Not Throw
        }
        
        $r = Get-MemoryPerformance

        It "Should have a computername equal to `$env:computername" {
            $r.computername | should be $env:COMPUTERNAME
        }

        It "should have a datetime of today" {
            $today = (Get-Date)
            $r.datetime.hour | should be $today.Hour
            $r.datetime.Day | should be $today.Day
            $r.datetime.month | should be $today.Month
        }

        It "should have available bytes" {
            $r.AvailableBytes | Should BeGreaterThan 0
        }

        It "Should accept pipelined input" {
        { "localhost" | Get-MemoryPerformance -ErrorAction stop } | Should Not Throw
    
        ("localhost","localhost","localhost" | Get-MemoryPerformance | measure-object).count | Should be 3
      
        }
       It "Should error with a bad computername" {
        { Get-MemoryPerformance -Computername 'F00' -ErrorAction stop } | Should Throw
    }
    } #Get-MemoryPerformance
    Context "Get-PhysicalMemory" {
        Mock Get-CimInstance {
            $data = @(
                [pscustomobject]@{
                PSComputername = "WinTest"
                Manufacturer = 0420
                Capacity = 16GB
                FormFactor = 12
                ConfiguredClockSpeed = 2133
                ConfiguredVoltage = 1200
                DeviceLocator = "ChannelA-DIMM0"
                },
                [pscustomobject]@{
                PSComputername = "WinTest"
                Manufacturer = 0420
                Capacity = 16GB
                FormFactor = 12
                ConfiguredClockSpeed = 2133
                ConfiguredVoltage = 1200
                DeviceLocator = "ChannelA-DIMM1"
                })
            Return $Data
        } -ParameterFilter {$Classname -eq "Win32_PhysicalMemory" -AND $Computername -eq "WinTest"}

        It "Should run without error" {
         {Get-PhysicalMemory -errorAction Stop} | Should Not Throw
        }

        $r = Get-PhysicalMemory -computername WinTest
        
        It "Should return 2 objects" {
         $r.count | should be 2
        }
        It "Should have a computername of WinTest" {
            $r[0].Computername | Should Be "WinTest"
        }

        It "Should have a Form of SODIMM" {
            $r[0].Form | Should Be "SODIMM"
        }

        It "Should have a Capacity of 16" {
            $r[0].CapacityGB | Should Be 16
        }
        It "Should have a clock speed of 2133" {
            $r[0].ClockSpeed | Should Be 2133
        }
     
        It "Should accept pipelined input" {
        { "localhost" | Get-PhysicalMemory -ErrorAction stop } | Should Not Throw
    
        ("WinTest","WinTest","WinTest" | Get-PhysicalMemory | measure-object).count | Should be 6
      
        }
       It "Should error with a bad computername" {
        { Get-PhysicalMemory -Computername 'F00' -ErrorAction stop } | Should Throw
    }
    }
  } #functions
} #in module
