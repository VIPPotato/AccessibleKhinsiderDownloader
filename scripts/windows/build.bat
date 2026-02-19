@echo off
setlocal

set "PROJECT_DIR=%~dp0..\.."
for %%p in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fp"
set "BUILD_DIR=%PROJECT_DIR%\build"

cmake --build "%BUILD_DIR%" --config Release --parallel
if errorlevel 1 exit /b %errorlevel%

ctest --test-dir "%BUILD_DIR%" -C Release --output-on-failure
exit /b %errorlevel%
