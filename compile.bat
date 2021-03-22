@ECHO OFF
cd app
zip -r ..\testbench.zip *
IF %ERRORLEVEL% EQU 0 GOTO Fin

:Fin
cd ..