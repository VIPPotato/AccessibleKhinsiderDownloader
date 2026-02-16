# Local Windows Dependencies

This folder is for local, machine-specific vendored dependencies used by Windows builds when vcpkg is not available.

Expected structure:

- `third_party/windows/deps/include/curl/...`
- `third_party/windows/deps/include/libxml2/...`
- `third_party/windows/deps/lib/libcurl.lib`
- `third_party/windows/deps/lib/libxml2.lib`
- `third_party/windows/deps/bin/*.dll`

Populate/update it with:

```bat
scripts\windows\vendor-deps.bat
```

You can override dependency source detection by setting:

- `KH_DEPS_ROOT` (for example: `C:\Users\<you>\Miniconda3\Library`)

This directory is ignored in git (except this README and `.gitkeep`).
