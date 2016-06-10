#Pester Tests

#Show-MemoryUsage can't be tested because it doesn't write anything to the pipeline

Import-Module ..\MemoryTools

inModuleScope MemoryTools {

#create a sample object like something imported from a CSV file
    #or other command
    $computerObject = New-object -typename PSObject -property @{
      Computername = $env:computername
      Location = "Chicago"
      OS = "Windows Server 2012 R2"
    }
    
    #test with CimSessions
    $testSessions = New-CimSession -computername $env:computername,$env:computername

Describe "Module" {

    $mod = Get-Module MemoryTools
    It "Should have an 5 functions" {
       $mod.ExportedFunctions.count | Should Be 6
    }
    It "Should have 5 aliases" {
       $mod.ExportedAliases.count | Should Be 6
    }
    It "Should have Format ps1xml files" {
        $mod.ExportedFormatFiles.count | Should BeGreaterThan 0
    }
    
    It "Should have an integer value for `$MemoryToolsOK" {
        ($MemoryToolsOK).GetType().Name | Should be 'Int32'
    }

    It "Should have an integer value for `$MemoryToolsWarning" {
        ($MemoryToolsWarning).GetType().Name | Should be 'Int32'
    }

} #describe module

Describe "Get-MemoryUsage" -Tags Functions {

    <#
     I am mocking the results with known values. The tested command will actually
     use the localhost but the result will be mocked.
    #>

    Mock Get-CimInstance {
        $data = [pscustomobject]@{
        PSComputername = "WinTest"
        FreePhysicalMemory = 4194304
        TotalVisibleMemorySize = 8298776
        Caption = "Windows Server 2012 R2 Datacenter"
        }
        Return $Data
    } -ParameterFilter {$Classname -eq "Win32_OperatingSystem" }
    
    $try = Get-MemoryUsage -computername $env:computername  

    It "should run with defaults and without error" {
        {Get-MemoryUsage -ErrorAction stop } | Should not Throw
    }
    It "Should show status as OK" {
        $try.status | Should be "OK"
    }

    It "Should filter on Status" {
       (Get-MemoryUsage -computername $env:computername -status "OK" | measure-object).count | Should be 1
       (Get-MemoryUsage -computername $env:computername -status "Critical" | measure-object).count | Should be 0
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
    
        ("localhost","localhost","localhost" | Get-MemoryUsage | Measure-Object).count | Should be 3

        ($computerobject,$computerobject | Get-MemoryUsage | Measure-Object).count | Should be 2
      
    }

    It "Should error with a bad computername" {
        { Get-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should Throw
    }

    It "Should accept CIMSessions as a parameter value" {
        (Get-MemoryUsage -CimSession $testSessions | Measure-Object).Count | Should be 2
    }

    It "Should accept CIMSessions from the pipeline" {
        ($testSessions | Get-MemoryUsage | Measure-Object).Count | Should be 2
    }

 }
 
Describe "Test-MemoryUsage" -Tags Functions {       
 
     Mock Get-CimInstance {
        $data = [pscustomobject]@{
        PSComputername = "WinTest"
        FreePhysicalMemory = 4194304
        TotalVisibleMemorySize = 8298776
        Caption = "Windows Server 2012 R2 Datacenter"
        }
        Return $Data
    } -ParameterFilter {$Classname -eq "Win32_OperatingSystem" }
     
    Context "Test-MemoryUsage: Percent"  {
        $r = Test-Memoryusage -Computername $env:computername
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
      
            ($computerobject,$computerobject | Test-MemoryUsage | Measure-Object).count | Should be 2
      
        }
        It "Should error with a bad computername" {
            { Test-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should Throw
        }      
       
    } 

    Context "Test-MemoryUsage: Free" {
        $r = Test-Memoryusage -Computername $env:computername -freeGB 4
        
        It "Should have a Test value of $True" {
            $r.test | should be $True
        }
        It "Should have a FreeGB value of 4" {
            $r.FreeGB | Should Be 4
        }
    }
    
    Context "Test-MemoryUsage: Total" {
        $r = Test-Memoryusage -Computername $env:computername -TotalGB 8
        
        It "Should have a Test value of $True" {
            $r.test | should be $True
        }
        It "Should have a TotalGB value of 8" {
            $r.TotalGB | Should Be 8
        }
    }
    
    Context "Test-MemoryUsage: Used" {
        $r = Test-Memoryusage -Computername $env:computername -UsedGB 4
        
        It "Should have a Test value of $True" {
            $r.test | should be $True
        }
        It "Should have a UsedGB value of 4" {
            $r.UsedGB | Should Be 4
        }

    }
}

Describe "Get-MemoryPerformance" -Tags Functions {

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
            ($computerobject,$computerobject | Get-MemoryPerformance | Measure-Object).count | Should be 2
        }

        It "Should error with a bad computername" {
        { Get-MemoryPerformance -Computername 'F00' -ErrorAction stop } | Should Throw
    }

}

Describe "Get-PhysicalMemory" -Tags Functions {

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
        } -ParameterFilter {$Classname -eq "Win32_PhysicalMemory" } 

        It "Should run without error" {
         {Get-PhysicalMemory -errorAction Stop} | Should Not Throw
        }

        $r = Get-PhysicalMemory -computername $env:computername
        
        It "Should return 2 objects" {
         $r.count | should be 2
        }
        It "Should have a computername of WinTest" {
            $r[0].Computername | Should Be "WinTest"
        }

        It "Should have a form value of SODIMM" {
            $r[0].Form | Should Be "SODIMM"
        }

        It "Should have a capacity value of 16" {
            $r[0].CapacityGB | Should Be 16
        }
        It "Should have a clock speed of 2133" {
            $r[0].ClockSpeed | Should Be 2133
        }
        
        It "Should accept pipelined input" {
            { "localhost" | Get-PhysicalMemory -ErrorAction stop } | Should Not Throw
                
            ($computerobject,$computerobject | Get-PhysicalMemory | Measure-Object).count | Should be 4
        }

       It "Should error with a bad computername" {
        { Get-PhysicalMemory -Computername 'F00' -ErrorAction stop } | Should Throw
    }
 } 

Describe "Get-TopProcessMemory" -Tags Functions {
        It "Should run without error" {
         {Get-TopProcessMemory -errorAction Stop} | Should Not Throw
        }

        $r = Get-TopProcessMemory -computername $env:computername
        
        It "Should return 5 objects by default" {
         $r.count | should be 5
        }

        It "Should have an owner value" {
            ($r.owner | Measure-Object).Count | Should begreaterThan 0
        }

        It "Should have a computername property" {
            $r[0].computername | Should be $env:computername
        }

        It "Should have a CreationDate property that is a [datetime]" {
            $r[0].CreationDate.GetType().Name | Should be "datetime"
        }

        It "Should return a specified number of processes" {
          (Get-TopProcessMemory -Top 7).Count | Should Be 7
        }
        It "Should accept multiple computernames" {
          $t = Get-TopProcessMemory -Computername $env:computername,$env:computername
          $t.count | Should Be 10
        }

        It "Should accept input by pipeline" {
            ($env:computername,$env:computername | Get-TopProcessMemory).Count | Should Be 10
        }

        It "Should accept input by property name via the pipeline" {
            ($computerobject| Get-TopProcessMemory).Count | Should Be 5
        }

        It "Should accept CIMSessions via the pipeline" {
          ($testSessions | Get-TopProcessMemory).count | Should be 10
        }

 }

    #clean up
    $testSessions | Remove-CimSession

} #in module
