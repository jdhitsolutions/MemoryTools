#requires -version 4.0

#region Define functions

Function Get-MemoryUsage {
[cmdletbinding(DefaultParameterSetName='ComputernameSet')]
Param(
[Parameter(
 Position = 0,
 ValueFromPipeline,
 ValueFromPipelineByPropertyName,
 ParameterSetName='ComputernameSet'
 )]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername = $env:Computername,

[ValidateSet("All","OK","Warning","Critical")]
[string]$Status = "All",

[Parameter(ParameterSetName='CimInstanceSessionSet', Mandatory, ValueFromPipeline)]
[Microsoft.Management.Infrastructure.CimSession[]]$CimSession
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "Using parameter set $($PSCmdlet.ParameterSetName)"
    Write-Verbose "PSBoundParameters"
    Write-Verbose ($PSBoundParameters | Out-String)

    $MyCimSession=@()
} #begin

Process {

 Write-Verbose "Using parameter set $($PSCmdlet.ParameterSetName)"

 if ($pscmdlet.ParameterSetName -eq 'ComputerNameSet') {
     #create a temporary cimsession if using a computername
     foreach ($item in $Computername) {
     Try {
        Write-Verbose "Creating temporary CIM Session to $item"
        $MyCIMSession += New-CimSession -ComputerName $item -ErrorAction Stop -OutVariable +tmpSess
        Write-Verbose "Added session"
     }
     Catch {
        Write-Error "[$($item.toUpper())] Failed to create temporary CIM Session. $($_.exception.message)"
     }
    } #foreach item in computername
 } #if computername parameter set
 else {
    Write-Verbose "Re-using CimSessions"
    $MyCimSession = $CimSession
 }

foreach ($session in $MyCIMSession) {
 
    Write-Verbose "Processing $($session.computername)"  

    Try {
        $os = Get-CimInstance -classname Win32_OperatingSystem -CimSession $session -ErrorAction stop
    }
    Catch {
        Write-Error "[$($session.Computername.toUpper())] Failed to retrieve data. $($_.exception.message)"
    }
    if ($os) {
        $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
    
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

        $obj = $os | Select @{Name="Computername";Expression={ $_.PSComputername.toUpper()}},
        @{Name = "Status";Expression = {$StatusProperty}},
        @{Name = "PctFree"; Expression =  {$pctFree}},
        @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
        @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}} 

        #add a custom type name
        $obj.psobject.typenames.insert(0,"MyMemoryUsage")

        #write object to the pipeline
        if ($Status -eq 'All') {
            $obj
        }
        else {
            #write filtered results
            $obj | Where {$_.Status -match $Status}
        }
        #reset variables just in case
        Clear-Variable OS,obj,Mycimsession

    } #if OS
       
} #foreach

 #clean up
    if ($tmpSess) {
        Write-Verbose "Removing temporary sessions"
        $tmpSess | out-string | write-Verbose
        $tmpSess | Remove-CimSession
        remove-Variable tmpsess
        get-cimsession | out-string | write-verbose
    }
} #process

End {
    
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end

} #end Get-MemoryUsage

Function Show-MemoryUsage {

[cmdletbinding(DefaultParameterSetName='ComputernameSet')]
Param(
[Parameter(
 Position = 0,
 ValueFromPipeline,
 ValueFromPipelineByPropertyName,
 ParameterSetName='ComputernameSet'
 )]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername = $env:Computername,

[Parameter(ParameterSetName='CimInstanceSessionSet', Mandatory, ValueFromPipeline)]
[Microsoft.Management.Infrastructure.CimSession[]]$CimSession
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "PSBoundParameters"
    Write-Verbose ($PSBoundParameters | Out-String)

    #a formatted report title
    $title = @"

****************
* Memory Check *
****************

"@

Write-Host $title -foregroundColor Cyan

    #initialize an array to hold data
    $data = @()
} #begin

Process {

 Write-Verbose "Using parameter set $($PSCmdlet.ParameterSetName)"

 if ($pscmdlet.ParameterSetName -eq 'ComputerNameSet') {
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
<#
foreach ($item in $computername) {

    if ($item.computername -is [string]) {
        Write-Verbose "Using Computername property"
        $computer = $item.Computername
    }
    else {
        $computer = $item
    }

    #get memory usage data for each computer
    $data += Get-MemoryUsage -Computername $computer
    
 } #foreach
 #>

} #Process

End {
    #write results to the host
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
   } #foreach string
    #write an extra blank line 
    write-Host "`n"
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end

} #end Show-MemoryUsage

Function Get-MemoryPerformance {

[cmdletbinding()]
Param(
[Parameter(
 Position = 0,
 ValueFromPipeline,
 ValueFromPipelineByPropertyName
 )]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[object[]]$Computername = $env:Computername
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    <#
        Get all memory performance counters. Assuming counters on the 
        client are the same as on the server. Sort by name.
    #>
    $all = (get-counter -ListSet Memory*).counter | Sort-Object
    Write-Verbose "PSBoundParameters"
    Write-Verbose ($PSBoundParameters | Out-String)
} #begin

Process {
foreach ($item in $computername) {

    if ($item.computername -is [string]) {
        Write-Verbose "Using Computername property"
        $computer = $item.Computername
    }
    else {
        $computer = $item
    }
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
[cmdletbinding(DefaultParameterSetName='PercentComputer')]
Param(
[ValidateNotNullorEmpty()]
[Alias("cn")]
[Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName="PercentComputer")]
[Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName="FreeComputer")]
[Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName="TotalComputer")]
[Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName="UsedComputer")]
[string[]]$Computername = $env:Computername,

[Parameter(mandatory,ParameterSetName="PercentCIM")]
[Parameter(mandatory,ParameterSetName="FreeCIM")]
[Parameter(mandatory,ParameterSetName="TotalCIM")]
[Parameter(mandatory,ParameterSetName="UsedCIM")]
[Microsoft.Management.Infrastructure.CimSession[]]$CimSession,


[Parameter(HelpMessage = "Enter the minimum % free memory",ParameterSetName="PercentComputer")]
[Parameter(HelpMessage = "Enter the minimum % free memory",ParameterSetName="PercentCIM")]
[ValidateNotNullorEmpty()]
[int]$PercentFree = 50,

[Parameter(HelpMessage = "Enter the minimum free memory in GB",Mandatory,ParameterSetName="FreeComputer")]
[Parameter(HelpMessage = "Enter the minimum free memory in GB",Mandatory,ParameterSetName="FreeCIM")]
[ValidateNotNullorEmpty()]
[double]$FreeGB,

[ValidateNotNullorEmpty()]
[Parameter(HelpMessage = "Enter the minimum total memory in GB",Mandatory,ParameterSetName="TotalComputer")]
[Parameter(HelpMessage = "Enter the minimum total memory in GB",Mandatory,ParameterSetName="TotalCIM")]
[int]$TotalGB,

[Parameter(HelpMessage = "Enter the minimum amount of used memory in GB",Mandatory,ParameterSetName="UsedComputer")]
[Parameter(HelpMessage = "Enter the manimum amount of used memory in GB",Mandatory,ParameterSetName="UsedCIM")]
[ValidateNotNullorEmpty()]
[double]$UsedGB,

[switch]$Quiet
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
   
    Write-Verbose "PSBoundParameters"
    Write-Verbose ($PSBoundParameters | Out-String)
} #begin

