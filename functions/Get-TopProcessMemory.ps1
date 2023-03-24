Function Get-TopProcessMemory {

    [CmdletBinding(DefaultParameterSetName = "Computername")]
    [alias("gtop")]
    [OutputType("topProcessMemoryUnit")]
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
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession,

        [validateRange(1, 25)]
        [Int]$Top = 5
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"

        #a private function to get process owner
        function _getProcessOwner {
            [CmdletBinding()]
            Param([object]$CimProcess)
            $own = $cimProcess | Invoke-CimMethod -MethodName GetOwner
            "$($own.domain)\$($own.user)"
        }
    } #Begin

    Process {
        Write-Verbose "[PROCESS] PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        Write-Verbose "[PROCESS] Using parameter set $($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -eq 'Computername') {
            #create a temporary cimsession if using a computername
            $myCIMSession = foreach ($item in $Computername) {
                Try {
                    Write-Verbose "[PROCESS] Creating temporary CIM Session to $item"
                    New-CimSession -ComputerName $item -ErrorAction Stop -OutVariable +TmpSess
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
                        PctUsed      = [math]::Round(($item.WorkingSetSize /$used) * 100, 4)
                        CreationDate = $item.CreationDate
                        Runtime      = (Get-Date) - $item.CreationDate
                        Owner        = $(_getProcessOwner $item)
                        Commandline  = $item.Commandline
                    }
                }
            }
        } #foreach
        #clean up
        if ($TmpSess.count -gt 0) {
            Write-Verbose "[PROCESS] Removing temporary sessions"
            $TmpSess | Out-String | Write-Verbose
            $TmpSess | Remove-CimSession
            Remove-Variable -name TmpSess -Force
        }
    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
    } #end
}
