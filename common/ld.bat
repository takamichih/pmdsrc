@echo off
rem %1: obj
rem %2: target
rem %3: /t for .com output (checks if not empty)
set tsuf=.com
if "%2" == "" set tsuf=.exe
..\common\ld-opt %1.obj %1%tsuf% %2
