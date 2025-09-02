### active_probe.bat

*Description:* Modifies the registry to use a global DNS for network connectivity status and forces a group policy update.

### adb_device_selector.bat

*Description:* Lists connected ADB devices and allows the user to select one. The selected device's ID is then stored in a variable for use in other scripts.

### adb_dns.bat

*Description:* Configures private DNS on an Android device using ADB commands. It can disable private DNS or set a specific DNS provider.

### cdm.bat

*Description:* Copies assets from the Windows Content Delivery Manager to a new folder on the desktop and renames them to `.jpg` files.

### clocksync.bat

*Description:* Synchronizes the computer's date and time with a connected Android device using ADB.

### copy_from_source.bat

*Description:* A script with two modes. The main mode uses `robocopy` to copy files from a source to a destination. An alternative mode is designed for copying contents from a disc drive.

### delete_temp_files.bat

*Description:* Deletes the user's temporary files located in `%userprofile%\AppData\Local\Temp\`.

### file_processing_template.bat

*Description:* A template script for processing files and directories. It validates input, checks for file compatibility, and triggers subroutines for further processing.

### fire_wall.bat

*Description:* A versatile script for managing Windows Firewall rules. It can add rules to allow or block applications for inbound, outbound, or all traffic, supporting both single file and directory processing.

### gdrive_download.bat

*Description:* Uses `robocopy` to copy files from a source (intended to be a Google Drive folder) to a destination.

### get_pc_resolution.bat

*Description:* Gets the computer's screen resolution and uses it to launch `scrcpy` with specific window dimensions and position.

### git_setup.bat

*Description:* Automates the initial setup and configuration of Git on a new system, including user details and default branch name. It also provides an option to generate an SSH key.

### hosted_network.bat

*Description:* Manages a wireless hosted network on Windows. It allows setting up, starting, stopping, and refreshing the hosted network, as well as showing its information.

### if_or_block.bat

*Description:* A simple script that demonstrates how to check if a variable's value is one of several possible values, similar to an "OR" condition in other programming languages.

### install_apks_and_magisk_modules.bat

*Description:* Automates the installation of APK files and Magisk modules on Android devices. It supports batch processing and cleanup after installation.

### install_appX.bat

*Description:* Installs `.appx`, `.msix`, and `.appxbundle` packages using PowerShell. Supports drag-and-drop functionality and batch installation.

### junctions.bat

*Description:* Manages NTFS junction points to create symbolic links between different folder locations for easier navigation and file management.

### measures.bat

*Description:* Waits for 4 minutes, then checks for a specific file on the desktop. If the file exists, it is deleted; otherwise, the user is logged off.

### measures.vbs

*Description:* A VBScript that executes `measures.bat` in a hidden window.

### measures.wsh

*Description:* A Windows Script Host file that specifies the path to `measures.vbs` and sets options for its execution.

### message.bat

*Description:* Sends the message "hesoyam" to the current user.

### multitap.bat

*Description:* A script for multitapping on a phone using ADB. It waits for a specific time, kills long-running cmd processes, and then starts tapping at a specific screen coordinate.

### netReset2.bat

*Description:* Resets the computer's network configuration by releasing and renewing the IP address, flushing the DNS cache, and resetting various network-related settings. It also enables the use of global DNS and forces a group policy update, then prompts for a restart.

### noxhost.bat

*Description:* Modifies the Windows hosts file to block telemetry, ads, and other unwanted connections from the Nox Android Emulator.

### ps1_with_powershell.bat

*Description:* Associates `.ps1` files with PowerShell, allowing them to be executed by double-clicking.

### restart_explorer.bat

*Description:* Restarts the Windows Explorer process.

### send.bat

*Description:* A simple script to push a file to an Android device's primary storage (`/storage/emulated/0/`) using `adb push`.

### setp.bat

*Description:* Adds the current directory to the system's PATH environment variable if it is not already present.

### Steamports.bat

*Description:* Configures the Windows Firewall to allow traffic for Steam Remote Play and VR Streaming by adding rules for the necessary ports.

### TiWorkerPatch.bat

*Description:* A script that repeatedly terminates the `TiWorker.exe` process (part of Windows Update) to prevent high CPU usage.

### TiWorkerPatch.vbs

*Description:* A VBScript that executes `TiWorkerPatch.bat` in a hidden window.

### unbloat.bat

*Description:* Helps in uninstalling or disabling packages on an Android device using ADB. It lists all packages and then prompts the user for a package name to uninstall/disable.

## Directories

### binaries

*Description:* Contains helper scripts and executables utilized by other scripts in this repository.

### binaries/device_selector.bat

*Description:* A helper script for selecting a device from a list of devices.