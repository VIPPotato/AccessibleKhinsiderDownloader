@echo off
setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0..\.."
for %%p in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fp"
set "VENDORED_ROOT=%PROJECT_DIR%\third_party\windows\deps"
set "SOURCE_ROOT="

if defined KH_DEPS_ROOT call :tryDepsRoot "%KH_DEPS_ROOT%"
if not defined SOURCE_ROOT if defined CONDA_PREFIX call :tryDepsRoot "%CONDA_PREFIX%\Library"
if not defined SOURCE_ROOT call :tryDepsRoot "%USERPROFILE%\Miniconda3\Library"
if not defined SOURCE_ROOT call :tryDepsRoot "%USERPROFILE%\miniconda3\Library"
if not defined SOURCE_ROOT call :tryDepsRoot "D:\downloads\AI\pinokio\bin\miniconda\Library"

if not defined SOURCE_ROOT (
    echo Could not find a dependency root with curl/libxml2.
    echo Set KH_DEPS_ROOT to a folder like "^<conda^>\Library".
    exit /b 1
)

echo Using source dependencies from: !SOURCE_ROOT!
echo Vendor target: !VENDORED_ROOT!

if not exist "!VENDORED_ROOT!" mkdir "!VENDORED_ROOT!"
if not exist "!VENDORED_ROOT!\include" mkdir "!VENDORED_ROOT!\include"
if not exist "!VENDORED_ROOT!\lib" mkdir "!VENDORED_ROOT!\lib"
if not exist "!VENDORED_ROOT!\bin" mkdir "!VENDORED_ROOT!\bin"

robocopy "!SOURCE_ROOT!\include\curl" "!VENDORED_ROOT!\include\curl" /E >nul
if errorlevel 8 (
    echo Failed to copy curl headers.
    exit /b 1
)

robocopy "!SOURCE_ROOT!\include\libxml2" "!VENDORED_ROOT!\include\libxml2" /E >nul
if errorlevel 8 (
    echo Failed to copy libxml2 headers.
    exit /b 1
)

call :copyRequiredHeader "iconv.h"
call :copyOptionalHeader "zlib.h"
call :copyOptionalHeader "zconf.h"

if not exist "!SOURCE_ROOT!\lib\libcurl.lib" (
    echo Missing source import library: !SOURCE_ROOT!\lib\libcurl.lib
    exit /b 1
)
copy /Y "!SOURCE_ROOT!\lib\libcurl.lib" "!VENDORED_ROOT!\lib\libcurl.lib" >nul

if exist "!SOURCE_ROOT!\lib\libxml2.lib" (
    copy /Y "!SOURCE_ROOT!\lib\libxml2.lib" "!VENDORED_ROOT!\lib\libxml2.lib" >nul
) else if exist "!SOURCE_ROOT!\lib\xml2.lib" (
    copy /Y "!SOURCE_ROOT!\lib\xml2.lib" "!VENDORED_ROOT!\lib\libxml2.lib" >nul
) else (
    echo Missing source import library: !SOURCE_ROOT!\lib\libxml2.lib or xml2.lib
    exit /b 1
)

if not exist "!SOURCE_ROOT!\bin\libcurl.dll" (
    echo Missing source runtime DLL: !SOURCE_ROOT!\bin\libcurl.dll
    exit /b 1
)
if not exist "!SOURCE_ROOT!\bin\libxml2.dll" (
    echo Missing source runtime DLL: !SOURCE_ROOT!\bin\libxml2.dll
    exit /b 1
)

copy /Y "!SOURCE_ROOT!\bin\libcurl.dll" "!VENDORED_ROOT!\bin\libcurl.dll" >nul
copy /Y "!SOURCE_ROOT!\bin\libxml2.dll" "!VENDORED_ROOT!\bin\libxml2.dll" >nul

set "DUMPBIN_EXE="
for /f "delims=" %%i in ('where dumpbin 2^>nul') do (
    if not defined DUMPBIN_EXE set "DUMPBIN_EXE=%%i"
)
if not defined DUMPBIN_EXE if exist "D:\downloads\AI\dione\bin\build_tools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\dumpbin.exe" (
    set "DUMPBIN_EXE=D:\downloads\AI\dione\bin\build_tools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\dumpbin.exe"
)
if not defined DUMPBIN_EXE (
    echo dumpbin.exe not found; cannot resolve transitive runtime dependencies.
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copy-runtime-deps.ps1" ^
 -Dumpbin "!DUMPBIN_EXE!" ^
 -SourceBin "!SOURCE_ROOT!\bin" ^
 -TargetDir "!VENDORED_ROOT!\bin" ^
 -EntryExe "does-not-exist.exe"
if errorlevel 1 (
    echo Failed while resolving transitive runtime dependencies.
    exit /b 1
)

echo Vendored dependencies refreshed.
exit /b 0

:copyRequiredHeader
if not exist "!SOURCE_ROOT!\include\%~1" (
    echo Missing source header: !SOURCE_ROOT!\include\%~1
    exit /b 1
)
copy /Y "!SOURCE_ROOT!\include\%~1" "!VENDORED_ROOT!\include\%~1" >nul
exit /b 0

:copyOptionalHeader
if exist "!SOURCE_ROOT!\include\%~1" (
    copy /Y "!SOURCE_ROOT!\include\%~1" "!VENDORED_ROOT!\include\%~1" >nul
)
exit /b 0

:tryDepsRoot
set "CANDIDATE=%~1"
if "%CANDIDATE%"=="" exit /b 0
if not exist "%CANDIDATE%" exit /b 0
if exist "%CANDIDATE%\include\curl\curl.h" if exist "%CANDIDATE%\include\libxml2\libxml\parser.h" if exist "%CANDIDATE%\lib\libcurl.lib" (
    if exist "%CANDIDATE%\lib\libxml2.lib" (
        set "SOURCE_ROOT=%CANDIDATE%"
        exit /b 0
    )
    if exist "%CANDIDATE%\lib\xml2.lib" (
        set "SOURCE_ROOT=%CANDIDATE%"
        exit /b 0
    )
)
exit /b 0
