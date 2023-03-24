# Memory Tools Changelog

## [Unreleased]

## [1.1.0] - 2023-03-24

### Added

- Added `Get-MemoryUsage`.
- Added format file `myProcessMemoryUsage.format.ps1xml`.
- Help updates.
- Updated `README.md`.

### Changed

- General code clean up.
- Restructured module, separating functions to separate files.
- Migrated changelog to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
- Moved pre-release change log information to `pre-release-changelog.md`.

## [1.0.0] - 2020-11-11

### Added

- Added a custom format file for the `physicalMemoryUnit` object type.
- Added a custom format file for the `topProcessMemoryUnit` object type.
- Added online help links.

### Changed

- Modified `Show-MemoryUsage` to use ANSI-escape sequences instead of `Write-Host`.
- Modified `Get-PhysicalMemory` to write a custom object called `physicalMemoryUnit` to the pipeline.
- Modified `Get-TopProcessMemory` to write a custom object called `topProcessMemoryUnit` to the pipeline.
- Updated `README.md` and `license.txt`.
- Code update and cleanup for PowerShell 7 compatibility.
- Modified manifest to require PowerShell 5.1 as the minimum and support Core.
- Modified table layout in `MyMemoryUsage.format.ps1xml`.
- Updated Pester tests.

[Unreleased]: https://github.com/jdhitsolutions/MemoryTools/compare/v1.1.0..HEAD
[1.1.0]: https://github.com/jdhitsolutions/MemoryTools/compare/v1.0.0..v1.1.0
[1.0.0]: https://github.com/jdhitsolutions/MemoryTools/tree/v1.0.0