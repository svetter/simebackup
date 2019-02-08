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
echo         ==============================
echo         ======    SimeBackup    ======
echo         ====         v1.7         ====
echo         ===       08.02.2019       ===
echo.
echo.
echo.
echo                  Please note:
echo SimeBackup must be run as administrator to work.

:setup
echo.
echo.
echo         ===  Directory selection   ===
echo.
set /p src= Enter backup source directory: 
set /p dst= Enter backup destination directory: 
echo.
echo.
echo         ===    Folder exclusion    ===
echo.
set /p incl_sys= Include system folders? (y/n, default no): 
echo Exclude any folders? Leave empty if no, format: "folder1" "folder2" ...
set /p excl_custom= Exclude these folders: 

set excl_temp="Backup logs"
if defined excl_custom set excl_temp=%excl_temp% %excl_custom%

set excl="System Volume Information" "$RECYCLE.BIN" "WindowsApps" "Temp" ".bzvol" ".tmp.drivedownload" %excl_temp%
if not defined incl_sys goto cont
if %incl_sys%==y (
	set excl=%excl_temp%
)

:cont
echo.
echo excluding: %excl%
echo.
echo.
echo         ===      Begin Backup      ===
echo.
echo Careful! All data in %dst% could be deleted!
timeout 4 > nul
echo.
set /p continue= Press Enter to begin backup, type to abort... 
if defined continue goto abort

:preparelog
for /f "tokens=2-4 delims=/. " %%a in ('date /t') do (set dt=%%c.%%b.%%a)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set tm=%%a.%%b)
set logf=backup_log_%dt%_%tm%.log


:copy
robocopy "%src%\\" "%dst%\\" * /xf "%src%\pagefile.sys" "%dst%\desktop.ini" /xd %excl% /mir /copy:DATO /dcopy:T /r:6 /w:5 /v /unilog+:%logf% /tee


:movelog
if not defined dst goto nodst
attrib -s -h +r "%dst%" > nul
set logdir="%dst%/Backup logs"
if not exist %logdir% mkdir %logdir%
robocopy "%cd%" %logdir% %logf% /mov /a-:SH > nul
rem echo.
rem echo.
rem echo Fixing folder icons...
rem cmd /c attrib +r %dst%\* /s /d > nul
rem echo halfway done...
rem cmd /c attrib -r %dst%\* /s > nul
rem echo done.
echo.
echo.
pause
goto restart

:nodst
echo.
echo.
echo         ===     Backup failed      ===
echo.
echo No destination directory specified.
echo.
del "%cd%\%logf%"
pause
goto restart

:abort
echo.
echo.
echo         ===     Backup aborted     ===
echo.
echo To complete the backup, don't type any characters on the "Press Enter to begin backup" prompt.
echo.
pause
goto restart

:restart
set continue=
echo Restarting...
echo.
echo.
echo.
goto cleanvars

:end
pause
exit