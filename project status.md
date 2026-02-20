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
- Qt was installed locally via `aqtinstall` into:
- `third_party/windows/qt/6.6.3/msvc2019_64`
- Working configure override used for this environment:
- `QT_CMAKE_PATH=third_party/windows/qt/6.6.3/msvc2019_64/lib/cmake`
- Latest verification in this environment:
- `scripts/windows/configure.bat` succeeded with local Qt + vendored deps.
- `scripts/windows/build.bat` succeeded and CTest passed (`ui_accessibility_checks`).
- `scripts/windows/deploy.bat` succeeded and packaged runtime dependencies.
- 2026-02-19 startup fix:
- Root cause of immediate exit (`-1`) was QML object creation failure from invalid accessibility/key snippets and a missing local `Qt5Compat.GraphicalEffects` module.
- Removed `Qt5Compat.GraphicalEffects` dependency from `AlbumItem.qml` and `AlbumImageCaret.qml` and replaced those effects with runtime-safe QtQuick primitives.
- Replaced unsupported handlers/properties:
- `Keys.onBackspacePressed`, `Keys.onRPressed`, `Keys.onHomePressed`, `Keys.onEndPressed`, `Keys.onPageUpPressed`, `Keys.onPageDownPressed` -> `Keys.onPressed` key routing.
- `Accessible.value` removed from custom controls and value text moved into `Accessible.description`.
- Removed invalid `Accessible.*` on `Window` roots (`Main.qml`, `UpdateCheckerDialog.qml`) and moved main-window semantics to an `Item` root (`maincol`).
- Updated `scripts/shared/accessibility_tests.py` to assert the corrected, Qt-valid accessibility patterns.
- Verification for this pass:
- `scripts/windows/build.bat` succeeded and CTest passed (`ui_accessibility_checks`).
- 2026-02-19 announcement wording follow-up:
- `WEnumButton` now keeps focused announcement format `Label: Value` while removing trailing `Current value` text from descriptions.
- `WEnumButton` value-change announcements now use value-only semantics during the change event (`announceValueOnly` + `Accessible.valueChanged()`), then restore normal naming immediately.
- `WNumberBox` now announces as `Label Value` (for example: `Download threads 1`) and no longer appends `Current value` to descriptions.
- `WNumberBox` now emits `Accessible.valueChanged()` when numeric value changes while the spin box or its plus/minus buttons are focused.
- Added test assertions for these semantics in `scripts/shared/accessibility_tests.py`.
- Verification for this pass:
- `scripts/windows/build.bat` succeeded and CTest passed (`ui_accessibility_checks`).
- `scripts/windows/deploy.bat` succeeded.
- `build/Release/appKhinsiderQT.exe` was launched successfully and remained running during a 4-second startup check.
- 2026-02-19 keyboard/screen-reader follow-up:
- Fixed editable-field keyboard trap where Tab inserted a tab character instead of moving focus:
- `src/ui/download/DownloadPanel.qml` `TextArea` now handles `Qt.Key_Tab` / `Qt.Key_Backtab` and explicitly moves focus via `nextItemInFocusChain`.
- `src/ui/search/SearchPanel.qml` `TextField` now handles `Qt.Key_Tab` / `Qt.Key_Backtab` with explicit forward/backward focus movement.
- Fixed combo value announcement delay:
- `src/ui/shared/WEnumButton.qml` now updates `Accessible.name` with the current option and calls `Accessible.valueChanged()` when selection changes while focused, so screen readers get an immediate value-change event.
- Added regression checks in `scripts/shared/accessibility_tests.py` for:
- editable field Tab/Shift+Tab key handling snippets, and
- combo value-change accessibility notification snippet (`Accessible.valueChanged()`).
- Verification for this pass:
- `scripts/windows/build.bat` succeeded and CTest passed (`ui_accessibility_checks`).
- 2026-02-19 search/about navigation follow-up:
- Search results list now exposes explicit selected semantics (`Accessible.selectable`/`Accessible.selected`) so screen readers can distinguish selected vs not selected entries.
- Search results are no longer tab-stopped per row (`activeFocusOnTab: false` on list items). Keyboard browsing inside the list is arrow-key driven.
- Enter on a focused search result now triggers quick add to downloads using preferred audio quality (`app.settings.preferredAudioQuality`) while preserving the existing visual layout.
- About contributors section now has a focusable list scope (`activeFocusOnTab: true`) and supports Up/Down/Home/End traversal across contributor rows.
- Contributor rows now expose selected state and can be focused/read with arrow keys, while the website link remains separately focusable.
- Added regression checks in `scripts/shared/accessibility_tests.py` for:
- search result selected-state semantics and quick-add hook snippets,
- contributor list focus scope and selected-row semantics.
- Verification for this pass:
- `scripts/windows/build.bat` succeeded and CTest passed (`ui_accessibility_checks`).
- 2026-02-19 checkbox multi-select follow-up:
- Search results now support checkbox-style selection via keyboard and screen reader semantics:
- Space/Enter toggles checked state per result.
- List items expose both selection and check state (`Accessible.selectable`/`Accessible.selected` and `Accessible.checkable`/`Accessible.checked`) so announcements remain explicit.
- Search list keeps arrow-key browsing model with no per-item tab stops, and adds shortcuts:
- `Ctrl+D` queues checked (or currently selected) albums directly to downloads.
- `Ctrl+U` appends checked (or currently selected) album URLs to the download tab input buffer.
- Search panel now includes action buttons near the list:
- `Add Checked` and `To URL Box`.
- Download URL input now syncs through a shared buffer (`DownloaderModel.bulkUrlBuffer`) so URLs appended from Search appear in the Download tab text area without breaking existing import behavior.
- Search model now exposes `albumLink` as a QML role to support selected-link actions.
- Verification for this pass:
- `scripts/windows/build.bat` succeeded and CTest passed (`ui_accessibility_checks`).

## TODO
- Evaluate search result filtering by category/platform (for example console/system) once parser/model coverage is confirmed reliable across search results and not just full album metadata.
