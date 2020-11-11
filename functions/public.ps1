
Function Get-MemoryUsage {
    [cmdletbinding(DefaultParameterSetName = 'Computername')]
    [OutputType("MyMemoryUsage")]
    [alias("gmem")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [string[]]$Computername = $env:Computername,

        [ValidateSet("All", "OK", "Warning", "Critical")]
        [string]$Status = "All",

        [Parameter(ParameterSetName = 'Cim', Mandatory, ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
        $MyCimSession = @()
    } #begin

    Process {
        Write-Verbose "[PROCESS] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($pscmdlet.ParameterSetName -eq 'Computername') {
            #create a temporary cimsession if using a computername
            foreach ($item in $Computername) {
                Try {
                    Write-Verbose "[PROCESS] Creating temporary CIM Session to $item"
                    $MyCIMSession += New-CimSession -ComputerName $item -ErrorAction Stop -OutVariable +tmpcs
                    $tmpSession = $True
                    Write-Verbose "[PROCESS] Added session"
                }
                Catch {
                    Write-Error "[$($item.toUpper())] Failed to create temporary CIM Session. $($_.exception.message)"
                }
            } #foreach item in computername
        } #if computername parameter set
        else {
            Write-Verbose "[PROCESS] Re-using CimSessions"
            $MyCIMSession = $CimSession
        }

        foreach ($session in $MyCIMSession) {

            Write-Verbose "[PROCESS] Processing $($session.computername) with session ID $($session.ID)"

            Try {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session -ErrorAction stop
            }
            Catch {
                Write-Error "[$($session.Computername.toUpper())] Failed to retrieve data. $($_.exception.message)"
            }
            if ($os) {
                # Determine if Dynamic Memory is used
                $MaxDynamicMemory = (Get-Counter -Counter "\Hyper-V Dynamic Memory Integration Service\Maximum Memory, Mbytes" -ComputerName $os.PSComputerName -ErrorAction SilentlyContinue).CounterSamples.CookedValue * 1KB

                # Determine the amount of free memory
                if ($MaxDynamicMemory) {
                    $FreeMemory = $os.FreePhysicalMemory + ($MaxDynamicMemory - $os.TotalVisibleMemorySize)
                    $TotalMemory = $MaxDynamicMemory
                }
                else {
                    $FreeMemory = $os.FreePhysicalMemory
                    $TotalMemory = $os.TotalVisibleMemorySize
                }

                $pctFree = [math]::Round(($FreeMemory / $TotalMemory) * 100, 2)

                if ($pctFree -ge $MemoryToolsOK) {
                    $StatusProperty = "OK"
                }
                elseif ($pctFree -ge $MemoryToolsWarning ) {
                    $StatusProperty = "Warning"
                }
                else {
                    #anything else is considered critical
                    $StatusProperty = "Critical"
                }

                $obj = [PSCustomObject]@{
                    PSTypename   = "MyMemoryUsage"
                    Computername = $OS.PSComputername.ToUpper()
                    Status       = $StatusProperty
                    PctFree      = $pctFree
                    FreeGB       = [math]::Round($FreeMemory / 1mb, 2)
                    TotalGB      = [int]($TotalMemory / 1mb)
                }

                #write object to the pipeline
                if ($Status -eq 'All') {
                    $obj
                }
                else {
                    #write filtered results
                    $obj | Where-Object { $_.Status -match $Status }
                }
                #reset variables erring on the side of caution
                Clear-Variable OS, obj, Mycimsession

            } #if OS

        } #foreach

        #clean up temporary sessions
        if ($tmpSession) {
            Write-Verbose "[PROCESS] Removing temporary sessions"
            $tmpcs | Out-String | Write-Verbose
            $tmpcs | Remove-CimSession
            Remove-Variable -name tmpcs
        }
    } #process

    End {
        Write-Verbose "[END    ] $($MyInvocation.Mycommand)"
    } #end

} #end Get-MemoryUsage

Function Show-MemoryUsage {

    [cmdletbinding(DefaultParameterSetName = 'Computername')]
    [alias("shmem")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [string[]]$Computername = $env:Computername,

        [Parameter(ParameterSetName = 'Cim', Mandatory, ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

        #a formatted report title
        $title = @"

    ****************
      Memory Check
    ****************
"@

        "$([char]0x1b)[38;5;159m$Title$([char]0x1b)[0m"
        # Write-Host $title -ForegroundColor Cyan

        #initialize an array to hold data
        $data = @()
    } #begin

    Process {
        Write-Verbose "[PROCESS] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($pscmdlet.ParameterSetName -eq 'Computername') {
            foreach ($Computer in $Computername) {
                #get memory usage data for each computer
                $data += Get-MemoryUsage -Computername $computer
            }
        }
        else {
            foreach ($session in $CIMSession) {
                #get memory usage data for each computer
                $data += Get-MemoryUsage -CimSession $session
            }
        }
    } #Process

    End {
        #format the results using a custom formatting view
        $data | Format-Table -View show
        Write-Verbose "[END    ] $($MyInvocation.Mycommand)"
    } #end

} #end Show-MemoryUsage

#get-memory usage and test for a minimum %free, FreeGB, TotalGB or UsedGB
Function Test-MemoryUsage {
    [cmdletbinding(DefaultParameterSetName = 'PercentComputer')]
    [alias("tmem")]
    [OutputType("Boolean", "PSCustomObject")]
    Param(
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "PercentComputer")]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "FreeComputer")]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "TotalComputer")]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "UsedComputer")]
        [string[]]$Computername = $env:Computername,

        [Parameter(Mandatory, ParameterSetName = "PercentCIM")]
        [Parameter(Mandatory, ParameterSetName = "FreeCIM")]
        [Parameter(Mandatory, ParameterSetName = "TotalCIM")]
        [Parameter(Mandatory, ParameterSetName = "UsedCIM")]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession,

        [Parameter(HelpMessage = "Enter the minimum % free memory", ParameterSetName = "PercentComputer")]
        [Parameter(HelpMessage = "Enter the minimum % free memory", ParameterSetName = "PercentCIM")]
        [ValidateNotNullorEmpty()]
        [int]$PercentFree = 50,

        [Parameter(HelpMessage = "Enter the minimum free memory in GB", Mandatory, ParameterSetName = "FreeComputer")]
        [Parameter(HelpMessage = "Enter the minimum free memory in GB", Mandatory, ParameterSetName = "FreeCIM")]
        [ValidateNotNullorEmpty()]
        [double]$FreeGB,

        [ValidateNotNullorEmpty()]
        [Parameter(HelpMessage = "Enter the minimum total memory in GB", Mandatory, ParameterSetName = "TotalComputer")]
        [Parameter(HelpMessage = "Enter the minimum total memory in GB", Mandatory, ParameterSetName = "TotalCIM")]
        [int]$TotalGB,

        [Parameter(HelpMessage = "Enter the minimum amount of used memory in GB", Mandatory, ParameterSetName = "UsedComputer")]
        [Parameter(HelpMessage = "Enter the minimum amount of used memory in GB", Mandatory, ParameterSetName = "UsedCIM")]
        [ValidateNotNullorEmpty()]
        [double]$UsedGB,

        [switch]$Quiet
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
    } #begin

    Process {
        Write-Verbose "[PROCESS] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        if ($Computername) {
            $usage = foreach ($Computer in $Computername) {
                #get memory usage data for each computer
                Get-MemoryUsage -Computername $computer
            }
        }
        else {
            $usage = foreach ($session in $CIMSession) {
                #get memory usage data for each computer
                Get-MemoryUsage -CimSession $session
            }
        }

        Foreach ($mem in $usage) {

            Switch -regex ($PSCmdlet.ParameterSetName) {
                "Used" {
                    Write-Verbose "[PROCESS] Testing if Used GB is >= to $UsedGB"
                    $used = $mem.TotalGB - $mem.FreeGB
                    Write-Verbose "[PROCESS] Used = $used"
                    if ($Used -ge $usedGB) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select-Object Computername, @{Name = "UsedGB"; Expression = { $used } },
                    @{Name = "Test"; Expression = { $test } }
                }
                "Total" {
                    Write-Verbose "[PROCESS] Testing if Total size is >= $TotalGB"
                    if ($mem.TotalGB -ge $TotalGB) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select-Object Computername, TotalGB, @{Name = "Test"; Expression = { $test } }
                }
                "Free" {
                    Write-Verbose "[PROCESS] Testing if Free GB is >= $FreeGB"
                    if ($FreeGB -le $mem.FreeGB) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select-Object Computername, FreeGB, @{Name = "Test"; Expression = { $test } }
                }
                "Percent" {
                    Write-Verbose "[PROCESS] Testing if Percent free is >= $PercentFree"
                    if ($mem.PctFree -ge $percentFree) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select-Object Computername, PctFree, @{Name = "Test"; Expression = { $test } }
                }
            } #switch

            if ($Quiet) {
                $Test
            }
            else {
                $data
            }
        } #foreach $mem

    } #process
    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

} #end Test-MemoryUsage

