@echo off
:: Git Setup Script
:: Customize the values below before running

set GIT_USERNAME="14ag"
set GIT_EMAIL="muriukipn@gmail.com"
set GIT_DEFAULT_BRANCH="main"
REM set GIT_EDITOR="notepad"

:: Configure Git settings
git config --global user.name %GIT_USERNAME%
git config --global user.email %GIT_EMAIL%
git config --global init.defaultBranch %GIT_DEFAULT_BRANCH%
REM git config --global core.editor %GIT_EDITOR%
git config --global pull.rebase false

echo Git has been configured with the following settings:
git config --global --list

:: Optional: Generate SSH key
set /p GEN_SSH=Do you want to generate an SSH key? (y/n): 
if /I "%GEN_SSH%"=="y" (
    ssh-keygen -t rsa -b 4096 -C %GIT_EMAIL%
    echo SSH key generated. Add it to your Git hosting provider.
) else (
    echo Skipping SSH key generation.
)

echo Git setup complete.
pause
