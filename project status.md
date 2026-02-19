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
- copy dependency DLLs into `build/Release`.
- Runtime dependency handling was hardened:
- Added `scripts/windows/copy-runtime-deps.ps1` to recursively resolve and copy transitive DLL dependencies (e.g., `zlib.dll`, `libssh2.dll`, `iconv.dll`, VC runtime DLLs) from the resolved dependency bin.
- `scripts/windows/deploy.bat` now calls this script after base DLL copy.
- Project-local vendored dependency flow added:
- `scripts/windows/vendor-deps.bat` copies headers, import libs, and runtime DLL dependency closure into `third_party/windows/deps`.
- `scripts/windows/configure.bat` now prefers `third_party/windows/deps` before global dependency locations.
- `third_party/windows/deps/README.md` documents the layout and usage.
- `scripts/windows/configure.bat` now uses `LIBXML2_*` cache variables (not `LibXml2_*`) and absolute project paths, so configure works from repo root and picks vendored libxml2 correctly.
- `scripts/windows/build.bat`, `clean.bat`, `fullbuild.bat`, and `fullbuildandcreateinstaller.bat` now resolve paths via `%~dp0`/absolute project paths.
- `scripts/windows/deploy.bat` now copies VC runtime DLLs from detected VC redist folders or `%SystemRoot%\System32` fallback.
- Added `scripts/shared/accessibility_tests.py` with feature-level accessibility assertions (navigation, search, download, settings, about, shared controls).
- `CMakeLists.txt` now registers `ui_accessibility_checks` in CTest.
- `scripts/windows/build.bat` now executes CTest automatically after each compile.
- Additional accessibility hardening added across QML panels/components (panel roles/names/descriptions, keyboard parity, and clearer control semantics).
- Local verification now passes with:
- `scripts/windows/configure.bat`
- `scripts/windows/build.bat`
- `scripts/windows/deploy.bat`
- Combined run `scripts/windows/configure.bat && scripts/windows/build.bat` also succeeds and produces:
- `build/Release/appKhinsiderQT.exe`
- Full run `scripts/windows/clean.bat && scripts/windows/configure.bat && scripts/windows/build.bat && scripts/windows/deploy.bat` succeeds.
- `scripts/windows/fullbuild.bat` also completes end-to-end in this environment.
