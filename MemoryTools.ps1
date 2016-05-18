#requires -version 4.0

#TO-DO
#TURN THIS INTO A MODULE
#create Test-memoryusage to run get-memory usage and test for a minimum %free, FreeGB, TotalGB or UsedGB
#create help

#region Define functions

Function Get-MemoryUsage {
[cmdletbinding()]
Param(
[Parameter(Position = 0,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername = $env:Computername
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
} #begin

Process {
foreach ($computer in $computername) {
    Write-Verbose "Processing $computer"
    Try {
        $os = Get-CimInstance Win32_OperatingSystem -ComputerName $Computer -ErrorAction stop
    }
    Catch {
        Write-Warning "[$($Computer.toUpper())] $($_.exception.message)"
    }
    if ($os) {
        $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
    
        if ($pctFree -ge 45) {
            $Status = "OK"
        }
        elseif ($pctFree -ge 15 ) {
            $Status = "Warning"
        }
        else {
            $Status = "Critical"
        }

        $os | Select @{Name="Computername";Expression={ $_.PSComputername.toUpper()}},
        @{Name = "Status";Expression = {$Status}},
        @{Name = "PctFree"; Expression =  {$pctFree}},
        @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
        @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}} 

        Clear-Variable OS
    } #if OS
} #foreach
} #process

End {
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end

} #end Get-MemoryUsage

Function Show-MemoryUsage {

[cmdletbinding()]
Param(
[Parameter(Position = 0,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername = $env:Computername
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    #a formatted report title
    $title = @"
****************
* Memory Check *
****************

"@

Write-Host $title -foregroundColor Cyan

} #begin

Process {
#foreach ($computer in $computername) {
    #get memory usage data
    $data = Get-MemoryUsage -Computername $computername
    #create a text table and split into an array based on each line
    $strings = ($data | Format-Table | Out-String).Trim().split("`n")
    #display the first two lines which should be the header
    $strings | select -first 2 | write-host -ForegroundColor Cyan
    #process remaining lines
    $strings | select -Skip 2 | foreach {
        #check for the status and select an appropriate color
        Switch -regex ($_) {
        "OK" { $color = "Green" }
        "Warning" { $color = "Yellow" }
        "Critical" {$color = "Red" }
        }
        #write the line with the corresponding alert color
        Write-Host $_ -ForegroundColor $color
    } 
 #} #foreach
} #Process

End {
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end

} #end Show-MemUsage

Function Get-MemoryPerformance {

[cmdletbinding()]
Param(
[Parameter(Position = 0,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername = $env:Computername
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    <#
        Get all memory performance counters. Assuming counters on the 
        client are the same as on the server. Sort by name.
    #>
    $all = (get-counter -ListSet Memory*).counter | Sort-Object
} #begin

Process {
    foreach ($computer in $computername) {
        Write-Verbose "Getting memory performance data from $Computer"
        Try {
            $data =  Get-Counter -Counter $all -computername $computer -ErrorAction Stop
            if ($data.CounterSamples) {
                $data.counterSamples | Select @{Name="Counter";Expression={ $_.path.Split("\")[-1]}},
                @{Name="Value";Expression={$_.cookedValue}} | foreach -begin {
             $h = [ordered]@{
              Computername = $computer.ToUpper()
              DateTime = (Get-Date)
              }
             } -process {
             #replace any / or - with spaces
             $rawname = $_.counter.replace("/"," ").replace("-"," ")
             #make proper case
             $proper = $rawname.split(" ").foreach({"$(([string]($_[0])).toUpper())$($_.substring(1))"})
             #join to new word
             $property = $proper -join ""
             #add to the hash table
             $h.Add($property,$_.Value)
            } -end {
                #turn the hashtable into an object
                [pscustomobject]$h
            }
            } #if data
        } #try
        Catch {
            Write-Error "Failed to get performance data from $($computer.toupper()). $($_.exception.message)"
        }
    } #foreach

} #process

End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
} #end
} #end Get-MemoryPerformance

Function Test-MemoryUsage {
#get-memory usage and test for a minimum %free, FreeGB, TotalGB or UsedGB
[cmdletbinding(DefaultParameterSetName="Percent")]
Param(
[Parameter(Position = 0,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername = $env:Computername,
[Parameter(ParameterSetName="Percent")]
[ValidateNotNullorEmpty()]
[int]$PercentFree = 50,
[Parameter(ParameterSetName="Free")]
[ValidateNotNullorEmpty()]
[double]$FreeGB,
[ValidateNotNullorEmpty()]
[Parameter(ParameterSetName="Total")]
[int]$TotalGB,
[Parameter(ParameterSetName="Used")]
[ValidateNotNullorEmpty()]
[double]$UsedGB,
[switch]$Quiet
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "Using parameter set $($PSCmdlet.ParameterSetName)"
     Switch ($PSCmdlet.ParameterSetName) {
            "Used"  { Write-Verbose "Testing if Used GB is >= to $UsedGB" }
            "Total" { Write-Verbose "Testing if Total size is >= $TotalGB"  }
            "Free"  { Write-Verbose "Testing if Free GB is >= $FreeGB" }
            "Percent"  { Write-Verbose "Testing if Percent free is >= $PercentFree" }
            } #switch
} #begin
Process {
    foreach ($computer in $computername) {
        Write-Verbose "Processing $computer"
        Try {
            $mem = Get-MemoryUsage -Computername $computer -ErrorAction Stop
            Switch ($PSCmdlet.ParameterSetName) {
            "Used"  {  
                        $used = $mem.TotalGB - $mem.FreeGB
                        if ($Used -ge $mem.usedGB) {
                            $Test = $True
                        }
                        else {
                            $Test = $False
                        }
                        $data = $mem | Select Computername,@{Name="UsedGB";Expression={$used}},
                        @{Name="Test";Expression={$test}}
                    }
            "Total" {
                        if ($mem.TotalGB -ge $TotalGB) {
                            $Test = $True
                        }
                        else {
                            $Test = $False
                        }
                        $data = $mem | Select Computername,TotalGB,@{Name="Test";Expression={$test}}
                    }
            "Free"  {
                        if ($FreeGB -le $mem.FreeGB) {
                            $Test = $True
                        }
                        else {
                            $Test = $False
                        }
                        $data = $mem | Select Computername,FreeGB,@{Name="Test";Expression={$test}}
                    }
            "Percent"  {
                        if ($mem.PctFree -ge $percentFree) {
                            $Test = $True
                        }
                        else {
                            $Test = $False
                        }
                        $data = $mem | Select Computername,PctFree,@{Name="Test";Expression={$test}}
                        }
            } #switch
            
            if ($Quiet) {
                $Test
            }
            else {
                $data
            }
        } #try
        Catch {
            Write-Warning "[$($Computer.toUpper())] $($_.exception.message)"
        }
    } #foreach
} #process
End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
} #end

} #end Test-MemoryUsage
#endregion

#define some aliases
Set-Alias -Name shmem -Value Show-MemoryUsage
Set-Alias -Name gmem -Value Get-MemoryUsage
Set-Alias -Name gmemp -Value Get-MemoryPerformance
Set-Alias -Name tmem -Value Test-MemoryUsage