Function Get-MemoryPerformance {

    [cmdletbinding(DefaultParameterSetName = "Computername")]
    [alias("gmemp")]
    [OutputType("Selected.Microsoft.Management.Infrastructure.CimInstance")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [string[]]$Computername = $env:Computername,

        [Parameter(
            ParameterSetName = 'Cim',
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNullorEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
        <#
        Get all memory performance counters. Assuming counters on the
        client are the same as on the server. Sort by name.
        #>
        $all = (Get-Counter -ListSet Memory*).counter | Sort-Object

        #get a list of class properties. Some of the properties don't
        #appear to have any values and are different than what you get
        #with Get-Counter
        $perfclass = Get-CimClass -ClassName Win32_PerfFormattedData_PerfOS_Memory
        $selected = $perfclass.CimClassProperties | Select-Object -Skip 9 -ExpandProperty Name
        $selected += @{Name = "DateTime"; Expression = { (Get-Date) } }
        $selected += @{Name = "ComputerName"; Expression = { $session.ComputerName } }
        Write-Verbose "[BEGIN  ] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)
    } #begin

    Process {

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($pscmdlet.ParameterSetName -eq 'Computername') {
            #create a temporary cimsession if using a computername
            $MyCIMSession = foreach ($item in $Computername) {
                Try {
                    Write-Verbose "[PROCESS] Creating temporary CIM Session to $item"
                    New-CimSession -ComputerName $item -ErrorAction Stop -OutVariable +tmpSess
                    Write-Verbose "[PROCESS] Added session"
                }
                Catch {
                    Write-Error "[$($item.toUpper())] Failed to create temporary CIM Session. $($_.exception.message)"
                }
            } #foreach item in computername
        } #if computername parameter set
        else {
            Write-Verbose "[PROCESS] Re-using CimSessions"
            $MyCimSession = $CimSession
        }

        foreach ($session in $MyCIMSession) {
            Try {
                Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Memory -CimSession $session |
                    Select-Object -Property $selected
            } #try
            Catch {
                Write-Error "Failed to get performance data from $($session.computername.toupper()). $($_.exception.message)"
            }
        } #foreach

        #clean up
        if ($tmpSess) {
            Write-Verbose "[PROCESS] Removing temporary sessions"
            $tmpSess | Remove-CimSession
            Remove-Variable tmpsess
        }

    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end
} #end Get-MemoryPerformance
Function Get-PhysicalMemory {

    [cmdletbinding(DefaultParameterSetName = "Computername")]
    [alias("gpmem")]
    [OutputType("physicalMemoryUnit")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [string[]]$Computername = $env:Computername,

        [Parameter(
            ParameterSetName = 'Cim',
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNullorEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
        Write-Verbose "[BEGIN  ] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        #define a hash table to resolve Form factor
        $form = @{
            0  = 'Unknown'
            1  = 'Other'
            2  = 'SIP'
            3  = 'DIP'
            4  = 'ZIP'
            5  = 'SOJ'
            6  = 'Proprietary'
            7  = 'SIMM'
            8  = 'DIMM'
            9  = 'TSOP'
            10 = 'PGA'
            11 = 'RIMM'
            12 = 'SODIMM'
            13 = 'SRIMM'
            14 = 'SMD'
            15 = 'SSMP'
            16 = 'QFP'
            17 = 'TQFP'
            18 = 'SOIC'
            19 = 'LCC'
            20 = 'PLCC'
            21 = 'BGA'
            22 = 'FPBGA'
            23 = 'LGA'
        }

    } #begin

    Process {

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($pscmdlet.ParameterSetName -eq 'Computername') {
            #create a temporary cimsession if using a computername
            $MyCIMSession = foreach ($item in $Computername) {
                Try {
                    Write-Verbose "[PROCESS] Creating temporary CIM Session to $item"
                    New-CimSession -ComputerName $item -ErrorAction Stop -OutVariable +tmpSess
                    Write-Verbose "[PROCESS] Added session"
                }
                Catch {
                    Write-Error "[$($item.toUpper())] Failed to create temporary CIM Session. $($_.exception.message)"
                }
            } #foreach item in computername
        } #if computername parameter set
        else {
            Write-Verbose "[PROCESS] Re-using CimSessions"
            $MyCimSession = $CimSession
        }

        foreach ($session in $MyCIMSession) {
            Write-Verbose "[PROCESS] Processing $($session.computername)"
            Try {
                $data = Get-CimInstance -ClassName win32_physicalmemory -CimSession $session -ErrorAction Stop

            } #Try
            Catch {
                Write-Error "[$($Session.ComputerName.toUpper())] $($_.exception.message)"
            }
            if ($data) {
                #create a custom object
                foreach ($item in $data) {
                    [pscustomobject]@{
                        PSTypeName   = "physicalMemoryUnit"
                        Computername = $item.PSComputername.ToUpper()
                        Manufacturer = $item.Manufacturer
                        CapacityGB   = $item.Capacity / 1GB
                        Form         = $form.item($item.FormFactor -as [int])
                        ClockSpeed   = $item.ConfiguredClockSpeed
                        Voltage      = $item.ConfiguredVoltage
                        Location     = $item.DeviceLocator
                    }
                }
            }
        } #foreach
        #clean up
        if ($tmpSess) {
            Write-Verbose "[PROCESS] Removing temporary sessions"
            $tmpSess | Remove-CimSession
            Remove-Variable tmpsess
        }
    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

} #get-PhysicalMemory

Function Get-TopProcessMemory {

    [cmdletbinding(DefaultParameterSetName = "Computername")]
    [alias("gtop")]
    [OutputType("topProcessMemoryUnit")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [string[]]$Computername = $env:Computername,

        [Parameter(
            ParameterSetName = 'Cim',
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNullorEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession,

        [validateRange(1, 25)]
        [int]$Top = 5
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

        #a private function to get process owner
        function _getProcessOwner {
            [cmdletbinding()]
            Param([object]$CimProcess)
            $own = $cimProcess | Invoke-CimMethod -MethodName GetOwner
            "$($own.domain)\$($own.user)"
        }
    } #Begin

    Process {
        Write-Verbose "[PROCESS] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($pscmdlet.ParameterSetName -eq 'Computername') {
            #create a temporary cimsession if using a computername
           $myCIMSession = foreach ($item in $Computername) {
                Try {
                    Write-Verbose "[PROCESS] Creating temporary CIM Session to $item"
                    New-CimSession -ComputerName $item -ErrorAction Stop -OutVariable +tmpSess
                    Write-Verbose "[PROCESS] Added session"
                }
                Catch {
                    Write-Error "[$($item.toUpper())] Failed to create temporary CIM Session. $($_.exception.message)"
                }
            } #foreach item in computername
        } #if computername parameter set
        else {
            Write-Verbose "[PROCESS] Re-using CimSessions"
            $MyCimSession = $CimSession
        }

        foreach ($session in $MyCIMSession) {
            Write-Verbose "[PROCESS] SessionID = $($session.ID)"
            Try {
                Write-Verbose "[PROCESS] Querying $($session.computername.ToUpper())"
                $data = Get-CimInstance -ClassName win32_process -CimSession $session -ErrorAction Stop | Sort-Object WorkingSetSize -Descending | Select-Object -First $Top
            } #Try
            Catch {
                Write-Error "[$($Session.Computername.toUpper())] $($_.exception.message)"
            } #Catch
            if ($data) {
                #get overall memory usage
                $mu = Get-MemoryUsage -CimSession $session
                [int64]$used = ($mu.totalGB - $mu.FreeGB) * 1gb

                Foreach ($item in $data) {
                    [PSCustomObject]@{
                        PSTypename   = "topProcessMemoryUnit"
                        Computername = $item.PSComputername.ToUpper()
                        ProcessID    = $item.ProcessID
                        Name         = $item.Name
                        WS           = $item.WorkingSetSize
                        PctUsed      = [math]::Round(($item.workingsetsize /$used) * 100, 4)
                        CreationDate = $item.CreationDate
                        Runtime      = (Get-Date) - $item.CreationDate
                        Owner        = $(_getProcessOwner $item)
                        Commandline  = $item.Commandline
                    }
                }
            }
        } #foreach
        #clean up
        if ($tmpSess.count -gt 0) {
            Write-Verbose "[PROCESS] Removing temporary sessions"
            $tmpSess | out-string | Write-Verbose
            $tmpSess | Remove-CimSession
            Remove-Variable -name tmpSess -Force
        }
    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end
} #end function

