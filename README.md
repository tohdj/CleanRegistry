# CleanRegistry — Windows Maintenance, Repair & Cleanup Script

<p align="left">
  <img src="https://shields.io" alt="Windows 10 | 11" />
  <img src="https://shields.io" alt="Batch / PowerShell" />
  <img src="https://shields.io" alt="Administrator Required" />
  <img src="https://shields.io" alt="Unlicense" />
  <img src="https://shields.io" alt="Last Commit" />
  <img src="https://shields.io" alt="GitHub Stars" />
</p>

**`CleanRegistry.bat`** is an all-in-one Windows maintenance batch script that creates a System Restore Point, repairs Windows system files, purges temporary system and browser caches, empties the Recycle Bin, and offers a system restart.

---

## 📑 Table of Contents

- [✨ Features](#-features)
  - [Additional Capabilities](#additional-capabilities)
- [📋 Prerequisites](#-prerequisites)
- [🚀 Usage](#-usage)
- [📄 Sample Log Output](#-sample-log-output)
- [⚠️ Important Warnings](#️-important-warnings)
- [❓ Troubleshooting & FAQ](#-troubleshooting--faq)
- [📄 License](#-license)

---

## ✨ Features

The script executes a 7-step automated maintenance routine:

1. **System Restore Point Creation**: Automatically enables System Restore on the `C:` drive and creates a restore point (`Pre-Cleanup Maintenance`) before making any changes.
2. **Windows Image Repair (DISM)**: Runs `DISM.exe /Online /Cleanup-image /Restorehealth` to check for and repair corruption in the Windows component store.
3. **System File Checker (SFC)**: Runs `sfc /scannow` to scan and restore corrupted or missing Windows system files.
4. **Temporary & Prefetch Cleanup**: Purges files from the user `%TEMP%` directory, `%WINDIR%\Temp`, and `%WINDIR%\Prefetch`.
5. **Windows Update Cache Reset**: Safely stops the Windows Update (`wuauserv`) and Background Intelligent Transfer (`bits`) services, clears the `SoftwareDistribution\Download` folder, and restarts the services.
6. **Multi-Browser Cache Purge**: Force-closes active browser processes and clears cached data for **Google Chrome**, **Microsoft Edge**, and **Mozilla Firefox**.
7. **Recycle Bin Cleanup**: Silently empties the Windows Recycle Bin.

### Additional Capabilities
* **Privilege Verification**: Automatically checks for Administrator rights before executing and prompts the user if elevation is missing.
* **Detailed Logging**: Generates a timestamped `SystemRepair_Log.txt` on the user's Desktop (or `C:\` as a fallback) detailing every step and command output.
* **Reboot Prompt**: Offers an interactive prompt at the end of the process to restart the computer with a 10-second grace period.

---

## 📋 Prerequisites

* **Operating System**: Windows 10 or Windows 11.
* **Permissions**: Must be executed with **Administrator** privileges.
* **PowerShell**: Enabled (used for creating restore points and emptying the Recycle Bin).

---

## 🚀 Usage

1. Clone the repository or download **`CleanRegistry.bat`** directly from the [Code](https://github.com) page:
   ```cmd
   git clone https://github.com.git
   ```
2. **Save and close all open work**, especially in web browsers, as the script will force-close Chrome, Edge, and Firefox.
3. Right-click **`CleanRegistry.bat`** and select **Run as administrator**.
4. Wait for all 7 steps to complete (DISM and SFC scans may take several minutes depending on your drive speed and system health).
5. When prompted, type `Y` to restart your computer immediately or `N` to exit and reboot manually later.
6. Review `SystemRepair_Log.txt` on your Desktop for detailed results.

---

## 📄 Sample Log Output

After running **`CleanRegistry.bat`**, a detailed report is saved to `%USERPROFILE%\Desktop\SystemRepair_Log.txt`:

```text
============================================================
System Repair & Advanced Cleanup Log - Wed 11/11/2026 21:45:12.08
============================================================

Creating System Restore Point...
Restore Point step completed.

Running DISM...
Deployment Image Servicing and Management tool
Version: 10.0.22621.2792

Image Version: 10.0.22631.4317

[==========================100.0%==========================] The restore operation completed successfully.
The operation completed successfully.
DISM step completed.

Running SFC...
Beginning system scan.  This process will take some time.

Beginning verification phase of system scan.
Verification 100% complete.

Windows Resource Protection did not find any integrity violations.
SFC step completed.

Cleaning Temp folders...
Temp and Prefetch caches cleared.

Clearing Windows Update Cache...
The Windows Update service is stopping.
The Windows Update service was stopped successfully.

The Background Intelligent Transfer Service service is not started.

The Windows Update service is starting.
The Windows Update service was started successfully.

The Background Intelligent Transfer Service service is starting.
The Background Intelligent Transfer Service service was started successfully.

Windows Update cache purged and services restarted.

Cleaning Browser Caches...
Chrome cache cleared.
Edge cache cleared.
Firefox cache cleared.
Browser cleanup complete.

Emptying Recycle Bin...
Recycle Bin successfully emptied.

============================================================
Repair and Advanced Cleanup complete at 21:51:44.62
============================================================
```

---

## ⚠️ Important Warnings

* **Browsers Will Force Close**: Step 6 uses `taskkill /f` on `chrome.exe`, `msedge.exe`, and `firefox.exe`. Ensure you have saved any open tabs or form data before running `CleanRegistry.bat`.
* **Recycle Bin Deletion is Permanent**: Step 7 permanently deletes all items currently in your Recycle Bin without a confirmation prompt.
* **Browser Profiles**: For Chrome and Edge, the script targets the `Default` user profile cache. Additional browser profiles will not be cleared by default.
* **Note on Naming**: Despite the repository name `CleanRegistry`, this script performs Windows component store repairs (DISM/SFC) and system/browser cache cleanup rather than direct Windows Registry modifications.

---

## ❓ Troubleshooting & FAQ

### **Windows Defender SmartScreen blocks the `.bat` file when I try to run it.**
Because `.bat` files downloaded from the internet do not carry a digital signature, Windows SmartScreen may show a *"Windows protected your PC"* pop-up.
* **Fix**: Click **More info** and then select **Run anyway**. You can also right-click `CleanRegistry.bat`, open **Properties**, check **Unblock** at the bottom of the General tab, and click **Apply**.

### **The script says `[ERROR] This script must be run as an Administrator` and exits.**
System-level operations like DISM, SFC, and stopping Windows Update services require elevated privileges.
* **Fix**: Do not double-click the file directly. Instead, right-click `CleanRegistry.bat` and select **Run as administrator**.

### **Step 2 (DISM) or Step 3 (SFC) appears frozen at `62.3%` or `100%`.**
This is normal Windows behavior. DISM and SFC pause on specific percentage milestones while verifying large component packages or writing repair logs.
* **Fix**: Allow the terminal window to run uninterrupted for 5–15 minutes before assuming it has stalled.

### **Step 1 fails to create a System Restore Point.**
Windows blocks creating multiple restore points within a 24-hour window by default (`SystemRestorePointCreationFrequency`), or Volume Shadow Copy services may be disabled.
* **Fix**: The script is designed to continue safely even if Step 1 is skipped. Check `SystemRepair_Log.txt` on your Desktop for the exact PowerShell message.

### **Will this delete my saved passwords, bookmarks, or browsing history?**
No. Step 6 only clears the `Cache`, `Code Cache`, `cache2`, and `jumpListCache` folders. Your bookmarks, saved passwords, extensions, and cookies remain untouched.

### **Where can I find the log file if it is not on my Desktop?**
If your Desktop path is redirected (for example, via OneDrive) or cannot be resolved, the script automatically falls back to saving the log at `C:\SystemRepair_Log.txt`.

---

## 📄 License

This project is free and unencumbered software released into the public domain under the [Unlicense](LICENSE).
