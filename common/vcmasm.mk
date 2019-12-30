# ml.exe: works up to version 9.00.30729.207 (WDK 7.1)
AS=ml /nologo
# link16.exe: tested with version 5.60.339 (VC++ 1.50/1.51 update Lnk563.exe)
# renamed to link16.exe
LD=link16 /nologo
ASFLAGS=/omf /I../common /Zm
.asm.exe:
	$(AS) $(ASFLAGS) $<
	$(LD) $(<R).obj,$@;

.asm.com:
	$(AS) $(ASFLAGS) $<
	$(LD) /tiny $(<R).obj,$@;

clean:
	del *.com
	del *.exe
	del *.obj