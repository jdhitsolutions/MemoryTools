---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version:
schema: 2.0.0
---

# Get-PhysicalMemory

## SYNOPSIS

Get physical memory details.

## SYNTAX

### ComputerNameSet (Default)

```yaml
Get-PhysicalMemory [<CommonParameters>]
```

### ComputernameSet

```yaml
Get-PhysicalMemory [[-Computername] <String[]>] [<CommonParameters>]
```

### CimInstanceSessionSet

```yaml
Get-PhysicalMemory -CimSession <CimSession[]> [<CommonParameters>]
```

## DESCRIPTION

This command will query the Win32_PhysicalMemory class to get hardware details about installed memory.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PhysicalMemory


Computername  : BOVINE320
Manufacturer  : Kingston
CapacityGB    : 16
Form          : SODIMM
ClockSpeed    : 2400
Voltage       : 1200
DeviceLocator : ChannelA-DIMM0

Computername  : BOVINE320
Manufacturer  : Kingston
CapacityGB    : 16
Form          : SODIMM
ClockSpeed    : 2400
Voltage       : 1200
DeviceLocator : ChannelB-DIMM0
```

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

Specify the name of a computer or computers to query.

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

