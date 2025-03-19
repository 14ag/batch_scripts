REM Description: Test script for firewall_v2.bat
@echo off
setlocal

:: Define the script to be tested
set "script_path=.\firewall_v2.bat"

:: Test case 1: No arguments provided
echo Test Case 1: No arguments ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
call %script_path%
echo Test Result: Check if the script prompts for input.
pause

:: Test case 2: Invalid allow_block parameter
echo Test Case 2: Invalid allow_block parameter ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
call %script_path% "test.txt" "invalid" "in"
echo Test Result: Check if the script displays the usage message.
pause

:: Test case 3: Invalid in_out_all parameter
echo Test Case 3: Invalid in_out_all parameter ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
call %script_path% "test.txt" "allow" "invalid"
echo Test Result: Check if the script displays the usage message.
pause

:: Test case 4: File does not exist
echo Test Case 4: File does not exist ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
call %script_path% "nonexistent.txt" "allow" "in"
echo Test Result: Check if the script displays "file not found" error.
pause

:: Test case 5: Correct parameters, but file extension is wrong
echo Test Case 5: Correct parameters, but file extension is wrong ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo This is a test > test.doc
call %script_path% "test.doc" "allow" "in"
echo Test Result: Check if the script displays "not a supported file" error.
pause
del test.doc

:: Test case 6: Correct parameters and file
echo Test Case 6: Correct parameters and file ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo This is a test > test.txt
call %script_path% "test.txt" "allow" "in"
echo Test Result: Check if the script processes the file correctly.
pause
del test.txt

:: Test case 7: Testing the "all" parameter
echo Test Case 7: Testing the "all" parameter ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo This is a test > test.txt
call %script_path% "test.txt" "allow" "all"
echo Test Result: Check if the script processes the file correctly for both in and out.
pause
del test.txt

:: Test case 8: Testing the "block" parameter
echo Test Case 8: Testing the "block" parameter ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo This is a test > test.txt
call %script_path% "test.txt" "block" "in"
echo Test Result: Check if the script processes the file correctly with block action.
pause
del test.txt

:: Test case 9: Testing directory processing
echo Test Case 9: Testing directory processing ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
mkdir test_dir
echo This is a test > test_dir\test.txt
call %script_path% "test_dir" "allow" "in"
echo Test Result: Check if the script processes all .txt files in the directory.
pause
rmdir /s /q test_dir

:: Test case 10: Testing multiple files in directory
echo Test Case 10: Testing multiple files in directory ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
mkdir test_dir
echo This is a test > test_dir\test1.txt
echo This is a test > test_dir\test2.txt
call %script_path% "test_dir" "allow" "in"
echo Test Result: Check if the script processes all .txt files in the directory.
pause
rmdir /s /q test_dir

:: Test case 11: Testing with different extension
echo Test Case 11: Testing with different extension ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo This is a test > test.exe
call %script_path% "test.exe" "allow" "in"
echo Test Result: Check if the script processes the .exe file correctly.
pause
del test.exe

:: Test case 12: Testing with mixed extensions in directory
echo Test Case 12: Testing with mixed extensions in directory ^
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
mkdir test_dir
echo This is a test > test_dir\test1.txt
echo This is a test > test_dir\test2.exe
call %script_path% "test_dir" "allow" "in"
echo Test Result: Check if the script processes only the .exe files in the directory.
pause
rmdir /s /q test_dir

endlocal