Process {

if ($Computername) {
    $usage = foreach ($Computer in $Computername) {
        #get memory usage data for each computer
        Get-MemoryUsage -Computername $computer
    }
  }
else {
    $usage = foreach ($session in $CIMSession) {
        #get memory usage data for each computer
        Get-MemoryUsage -CimSession $session -ErrorAction
    }
}

Foreach ($mem in $usage) {    
    
        Switch -regex ($PSCmdlet.ParameterSetName) {
        "Used"  {  
                Write-Verbose "Testing if Used GB is >= to $UsedGB" 
                    $used = $mem.TotalGB - $mem.FreeGB
                    Write-Verbose "Used = $used"
                    if ($Used -ge $usedGB) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select Computername,@{Name="UsedGB";Expression={$used}},
                    @{Name="Test";Expression={$test}}
                }
        "Total" {
                Write-Verbose "Testing if Total size is >= $TotalGB"
                    if ($mem.TotalGB -ge $TotalGB) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select Computername,TotalGB,@{Name="Test";Expression={$test}}
                }
        "Free"  {
                Write-Verbose "Testing if Free GB is >= $FreeGB"
                    if ($FreeGB -le $mem.FreeGB) {
                        $Test = $True
                    }
                    else {
                        $Test = $False
                    }
                    $data = $mem | Select Computername,FreeGB,@{Name="Test";Expression={$test}}
                }
        "Percent"  {
                Write-Verbose "Testing if Percent free is >= $PercentFree"
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
 } #foreach $mem

} #process
End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
} #end

} #end Test-MemoryUsage

Function Get-PhysicalMemory {

[cmdletbinding()]
Param(
[Parameter(
 Position = 0,
 ValueFromPipeline,
 ValueFromPipelineByPropertyName
 )]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[object[]]$Computername = $env:Computername
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "PSBoundParameters"
    Write-Verbose ($PSBoundParameters | Out-String)
    
    #define a hash table to resolve Form factor
    $form = @{
    0 = 'Unknown'
    1 = 'Other'
    2 = 'SIP'
    3 = 'DIP'
    4 = 'ZIP'
    5 = 'SOJ'
    6 = 'Proprietary'
    7 = 'SIMM'
    8 = 'DIMM'
    9 = 'TSOP'
    10 ='PGA'
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
foreach ($item in $computername) {

    if ($item.computername -is [string]) {
        Write-Verbose "Using Computername property"
        $computer = $item.Computername
    }
    else {
        $computer = $item
    }
        Try {
        Get-CimInstance win32_physicalmemory -computername $computer | 
        Select @{Name="Computername";Expression={$_.PSComputername.ToUpper()}},
        Manufacturer,@{Name="CapacityGB";Expression={$_.Capacity/1GB}},
        @{Name="Form";Expression={$form.item($_.FormFactor -as [int])}},
        @{Name="ClockSpeed";Expression={$_.ConfiguredClockSpeed}},
        @{Name="Voltage";Expression={$_.ConfiguredVoltage}},DeviceLocator 
        } #Try
        Catch {
         Write-Error "[$($Computer.toUpper())] $($_.exception.message)"
        }
    } #foreach
} #process

End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
} #end

} #get-PhysicalMemory
#endregion

#import module variables and aliases
. $PSScriptRoot\MemoryToolsSettings.ps1

