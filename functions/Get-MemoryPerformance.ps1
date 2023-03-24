Function Get-MemoryPerformance {
    [CmdletBinding(DefaultParameterSetName = "Computername")]
    [alias("gmemp")]
    [OutputType("Selected.Microsoft.Management.Infrastructure.CimInstance")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("cn")]
        [string[]]$Computername = $env:Computername,

        [Parameter(
            ParameterSetName = 'Cim',
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
        <#
        Get all memory performance counters. Assuming counters on the
        client are the same as on the server. Sort by name.
        #>
        $all = (Get-Counter -ListSet Memory*).counter | Sort-Object

        #get a list of class properties. Some of the properties don't
        #appear to have any values and are different than what you get
        #with Get-Counter
        $PerfClass = Get-CimClass -ClassName Win32_PerfFormattedData_PerfOS_Memory
        $selected = $PerfClass.CimClassProperties | Select-Object -Skip 9 -ExpandProperty Name
        $selected += @{Name = "DateTime"; Expression = { (Get-Date) } }
        $selected += @{Name = "ComputerName"; Expression = { $session.ComputerName } }
        Write-Verbose "[BEGIN  ] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)
    } #begin

    Process {

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -eq 'Computername') {
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
                Write-Error "Failed to get performance data from $($session.computername.ToUpper()). $($_.exception.message)"
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
        Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
    } #end
}
