.suffixes:
.suffixes:.exe .com .obj .asm

!include ..\common\optasm.mak
#!include ..\common\masm.mak
#!include ..\common\jwasm.mak

!include ..\common\link.mak
#!include ..\common\wlink.mak

clean: .symbolic
	rm -f *.com *.obj *.exe *.err

