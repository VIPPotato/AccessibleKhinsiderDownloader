@echo off
setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0..\.."
for %%p in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fp"
set "BUILD_DIR=%PROJECT_DIR%\build"
set "EXE_PATH=%BUILD_DIR%\Release\appKhinsiderQT.exe"
set "CACHE_FILE=%BUILD_DIR%\CMakeCache.txt"
set "QT_BIN_PATH="
set "DEPS_BIN="

if not exist "%EXE_PATH%" (
    echo Build output not found: "%EXE_PATH%"
    echo Run scripts/windows/configure.bat and scripts/windows/build.bat first.
    exit /b 1
)

if exist "%CACHE_FILE%" (
    for /f "tokens=1,* delims==" %%a in ('findstr /b /c:"Qt6_DIR:PATH=" "%CACHE_FILE%"') do (
        set "QT6_DIR=%%b"
    )
    if defined QT6_DIR (
        set "QT6_DIR=!QT6_DIR:/=\!"
        for %%q in ("!QT6_DIR!\..\..\..\bin") do (
            if exist "%%~fq\windeployqt.exe" set "QT_BIN_PATH=%%~fq"
        )
    )
)

if not defined QT_BIN_PATH if defined QT_CMAKE_PATH (
    for %%q in ("%QT_CMAKE_PATH%\..\..\bin") do (
        if exist "%%~fq\windeployqt.exe" set "QT_BIN_PATH=%%~fq"
    )
)

if not defined QT_BIN_PATH call :findQtBinInRoot "C:\Qt"
if not defined QT_BIN_PATH call :findQtBinInRoot "%USERPROFILE%\Qt"
if not defined QT_BIN_PATH call :findQtBinInRoot "%USERPROFILE%\Documents\Qt"
if not defined QT_BIN_PATH call :findQtBinInRoot "D:\Documents\projects\software\line desktop access\temp_qt"

if not defined QT_BIN_PATH (
    echo Could not find windeployqt.exe.
    echo Set QT_CMAKE_PATH or run configure.bat first.
    exit /b 1
)

echo Using windeployqt from: !QT_BIN_PATH!
set "DEPLOY_ARGS=--qmldir ""%PROJECT_DIR%\src\ui"" --no-translations --release"
"!QT_BIN_PATH!\windeployqt.exe" %DEPLOY_ARGS% --force-openssl "%EXE_PATH%"
if errorlevel 1 (
    echo Retrying windeployqt without --force-openssl for older Qt versions...
    "!QT_BIN_PATH!\windeployqt.exe" %DEPLOY_ARGS% "%EXE_PATH%"
    if errorlevel 1 exit /b %errorlevel%
)

call :copyDependencyDll "%CACHE_FILE%" "CURL_LIBRARY" "libcurl.dll"
call :copyDependencyDll "%CACHE_FILE%" "LibXml2_LIBRARY" "libxml2.dll"
set "LIB_PATH="
if exist "%CACHE_FILE%" (
    for /f "tokens=1,* delims==" %%a in ('findstr /b /c:"CURL_LIBRARY:" "%CACHE_FILE%"') do (
        set "LIB_PATH=%%b"
    )
)
if defined LIB_PATH (
    set "LIB_PATH=!LIB_PATH:/=\!"
    for %%d in ("!LIB_PATH!\..\..\bin") do (
        if exist "%%~fd" set "DEPS_BIN=%%~fd"
    )
)

if not defined DEPS_BIN (
    set "LIB_PATH="
    if exist "%CACHE_FILE%" (
        for /f "tokens=1,* delims==" %%a in ('findstr /b /c:"LibXml2_LIBRARY:" "%CACHE_FILE%"') do (
            set "LIB_PATH=%%b"
        )
    )
    if defined LIB_PATH (
        set "LIB_PATH=!LIB_PATH:/=\!"
        for %%d in ("!LIB_PATH!\..\..\bin") do (
            if exist "%%~fd" set "DEPS_BIN=%%~fd"
        )
    )
)

if defined DEPS_BIN (
    echo Resolving transitive dependencies from: !DEPS_BIN!
    call :copyDependencyClosure "!DEPS_BIN!" "%BUILD_DIR%\Release"
) else (
    echo Skipping transitive dependency copy: no dependency bin could be resolved.
)
exit /b 0

:findQtBinInRoot
set "ROOT=%~1"
if not exist "!ROOT!" exit /b 0
call :checkQtBinLayout "!ROOT!"
if defined QT_BIN_PATH exit /b 0
for /d %%d in ("!ROOT!\*") do (
    call :checkQtBinLayout "%%~fd"
    if defined QT_BIN_PATH exit /b 0
)
exit /b 0

:checkQtBinLayout
set "CANDIDATE=%~1"
if exist "!CANDIDATE!\bin\windeployqt.exe" (
    set "QT_BIN_PATH=!CANDIDATE!\bin"
    exit /b 0
)
for /d %%m in ("!CANDIDATE!\msvc*_64") do (
    if exist "%%~fm\bin\windeployqt.exe" (
        set "QT_BIN_PATH=%%~fm\bin"
        exit /b 0
    )
)
for /d %%m in ("!CANDIDATE!\*\msvc*_64") do (
    if exist "%%~fm\bin\windeployqt.exe" (
        set "QT_BIN_PATH=%%~fm\bin"
        exit /b 0
    )
)
exit /b 0

:copyDependencyDll
set "CACHE=%~1"
set "CACHE_KEY=%~2"
set "DLL_NAME=%~3"
set "LIB_PATH="

if not exist "%CACHE%" exit /b 0
for /f "tokens=1,* delims==" %%a in ('findstr /b /c:"%CACHE_KEY%:" "%CACHE%"') do (
    set "LIB_PATH=%%b"
)
if not defined LIB_PATH exit /b 0

set "LIB_PATH=!LIB_PATH:/=\!"
for %%d in ("!LIB_PATH!\..\..\bin\%DLL_NAME%") do (
    if exist "%%~fd" (
        copy /Y "%%~fd" "%BUILD_DIR%\Release\%DLL_NAME%" >nul
        echo Copied %DLL_NAME% from %%~fd
    )
)
exit /b 0

:copyDependencyClosure
set "SRC_BIN=%~1"
set "TARGET_DIR=%~2"
set "DUMPBIN_EXE="

for /f "delims=" %%i in ('where dumpbin 2^>nul') do (
    if not defined DUMPBIN_EXE set "DUMPBIN_EXE=%%i"
)
if not defined DUMPBIN_EXE if exist "D:\downloads\AI\dione\bin\build_tools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\dumpbin.exe" (
    set "DUMPBIN_EXE=D:\downloads\AI\dione\bin\build_tools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\dumpbin.exe"
)
if not defined DUMPBIN_EXE (
    echo dumpbin.exe not found; unable to resolve transitive dependencies.
    exit /b 0
)

set "DEPS_SCRIPT=%~dp0copy-runtime-deps.ps1"
if not exist "%DEPS_SCRIPT%" (
    echo Dependency copy script not found: %DEPS_SCRIPT%
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%DEPS_SCRIPT%" -Dumpbin "%DUMPBIN_EXE%" -SourceBin "%SRC_BIN%" -TargetDir "%TARGET_DIR%" -EntryExe "appKhinsiderQT.exe"
if errorlevel 1 (
    echo Failed to resolve transitive dependencies.
    exit /b 1
)
exit /b 0
