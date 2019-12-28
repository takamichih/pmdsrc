@echo off
set tiny=
if not "%3" == "" set tiny=com
@echo on
jwlink name %2 format dos %tiny% file %1
