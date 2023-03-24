Function Show-MemoryUsage {

    [CmdletBinding(DefaultParameterSetName = 'Computername')]
    [alias("shmem")]
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

        [Parameter(ParameterSetName = 'Cim', Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"

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

        if ($PSCmdlet.ParameterSetName -eq 'Computername') {
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
        Write-Verbose "[END    ] $($MyInvocation.MyCommand)"
    } #end

}
