Function Get-MemoryUsage {
    [CmdletBinding(DefaultParameterSetName = 'Computername')]
    [OutputType("MyMemoryUsage")]
    [alias("gmem")]
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

        [ValidateSet("All", "OK", "Warning", "Critical")]
        [String]$Status = "All",

        [Parameter(ParameterSetName = 'Cim', Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
        $MyCimSession = @()
    } #begin

    Process {
        Write-Verbose "[PROCESS] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -eq 'Computername') {
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
                    TotalGB      = [Int]($TotalMemory / 1mb)
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
        Write-Verbose "[END    ] $($MyInvocation.MyCommand)"
    } #end

}
