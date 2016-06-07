#global settings for MemoryTools commands

<#
These are variables that will be used with Get-MemoryUsage
to determine the status. The value is a percentage of free
physical memory available.

Any detected value less than $MemoryToolsWarning will be
classified as Critical.

You can change these variables at any time during your session.
Or modify the file for permanent changes. You will need to 
re-import the module for the changes to take effect.
#>


[ValidateRange(1,100)][int32]$Global:MemoryToolsOK = 45
[ValidateRange(1,100)][int32]$Global:MemoryToolsWarning = 15

#define some aliases
Set-Alias -Name shmem -Value Show-MemoryUsage
Set-Alias -Name gmem -Value Get-MemoryUsage
Set-Alias -Name gmemp -Value Get-MemoryPerformance
Set-Alias -Name tmem -Value Test-MemoryUsage
Set-Alias -Name gpmem -Value Get-Physicalmemory
Set-Alias -name gtop -Value Get-TopProcessMemory
