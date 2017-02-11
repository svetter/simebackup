@echo off
color 0A
title SimeBackup

:cleanvars
set src=
set dst=
set incl_sys=
set excl_custom=


:label
echo.
echo     =====     SimeBackup     =====
echo     ====         v1.0         ====
echo     ===       11.02.2017       ===
echo.
echo.

:setup
echo     ===  Directory selection   ===
echo.
set /p src= Enter backup source directory: 
set /p dst= Enter backup destination directory: 
echo.
echo     ===    Folder exclusion    ===
echo.
set /p incl_sys= Include system folders? (y/n, default no): 
echo Exclude any folders? Leave empty if no, format: "folder1" "folder2" ...
set /p excl_custom= Exclude these folders: 

set excl_temp="Backup logs"
if defined excl_custom set excl_temp=%excl_temp% %excl_custom%

set excl="System Volume Information" "$RECYCLE.BIN" %excl_temp%
if not defined incl_sys goto cont
if %incl_sys%==y (
	set excl=%excl_temp%
)

:cont
echo.
echo excluding: %excl%
echo.
echo     ===      Begin Backup      ===
echo.
color 0A
echo Careful! All data in %dst% could be deleted!
set /p continue= Press Enter to begin backup, type to abort... 
color 0A
if defined continue goto abort

:preparelog
for /f "tokens=2-4 delims=/. " %%a in ('date /t') do (set dt=%%c.%%b.%%a)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set tm=%%a.%%b)
set logf=%dt%_%tm%.log


:copy
robocopy %src% %dst% * /mir /copy:DATO /dcopy:T /mon:0 /xd %excl% /r:10 /w:10 /v /unilog+:%logf% /tee


:movelog
set logdir="%dst%/Backup logs"
if not exist %logdir% mkdir %logdir%
robocopy %cd% %logdir% %logf% /mov /a-:SH /ns /nc /nfl /ndl /np /njh /njs
rem move %cd%/%logf% %logdir%
goto restart

:abort
echo.
echo     ===     Backup aborted     ===
echo.
echo To complete the backup, don't type any characters on the "Press Enter to begin backup" prompt.
echo Restarting...
echo.
echo.
echo.
goto cleanvars

:restart
pause
goto cleanvars

:end
pause