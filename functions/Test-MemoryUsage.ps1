Function Test-MemoryUsage {
    [CmdletBinding(DefaultParameterSetName = 'PercentComputer')]
    [alias("tmem")]
    [OutputType("Boolean", "PSCustomObject")]
    Param(
        [ValidateNotNullOrEmpty()]
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
        [ValidateNotNullOrEmpty()]
        [Int]$PercentFree = 50,

        [Parameter(HelpMessage = "Enter the minimum free memory in GB", Mandatory, ParameterSetName = "FreeComputer")]
        [Parameter(HelpMessage = "Enter the minimum free memory in GB", Mandatory, ParameterSetName = "FreeCIM")]
        [ValidateNotNullOrEmpty()]
        [double]$FreeGB,

        [ValidateNotNullOrEmpty()]
        [Parameter(HelpMessage = "Enter the minimum total memory in GB", Mandatory, ParameterSetName = "TotalComputer")]
        [Parameter(HelpMessage = "Enter the minimum total memory in GB", Mandatory, ParameterSetName = "TotalCIM")]
        [Int]$TotalGB,

        [Parameter(HelpMessage = "Enter the minimum amount of used memory in GB", Mandatory, ParameterSetName = "UsedComputer")]
        [Parameter(HelpMessage = "Enter the minimum amount of used memory in GB", Mandatory, ParameterSetName = "UsedCIM")]
        [ValidateNotNullOrEmpty()]
        [double]$UsedGB,

        [Switch]$Quiet
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
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
        Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
    } #end
}
