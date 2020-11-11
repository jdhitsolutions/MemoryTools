---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version: https://bit.ly/2Tp7IWy
schema: 2.0.0
---

# Show-MemoryUsage

## SYNOPSIS

Display a colorized version of memory usage.

## SYNTAX

### Computername (Default)

```yaml
Show-MemoryUsage [[-Computername] <String[]>] [<CommonParameters>]
```

### Cim

```yaml
Show-MemoryUsage -CimSession <CimSession[]> [<CommonParameters>]
```

## DESCRIPTION

This is a variation of the Get-MemoryUsage command. This version displays a colorized and formatted table using a custom view. Normal values will be displayed in green. Warnings will be displayed in yellow and Critical systems in red. The criteria for what is normal or not is based on the $MemoryToolsOK and $MemoryToolsWarning global variable values. You can modify these values from the console.

## EXAMPLES

### Example 1

```powershell
PS C:\> show-memoryusage -Computername Dom1,Srv1,Srv2,Win10

****************
  Memory Check
****************

Computername     Status    PctFree   FreeGB  TotalGB
------------     ------    -------   ------  -------
DOM1             OK          99.92   1023.2     1024
SRV1             OK          99.96  1023.63     1024
SRV2             OK          99.95  1023.51     1024
WIN10            Warning     36.89     1.19        3
```

The line for Win10 would be displayed in Yellow. The other computers would be displayed in Green.

## PARAMETERS

### -CimSession

Connect to an existing CimSession.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

### Microsoft.Management.Infrastructure.CimSession[]

## OUTPUTS

### This command creates a formatted table

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-MemoryUsage](Get-MemoryUsage.md)
