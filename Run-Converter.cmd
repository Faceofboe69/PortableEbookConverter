@echo off
REM ==========================================================================
REM  Portable Ebook Converter - launcher
REM  Double-click this file to start the converter GUI. No installation needed.
REM  It runs the bundled PowerShell script with an execution policy bypass so
REM  nothing has to be installed or changed on the machine.
REM ==========================================================================
setlocal
set "HERE=%~dp0"

REM Prefer Windows PowerShell (present on all Windows 10/11 installs).
where powershell >nul 2>&1
if %ERRORLEVEL%==0 (
    powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%HERE%Convert-Ebooks.ps1"
    goto :end
)

REM Fall back to PowerShell 7+ (pwsh) if the classic one is missing.
where pwsh >nul 2>&1
if %ERRORLEVEL%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -STA -File "%HERE%Convert-Ebooks.ps1"
    goto :end
)

echo PowerShell was not found on this system. It ships with Windows 10 and 11.
pause

:end
endlocal
