@echo off
:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Running with Administrator privileges.
) else (
    echo [ERROR] This script must be run as an Administrator.
    echo Please right-click the batch file and select "Run as administrator".
    pause
    exit /b
)

:: Define a safe log file path (Fallback to C:\ if Desktop/UserProfile isn't resolved)
if exist "%USERPROFILE%\Desktop" (
    set "LOGFILE=%USERPROFILE%\Desktop\SystemRepair_Log.txt"
) else (
    set "LOGFILE=%SystemDrive%\SystemRepair_Log.txt"
)

echo ============================================================
echo "Starting System Maintenance, Repair, & Browser Cache Purge"
echo "Logs will be saved to: %LOGFILE%"
echo ============================================================
echo.

:: Initialize the log file with header info
echo ============================================================ > "%LOGFILE%"
echo System Repair ^& Advanced Cleanup Log - %DATE% %TIME% >> "%LOGFILE%"
echo ============================================================ >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: 1. Create a System Restore Point
echo [STEP 1/7] Creating a System Restore Point for safety...
echo Creating System Restore Point... >> "%LOGFILE%"
powershell -NoProfile -Command "Enable-ComputerRestore -Drive 'C:'" >> "%LOGFILE%" 2>&1
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Pre-Cleanup Maintenance' -RestorePointType 'MODIFY_SETTINGS'" >> "%LOGFILE%" 2>&1
echo Restore Point step completed. >> "%LOGFILE%"
echo.

:: 2. Run DISM to repair the Windows component store image
echo [STEP 2/7] Running DISM to check and repair Windows image files...
echo Running DISM... >> "%LOGFILE%"
DISM.exe /Online /Cleanup-image /Restorehealth >> "%LOGFILE%" 2>&1
echo DISM step completed. >> "%LOGFILE%"
echo.

:: 3. Run SFC to scan and fix corrupted system files
echo [STEP 3/7] Running System File Checker (SFC) to fix file integrity...
echo Running SFC... >> "%LOGFILE%"
sfc /scannow >> "%LOGFILE%" 2>&1
echo SFC step completed. >> "%LOGFILE%"
echo.

:: 4. Clear System and User Temp Folders
echo [STEP 4/7] Purging System and User Temporary Cache files...
echo Cleaning Temp folders... >> "%LOGFILE%"
del /q /f /s "%TEMP%\*.*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rmdir /s /q "%%x" >nul 2>&1
del /q /f /s "%WINDIR%\Temp\*.*" >nul 2>&1
for /d %%x in ("%WINDIR%\Temp\*") do rmdir /s /q "%%x" >nul 2>&1
del /q /f /s "%WINDIR%\Prefetch\*.*" >nul 2>&1
for /d %%x in ("%WINDIR%\Prefetch\*") do rmdir /s /q "%%x" >nul 2>&1
echo Temp and Prefetch caches cleared. >> "%LOGFILE%"
echo.

:: 5. Clear Windows Update Cache (SoftwareDistribution)
echo [STEP 5/7] Resetting and clearing Windows Update cache...
echo Clearing Windows Update Cache... >> "%LOGFILE%"
net stop wuauserv >> "%LOGFILE%" 2>&1
net stop bits >> "%LOGFILE%" 2>&1
del /q /f /s "%WINDIR%\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%x in ("%WINDIR%\SoftwareDistribution\Download\*") do rmdir /s /q "%%x" >nul 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1
net start bits >> "%LOGFILE%" 2>&1
echo Windows Update cache purged and services restarted. >> "%LOGFILE%"
echo.

:: 6. Clear Browser Caches (Google Chrome, Microsoft Edge, Mozilla Firefox)
echo [STEP 6/7] Purging Google Chrome, Microsoft Edge, and Firefox caches...
echo Cleaning Browser Caches... >> "%LOGFILE%"

:: Force close browsers to release file locks on cache directories
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im firefox.exe >nul 2>&1

:: Google Chrome Cache Removal
if exist "%LOCALAPPDATA%\Google\Chrome\User Data" (
    del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
    del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache\*.*" >nul 2>&1
    echo Chrome cache cleared. >> "%LOGFILE%"
)

:: Microsoft Edge Cache Removal
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data" (
    del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
    del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache\*.*" >nul 2>&1
    echo Edge cache cleared. >> "%LOGFILE%"
)

:: Mozilla Firefox Cache Removal
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    del /q /f /s "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2\*.*" >nul 2>&1
    del /q /f /s "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\jumpListCache\*.*" >nul 2>&1
    echo Firefox cache cleared. >> "%LOGFILE%"
)
echo Browser cleanup complete. >> "%LOGFILE%"
echo.

:: 7. Empty the Recycle Bin
echo [STEP 7/7] Automatically emptying the Recycle Bin...
echo Emptying Recycle Bin... >> "%LOGFILE%"
powershell -NoProfile -Command "Clear-RecycleBin -Confirm:$false" >> "%LOGFILE%" 2>&1
echo Recycle Bin successfully emptied. >> "%LOGFILE%"
echo.

echo ============================================================ >> "%LOGFILE%"
echo Repair and Advanced Cleanup complete at %TIME% >> "%LOGFILE%"
echo ============================================================ >> "%LOGFILE%"

echo ============================================================
echo All processes complete! Log saved.
echo ============================================================
echo.

:: Prompt the user for an automatic restart
set /p REBOOT="Would you like to restart your computer now? (Y/N): "
if /i "%REBOOT%"=="Y" (
    echo Restarting computer in 10 seconds. Save all open work!
    shutdown /r /t 10 /c "System maintenance complete. Rebooting system."
) else (
    echo Restart canceled. Exiting script.
    pause
)
