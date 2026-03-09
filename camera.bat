@echo off

(
scrcpy --list-displays | find /i "--display-id=3"
) && (
	set "new_display=--display-id=2"
) || (
	set "new_display="
)


scrcpy --tcpip=192.168.137.62 --no-audio --stay-awake --no-mouse-hover --turn-screen-off --new-display=600x600 --no-clipboard-autosync --angle=0 --start-app=com.google.android.GoogleCameraEngR18F1    
::
::--no-control
:: --tcpip=192.168.100.33
::
::
::
::
::