# Archived Changelog for MemoryTools

Change log for the module before the first public release.

## v0.5.0

- Minor code cleanup
- Updated documentation (Issue #11)
- Added a changelog to the repository
- Updated `README.md`.

## v0.4.2

- Merge branch `featureDynamicMemory` of https://github.com/IskanderNovena/MemoryTools into IskanderNovena-featureDynamicMemory (Issue #12)

## 0.4.1

- Removed dev and scratch files from the module prior to publishing to PSGallery.

## v0.4.0

- Added a new function Get-TopProcessMemory. (Issue #3)
- Revised Verbose message formatting.
- Updated Pester tests. (Issue #9)
- Update module manifest.

## v0.3.1

- Updated Pester tests
- Fixed a typo bug with `Get-MemoryPerformance`
- Fixed a bug where `computername` wasn't getting added to `Get-MemoryPerformance`
- Fixed a bug where `datetime` wasn't getting added to `Get-MemoryPerformance`

## v0.3.0

- Revised `Get-MemoryPerformance` to use `Get-CimInstance`. (Issue #8)
- Fixed a bug in several commands that wasn't removing temporary sessions.
- Published module to GitHub.

## v0.2.9

- Modified `Get-Physicalmemory` to support CimSessions.
- Removed debug and trace code from functions.

## v0.2.8

- Modified `Test-MemoryUsage` to support CimSessions.
- Fixed a bug with `Test-MemoryUsage` that calculate Used test properly.

## v0.2.7

- Modified `Get-MemoryUsage` to accept CIMSessions.
- working on Pester tests for CimSessions. Not Complete.

## v0.2.6

- Added `MemoryToolsSettings.ps1`.
- Moved alias definitions to the settings file.
- Modified `Get-MemoryUsage` to use global variables from the setting file for OK and Warning levels. (Issue #5)
- Revised Pester tests to reflect changes.
- Updated manifest.

## v0.2.5

- Modified `Get-MemoryUsage` to filter on Status. (Issue #4)
- Modified Pester tests.

## v0.2.4

- Fixed formatting bug with `Show-MemoryUsage`. (Issue #2)

## v0.2.3

- Fixed pipelining issues. (#1)

## v0.2.0

- Initial release.
