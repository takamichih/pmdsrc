@echo off
call ..\common\as pmd
call ..\common\as pmdb2
call ..\common\as pmd86
call ..\common\as pmdppz
call ..\common\as pmdppze
call ..\common\as pmdva
call ..\common\as pmdva1
call ..\common\ld pmd /t
call ..\common\ld pmdb2 /t
call ..\common\ld pmd86 /t
call ..\common\ld pmdppz /t
call ..\common\ld pmdppze /t
call ..\common\ld pmdva /t
call ..\common\ld pmdva1 /t
