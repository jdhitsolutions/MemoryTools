---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version:
schema: 2.0.0
---

# Get-MemoryUsage

## SYNOPSIS

Get a snapshot of memory usage.

## SYNTAX

### ComputernameSet (Default)

```yaml
Get-MemoryUsage [[-Computername] <String[]>] [-Status <String>] [<CommonParameters>]
```

### CimInstanceSessionSet

```yaml
Get-MemoryUsage [-Status <String>] -CimSession <CimSession[]> [<CommonParameters>]
```

## DESCRIPTION

This command will write a custom memory utilization object to the pipeline that indicates the current memory state.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-MemoryUsage -computername chi-p50

 Computername Status PctFree FreeGB TotalGB
    ------------ ------ ------- ------ -------
    CHI-P50      OK       71.99  45.98      64
```

### Example 2

```powershell
PS C:\> Get-MemoryUsage dom1,srv1,srv2,win10 -Status Warning

Computername Status  PctFree FreeGB TotalGB
------------ ------  ------- ------ -------
WIN10        Warning   36.57   1.17       3
```

Get usage from several computers but filter and only display those with a Warning.

## PARAMETERS

### -CimSession

Connect using an existing CIMSession

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

Specify the name of the computer or computers to query.

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

### -Status

Filter on a given status.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, OK, Warning, Critical

Required: False
Position: Named
Default value: None
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

[Show-MemoryUsage](./Show-MemoryUsage.md)

[Test-MemoryUsage](./Test-MemoryUsage.md)

[Get-TopProcessMemory](./Get-TopProcessMemory.md)