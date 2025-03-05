@echo off
:: to disable private dns
:: adb shell settings put global private_dns_mode off

:: to enable private dns with hostname (example with dns.adguard.com)
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier dot.tiar.app