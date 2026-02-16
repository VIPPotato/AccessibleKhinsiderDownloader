@echo off
setlocal

set "PROJECT_DIR=%~dp0..\.."
for %%p in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fp"

call :removeDir "%PROJECT_DIR%\build"
call :removeDir "%PROJECT_DIR%\cmake-build-debug"
call :removeDir "%PROJECT_DIR%\vcpkg_installed"
call :removeDir "%PROJECT_DIR%\Output"
call :removeDir "%PROJECT_DIR%\.rcc"
call :removeDir "%PROJECT_DIR%\.qt"
exit /b 0

:removeDir
if exist "%~1" rd /s /q "%~1"
exit /b 0
