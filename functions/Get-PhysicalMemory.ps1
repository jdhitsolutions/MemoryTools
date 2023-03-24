Function Get-PhysicalMemory {

    [CmdletBinding(DefaultParameterSetName = "Computername")]
    [alias("gpmem")]
    [OutputType("physicalMemoryUnit")]
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
                    [PSCustomObject]@{
                        PSTypeName   = "physicalMemoryUnit"
                        Computername = $item.PSComputername.ToUpper()
                        Manufacturer = $item.Manufacturer
                        CapacityGB   = $item.Capacity / 1GB
                        Form         = $form.item($item.FormFactor -as [Int])
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
        Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
    } #end

}
