@echo off
setlocal

call "%~dp0clean.bat"
call "%~dp0updateversion.bat"
call "%~dp0configure.bat"
if errorlevel 1 exit /b %errorlevel%
call "%~dp0build.bat"
if errorlevel 1 exit /b %errorlevel%
call "%~dp0deploy.bat"
exit /b %errorlevel%
