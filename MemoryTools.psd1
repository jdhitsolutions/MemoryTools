#
# Module manifest for module 'MemoryTools'
#
@{

    RootModule           = 'MemoryTools.psm1'
    ModuleVersion        = '1.1.0'
    CompatiblePSEditions = 'Desktop', 'Core'
    GUID                 = 'c26f558f-2f21-4b5e-a9ef-5aa646dd262e'
    Author               = 'Jeff Hicks'
    CompanyName          = 'JDH Information Technology Solutions, Inc.'
    Copyright            = '(c) 2016-2023 JDH Information Technology Solutions, Inc. All rights reserved.'
    Description          = 'A set of functions for checking, testing and reporting memory usage using WMI and performance counters.'
    PowerShellVersion    = '5.1'
    # TypesToProcess = @()
    FormatsToProcess     = @(
        "formats\MyMemoryUsage.format.ps1xml",
        "formats\physicalMemoryUnit.format.ps1xml",
        "formats\topProcessMemoryUnit.format.ps1xml",
        "formats\myProcessMemory.format.ps1xml"
    )
    FunctionsToExport    = @(
        'Get-MemoryUsage',
        'Get-ProcessMemory',
        'Show-MemoryUsage',
        'Test-MemoryUsage',
        'Get-MemoryPerformance',
        'Get-PhysicalMemory',
        'Get-TopProcessMemory'
    )
    CmdletsToExport      = ''
    VariablesToExport    = @('MemoryToolsOK', 'MemoryToolsWarning')
    AliasesToExport      = @(
        'gmem',
        'shmem',
        'tmem',
        'gmemp',
        'gpmem',
        'gtop'
    )
    PrivateData          = @{
        PSData = @{
            Tags       = @("Performance", "Memory", "Process")
            LicenseUri = 'https://github.com/jdhitsolutions/MemoryTools/blob/master/license.txt'
            ProjectUri = 'https://github.com/jdhitsolutions/MemoryTools'
            # IconUri = ''
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # DefaultCommandPrefix = ''
}

