#requires -version 4.0

#TURN THIS INTO A MODULE
#FIX formatting for Show-MemoryUsage
#create Test-memoryusage to run get-memory usage and test for a minimum %free,
#FreeGB, TotalGB or UsedGB
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

} #end function

Set-Alias -Name gmu -Value Get-MemoryUsage

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
    $title = @"

Memory Check
------------

"@

Write-Host $title -foregroundColor Cyan

([pscustomobject]@{
Computername = ''
Status = ''
PctFree = ''
FreeGB = ''
TotalGB = ''
} |format-table -autosize | out-string).Trim() | write-host -ForegroundColor Cyan

} #begin

Process {
foreach ($computer in $computername) {
    #get memory usage data
    $data = Test-MemoryUsage -Computername $computer

    Switch ($data.Status) {
    "OK" { $color = "Green" }
    "Warning" { $color = "Yellow" }
    "Critical" {$color = "Red" }
    }
    
    ($data | Format-Table -AutoSize -HideTableHeaders | Out-String).Trim() | Write-Host -ForegroundColor $color
 } #foreach
} #Process

End {
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end

} #end Show-MemUsage

set-alias -Name smu -Value Show-MemoryUsage

<#
$counters = "\Memory\Available Bytes","\Memory\Committed Bytes","\Memory\% Committed Bytes In Use"
$d = Get-Counter -Counter $counters

#$d.CounterSamples[0].path.Split("\")[-1]

$d.CounterSamples | Select @{Name="Counter";Expression={ $_.path.Split("\")[-1]}},
@{Name="Value";Expression={$_.cookedValue}}

#>



#endregion

