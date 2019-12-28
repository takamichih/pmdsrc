@echo off
set tiny=
if not "%3" == "" set tiny=/tiny
@echo on
link /nologo %tiny% %1,%2;
