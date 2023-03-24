# MemoryTools

[![PSGallery Version](https://img.shields.io/powershellgallery/v/MemoryTools.png?style=for-the-badge&logo=powershell&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/MemoryTools/) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/MemoryTools.png?style=for-the-badge&label=Downloads)](https://www.powershellgallery.com/packages/MemoryTools/)

This module contains a set of PowerShell functions for reporting on computer memory utilization and configuration. The commands use `Get-CimInstance`, so PowerShell 3.0 or later must be installed on remote computers, and they need to be configured for PowerShell remoting.

The project was first described on my [blog](http://bit.ly/1Tooj3Q).

Install the latest version of this module from the PowerShell Gallery. It should work in Windows PowerShell 5.1 and PowerShell 7 on a Windows platform.

```powershell
Install-Module MemoryTools [-scope CurrentUser]
```

## [Get-MemoryUsage](docs/Get-MemoryUsage.md)

This command will write a custom memory utilization object to the pipeline that indicates the current memory state.

```powershell
PS C:\> Get-MemoryUsage

Computername Status PctFree FreeGB TotalGB
------------ ------ ------- ------ -------
PROSPERO     OK        73.5  46.83      64
```

## [Show-MemoryUsage](docs/Show-MemoryUsage.md)

This command will also get the same information as Get-MemoryUsage but will display it with colorized output.

![Alt Colorized Memory Usage](assets/show-memoryusage.png)

## [Test-MemoryUsage](docs/Test-MemoryUsage.md)

This command can be used to test if memory utilization meets some criteria. There are several parameter sets for different tests. All of them can be used with `-Quiet` to return a simple Boolean value.

### Percent Free

The default behavior is to see if there is at least 50% free memory, but you can specify a different value.

```powershell
PS C:\> Test-MemoryUsage

Computername PctFree Test
------------ ------- ----
PROSPERO       73.23 True

```

### FreeGB

Test if there is at least X amount of free memory available.

```powershell
PS C:\> Test-MemoryUsage -freegb 8

Computername FreeGB Test
------------ ------ ----
PROSPERO      46.66 True

```

### TotalGB

Test if the computer has at least X amount of total memory.

```powershell
PS C:\> Test-MemoryUsage -TotalGB 16

Computername TotalGB Test
------------ ------- ----
PROSPERO          64 True

```

## UsedGB

Test if the computer is using X amount of memory or greater.

```powershell
PS C:\> Test-MemoryUsage -UsedGB 4

Computername UsedGB Test
------------ ------ ----
PROSPERO      17.37 True

```

## [Get-MemoryPerformance](docs/Get-MemoryPerformance.md)

This command will query memory performance counters.

```powershell
PS C:\> Get-MemoryPerformance

AvailableBytes                       : 36180754432
AvailableKBytes                      : 35332768
AvailableMBytes                      : 34504
CacheBytes                           : 436342784
CacheBytesPeak                       : 588001280
CacheFaultsPersec                    : 0
CommitLimit                          : 78617718784
CommittedBytes                       : 40527859712
DemandZeroFaultsPersec               : 251
FreeAndZeroPageListBytes             : 20220755968
FreeSystemPageTableEntries           : 12448913
LongTermAverageStandbyCacheLifetimes : 14400
ModifiedPageListBytes                : 1235890176
PageFaultsPersec                     : 232
PageReadsPersec                      : 0
PagesInputPersec                     : 0
PagesOutputPersec                    : 0
PagesPersec                          : 0
PageWritesPersec                     : 0
PercentCommittedBytesInUse           : 51
PoolNonpagedAllocs                   : 0
PoolNonpagedBytes                    : 1043083264
PoolPagedAllocs                      : 0
PoolPagedBytes                       : 858091520
PoolPagedResidentBytes               : 802910208
StandbyCacheCoreBytes                : 128360448
StandbyCacheNormalPriorityBytes      : 6915219456
StandbyCacheReserveBytes             : 8916418560
SystemCacheResidentBytes             : 436342784
SystemCodeResidentBytes              : 8192
SystemCodeTotalBytes                 : 8192
SystemDriverResidentBytes            : 15392768
SystemDriverTotalBytes               : 40984576
TransitionFaultsPersec               : 11
TransitionPagesRePurposedPersec      : 0
WriteCopiesPersec                    : 0
DateTime                             : 11/11/2020 5:56:08 PM
ComputerName                         : PROSPERO
```

Or you might use it like this:

```powershell
PS C:\> Get-CimSession | Get-MemoryPerformance | Select-Object Computername,CommittedBytes,AvailableMBytes,CacheBytes

ComputerName CommittedBytes AvailableMBytes CacheBytes
------------ -------------- --------------- ----------
thinkp1          4630245376           29007  139804672
win10            1045913600             989   69541888
srv1              598110208             592   22425600
dom1             1357385728            2913   52137984
srv2              586850304             534   28585984
```

## [Get-PhysicalMemory](docs/Get-PhysicalMemory.md)

This command will query the Win32_PhysicalMemory class to get hardware details.

```powershell
PS C:\> Get-PhysicalMemory -Computername thinkp1

   Computername: THINKP1

Manufacturer CapacityGB Form   ClockSpeed Voltage Location
------------ ---------- ----   ---------- ------- --------
Samsung      16         SODIMM 2667       1200    ChannelA-DIMM0
Micron       16         SODIMM 2667       1200    ChannelB-DIMM0
```

## [Get-TopProcessMemory](docs/Get-TopProcessMemory.md)

This command will use `Get-CimInstance` to retrieve the top processes by *Workingset*. It will retrieve the top 5 by default. The output will include a percentage of the total memory in use and the process owner.

```powershell
PS C:\> Get-TopProcessMemory

   Computername: PROSPERO

ProcessID   : 4280
Name        : Memory Compression
WS(MB)      : 1306.37
PctUsed     : 4.9505
Owner       : NT AUTHORITY\SYSTEM
Commandline :

ProcessID   : 40800
Name        : pwsh.exe
WS(MB)      : 1250.1
PctUsed     : 4.7373
Owner       : PROSPERO\Jeff
Commandline : "C:\Program Files\PowerShell\7\pwsh.exe" -nologo

ProcessID   : 43612
Name        : pwsh.exe
WS(MB)      : 534.37
PctUsed     : 2.025
Owner       : PROSPERO\Jeff
Commandline : "C:\Program Files\PowerShell\7\pwsh.exe" -NoProfile
              -ExecutionPolicy Bypass -Command "Import-Module 'c:\Users\Jeff\.vs
              code\extensions\ms-vscode.powershell-2023.2.1\modules\PowerShellEd
              itorServices\PowerShellEditorServices.psd1'; Start-EditorServices
              -HostName 'Visual Studio Code Host' -HostProfileId
              'Microsoft.VSCode' -HostVersion '2023.2.1' -AdditionalModules
              @('PowerShellEditorServices.VSCode') -BundledModulesPath 'c:\Users
              \Jeff\.vscode\extensions\ms-vscode.powershell-2023.2.1\modules'
              -EnableConsoleRepl -StartupBanner '' -LogLevel 'Normal' -LogPath '
              c:\Users\Jeff\AppData\Roaming\Code\User\globalStorage\ms-vscode.po
              wershell\logs\1679663113-13d77409-f0b9-4af6-87e8-58d6de36834f16796
              62816963\EditorServices.log' -SessionDetailsPath 'c:\Users\Jeff\Ap
              pData\Roaming\Code\User\globalStorage\ms-vscode.powershell\session
              s\PSES-VSCode-29600-898846.json' -FeatureFlags @() "

ProcessID   : 13480
Name        : PhoneExperienceHost.exe
WS(MB)      : 431.92
PctUsed     : 1.6368
Owner       : PROSPERO\Jeff
Commandline : "C:\Program Files\WindowsApps\Microsoft.YourPhone_1.23022.139.0_x6
              4__8wekyb3d8bbwe\PhoneExperienceHost.exe"
              -Restart:{F534506B-042E-4975-BF2C-806D54F0EBC7}

ProcessID   : 31184
Name        : firefox.exe
WS(MB)      : 349.93
PctUsed     : 1.3261
Owner       : PROSPERO\Jeff
Commandline : "C:\Program Files\Mozilla Firefox\firefox.exe" -osint -url
              https://pester.dev/docs/commands/Should
```

## [Get-ProcessMemory](docs/Get-ProcessMemory.md)

Get a snapshot of a process' memory usage based on its workingset value. Processes are grouped by name.

```powershell
PS C:\> Get-ProcessMemory | Select-Object -first 5

Name                   Count Threads      AvgMB      SumMB     Computername
----                   ----- -------      -----      -----     ------------
firefox                   17     467   142.2585  2418.3945         PROSPERO
pwsh                       3     101   642.0807  1926.2422         PROSPERO
svchost                  102     692    16.0955  1641.7461         PROSPERO
Code                      13     264    117.466  1527.0586         PROSPERO
Memory Compression         1      54  1306.3555  1306.3555         PROSPERO
```

## Roadmap

I have plans to revise commands to take advantage of SSH remoting in PowerShell 7. It also might be nice to have a WPF-based GUI to display memory information.
