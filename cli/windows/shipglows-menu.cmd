@echo off
setlocal DisableDelayedExpansion
rem Show the native selector while one session-bound PowerShell backend warms.
if not exist "%SHIPGLOWS_MANAGED_PWSH%" exit /b 70
if not exist "%~dp0shipglows-devserver.ps1" exit /b 70
if not exist "%~dp0shipglows-menu.txt" exit /b 70
if not exist "%~dp0ShipGlows.MenuSession.ps1" exit /b 70
set "_SHIPGLOWS_FZF="
for %%F in (fzf.exe) do set "_SHIPGLOWS_FZF=%%~$PATH:F"
if not defined _SHIPGLOWS_FZF exit /b 70
if not exist "%TEMP%\" exit /b 70
:shipglows_channel
set "_SHIPGLOWS_PIPE=shipglows-menu-%RANDOM%-%RANDOM%"
set "_SHIPGLOWS_CHANNEL=%TEMP%\%_SHIPGLOWS_PIPE%"
if exist "%_SHIPGLOWS_CHANNEL%.*" goto shipglows_channel
set "_SHIPGLOWS_SELECTION=%_SHIPGLOWS_CHANNEL%.selection"
start "" /b "%SHIPGLOWS_MANAGED_PWSH%" -NoLogo -NoProfile -File "%~dp0ShipGlows.MenuSession.ps1" -RequestPath "%_SHIPGLOWS_CHANNEL%.request"

:shipglows_menu
"%_SHIPGLOWS_FZF%" --height=~60%% --layout=reverse --border --prompt "What do you want to do? > " --no-multi < "%~dp0shipglows-menu.txt" > "%_SHIPGLOWS_SELECTION%"
if errorlevel 131 goto shipglows_menu_unavailable
if errorlevel 130 goto shipglows_menu
if errorlevel 2 goto shipglows_menu_unavailable
if errorlevel 1 goto shipglows_menu
set "_SHIPGLOWS_CHOICE="
rem Validate the one-character key before FOR reads it; selected text is never executed.
"%SystemRoot%\System32\findstr.exe" /r /b /c:"[1-9nartu0]  " "%_SHIPGLOWS_SELECTION%" > "%_SHIPGLOWS_CHANNEL%.validated"
for /f "usebackq tokens=1" %%K in ("%_SHIPGLOWS_CHANNEL%.validated") do set "_SHIPGLOWS_CHOICE=%%K"
if not defined _SHIPGLOWS_CHOICE goto shipglows_menu
del /q "%_SHIPGLOWS_SELECTION%" "%_SHIPGLOWS_CHANNEL%.validated" >nul 2>&1
> "%_SHIPGLOWS_CHANNEL%.request.new" echo(%_SHIPGLOWS_CHOICE%
move /y "%_SHIPGLOWS_CHANNEL%.request.new" "%_SHIPGLOWS_CHANNEL%.request" >nul
if "%_SHIPGLOWS_CHOICE%"=="0" exit /b 0
rem The wait helper never reads input. Parse the whole return path before a
rem running updater can replace this launcher. Only pre-action failure 70
rem permits the ordinary persistent fallback.
(
type "\\.\pipe\%_SHIPGLOWS_PIPE%" >nul 2>&1
if errorlevel 1 (
"%SHIPGLOWS_MANAGED_PWSH%" -NoLogo -NoProfile -File "%~dp0ShipGlows.MenuSession.ps1" -RequestPath "%_SHIPGLOWS_CHANNEL%.request" -Wait
if errorlevel 71 call exit /b %%errorlevel%%
if not errorlevel 70 call exit /b %%errorlevel%%
if exist "%_SHIPGLOWS_CHANNEL%.accepted" exit /b 1
"%SHIPGLOWS_MANAGED_PWSH%" -NoLogo -NoProfile -File "%~dp0shipglows-devserver.ps1" -InitialMenuSelection %_SHIPGLOWS_CHOICE%
call exit /b %%errorlevel%%
)
rem The helper publishes a closed numeric code before closing the pipe.
"%SystemRoot%\System32\findstr.exe" /r /x /c:"[0-9]" /c:"[0-9][0-9]" /c:"[01][0-9][0-9]" /c:"2[0-4][0-9]" /c:"25[0-5]" "%_SHIPGLOWS_CHANNEL%.done" > "%_SHIPGLOWS_CHANNEL%.validated"
if errorlevel 1 exit /b 1
for /f "usebackq tokens=1" %%E in ("%_SHIPGLOWS_CHANNEL%.validated") do set "_SHIPGLOWS_EXIT=%%E"
if not exist "%_SHIPGLOWS_CHANNEL%.accepted" (
"%SystemRoot%\System32\findstr.exe" /l /x /c:"70" "%_SHIPGLOWS_CHANNEL%.done" >nul
if not errorlevel 1 (
del /q "%_SHIPGLOWS_CHANNEL%.request" "%_SHIPGLOWS_CHANNEL%.worker" "%_SHIPGLOWS_CHANNEL%.done" "%_SHIPGLOWS_CHANNEL%.validated" >nul 2>&1
"%SHIPGLOWS_MANAGED_PWSH%" -NoLogo -NoProfile -File "%~dp0shipglows-devserver.ps1" -InitialMenuSelection %_SHIPGLOWS_CHOICE%
call exit /b %%errorlevel%%
)
)
del /q "%_SHIPGLOWS_CHANNEL%.request" "%_SHIPGLOWS_CHANNEL%.worker" "%_SHIPGLOWS_CHANNEL%.done" "%_SHIPGLOWS_CHANNEL%.accepted" "%_SHIPGLOWS_CHANNEL%.validated" >nul 2>&1
call exit /b %%_SHIPGLOWS_EXIT%%
)

:shipglows_menu_unavailable
del /q "%_SHIPGLOWS_SELECTION%" "%_SHIPGLOWS_CHANNEL%.validated" >nul 2>&1
> "%_SHIPGLOWS_CHANNEL%.request.new" echo(0
move /y "%_SHIPGLOWS_CHANNEL%.request.new" "%_SHIPGLOWS_CHANNEL%.request" >nul
exit /b 70
