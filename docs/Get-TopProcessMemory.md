---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version:
schema: 2.0.0
---

# Get-TopProcessMemory

## SYNOPSIS

Display processes using the most memory.

## SYNTAX

### ComputerNameSet (Default)

```yaml
Get-TopProcessMemory [-Top <Int32>] [<CommonParameters>]
```

### ComputernameSet

```yaml
Get-TopProcessMemory [[-Computername] <String[]>] [-Top <Int32>] [<CommonParameters>]
```

### CimInstanceSessionSet

```yaml
Get-TopProcessMemory -CimSession <CimSession[]> [-Top <Int32>] [<CommonParameters>]
```

## DESCRIPTION

This command will use Get-CimInstance to retrieve the top processes by Workingset. It will retrieve the top 5 by default. The output will include a percentage of total in-use memory the process is using as well as the process owner.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-TopProcessMemory -Computername chi-p50

    Computername : chi-p50
    ProcessID    : 3128
    Name         : dns.exe
    WS(MB)       : 450.78125
    PctUsed      : 2.28
    CreationDate : 5/21/2018 10:50:39 AM
    RunTime      : 17.00:21:09.9646185
    Commandline  : C:\WINDOWS\system32\dns.exe
    Owner        : NT AUTHORITY\NETWORK SERVICE

    Computername : chi-p50
    ProcessID    : 3104
    Name         : MsMpEng.exe
    WS(MB)       : 137.33984375
    PctUsed      : 0.69
    CreationDate : 5/21/2018 10:50:39 AM
    RunTime      : 17.00:21:10.0191119
    Commandline  : 
    Owner        : NT AUTHORITY\NETWORK SERVICE

    Computername : chi-p50
    ProcessID    : 7180
    Name         : ServerManager.exe
    WS(MB)       : 90.6328125
    PctUsed      : 0.46
    CreationDate : 5/21/2018 10:51:07 AM
    RunTime      : 17.00:20:42.2754743
    Commandline  : "C:\WINDOWS\system32\ServerManager.exe" 
    Owner        : NT AUTHORITY\NETWORK SERVICE

    Computername : chi-p50
    ProcessID    : 7568
    Name         : Lenovo.Modern.ImController.exe
    WS(MB)       : 81.3359375
    PctUsed      : 0.41
    CreationDate : 5/21/2018 11:03:01 AM
    RunTime      : 17.00:08:47.9026653
    Commandline  : "C:\Program Files\Lenovo\ImController\Service\Lenovo.Modern.ImController.exe"
    Owner        : NT AUTHORITY\NETWORK SERVICE

    Computername : chi-p50
    ProcessID    : 7980
    Name         : MicrosoftEdgeCP.exe
    WS(MB)       : 78.5390625
    PctUsed      : 0.4
    CreationDate : 5/22/2018 8:06:35 PM
    RunTime      : 15.15:05:14.5392500
    Commandline  : "C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\microsoftedgecp.exe" SCODEF:7004 REDAT:140564 /prefetch:2
    Owner        : NT AUTHORITY\NETWORK SERVICE
```

{{ Add example description here }}

## PARAMETERS

### -CimSession

Connect via an existing CimSession.

```yaml
Type: CimSession[]
Parameter Sets: CimInstanceSessionSet
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Computername

The name of a computer or computers to query.

```yaml
Type: String[]
Parameter Sets: ComputernameSet
Aliases: cn

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Top

The number of processes to retrieve. There is a maximum value of 25.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

### Microsoft.Management.Infrastructure.CimSession[]

## OUTPUTS

### System.Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-MemoryUsage](./Get-MemoryUsage.md)

[Show-MemoryUsage](/Show-MemoryUsage.md)