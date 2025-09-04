# Overview of Batch Scripts Repository

This repository contains a collection of scripts that are passively maintained. Below is a structured overview of each file and directory, detailing their functions and purposes.

## Table of Contents

- [Overview of Batch Scripts Repository](#overview-of-batch-scripts-repository)
  - [Table of Contents](#table-of-contents)
  - [Directories](#directories)
    - [binaries](#binaries)
    - [by_claude](#by_claude)
    - [powershell](#powershell)
  - [Batch Scripts](#batch-scripts)

## Scripts

### lab\proj.txt

*Description:* A project description for a VBScript that gets gateway information for WiFi, mobile hotspot, and Ethernet connections.

### lab\lab.bat

*Description:* A batch script that calls the VBScript `GetGateways_Strict_Debug.vbs` and processes its output to get gateway information.

### lab\GetGateways_Strict_Debug.vbs

*Description:* A VBScript that returns the gateway IP addresses for different network adapters, including WiFi, Ethernet, and mobile hotspots.

### lab\ip.vbs

*Description:* A VBScript that displays IPv4 addresses and default gateways for all network adapters.

### binaries\dots.bat

*Description:* A batch script that displays a series of animations using `echo` and `ping` commands.

### binaries\file_or_folder.bat

*Description:* A batch script that checks if a given path is a file or a folder.

### binaries\get_admin.bat

*Description:* A batch script that requests administrative privileges if the script is not already running with them.

### binaries\getandroid.cmd

*Description:* A command script that lists connected Android devices and allows the user to select one.

### binaries\header.bat

*Description:* A binary file, content cannot be displayed.

### binaries\s.bat

*Description:* A batch script that finds and displays the wireless gateway address.

### binaries\s1.bat

*Description:* A simple batch script that sets a variable `y` to the value `selector` using `set0` and then echoes the value of `y`.

### binaries\script_location_validator.bat

*Description:* A batch script that validates if a callback script exists and is executable.

### binaries\selector.bat

*Description:* A batch script that takes a command as input, displays the output of the command as a numbered list, and allows the user to select an option from the list.

### binaries\set0.cmd

*Description:* A command script that assigns the output of a command to a variable.

### binaries\stringlength_counter.bat

*Description:* A batch script that truncates a string. It seems to be a helper function for another script.

### binaries\t.bat

*Description:* A simple batch script that echoes a string of "q"s.

### binaries\test.bat

*Description:* A test script that uses `set0.cmd` to assign the output of the `t.bat` script to the variable `x` and then echoes the value of `x`.

### by_claude\1.bat

*Description:* A batch script that backs up the PowerShell color palette to a .reg file on the desktop.

### by_claude\dynamic_batch_menu.bat

*Description:* A batch script that provides a dynamic menu for file operations, system information, and network tools.

### by_claude\Power.bat

*Description:* A batch script that allows viewing, modifying, and resetting PowerShell's color settings.

### by_claude\reg2bat.bat

*Description:* A batch script that converts a .reg file into a .bat file that applies the registry changes.

### by_claude\themebackup.bat

*Description:* A batch script that backs up the current Windows theme settings to a .reg file.

### gateway\adb_device_selector.bat

*Description:* A batch script that lists connected Android devices and allows the user to select one.

### gateway\beta_v2.0\AI Research Report Template.pdf

*Description:* A technical research report about establishing an FTP connection to a phone.

### gateway\beta_v2.0\binaries\auto_ftp_connector.bat

*Description:* A batch script that automatically detects and connects to a phone's FTP server across multiple network configurations.

### gateway\beta_v2.0\binaries\checkftp.bat

*Description:* A batch script that checks if a given port is open on a given IP address using PowerShell.

### gateway\beta_v2.0\binaries\gateway.vbs

*Description:* A VBScript that detects the gateway of the active network connection, with a focus on identifying mobile hotspots.

### gateway\beta_v2.0\binaries\main.bat

*Description:* A batch script that repeatedly checks if an FTP server is accessible at a specific IP address and port.

### gateway\beta_v2.0\FTP Automation Setup Guide.pdf

*Description:* A setup guide for the Automated FTP Phone Connection solution.

### gateway\beta_v2.0\ftp_config_manager.bat

*Description:* A batch script that provides a comprehensive menu-driven interface for managing FTP connection settings, including viewing, editing, and testing configurations, as well as managing network profiles.

### gateway\beta_v2.0\ftp_connection_log.txt

*Description:* A log file that contains records of successful FTP connections.

### gateway\beta_v2.0\ftp_launcher_main.bat

*Description:* A comprehensive batch script that acts as a central launcher for a suite of tools designed to connect to a phone's FTP server. It provides a menu-driven interface with various connection methods, configuration options, and troubleshooting tools.

### gateway\beta_v2.0\monitor_log.txt

*Description:* A log file that records phone detection events, including the IP address, network type, MAC address, and timestamp.

### gateway\beta_v2.0\network_helper.vbs

*Description:* A VBScript that provides a set of functions to aid in network discovery and device selection for the FTP phone connector. It includes functions to get the default gateway, find a phone by its MAC address, detect the phone on the network, and show UI dialogs for device selection and manual IP input.

### gateway\beta_v2.0\network_monitor.bat

*Description:* A batch script that runs in the background and continuously monitors the network for a specific phone's MAC address. When the phone is detected, it provides a notification and options to connect to the FTP server.

### gateway\beta_v2.0\network_scanner.ps1

*Description:* A PowerShell script that provides advanced network scanning capabilities to detect a phone's FTP server. It can perform parallel scanning, identify devices with open FTP ports, and prioritize scanning based on network type.

### gateway\beta_v2.0\phone_cache.txt

*Description:* A cache file that stores the last known IP address of the phone and the timestamp of the last successful connection.

### gateway\beta_v2.0\phone_profiles.ini

*Description:* An INI file that stores network profiles for the FTP phone connector. Each profile seems to contain the SSID, IP address, and network range.

### gateway\beta_v2.0\quick_ftp_launcher.bat

*Description:* A batch script that provides a fast way to connect to the phone's FTP server by using a cache of the last known IP address and a history of recent connections. If these quick methods fail, it falls back to a smart scan and then to the main `auto_ftp_connector.bat` script.

### gateway\beta_v2.0\test_ftp_setup.bat

*Description:* A comprehensive test suite for the FTP Phone Connection solution. It checks for required scripts, network adapter and gateway configurations, PowerShell availability, and the phone's presence in the ARP cache. It also provides options for testing the FTP connection, performing a quick network scan, and generating a detailed test report.

### gateway\connect_ftp.bat

*Description:* A batch script that attempts to automatically find a phone's IP address by its MAC address in the ARP cache, and if not found, it pings all devices on the connected subnets to populate the ARP cache and then checks again. If the phone is still not found, it prompts the user for the IP address manually using a VBScript. Once the IP is determined, it opens an FTP connection to the phone.

### gateway\ftp_on_gateway.bat

*Description:* A batch script that attempts to connect to an FTP server on a phone. It first tries to get the gateway IP address and then checks if the FTP server is reachable. It includes functions for getting the gateway, checking the FTP connection, and providing a selector menu. It also has a manual input option if the automatic detection fails.

### gateway\ftp_on_manual_ip.bat

*Description:* A simple batch script that opens an FTP connection to a hardcoded IP address and credentials.

### gateway\gateway_beta_v1.1.bat

*Description:* A batch script that gets the gateway IP address from a VBScript, tests the connection to a specific port on that IP using PowerShell, and then opens an FTP connection if the test is successful. If the test fails, it prompts the user for the last two octets of the IP address and then attempts to connect.

### gateway\gateway.vbs

*Description:* A VBScript that retrieves and displays the default gateway IP address of the active network connection.

### gateway\input_ip.vbs

*Description:* A VBScript that displays an input box with a prompt, title, and default value provided as command-line arguments, and returns the user's input.

### gateway\log.txt

*Description:* A log file that records the steps taken by the `connect_ftp.bat` script, including ARP cache scans, pings, and manual input prompts.

### gateway\New Text Document.txt

*Description:* A text file that describes the project's goal of automating the process of connecting to an FTP server on a phone, with various network configurations. It outlines the desired steps for the script to take, including searching for the phone on different networks, providing a device selection menu, and offering a manual input option as a last resort.

### powershell\cheskstart.ps1

*Description:* A PowerShell script that checks if the Start Menu is the foreground window.

