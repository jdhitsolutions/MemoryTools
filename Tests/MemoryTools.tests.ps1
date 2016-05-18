

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
           PSComputername = $env:computername
           FreePhysicalMemory = 4194304
           TotalVisibleMemorySize = 8298776
          }
          Return $Data
        } -ParameterFilter {$Classname -eq "Win32_OperatingSystem" -AND $Computername -eq $env:computername}
        
    $try = Get-MemoryUsage
    It "Should show status as OK" {
        $try.status | Should be "OK"
    }
    It "Should show computername as localhost [$env:computername]" {
        $try.computername | should be $env:computername
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
    }
    It "Should error with a bad computername" {
        { Get-MemoryUsage -Computername 'F00' -ErrorAction stop } | Should Throw
    }
    } #Get-MemoryUsage

} #in module
