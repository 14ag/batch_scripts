::@echo off
set x=0

echo x>foo.txt



set /p bar=<foo.txt

echo The variable 'bar' now holds the value: _%bar%_

pause
:: i want to increase %x% by passing it to a child cmd as the argument %1 then assign it to %x% 
::and then retrieve it using echo and reassign using a for /f loop. i must use 'start /b cmd /c'. no temporary files should be created.