---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version: https://bit.ly/34y1oCF
schema: 2.0.0
---

# Get-TopProcessMemory

## SYNOPSIS

Display processes using the most memory based on WorkingSet.

## SYNTAX

### ComputerName (Default)

```yaml
Get-TopProcessMemory [[-Computername] <String[]>] [-Top <Int32>] [<CommonParameters>]
```

### Cim

```yaml
Get-TopProcessMemory -CimSession <CimSession[]> [-Top <Int32>] [<CommonParameters>]
```

## DESCRIPTION

This command will use Get-CimInstance to retrieve the top processes by WorkingSet. It will retrieve the top 5 by default. The output will include a percentage of total in-use memory the process is using as well as the process owner.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-TopProcessMemory -top 1

Computername: PROSPERO

ProcessID   : 3060
Name        : powershell.exe
WS(MB)      : 1455.89
PctUsed     : 4.8277
Owner       : PROSPERO\Jeff
Commandline : "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Version 5.1 -s -NoLogo -NoProfile
```

Get the top process for the local computer.

### Example 2

```powershell
PS C:\> Get-Cimsession | Get-TopProcessMemory | Sort Owner | Format-Table -GroupBy Owner -Property ProcessID,Name,WS,PctUsed

   Owner: COMPANY\ArtD

Computername ProcessID Name                  WS PctUsed
------------ --------- ----                  -- -------
WIN10             3520 powershell.exe 153464832 14.2925

   Owner: NT AUTHORITY\SYSTEM

Computername ProcessID Name               WS PctUsed
------------ --------- ----               -- -------
WIN10             2396 MsMpEng.exe 164093952 15.2824
WIN10             1400 svchost.exe  65187840  6.0711
WIN10              984 LogonUI.exe  55332864  5.1533
WIN10             1056 svchost.exe  47890432  4.4601
```

Use an existing CIMSession and get the top 5 processes. The output is sorted by the Owner property and formatted as a table.

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

### topProcessMemoryUnit

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-MemoryUsage](Get-MemoryUsage.md)

[Show-MemoryUsage](Show-MemoryUsage.md)
