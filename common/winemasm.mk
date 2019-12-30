export WINEDEBUG:=-all
# ml.exe: works up to version 9.00.30729.207 (WDK 7.1)
AS:=wine ~/ml9/ml /nologo
# link.exe: tested with version 5.60.339 (VC++ 1.50/1.51 update Lnk563.exe)
LD:=wine ~/ml9/link /nologo
ASFLAGS:=/omf /I../common /Zm
.PHONY:	clean

%.exe:	%.obj
	@echo " Linking: $@"
	@$(LD) $<,$@\;

%.com:	%.obj
	@echo " Linking: $@"
	@$(LD) /tiny $<,$@\;

%.obj:	%.asm
	@$(AS) $(ASFLAGS) $<

clean:
	rm -f *.obj *.exe *.com
