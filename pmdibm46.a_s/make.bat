@echo off
call ..\common\as pmdl
call ..\common\as pmdibm
call ..\common\as mc
call ..\common\as mch
call ..\common\as efc
call ..\common\as pmp
call ..\common\ld pmdl /t
call ..\common\ld pmdibm /t
call ..\common\ld mc
call ..\common\ld mch
call ..\common\ld efc
call ..\common\ld pmp /t
