@echo off
setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0..\.."
for %%p in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fp"
set "PROJECT_DEPS_ROOT=%PROJECT_DIR%\third_party\windows\deps"
set "BUILD_DIR=%PROJECT_DIR%\build"

set "QT_FOUND=false"
set "QT_MSVC_PATH="

if defined QT_CMAKE_PATH (
    if exist "%QT_CMAKE_PATH%\Qt6\Qt6Config.cmake" (
        set "QT_MSVC_PATH=%QT_CMAKE_PATH%"
        set "QT_FOUND=true"
    ) else if exist "%QT_CMAKE_PATH%\Qt6Config.cmake" (
        set "QT_MSVC_PATH=%QT_CMAKE_PATH%"
        set "QT_FOUND=true"
    ) else (
        echo QT_CMAKE_PATH is set but no Qt6Config.cmake was found in "%QT_CMAKE_PATH%".
    )
)

if not !QT_FOUND!==true call :findQtInRoot "C:\Qt"
if not !QT_FOUND!==true call :findQtInRoot "%USERPROFILE%\Qt"
if not !QT_FOUND!==true call :findQtInRoot "%USERPROFILE%\Documents\Qt"
if not !QT_FOUND!==true call :findQtInRoot "D:\Documents\projects\software\line desktop access\temp_qt"

if not !QT_FOUND!==true (
    echo Could not find a Qt installation with Qt6Config.cmake.
    echo Set QT_CMAKE_PATH to a Qt CMake folder, usually "...\\msvc*_64\\lib\\cmake".
    exit /b 1
)

if not exist "!QT_MSVC_PATH!\Qt6\Qt6Config.cmake" if not exist "!QT_MSVC_PATH!\Qt6Config.cmake" (
    echo Qt CMake path is invalid: "!QT_MSVC_PATH!"
    exit /b 1
)

set "USE_VCPKG=false"
if not defined VCPKG_ROOT (
    if exist "C:\vcpkg\scripts\buildsystems\vcpkg.cmake" set "VCPKG_ROOT=C:\vcpkg"
)
if not defined VCPKG_ROOT (
    if exist "%USERPROFILE%\vcpkg\scripts\buildsystems\vcpkg.cmake" set "VCPKG_ROOT=%USERPROFILE%\vcpkg"
)
if defined VCPKG_ROOT (
    if exist "%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" (
        set "USE_VCPKG=true"
    ) else (
        echo VCPKG_ROOT is set to "%VCPKG_ROOT%" but toolchain file was not found there.
    )
)

echo Using Qt from: !QT_MSVC_PATH!

if !USE_VCPKG!==true (
    echo Using vcpkg from: "%VCPKG_ROOT%"
    cmake -S "!PROJECT_DIR!" -B "!BUILD_DIR!" -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" -DCMAKE_PREFIX_PATH="!QT_MSVC_PATH!"
    exit /b %errorlevel%
)

set "DEPS_ROOT="
if not defined DEPS_ROOT call :tryDepsRoot "%PROJECT_DEPS_ROOT%"
if defined KH_DEPS_ROOT call :tryDepsRoot "%KH_DEPS_ROOT%"
if not defined DEPS_ROOT if defined CONDA_PREFIX call :tryDepsRoot "%CONDA_PREFIX%\Library"
if not defined DEPS_ROOT call :tryDepsRoot "%USERPROFILE%\Miniconda3\Library"
if not defined DEPS_ROOT call :tryDepsRoot "%USERPROFILE%\miniconda3\Library"
if not defined DEPS_ROOT call :tryDepsRoot "D:\downloads\AI\pinokio\bin\miniconda\Library"

if not defined DEPS_ROOT (
    echo Could not find curl/libxml2 dependencies.
    echo Install vcpkg and set VCPKG_ROOT, or set KH_DEPS_ROOT to a folder like "^<conda^>\Library".
    exit /b 1
)

set "LIBXML_LIBRARY=!DEPS_ROOT!\lib\libxml2.lib"
if not exist "!LIBXML_LIBRARY!" set "LIBXML_LIBRARY=!DEPS_ROOT!\lib\xml2.lib"

echo Using fallback dependencies from: !DEPS_ROOT!
cmake -S "!PROJECT_DIR!" -B "!BUILD_DIR!" ^
 -DCMAKE_TOOLCHAIN_FILE= ^
 -DCMAKE_PREFIX_PATH="!QT_MSVC_PATH!;!DEPS_ROOT!" ^
 -DCURL_INCLUDE_DIR="!DEPS_ROOT!\include" ^
 -DCURL_LIBRARY="!DEPS_ROOT!\lib\libcurl.lib" ^
 -DLIBXML2_INCLUDE_DIR="!DEPS_ROOT!\include\libxml2" ^
 -DLIBXML2_LIBRARY="!LIBXML_LIBRARY!"
exit /b %errorlevel%

:findQtInRoot
set "ROOT=%~1"
if not exist "!ROOT!" exit /b 0
call :checkQtLayout "!ROOT!"
if !QT_FOUND!==true exit /b 0
for /d %%d in ("!ROOT!\*") do (
    call :checkQtLayout "%%~fd"
    if !QT_FOUND!==true exit /b 0
)
exit /b 0

:checkQtLayout
set "CANDIDATE=%~1"
if exist "!CANDIDATE!\lib\cmake\Qt6\Qt6Config.cmake" (
    set "QT_MSVC_PATH=!CANDIDATE!\lib\cmake"
    set "QT_FOUND=true"
    exit /b 0
)
for /d %%m in ("!CANDIDATE!\msvc*_64") do (
    if exist "%%~fm\lib\cmake\Qt6\Qt6Config.cmake" (
        set "QT_MSVC_PATH=%%~fm\lib\cmake"
        set "QT_FOUND=true"
        exit /b 0
    )
)
for /d %%m in ("!CANDIDATE!\*\msvc*_64") do (
    if exist "%%~fm\lib\cmake\Qt6\Qt6Config.cmake" (
        set "QT_MSVC_PATH=%%~fm\lib\cmake"
        set "QT_FOUND=true"
        exit /b 0
    )
)
exit /b 0

:tryDepsRoot
set "CANDIDATE=%~1"
if "%CANDIDATE%"=="" exit /b 0
if not exist "%CANDIDATE%" exit /b 0
if exist "%CANDIDATE%\include\curl\curl.h" if exist "%CANDIDATE%\include\libxml2\libxml\parser.h" if exist "%CANDIDATE%\lib\libcurl.lib" (
    if exist "%CANDIDATE%\lib\libxml2.lib" (
        set "DEPS_ROOT=%CANDIDATE%"
        exit /b 0
    )
    if exist "%CANDIDATE%\lib\xml2.lib" (
        set "DEPS_ROOT=%CANDIDATE%"
        exit /b 0
    )
)
exit /b 0
