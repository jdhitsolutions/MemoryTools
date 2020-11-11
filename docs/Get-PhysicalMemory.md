---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version: https://bit.ly/2HAmHKD
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

### Computername

```yaml
Get-PhysicalMemory [[-Computername] <String[]>] [<CommonParameters>]
```

### Cim

```yaml
Get-PhysicalMemory -CimSession <CimSession[]> [<CommonParameters>]
```

## DESCRIPTION

This command will query the Win32_PhysicalMemory class to get hardware details about installed memory. The command writes a custom object to the pipeline.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PhysicalMemory

   Computername: PROSPERO

Manufacturer CapacityGB Form   ClockSpeed Voltage Location
------------ ---------- ----   ---------- ------- --------
Crucial      32         SODIMM 2666       1200    ChannelA-DIMM0
Crucial      32         SODIMM 2666       1200    ChannelB-DIMM0
```

### Example 2

```powershell
PS C:\> Get-Physicalmemory -Computername thinkp1,prospero

   Computername: THINKP1

Manufacturer CapacityGB Form   ClockSpeed Voltage Location
------------ ---------- ----   ---------- ------- --------
Samsung      16         SODIMM 2667       1200    ChannelA-DIMM0
Micron       16         SODIMM 2667       1200    ChannelB-DIMM0

   Computername: PROSPERO

Manufacturer CapacityGB Form   ClockSpeed Voltage Location
------------ ---------- ----   ---------- ------- --------
Crucial      32         SODIMM 2666       1200    ChannelA-DIMM0
Crucial      32         SODIMM 2666       1200    ChannelB-DIMM0
```

### Example 3

```powershell
PS C:\> Get-Cimsession | Get-PhysicalMemory

   Computername: WIN10

Manufacturer          CapacityGB Form    ClockSpeed Voltage Location
------------          ---------- ----    ---------- ------- --------
Microsoft Corporation 2          Unknown 0          0       M0001

   Computername: SRV1

Manufacturer          CapacityGB Form    ClockSpeed Voltage Location
------------          ---------- ----    ---------- ------- --------
Microsoft Corporation 2          Unknown 0          0       M0001

   Computername: DOM1

Manufacturer          CapacityGB Form    ClockSpeed Voltage Location
------------          ---------- ----    ---------- ------- --------
Microsoft Corporation 3.875      Unknown 0          0       M0001
Microsoft Corporation 4.125      Unknown 0          0       M0002
```

Pipe existing CIMSessions to the command. This example querying Hyper-V virtual machines so the results are a bit different.

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

### physicalMemoryUnit

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS
