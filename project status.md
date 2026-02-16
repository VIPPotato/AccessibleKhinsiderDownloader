# Project Status

## Objective
Improve the Qt app so it follows screen-reader and keyboard accessibility best practices for a PR-ready set of changes.

## Notes
- Status filename corrected to `project status.md`.

## Progress Log
- [x] Pass 1 completed: shared controls now expose accessibility metadata and keyboard activation.
- [x] Pass 2 completed: explicit accessibility labels and keyboard behavior added in main/search/download/settings panels.
- [x] Pass 3 completed: delegates, dialogs, and hover-only download actions now include keyboard/screen-reader support.

## Build Status
- Build scripts were updated to:
- auto-detect Qt from common install locations (including `QT_CMAKE_PATH` override),
- use vcpkg if available, and
- fall back to a conda `Library` root (`KH_DEPS_ROOT` override) for curl/libxml2 when vcpkg is absent.
- `scripts/windows/deploy.bat` was updated to:
- discover Qt from `build/CMakeCache.txt` or known locations,
- retry `windeployqt` without `--force-openssl` for older Qt versions, and
- copy `libcurl.dll` and `libxml2.dll` into `build/Release` when found.
- Local verification now passes with:
- `scripts/windows/configure.bat`
- `scripts/windows/build.bat`
- Combined run `scripts/windows/configure.bat && scripts/windows/build.bat` also succeeds and produces:
- `build/Release/appKhinsiderQT.exe`
- `scripts/windows/fullbuild.bat` also completes end-to-end in this environment.
