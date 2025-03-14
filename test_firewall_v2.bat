@echo off
setlocal

:: Define the script to be tested
set "script_path=.\firewall_v2.bat"

:: Test case 1: No arguments provided
echo Test Case 1: No arguments
call %script_path%
echo Test Result: Check if the script prompts for input.
pause

:: Test case 2: Invalid allow_block parameter
echo Test Case 2: Invalid allow_block parameter
call %script_path% "test.txt" "invalid" "in"
echo Test Result: Check if the script displays the usage message.
pause

:: Test case 3: Invalid in_out_all parameter
echo Test Case 3: Invalid in_out_all parameter
call %script_path% "test.txt" "allow" "invalid"
echo Test Result: Check if the script displays the usage message.
pause

:: Test case 4: File does not exist
echo Test Case 4: File does not exist
call %script_path% "nonexistent.txt" "allow" "in"
echo Test Result: Check if the script displays "file not found" error.
pause

:: Test case 5: Correct parameters, but file extension is wrong
echo Test Case 5: Correct parameters, but file extension is wrong
echo This is a test > test.doc
call %script_path% "test.doc" "allow" "in"
echo Test Result: Check if the script displays "not a supported file" error.
pause
del test.doc

:: Test case 6: Correct parameters and file
echo Test Case 6: Correct parameters and file
echo This is a test > test.txt
call %script_path% "test.txt" "allow" "in"
echo Test Result: Check if the script processes the file correctly.
pause
del test.txt

:: Test case 7: Testing the "all" parameter
echo Test Case 7: Testing the "all" parameter
echo This is a test > test.txt
call %script_path% "test.txt" "allow" "all"
echo Test Result: Check if the script processes the file correctly for both in and out.
pause
del test.txt

:: Test case 8: Testing the "block" parameter
echo Test Case 8: Testing the "block" parameter
echo This is a test > test.txt
call %script_path% "test.txt" "block" "in"
echo Test Result: Check if the script processes the file correctly with block action.
pause
del test.txt

:: Test case 9: Testing directory processing
echo Test Case 9: Testing directory processing
mkdir test_dir
echo This is a test > test_dir\test.txt
call %script_path% "test_dir" "allow" "in"
echo Test Result: Check if the script processes all .txt files in the directory.
pause
rmdir /s /q test_dir

endlocal