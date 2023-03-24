---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version:
schema: 2.0.0
---

# Get-ProcessMemory

## SYNOPSIS

Get a snapshot of a process' memory usage.

## SYNTAX

```yaml
Get-ProcessMemory [[-Name] <String[]>] [-Computername <String[]>]
[-Credential <PSCredential>] [-ThrottleLimit <Int32>]
[-Authentication <String>] [<CommonParameters>]
```

## DESCRIPTION

Get a snapshot of a process' memory usage based on its workingset value.
You can get the same information using Get-Process or by querying the Win32_Process WMI class with Get-CimInstance.
This command uses Invoke-Command to gather the information remotely.
Many of the parameters are from that cmdlet.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-ProcessMemory code,powershell*

Name                   Count Threads      AvgMB      SumMB      Computername
----                   ----- -------      -----      -----      ------------
Code                       9     154   112.8199  1015.3789         BOVINE320
powershell                 3      77   179.1367   537.4102         BOVINE320
powershell_ise             1      21   242.0586   242.0586         BOVINE320
```

The default output displays the process name, the total process count, the total number of threads, the average workingset value per process in MB and the total workingset size of all processes also formatted in MB.

### EXAMPLE 2

```powershell
PS C:\> Get-ProcessMemory -computername srv1,srv2,dom1 -Name lsass -cred company\artd

Name                   Count Threads      AvgMB      SumMB     Computername
----                   ----- -------      -----      -----     ------------
lsass                      1      30    60.1719    60.1719             DOM1
lsass                      1       7    10.8594    10.8594             SRV1
lsass                      1       7     9.6953     9.6953             SRV2
```

### EXAMPLE 3

```powershell
PS C:\> Get-ProcessMemory *ActiveDirectory* -Computername dom1 | Select-Object *

Name         : Microsoft.ActiveDirectory.WebServices
Count        : 1
Threads      : 10
Average      : 46940160
Sum          : 46940160
Computername : DOM1
```

This example uses a wildcard for the process name because the domain controller only has one related process.
The output shows the raw values.

### EXAMPLE 4

```powershell
PS C:\> Get-ProcessMemory *edge*,firefox,chrome | sort sum -Descending

Name                   Count Threads      AvgMB      SumMB     Computername
----                   ----- -------      -----      -----     ------------
firefox                    6     189   180.4134  1082.4805        BOVINE320
chrome                     8     124    67.1377   537.1016        BOVINE320
MicrosoftEdgeCP            4     171    66.1846   264.7383        BOVINE320
MicrosoftEdge              1      37    70.1367    70.1367        BOVINE320
MicrosoftEdgeSH            1      10     8.2734     8.2734        BOVINE320
```

Get browser processes and sort on the underlying SUM property in descending order.

## PARAMETERS

### -Name

The process name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Computername

The name of a remote computer.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $env:COMPUTERNAME
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

A credential for the remote computer.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrottleLimit

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Authentication

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string[]]

## OUTPUTS

### myProcessMemory

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-Process]()
[Get-TopProcessMemory](Get-TopProcessMemory.md)
