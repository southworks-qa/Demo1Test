@echo off
setlocal
CD /d "%~dp0"

REM Removed Admin Priviledge Requirement
REM ::Test If script has Admin Priviledges/is elevated
REM REG QUERY "HKU\S-1-5-19"
REM IF %ERRORLEVEL% NEQ 0 (
REM     ECHO Please run this script as an administrator
REM     pause
REM     EXIT /B 1
REM )

cls

IF EXIST %WINDIR%\SysWow64 (
set powerShellDir=%WINDIR%\SysWow64\windowspowershell\v1.0
) ELSE (
set powerShellDir=%WINDIR%\system32\windowspowershell\v1.0
)

call %powerShellDir%\powershell.exe -Command Set-ExecutionPolicy unrestricted

cls

call %powerShellDir%\powershell.exe -Command "&'.\Setup\tasks\install-demotoolkit.ps1'"; exit $LASTEXITCODE

IF %ERRORLEVEL% == 1 GOTO exit

cls

call %powerShellDir%\powershell.exe -Command "&'.\Setup\setup.local.ps1'"

:exit


