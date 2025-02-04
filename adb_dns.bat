@echo off
rem to disable private dns
REM adb shell settings put global private_dns_mode off

rem to enable private dns with hostname (example with dns.adguard.com)
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier dot.tiar.app