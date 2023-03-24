
Function Get-ProcessMemory {
    [CmdletBinding()]
    [OutputType("myProcessMemory")]

    Param  (
        [Parameter(ValueFromPipeline, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name = "*",
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername = $env:COMPUTERNAME,
        [PSCredential]$Credential,
        [Int32]$ThrottleLimit,
        [ValidateSet('Default', 'Basic', 'Credssp', 'Digest', 'Kerberos', 'Negotiate', 'NegotiateWithImplicitCredential')]
        [ValidateNotNullOrEmpty()]
        [String]$Authentication = "default"
    )

    Begin {

        Write-Verbose "Starting $($MyInvocation.MyCommand)"

        $sb = {
            Param([string[]]$ProcessName)

            # a process might have multiple instances so get each one by name
            #group the processes to accommodate the use of wildcards
            $data = Get-Process -Name $ProcessName | Group-Object -Property Name
            $out = foreach ($item in $data) {
                $item.group | Measure-Object -Property WorkingSet -Sum -Average |
                Select-Object -Property @{Name = "Name"; Expression = { $item.name } },
                Count,
                @{Name = "Threads"; Expression = { $item.group.threads.count } },
                Average, Sum,
                @{Name = "Computername"; Expression = { $env:computername } }
            }
            #sort output in descending order by the sum property
            $out | Sort-Object -Property Sum -Descending
        } #close ScriptBlock

        #update PSBoundParameters so it can be splatted to Invoke-Command
        [void]$PSBoundParameters.Add("ScriptBlock", $sb)
        [void]$PSBoundParameters.add("HideComputername", $True)

    } #begin

    Process {

        [void]$PSBoundParameters.Remove("Name")
        Write-Verbose "Querying processes $($name -join ',') on $($Computername -join ',')"

        #need to make sure argument is treated as an array
        $PSBoundParameters.ArgumentList = , @($Name)
        if (-Not $PSBoundParameters.ContainsKey("Computername")) {
            #add the default value if nothing was specified
            [void]$PSBoundParameters.Add("Computername", $Computername)
        }
        $PSBoundParameters | Out-String | Write-Verbose

        Invoke-Command @PSBoundParameters |
        Select-Object -Property * -ExcludeProperty RunSpaceID, PS* |
        ForEach-Object {
            #insert a custom type name for the format directive
            [void]($_.PSObject.TypeNames.insert(0, "myProcessMemory"))
            $_
        }

    } #process

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    } #end

} #close function
