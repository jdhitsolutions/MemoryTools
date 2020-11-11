---
external help file: MemoryTools-help.xml
Module Name: MemoryTools
online version: https://bit.ly/2TrAq9d
schema: 2.0.0
---

# Get-MemoryPerformance

## SYNOPSIS

Get memory information from performance counters

## SYNTAX

### Computername

```yaml
Get-MemoryPerformance [[-Computername] <String[]>] [<CommonParameters>]
```

### Cim

```yaml
Get-MemoryPerformance -CimSession <CimSession[]> [<CommonParameters>]
```

## DESCRIPTION

Use this command to simplify the process of getting data from memory-related performance counters.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-MemoryPerformance



AvailableBytes                       : 17207111680
AvailableKBytes                      : 16803820
AvailableMBytes                      : 16409
CacheBytes                           : 374910976
CacheBytesPeak                       : 627560448
CacheFaultsPersec                    : 6419
CommitLimit                          : 39345614848
CommittedBytes                       : 21974437888
DemandZeroFaultsPersec               : 741
FreeAndZeroPageListBytes             : 696127488
FreeSystemPageTableEntries           : 12267190
LongTermAverageStandbyCacheLifetimes : 14400
ModifiedPageListBytes                : 24715264
PageFaultsPersec                     : 7204
PageReadsPersec                      : 0
PagesInputPersec                     : 0
PagesOutputPersec                    : 0
PagesPersec                          : 0
PageWritesPersec                     : 0
PercentCommittedBytesInUse           : 55
PoolNonpagedAllocs                   : 1182049
PoolNonpagedBytes                    : 559136768
PoolPagedAllocs                      : 1398128
PoolPagedBytes                       : 831823872
PoolPagedResidentBytes               : 741318656
StandbyCacheCoreBytes                : 155684864
StandbyCacheNormalPriorityBytes      : 9012703232
StandbyCacheReserveBytes             : 7342587904
SystemCacheResidentBytes             : 374902784
SystemCodeResidentBytes              : 0
SystemCodeTotalBytes                 : 0
SystemDriverResidentBytes            : 12992512
SystemDriverTotalBytes               : 29093888
TransitionFaultsPersec               : 83
TransitionPagesRePurposedPersec      : 0
WriteCopiesPersec                    : 0
DateTime                             : 11/21/2020 12:17:16 PM
ComputerName                         : WIN10Desktop
```

Get all memory counters for the local computer.

### Example 2

```powershell
PS C:\> Get-MemoryPerformance -Computername $c | Select Computername,%CommittedBytes*,AvailableMBytes,CacheBytes

    Computername %CommittedBytesInUse AvailableMbytes CacheBytes
    ------------ -------------------- --------------- ----------
    CHI-HVR1         7.05788756820636           14839   99377152
    CHI-HVR2         16.8986961377323           13144   83001344
    CHI-P50           24.753204334977           47143   94998528
    CHI-DC04         47.8621563768474            1030  180101120
    Win10-ENT-01      79.914213523203            1545   96137216
```

Get selected performance data from multiple computers defined in variable c.

## PARAMETERS

### -CimSession

Connect to a CimSession.

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

Enter the name of a computer to connect to.

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

[Get-Counter]()

[Get-MemoryUsage](Get-MemoryUsage.md)
