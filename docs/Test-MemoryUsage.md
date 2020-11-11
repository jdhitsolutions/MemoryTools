---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version: https://bit.ly/2TFkXml
schema: 2.0.0
---

# Test-MemoryUsage

## SYNOPSIS

Test if a computer meets a specific memory threshold.

## SYNTAX

### PercentComputer (Default)

```yaml
Test-MemoryUsage [[-Computername] <String[]>] [-PercentFree <Int32>] [-Quiet] [<CommonParameters>]
```

### UsedComputer

```yaml
Test-MemoryUsage [[-Computername] <String[]>] -UsedGB <Double> [-Quiet] [<CommonParameters>]
```

### TotalComputer

```yaml
Test-MemoryUsage [[-Computername] <String[]>] -TotalGB <Int32> [-Quiet] [<CommonParameters>]
```

### FreeComputer

```yaml
Test-MemoryUsage [[-Computername] <String[]>] -FreeGB <Double> [-Quiet] [<CommonParameters>]
```

### UsedCIM

```yaml
Test-MemoryUsage -CimSession <CimSession[]> -UsedGB <Double> [-Quiet] [<CommonParameters>]
```

### TotalCIM

```yaml
Test-MemoryUsage -CimSession <CimSession[]> -TotalGB <Int32> [-Quiet] [<CommonParameters>]
```

### FreeCIM

```yaml
Test-MemoryUsage -CimSession <CimSession[]> -FreeGB <Double> [-Quiet] [<CommonParameters>]
```

### PercentCIM

```yaml
Test-MemoryUsage -CimSession <CimSession[]> [-PercentFree <Int32>] [-Quiet] [<CommonParameters>]
```

## DESCRIPTION

This command can be used to test if memory utilization meets some criteria. There are several parameter sets for different tests. All of them can be used with -Quiet to return a simple Boolean value.

## EXAMPLES

### Example 1

```powershell
PS C:\> Test-MemoryUsage

Computername PctFree Test
------------ ------- ----
BOVINE320      50.53 True
```

Run the default test on the local computer. The default percentage threshold is 50%.

### Example 2

```powershell
PS C:\> Test-MemoryUsage -FreeGB 16

Computername FreeGB  Test
------------ ------  ----
BOVINE320     15.93 False
```

Test if the computer has at least 16GB of free memory.

### Example 3

```powershell
PS C:\> Test-MemoryUsage -computername CHI-P50 -TotalGB 32 -Quiet
True
```

Test if the computer has at least 32GB of memory but only return True or False.

### Example 4

```powershell
PS C:\> Test-MemoryUsage -UsedGB 20

Computername UsedGB  Test
------------ ------  ----
BOVINE320     15.74 False
```

Test if the computer is using at least 20GB of memory.

## PARAMETERS

### -CimSession

Connect to an existing CimSession.

```yaml
Type: CimSession[]
Parameter Sets: UsedCIM, TotalCIM, FreeCIM, PercentCIM
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

Enter the name of a computer or computers to test.

```yaml
Type: String[]
Parameter Sets: PercentComputer, UsedComputer, TotalComputer, FreeComputer
Aliases: cn

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FreeGB

Enter the minimum free memory in GB.

```yaml
Type: Double
Parameter Sets: FreeComputer, FreeCIM
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PercentFree

Enter the minimum % free memory

```yaml
Type: Int32
Parameter Sets: PercentComputer, PercentCIM
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet

Suppress details and return a Boolean value.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TotalGB

Enter the minimum total memory in GB

```yaml
Type: Int32
Parameter Sets: TotalComputer, TotalCIM
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UsedGB

Enter the minimum amount of used memory in GB

```yaml
Type: Double
Parameter Sets: UsedComputer, UsedCIM
Aliases:

Required: True
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

## OUTPUTS

### System.Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-MemoryUsage](Get-MemoryUsage.md)

[Get-MemoryPerformance](Get-MemoryPerformance.md)

[Get-TopProcessMemory](Get-TopProcessMemory.md)
