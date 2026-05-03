@echo off
:: Git Setup Script
:: Customize the values below before running

set GIT_USERNAME="14ag"
set GIT_EMAIL="muriukipn@gmail.com"
set GIT_DEFAULT_BRANCH="main"
:: set GIT_EDITOR="notepad"

:: Configure Git settings
git config --global user.name %GIT_USERNAME%
git config --global user.email %GIT_EMAIL%
git config --global init.defaultBranch %GIT_DEFAULT_BRANCH%
:: git config --global core.editor %GIT_EDITOR%
git config --global pull.rebase false

echo Git has been configured with the following settings:
git config --global --list



echo Git setup complete.
pause
