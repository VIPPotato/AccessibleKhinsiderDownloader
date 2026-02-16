@echo off
setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0..\.."
for %%p in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fp"
set "BUILD_DIR=%PROJECT_DIR%\build"
set "EXE_PATH=%BUILD_DIR%\Release\appKhinsiderQT.exe"
set "CACHE_FILE=%BUILD_DIR%\CMakeCache.txt"
set "QT_BIN_PATH="

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
