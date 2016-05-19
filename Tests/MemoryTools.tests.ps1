
#Show-MemoryUsage can't be tested because it doesn't write anything to the pipeline

Import-Module ..\MemoryTools

inModuleScope MemoryTools {
Describe "MemoryTools Module" {
    It "Should have an 4 functions" {
       ((Get-Module MemoryTools).ExportedFunctions).count | Should Be 4
    }
    It "Should have 4 aliases" {
       (Get-Module MemoryTools).ExportedAliases.count | Should Be 4

    }
} #describe module

Describe "Get-MemoryUsage" -Tags "Get" {
    Mock Get-CimInstance {
           $data = [pscustomobject]@{
           PSComputername = "WinTest"
           FreePhysicalMemory = 4194304
           TotalVisibleMemorySize = 8298776
          }
          Return $Data
        } -ParameterFilter {$Classname -eq "Win32_OperatingSystem" -AND $Computername -eq "WinTest"}
        
    $try = Get-MemoryUsage -computername WinTest
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

Describe "Test-MemoryUsage" -Tags Test {
    It "Should run with defaults and without error" {
        {Test-MemoryUsage -ErrorAction Stop} | Should Not Throw
    }
    

} #Test-MemoryUsage

Describe "Get-MemoryPerformance" {
    It "Should run with defaults and without error" {
        {Get-MemoryPerformance -ErrorAction Stop} | Should Not Throw
    }
} #Get-MemoryPerformance

} #in module
