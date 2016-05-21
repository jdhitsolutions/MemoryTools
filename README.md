# MemoryTools #

This module contains a set of PowerShell functions for reporting on computer
memory utilization and configuration. The commands use Get-CimInstance so
remote computers must be running PowerShell 3.0 or later.

## Get-MemoryUsage ##
This command will write a custom memory utilization object to the pipeline
that indicates the current memory state.

    Computername Status PctFree FreeGB TotalGB
    ------------ ------ ------- ------ -------
    CHI-P50      OK       71.99  45.98      64

## Show-MemoryUsage ##
This command will also get the same information as Get-MemoryUsage but will
display it with colorized output.

![Alt Colorized Memory Usage](http://jdhitsolutions.com/blog/wp-content/uploads/2016/05/show-memoryusage.png "Show-MemoryUsage")

## Test-MemoryUsage ##
This command can be used to test if memory utilization meets some criteria.
There are several parameter sets for the different tests. All of them can
be used with -Quiet to return a simple Boolean value.

### Percent Free ###
The default behavior is to see is there is at least 50% free memory, but you
can specify a different value.

    PS C:\> Test-MemoryUsage

    Computername PctFree  Test
    ------------ -------  ----
    WIN81-ENT-01   19.17 False

### FreeGB ###
Test if there is at least X amount of free memory available.

    PS C:\> Test-MemoryUsage -FreeGB 2

    Computername FreeGB  Test
    ------------ ------  ----
    WIN81-ENT-01   1.45 False


### TotalGB ###
Test if the computer has at least X amount of total memory.

    PS C:\> Test-MemoryUsage -TotalGB 8

    Computername TotalGB Test
    ------------ ------- ----
    WIN81-ENT-01       8 True

### UsedGB ###
Test if the computer is using X amount of memory or greater.


    PS C:\> Test-memoryusage -UsedGB 4

    Computername UsedGB Test
    ------------ ------ ----
    WIN81-ENT-01   6.51 True


## Get-MemoryPerformance ##
This command will query memory performance counters.

    PS C:\> Get-MemoryPerformance -Computername $c | Select Computername,%CommittedBytes*,AvailableMBytes,CacheBytes

    Computername %CommittedBytesInUse AvailableMbytes CacheBytes
    ------------ -------------------- --------------- ----------
    CHI-HVR1         7.05788756820636           14839   99377152
    CHI-HVR2         16.8986961377323           13144   83001344
    CHI-P50           24.753204334977           47143   94998528
    CHI-DC04         47.8621563768474            1030  180101120
    WIN81-ENT-01      79.914213523203            1545   96137216

## Get-PhysicalMemory ##
This command will query the Win32_PhysicalMemory class to get hardware details.

    PS C:\> get-physicalmemory -Computername chi-p50


    Computername  : CHI-P50
    Manufacturer  : 0420
    CapacityGB    : 16
    Form          : SODIMM
    ClockSpeed    : 2133
    Voltage       : 1200
    DeviceLocator : ChannelA-DIMM0

    Computername  : CHI-P50
    Manufacturer  : 0420
    CapacityGB    : 16
    Form          : SODIMM
    ClockSpeed    : 2133
    Voltage       : 1200
    DeviceLocator : ChannelA-DIMM1

    Computername  : CHI-P50
    Manufacturer  : 0420
    CapacityGB    : 16
    Form          : SODIMM
    ClockSpeed    : 2133
    Voltage       : 1200
    DeviceLocator : ChannelB-DIMM0

    Computername  : CHI-P50
    Manufacturer  : 0420
    CapacityGB    : 16
    Form          : SODIMM
    ClockSpeed    : 2133
    Voltage       : 1200
    DeviceLocator : ChannelB-DIMM1


****************************************************************
DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED 
THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK. IF YOU DO 
NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, DO NOT USE
OUTSIDE OF A SECURE, TEST SETTING.      
****************************************************************
