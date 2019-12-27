;==============================================================================
;
;	PPS/PCM�t�@�C���̓ǂݍ��� PCM��������WORK�Ɏg��Version / Include�p
;	PMDPCM.EXE/PMP.COM/MC.EXE �p
;	x8 bit�p�ɕύX /ver.4.4�ȍ~
;	.P86������ǉ� /ver.4.5�ȍ~
;
;	DISKPMD.INC��\��include�����Ă������ƁB
;	cs:[kankyo_seg]�Ɋ��̃Z�O�����g�����Ă������ƁB
;
;==============================================================================

ppsdrv		equ	64h		;PPSDRV��Vector
p86drv		equ	65h		;P86DRV��Vector

;==============================================================================
;
;	PCM(PPC/P86)�t�@�C���̓ǂݍ���
;		P86DRV.COM���풓���Ă���� .P86���A
;		�����łȂ��ꍇ�� .PPC��ǂށB
;
;		input	DS:AX	filename	(128byte)
;			ES:DI	pcm_work	(32KB,P86�̏ꍇ�͕K�v����)
;		output	cy=1	Not Loaded
;				AX=1	SPB/ADPCM-RAM��PMDB2���Ȃ�
;					86B/P86DRV   ��PMD86���Ȃ�
;				AX=2	�t�@�C�����Ȃ�
;				AX=3	�t�@�C����PMD��PCM�f�[�^�ł͂Ȃ�
;				AX=4	SPB/���ɓǂݍ���ł���̂Ɠ���������
;					86B/�e��OVER
;				AX=5	�t�@�C�����ǂ߂Ȃ�
;				AX=6	PCM���������A�N�Z�X��������
;
;	.PPC format:
;		WORK=PMD��PCMWORK , DATA=PCMRAM�擪��WORK , FILE=PCMFILE
;					 123456789012345678901234567890
;		DATA/FILE�̂�		"ADPCM DATA for  PMD ver.4.4-  "30bytes
;		WORK/DATA/FILE		1Word		Next START Address
;					2Word*256	START/STOP
;		WORK/DATA�̂�		128bytes	FILENAME
;		DATA�̂�		32bytes		�\��
;
;		PCMRAM_Work		=00000H�`00025H
;		PCMRAM_Main_data	=00026H�`01FFFH
;
;	.P86 format:
;		"PCM86 DATA",0ah,0	12 byte
;		P86DRV��version		1  byte
;		�S�̂̃T�C�Y		3  byte
;		���Ftable		start(3),size(3) * 256 (1536) bytes
;		���F�f�[�^		��
;
;==============================================================================
pcm_all_load	proc

	assume	ds:nothing,es:nothing

	cld
	push	ds
	push	es
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	mov	cs:[filename_ofs],ax
	mov	ax,ds
	mov	cs:[filename_seg],ax
	mov	cs:[pcmdata_ofs],di
	mov	ax,es
	mov	cs:[pcmdata_seg],ax
	mov	ah,0eh		;GET_PCM_ADR
	int	60h		;DS:DX=PCM���[�N
	mov	cs:[pcmwork_ofs],dx
	mov	ax,ds
	mov	cs:[pcmwork_seg],ax

	call	all_load

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	es
	pop	ds
	ret

pcm_all_load	endp

;==============================================================================
;
;	PPS�t�@�C���̓ǂݍ���
;
;		input	DS:AX	filename	(128byte)
;		output	cy=1	AX=1	PPSDRV���풓���Ă��Ȃ�
;				AX=2	�t�@�C��������
;				AX=3	PPSDRV�̗e�ʂ��I�[�o�[����
;				AX=5	�t�@�C�����ǂ߂Ȃ�
;
;	PPSDATA�\��
;			2Word*14	Start address/Length
;			�ȍ~		PPS Data
;
;==============================================================================
pps_load	proc
	assume	ds:nothing,es:nothing
	cld
	push	ds
	push	es
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	mov	cs:[filename_ofs],ax
	mov	ax,ds
	mov	cs:[filename_seg],ax

	call	ppsdrv_check
	jc	not_load

pps_load_exec:
	mov	ah,4
	int	ppsdrv
	mov	cs:[pcmdata_ofs],dx
	mov	ax,ds
	mov	cs:[pcmdata_seg],ax
	mov	cs:[pcmdata_size],cx

	call	pps_load_main

not_load:
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	es
	pop	ds
	ret

pps_load	endp

;==============================================================================
;	pps load
;		in	cs:[filename_ofs/seg]	Filename
;			cs:[pcmdata_ofs/seg]	PPSData�ʒu
;			cs:[pcmdata_size]	PPSData�e��
;==============================================================================
pps_load_main	proc
	call	filename_set

;-----------------------------------------------------------------------------
;	File Read
;-----------------------------------------------------------------------------
	lds	dx,dword ptr cs:[filename_ofs]
	mov	es,cs:[kankyo_seg]
	call	opnhnd		;Open
	jc	allload_exit2p	;File������

	lds	dx,dword ptr cs:[pcmdata_ofs]
	mov	cx,cs:[pcmdata_size]
	inc	cx		;1byte�]�v�ɓǂ�
	push	cx
	call	redhnd
	pop	cx
	jc	allload_exit5p_close	;file���ǂ߂Ȃ�
	cmp	ax,cx
	jz	allload_exit3p_close	;�e�ʃI�[�o�[

	call	clohnd
	xor	ax,ax
	ret

pps_load_main	endp

;==============================================================================
;	.PPC/.P86 �ꊇload
;		in	cs:[filename_ofs/seg]	Filename
;			cs:[pcmdata_ofs/seg]	PCMData loadarea
;			cs:[pcmwork_ofs/seg]	PMD��PCMwork
;==============================================================================
all_load	proc
;-----------------------------------------------------------------------------
;	�ǂݍ��ނ̂�.P86��.PPC���ǂ����𔻕�
;-----------------------------------------------------------------------------
	call	check_p86drv
	jnc	p86_load
	mov	ah,09h
	int	60h		;board check
	cmp	al,1
	jnz	allload_exit1

;-----------------------------------------------------------------------------
;	.PPC read Main
;-----------------------------------------------------------------------------
	call	check_pmdb2
	jc	allload_exit1
	call	filename_set

;-----------------------------------------------------------------------------
;	File��PMD�̃��[�N�Ƀw�b�_�����ǂ݂���
;-----------------------------------------------------------------------------
	lds	dx,dword ptr cs:[filename_ofs]
	mov	es,cs:[kankyo_seg]
	call	opnhnd		;Open
	jc	allload_exit2
	lds	dx,dword ptr cs:[pcmdata_ofs]
	mov	cx,30		;���ʕ�����
	call	redhnd
	jc	allload_exit5_close
	cmp	ax,30		;Header�̒���=�ǂݍ��񂾒������H
	jnz	allload_exit3_close

	lds	bx,dword ptr cs:[pcmdata_ofs]
	cmp	word ptr 0[bx],"VP"	;PV
	jnz	not_pvi
	cmp	word ptr 2[bx],"2I"	;I2
	jnz	not_pvi
	cmp	byte ptr 10[bx],02h	;RAM Type 8bit
	jz	pvi_load
not_pvi:
	cmp	word ptr 0[bx],"DA"	;AD
	jnz	allload_exit3_close		;PMD��PCM�f�[�^�ł͂Ȃ�
	cmp	word ptr 2[bx],"CP"	;PC
	jnz	allload_exit3_close		;PMD��PCM�f�[�^�ł͂Ȃ�
	cmp	word ptr 4[bx]," M"	;M 
	jnz	allload_exit3_close		;PMD��PCM�f�[�^�ł͂Ȃ�

	lds	dx,dword ptr cs:[pcmwork_ofs]
	mov	cx,4*256+2	;Header�̒��� (filename�͂Ȃ�)
	call	redhnd		;Read
	jc	allload_exit5_close
	cmp	ax,4*256+2	;Header�̒���=�ǂݍ��񂾒������H
	jnz	allload_exit3_close

;-----------------------------------------------------------------------------
;	PMD�̃��[�N��Filename������
;-----------------------------------------------------------------------------
ppc_load_main:
	call	write_filename_to_pmdwork

;-----------------------------------------------------------------------------
;	PCMRAM�̃w�b�_��ǂ�
;-----------------------------------------------------------------------------
	cmp	cs:[retry_flag],0
	jnz	write_pcm_main		;������
	mov	cs:[pcmstart],0
	mov	cs:[pcmstop],25h	;read 25h*32 = 1184(32+256*4+128) bytes
	call	pcmread
	jc	allload_exit6_close

;-----------------------------------------------------------------------------
;	PMD�̃��[�N��PCMRAM�̃w�b�_���r
;-----------------------------------------------------------------------------
	lds	si,dword ptr cs:[pcmdata_ofs]
	les	di,dword ptr cs:[pcmwork_ofs]
	add	si,30		;"ADPCM�`"�w�b�_���΂�
	mov	cx,+(4*256+128+2)/2
rep	cmpsw
	jz	allload_exit4_close	;��v����

;-----------------------------------------------------------------------------
;	PMD�̃��[�N��PCMRAM���ɏ�������
;-----------------------------------------------------------------------------
write_pcm_main:
	mov	ax,cs
	mov	ds,ax
	mov	si,offset adpcm_header
	les	di,dword ptr cs:[pcmdata_ofs]
	mov	cx,30/2		;"ADPCM�`"�w�b�_����������
rep	movsw
	lds	si,dword ptr cs:[pcmwork_ofs]
	mov	cx,+(4*256+128+2)/2
rep	movsw
	mov	cs:[pcmstart],0
	mov	cs:[pcmstop],25h
	call	pcmstore

;-----------------------------------------------------------------------------
;	PCMDATA��PCMRAM�ɏ�������
;	8000h���ǂݍ��݂Ȃ����`
;-----------------------------------------------------------------------------
	mov	ax,cs
	mov	ds,ax
	mov	dx,offset allload_mes
	mov	ah,09h
	int	21h		;"�o�b�l��`��"�̕\��

	lds	bx,dword ptr cs:[pcmwork_ofs]
	mov	ax,ds:[bx]	;AX=PCM Next Start Address
	sub	ax,26h		;���ۂɂ��ꂩ��]������f�[�^�ʂɕϊ�

	mov	cs:[pcmstart],26h
	mov	cs:[pcmstop],426h	;400h*32=8000h �ꊇ
allload_loop:
	cmp	ax,401h
	jc	allload_last
	sub	ax,400h

	mov	bp,ax	;Push
	lds	dx,dword ptr cs:[pcmdata_ofs]
	mov	cx,8000h
	call	redhnd		;DISK Read
	jc	allload_exit5_close
	cmp	ax,8000h
	jnz	allload_exit3_close
	call	pcmstore	;PCM Store
	add	cs:[pcmstart],400h
	add	cs:[pcmstop],400h
	mov	ax,bp	;Pop
	jmp	allload_loop

allload_last:
	or	ax,ax
	jz	allload_justend
	mov	bp,ax	;Push
	add	ax,cs:[pcmstart]
	mov	cs:[pcmstop],ax
	lds	dx,dword ptr cs:[pcmdata_ofs]
	mov	cx,8000h
	call	redhnd		;DISK Read
	jc	allload_exit5_close
	mov	bx,bp	;Pop
	add	bx,bx
	add	bx,bx
	add	bx,bx
	add	bx,bx
	add	bx,bx
	cmp	ax,bx
	pushf
	call	pcmstore	;PCM Store
	popf
	jc	allload_exit3_close
allload_justend:
	call	clohnd		;FILE Close

;-----------------------------------------------------------------------------
;	�I��
;-----------------------------------------------------------------------------
	xor	ax,ax
	ret

all_load	endp

;==============================================================================
;	.PVI loading
;==============================================================================
pvi_load:
;-----------------------------------------------------------------------------
;	�w�b�_/���Ftable�̎c���ǂݍ���
;-----------------------------------------------------------------------------
	lds	dx,dword ptr cs:[pcmdata_ofs]
	add	dx,30
	mov	cx,128*4+16-30	;Header �c��
	call	redhnd
	jc	allload_exit5_close
	cmp	ax,128*4+16-30
	jnz	allload_exit3_close

;-----------------------------------------------------------------------------
;	pvi�̉��F��񂩂�pmd�֓]��
;-----------------------------------------------------------------------------
	lds	si,dword ptr cs:[pcmdata_ofs]
	add	si,16
	les	di,dword ptr cs:[pcmwork_ofs]
	add	di,2
	xor	bx,bx
	mov	cx,128
	mov	dx,26h
tableset_loop:
	lodsw
	add	ax,dx
	stosw
	lodsw
	or	ax,ax
	jnz	not_null_pcm
	sub	word ptr es:-2[di],dx
	sub	ax,dx
not_null_pcm:
	add	ax,dx
	stosw
	cmp	bx,ax
	jnc	not_set_max
	mov	bx,ax
	inc	bx
not_set_max:
	loop	tableset_loop
	xor	ax,ax
	mov	cx,128*2
rep	stosw		;�c��128�͖���`
	mov	di,cs:[pcmwork_ofs]
	mov	es:[di],bx

	jmp	ppc_load_main	;���Ƃ�ppc�Ɠ���

;==============================================================================
;	P86 data �ꊇload
;		in	cs:[filename_ofs/seg]	Filename
;==============================================================================
p86_load	proc
;-----------------------------------------------------------------------------
;	P86drv��check
;-----------------------------------------------------------------------------
	call	filename_set
	mov	ah,-2
	int	p86drv		;INT65H �g�p��?
	or	al,al
	jnz	allload_exit6

;-----------------------------------------------------------------------------
;	.P86buffer ������ & Read����
;-----------------------------------------------------------------------------
	xor	ah,ah
	int	p86drv		;.P86 buffer ������
	mov	ah,1
	int	p86drv		;.P86��ǂݍ��ވʒu������

	mov	cs:[pcmdata_ofs],dx
	mov	cs:[pcmdata_seg],ds
	mov	cs:[pcmdata_size_s],bl
	mov	cs:[pcmdata_size],cx

;-----------------------------------------------------------------------------
;	P86Data,Size�m�F
;-----------------------------------------------------------------------------
	lds	dx,dword ptr cs:[filename_ofs]
	mov	es,cs:[kankyo_seg]
	call	opnhnd		;Open
	jc	allload_exit2

	lds	dx,dword ptr cs:[pcmdata_ofs]
	mov	cx,16		;Header���̂�
	call	redhnd		;Read
	jc	allload_exit5_close
	cmp	ax,16		;Header�̒���=�ǂݍ��񂾒������H
	jnz	allload_exit3_close

	lds	bx,dword ptr cs:[pcmdata_ofs]
	cmp	word ptr 0[bx],"CP"	;PC
	jnz	allload_exit3_close
	cmp	word ptr 2[bx],"8M"	;M8
	jnz	allload_exit3_close
	cmp	byte ptr 4[bx],"6"	;6
	jnz	allload_exit3_close

	mov	cx,13[bx]		;Size_W
	mov	dl,15[bx]		;Size_S
	mov	ax,cs:[pcmdata_size]	;Size_W (�ő�)
	mov	bl,cs:[pcmdata_size_s]	;Size_S (�ő�)
	sub	ax,cx
	sbb	bl,dl
	jnc	not_over_size

	xor	ah,ah
	int	p86drv
	jmp	allload_exit4pp_close	;�e�� over

not_over_size:
	mov	cs:[pcmdata_size],cx	;�ǂݍ��ރT�C�Y���L�^
	mov	cs:[pcmdata_size_s],dl	;//

;-----------------------------------------------------------------------------
;	�ǂݍ���
;-----------------------------------------------------------------------------
	lds	dx,dword ptr cs:[pcmdata_ofs]
	add	dx,16			;Header�͂����ǂ�
	sub	cs:[pcmdata_size],16	;//
	sbb	cs:[pcmdata_size_s],0	;//

	cmp	cs:[pcmdata_size_s],0
	jz	p86_last_load

;-----------------------------------------------------------------------------
;	64KB���ǂ�
;-----------------------------------------------------------------------------
p86_read_loop:
	mov	bp,2		;32KB*2 = 64KB
p86_read_loop2:
	mov	cx,32*1024	;32KB
	push	ds
	push	dx
	call	redhnd
	pop	dx
	pop	ds
	jc	allload_exit5_close
	add	dx,32*1024
	jnc	p86_not_over_seg
	mov	bx,ds
	add	bx,1000h
	mov	ds,bx
p86_not_over_seg:
	cmp	ax,32*1024
	jnz	allload_exit3_close

	dec	bp
	jnz	p86_read_loop2

	dec	cs:[pcmdata_size_s]
	jnz	p86_read_loop

;-----------------------------------------------------------------------------
;	�Ō�̓ǂݍ���
;-----------------------------------------------------------------------------
p86_last_load:
	mov	cx,cs:[pcmdata_size]
	or	cx,cx
	jz	p86_just_loaded
	push	cx
	call	redhnd
	pop	cx
	jc	allload_exit5_close
	cmp	ax,cx
	jnz	allload_exit3_close

;-----------------------------------------------------------------------------
;	�ǂݍ��ݏI��
;-----------------------------------------------------------------------------
p86_just_loaded:
	call	clohnd

	mov	ah,2
	int	p86drv		;PMD86�ւ̓o�^

	xor	ax,ax		;����I��
	ret

p86_load	endp

;-----------------------------------------------------------------------------
;	�G���[���^�[��
;-----------------------------------------------------------------------------
allload_exit1:
	mov	dx,offset exit1_mes
	mov	ax,1	;PCM����`�o���܂���B
	jmp	error_exec

allload_exit1p:
	mov	dx,offset exit1p_mes
	mov	ax,1	;PPSDRV���풓���ĂȂ�
	jmp	error_exec

allload_exit2:
	mov	dx,offset exit2_mes
	mov	ax,2	;PCM�t�@�C�����Ȃ�
	jmp	error_exec

allload_exit2p:
	mov	dx,offset exit2p_mes
	mov	ax,2	;PPS�t�@�C�����Ȃ�
	jmp	error_exec

allload_exit3_close:
	call	clohnd
	mov	dx,offset exit3_mes
	mov	ax,3	;�t�@�C����PMD��PCM�ł͂Ȃ�
	jmp	error_exec

allload_exit3p_close:
	call	clohnd
	mov	dx,offset exit3p_mes
	mov	ax,3	;PPS�f�[�^�e�ʃI�[�o�[
	jmp	error_exec

allload_exit4_close:
	call	clohnd
	mov	dx,offset exit4_mes
	mov	ax,4	;�f�[�^����v����
	jmp	error_exec

allload_exit4pp_close:
	call	clohnd
	mov	dx,offset exit4pp_mes
	mov	ax,4	;P86�e�ʂ�����Ȃ�
	jmp	error_exec

allload_exit5_close:
	call	clohnd
	mov	dx,offset exit5_mes
	mov	ax,5	;PCM�t�@�C�����ǂ߂Ȃ�
	jmp	error_exec

allload_exit5p_close:
	call	clohnd
	mov	dx,offset exit5p_mes
	mov	ax,5	;PPS�t�@�C�����ǂ߂Ȃ�
	jmp	error_exec

allload_exit6_close:
	call	clohnd
allload_exit6:
	mov	dx,offset exit6_mes
	mov	ax,6	;PCM�������A�N�Z�X��
	jmp	error_exec

error_exec:
	push	ax
	mov	ax,cs
	mov	ds,ax
	mov	ah,09h
	int	21h
	pop	ax
	stc
	ret

;==============================================================================
;	PMDB2��ADPCM��Check
;		output	cy	PMDB2����ADPCM���Ȃ�
;==============================================================================
check_pmdb2	proc
;-----------------------------------------------------------------------------
;	PMDB2��ADPCM�̓���CHECK
;-----------------------------------------------------------------------------
	mov	ah,10h
	int	60h		;get_workadr in DS:DX
	mov	bx,dx
	mov	bx,-2[bx]	;ds:bx = open_work
	cmp	_pcm_gs_flag[bx],0
	jnz	cpb_stc_ret	;ERROR Return
	mov	ax,_fm2_port1[bx]
	mov	cs:[port46],ax
	mov	ax,_fm2_port2[bx]
	mov	cs:[port47],ax
	clc
	ret
cpb_stc_ret:
	stc
	ret
check_pmdb2	endp

;==============================================================================
;	P86DRV�̏풓Check
;		output	cy	P86DRV���Ȃ�
;==============================================================================
check_p86drv	proc
	push	es
	push	ax
	xor	ax,ax
	mov	es,ax
	les	bx,es:[p86drv*4]
	cmp	word ptr es:2[bx],"8P"
	jnz	p86drv_not_found
	cmp	byte ptr es:4[bx],"6"
	jnz	p86drv_not_found
	pop	ax
	pop	es
	clc
	ret
p86drv_not_found:
	pop	ax
	pop	es
	stc
	ret

check_p86drv	endp

;==============================================================================
;	PPSDRV �풓check
;			output	cy=1	�풓���ĂȂ�
;==============================================================================
ppsdrv_check	proc
	xor	ax,ax
	mov	es,ax
	les	bx,es:[ppsdrv*4]
	cmp	word ptr es:2[bx],"MP"
	jnz	allload_exit1p
	cmp	byte ptr es:4[bx],"P"
	jnz	allload_exit1p
	clc
	ret
ppsdrv_check	endp

;==============================================================================
;	Filename�̑啶�������p�X���������
;==============================================================================
filename_set	proc
;-----------------------------------------------------------------------------
;	Filename������������啶���ɕϊ�(SHIFTJIS���t��)
;-----------------------------------------------------------------------------
	lds	si,dword ptr cs:[filename_ofs]
exbig_loop:
	lodsb
	call	sjis_check	;in DISKPMD.INC
	jnc	exbig_nonsjis
	inc	si		;2byte�ڂ��΂�
	jmp	exbig_loop
exbig_nonsjis:
	or	al,al
	jz	exbig_exit
	cmp	al,"a"
	jc	exbig_loop
	cmp	al,"z"+1
	jnc	exbig_loop
	and	al,11011111b	;���������啶���ϊ�
	mov	ds:-1[si],al	;���ď�����
	jmp	exbig_loop
exbig_exit:

;-----------------------------------------------------------------------------
;	Filename���̃p�X���𔲂���filename_ofs2��ݒ�(File����r�p)
;-----------------------------------------------------------------------------
	lds	si,dword ptr cs:[filename_ofs]
	mov	bx,si
yencheck_loop:
	lodsb
	call	sjis_check	;in DISKPMD.INC
	jnc	yencheck_nonsjis
	inc	si	;2byte�ڂ��΂�
	jmp	yencheck_loop
yencheck_nonsjis:
	or	al,al
	jz	yencheck_exit
	cmp	al,"\"
	jnz	yencheck_loop
	mov	bx,si
	jmp	yencheck_loop
yencheck_exit:
	mov	cs:[filename_ofs2],bx
	mov	ax,ds
	mov	cs:[filename_seg2],ax	;�Z�O�����g��filename_seg�ƈꏏ

	ret

filename_set	endp

;==============================================================================
;	PMD�̃��[�N��Filename������
;==============================================================================
write_filename_to_pmdwork	proc
	lds	si,dword ptr cs:[filename_ofs2]
	les	di,dword ptr cs:[pcmwork_ofs]
	add	di,4*256+2	;ES:DI = PMD��PCM_WORK��Filename�i�[�ʒu
	mov	cx,128		;byte��
write_filename_loop:
	dec	cx
	movsb
	cmp	byte ptr -1[si],0
	jnz	write_filename_loop
	xor	al,al
rep	stosb			;�c����O�Ŗ��߂�
	ret
write_filename_to_pmdwork	endp

;==============================================================================
;	�o�b�l�������փ��C������������f�[�^�𑗂� (x8,����/�ᑬ�I���)
;
;	INPUTS 	.. cs:[pcmstart]   	to Start Address
;		.. cs:[pcmstop]    	to Stop  Address
;		.. cs:[pcmdata_ofs/seg]	to PCMData_Buffer
;==============================================================================
pcmstore	proc
	call	key_check_reset

	mov	dx,0001h
	call	out46

	mov	dx,1017h	;brdy�ȊO�̓}�X�N(=timer���荞�݂͊|����Ȃ�)
	call	out46
	mov	dx,1080h
	call	out46
	mov	dx,0060h
	call	out46
	mov	dx,0102h	;x8
	call	out46

	mov	dx,0cffh
	call	out46
	inc	dh
	call	out46

	mov	bx,cs:[pcmstart]
	mov	dh,002h
	mov	dl,bl
	call	out46
	inc	dh
	mov	dl,bh
	call	out46

	mov	dx,04ffh
	call	out46
	inc	dh
	call	out46

	lds	si,dword ptr cs:[pcmdata_ofs]
	mov	cx,cs:[pcmstop]
	sub	cx,cs:[pcmstart]
	add	cx,cx
	add	cx,cx
	add	cx,cx
	add	cx,cx
	add	cx,cx

	mov	dx,cs:[port46]
	mov	bx,cs:[port47]

	cmp	cs:[adpcm_wait],0
	jz	fast_store

;------------------------------------------------------------------------------
;	�ᑬ��`
;------------------------------------------------------------------------------
slow_store:
	in	al,dx
	or	al,al
	js	slow_store

	mov	al,8	;PCMDAT	reg.
	cli
	out	dx,al
	push	cx
	mov	cx,cs:[wait_clock]
	loop	$
	pop	cx

	xchg	bx,dx
	lodsb
	out	dx,al	;OUT	data
	sti
	xchg	dx,bx
o4601xx:
	in	al,dx
	test	al,8	;BRDY	check
	jz	o4601xx
o4601xxb:
	in	al,dx
	or	al,al	;BUSY	check
	js	o4601xxb

	mov	al,10h
	cli
	out	dx,al
	push	cx
	mov	cx,cs:[wait_clock]
	loop	$
	pop	cx
	xchg	dx,bx
	mov	al,80h
	out	dx,al	;BRDY	reset
	sti
	xchg	dx,bx

	loop	slow_store

	jmp	pcmst_exit

;------------------------------------------------------------------------------
;	������`
;------------------------------------------------------------------------------
fast_store:

o4600x:	in	al,dx
	or	al,al
	js	o4600x
	call	cli_sub
	mov	al,8	;PCMDAT	reg.
	out	dx,al
	push	cx
	mov	cx,cs:[wait_clock]
	loop	$
	pop	cx
	xchg	bx,dx

fast_store_loop:
	lodsb
	out	dx,al	;OUT	data
	xchg	bx,dx
o4601x:
	in	al,dx
	test	al,8	;BRDY	check
	jz	o4601x
	xchg	dx,bx
	loop	fast_store_loop
	call	sti_sub

pcmst_exit:
	mov	dx,1000h
	call	out46
	mov	dx,1080h
	call	out46
	mov	dx,0001h
	call	out46

	call	key_check_set
	ret

;------------------------------------------------------------------------------
;	RS-232C�ȊO�͊��荞�݂��֎~����
;	(FM����LSI �� ADDRESS�̕ύX�������Ȃ���)
;------------------------------------------------------------------------------
cli_sub:
	push	ax
	push	dx
	cli
	mov	dx,cs:[mmask_port]
	in	al,dx
	mov	cs:[mmask_push],al
	or	al,11101111b		;RS�̂ݕω������Ȃ�
	out	dx,al
	sti
	pop	dx
	pop	ax
	ret

;------------------------------------------------------------------------------
;	���subroutine�ŋ֎~�������荞�݂����ɖ߂�
;------------------------------------------------------------------------------
sti_sub:
	push	ax
	push	dx
	cli
	mov	dx,cs:[mmask_port]
	mov	al,cs:[mmask_push]
	out	dx,al
	sti
	pop	dx
	pop	ax
	ret

pcmstore	endp

;==============================================================================
;	�o�b�l���������烁�C���������ւ̃f�[�^��荞��
;
;	Inputs	.. cs:[pcmstart]  	to Start Address
;		.. cs:[pcmstop]   	to Stop  Address
;		.. cs:[pcmdata_ofs/seg]	to PCMDATA_Buffer
;==============================================================================
pcmread	proc
	call	key_check_reset
	jnc	pcmread_exec
	ret

pcmread_exec:
	mov	dx,0001h
	call	out46

	mov	dx,1000h
	call	out46
	mov	dx,1080h
	call	out46
	mov	dx,0020h
	call	out46
	mov	dx,0102h	;x8
	call	out46
	mov	dx,0cffh
	call	out46
	inc	dh
	call	out46
	mov	bx,cs:[pcmstart]
	mov	dh,002h
	mov	dl,bl
	call	out46
	mov	dh,003h
	mov	dl,bh
	call	out46
	mov	dx,04ffh
	call	out46
	inc	dh
	call	out46

	call	pget
	call	pget

	mov	cx,cs:[pcmstop]
	sub	cx,cs:[pcmstart]
	add	cx,cx
	add	cx,cx
	add	cx,cx
	add	cx,cx
	add	cx,cx

	les	di,dword ptr cs:[pcmdata_ofs]

pcr00:	mov	al,8
	mov	dx,cs:[port46]
	cli
	out	dx,al

pcr01:	in	al,dx
	test	al,00001000b
	jz	pcr01

pcr02:	in	al,dx
	or	al,al
	js	pcr02

	mov	dx,cs:[port47]
	in	al,dx
	sti
	stosb

	mov	dx,1080h
	call	out46

	loop	pcr00

	mov	dx,0001h
	call	out46

	call	key_check_set
	ret

;==============================================================================
;	���ʓǂݗp
;==============================================================================
pget:	mov	al,008h
	mov	dx,cs:[port46]
	cli
	out	dx,al
pg01:	in	al,dx
	or	al,al
	js	pg01
	mov	dx,cs:[port47]
	in	al,dx
	sti
	mov	dx,1080h
	call	out46
	ret

pcmread	endp

;==============================================================================
;	�n�o�m�`���|�[�g�ւ̃f�[�^�̏�������
;
;	Inputs	.. dh to Register
;		.. dl to Data
;==============================================================================
out46	proc
	push	dx
	push	bx
	mov	bx,dx
	mov	dx,cs:[port46]
o4600:	in	al,dx
	or	al,al
	js	o4600
	mov	al,bh
	cli
	out	dx,al
	push	cx
	mov	cx,cs:[wait_clock]
	loop	$
	pop	cx
	mov	dx,cs:[port47]
	mov	al,bl
	out	dx,al
	sti
	pop	bx
	pop	dx
	ret

out46	endp

;==============================================================================
;	PMD�� ESC/GRPH���͂������Ȃ�����
;	���̑��K�v�ȃf�[�^��pmd��segment����ǂݎ��
;		out	cy	acccess flag on
;==============================================================================
key_check_reset:
	push	ds
	push	ax
	push	bx
	push	dx
	mov	ah,10h
	int	60h
	mov	bx,dx
	mov	bx,-2[bx]
	mov	ax,_wait_clock[bx]
	mov	cs:[wait_clock],ax	;get wait_clock
	mov	al,_adpcm_wait[bx]
	mov	cs:[adpcm_wait],al	;get adpcm_wait
	mov	cs:[mmask_port],02h	;master_mask (98)
	cmp	word ptr ds:[84h],"AV"
	jnz	kcr_notva
	mov	cs:[mmask_port],18ah	;master_mask (VA)
kcr_notva:
	cmp	_pcm_access[bx],0	;cf=0
	jnz	kcr_exit
	mov	al,_key_check[bx]
	mov	cs:[key_check_push],al
	mov	_key_check[bx],0
	mov	_pcm_access[bx],1
	stc				;cf=1
kcr_exit:
	cmc
	pop	dx
	pop	bx
	pop	ax
	pop	ds
	ret


;==============================================================================
;	PMD�� ESC/GRPH���͂����ɖ߂�
;	PCM�������A�N�Z�X�t���O��off
;==============================================================================
key_check_set:
	push	ds
	push	ax
	push	bx
	push	dx
	mov	ah,10h
	int	60h
	mov	bx,dx
	mov	bx,-2[bx]
	mov	al,cs:[key_check_push]
	mov	_key_check[bx],al
	mov	_pcm_access[bx],0
	pop	dx
	pop	bx
	pop	ax
	pop	ds
	ret

;==============================================================================
;	DataArea
;==============================================================================
allload_mes	db	"�o�b�l���`���ł��B���΂炭���҂��������B",13,10,"$"
exit1_mes	db	"PCM����`�o������ł͂���܂���B",13,10,"$"
exit1p_mes	db	"PPSDRV���풓���Ă��܂���B",13,10,"$"
exit2_mes	db	"PCMFile��������܂���B",13,10,"$"
exit2p_mes	db	"PPSFile��������܂���B",13,10,"$"
exit3_mes	db	"PCMFile��FORMAT���Ⴂ�܂��B",13,10,"$"
exit3p_mes	db	"PPSDRV�̊m�ۗe�ʂ�����܂���B",13,10,"$"
exit4_mes	db	"PCMData����v�����̂œǂݍ��݂܂���B",13,10,"$"
exit4pp_mes	db	"P86DRV�̊m�ۗe�ʂ�����܂���B",13,10,"$"
exit5_mes	db	"PCMFile���ǂݍ��߂܂���B",13,10,"$"
exit5p_mes	db	"PPSFile���ǂݍ��߂܂���B",13,10,"$"
exit6_mes	db	"PCM�������𑼂̃A�v���P�[�V�������A�N�Z�X���ł��B",13,10,"$"
adpcm_header	db	"ADPCM DATA for  PMD ver.4.4-  " ;30 bytes

retry_flag	db	0
key_check_push	db	0
wait_clock	dw	0
adpcm_wait	db	0
mmask_port	dw	0
mmask_push	db	0

		even
filename_ofs	dw	?
filename_seg	dw	?
filename_ofs2	dw	?
filename_seg2	dw	?
pcmdata_ofs	dw	?
pcmdata_seg	dw	?
pcmdata_size_s	db	?
pcmdata_size	dw	?
pcmwork_ofs	dw	?
pcmwork_seg	dw	?
port46		dw	?
port47		dw	?
pcmstop		dw	?
pcmstart	dw	?
fhand2		dw	?

open_work	struc
_mmlbuf		dw	?		;Musicdata��address+1
_tondat		dw	?		;Voicedata��address
_efcdat		dw	?		;FM  Effecdata��address
_fm1_port1	dw	?		;FM���� I/O port (�\1)
_fm1_port2	dw	?		;FM���� I/O port (�\2)
_fm2_port1	dw	?		;FM���� I/O port (��1)
_fm2_port2	dw	?		;FM���� I/O port (��2)
_fmint_ofs	dw	?		;FM���荞�݃t�b�N�A�h���X offset
_fmint_seg	dw	?		;FM���荞�݃t�b�N�A�h���X address
_efcint_ofs	dw	?		;���ʉ����荞�݃t�b�N�A�h���X offset
_efcint_seg	dw	?		;���ʉ����荞�݃t�b�N�A�h���X address
_prgdat_adr	dw	?		;�ȃf�[�^�����F�f�[�^�擪�Ԓn
_radtbl		dw	?		;R part offset table �擪�Ԓn
_rhyadr		dw	?		;R part ���t���Ԓn
_rhythmmask	db	?		;Rhythm�����̃}�X�N x8c/10h��bit�ɑΉ�
_board		db	?		;FM�����{�[�h����^�Ȃ�flag
_key_check	db	?		;ESC/GRPH key Check flag
_fm_voldown	db	?		;FM voldown ���l
_psg_voldown	db	?		;PSG voldown ���l
_pcm_voldown	db	?		;PCM voldown ���l
_rhythm_voldown	db	?		;RHYTHM voldown ���l
_prg_flg	db	?		;�ȃf�[�^�ɉ��F���܂܂�Ă��邩f_lag
_x68_flg	db	?		;OPM flag
_status		db	?		;status1
_status2	db	?		;status2
_tempo_d	db	?		;tempo (TIMER-B)
_fadeout_speed	db	?		;Fadeout���x
_fadeout_volume	db	?		;Fadeout����
_syousetu	db	?		;���߃J�E���^
_syousetu_lng	db	?		;���߂̒���
_opncount	db	?		;�ŒZ�����J�E���^
_TimerAtime	db	?		;TimerA�J�E���^
_effflag	db	?		;PSG���ʉ�����on/off flag
_psnoi		db	?		;PSG noise���g��
_psnoi_last	db	?		;PSG noise���g��(�Ō�ɒ�`�������l)
_fm_effec_num	db	?		;��������FM���ʉ��ԍ�
_fm_effec_flag	db	?		;FM���ʉ�������flag (1)
_disint		db	?		;FM���荞�ݒ��Ɋ��荞�݂��֎~���邩flag
_pcmflag	db	?		;PCM���ʉ�������flag
_pcmstart	dw	?		;PCM���F��start�l
_pcmstop	dw	?		;PCM���F��stop�l
_pcm_effec_num	db	?		;��������PCM���ʉ��ԍ�
__pcmstart	dw	?		;PCM���ʉ���start�l
__pcmstop	dw	?		;PCM���ʉ���stop�l
__voice_delta_n	dw	?		;PCM���ʉ���delta_n�l
__pcmpan	db	?		;PCM���ʉ���pan
__pcm_volume	db	?		;PCM���ʉ���volume
_rshot_dat	db	?		;���Y������ shot flag
_rdat		db	6 dup (?)	;���Y������ ����/�p���f�[�^
_rhyvol		db	?		;���Y���g�[�^�����x��
_kshot_dat	dw	?		;�r�r�f���Y�� shot flag
_ssgefcdat	dw	?		;PSG Effecdata��address
_ssgefclen	dw	?		;PSG Effecdata�̒���
_play_flag	db	?		;play flag
_pause_flag	db	?		;pause flag
_fade_stop_flag	db	?		;Fadeout�� MSTOP���邩�ǂ����̃t���O
_kp_rhythm_flag	db	?		;K/Rpart��Rhythm������炷��flag
_TimerBflag	db	?		;TimerB���荞�ݒ��H�t���O
_TimerAflag	db	?		;TimerA���荞�ݒ��H�t���O
_int60flag	db	?		;INT60H���荞�ݒ��H�t���O
_int60_result	db	?		;INT60H�̎��sErrorFlag
_pcm_gs_flag	db	?		;ADPCM�g�p ���t���O (0�ŋ���)
_esc_sp_key	db	?		;ESC +?? Key Code
_grph_sp_key	db	?		;GRPH+?? Key Code
_rescut_cant	db	?		;�풓�����֎~�t���O
_slot_detune1	dw	?		;FM3 Slot Detune�l slot1
_slot_detune2	dw	?		;FM3 Slot Detune�l slot2
_slot_detune3	dw	?		;FM3 Slot Detune�l slot3
_slot_detune4	dw	?		;FM3 Slot Detune�l slot4
_wait_clock	dw	?		;FM ADDRESS-DATA�� Loop $�̉�
_wait1_clock	dw	?		;loop $ �P�̑��x
_ff_tempo	db	?		;�����莞��TimerB�l
_pcm_access	db	?		;PCM�Z�b�g���� 1
_TimerB_speed	db	?		;TimerB�̌��ݒl(=ff_tempo�Ȃ�ff��)
_fadeout_flag	db	?		;��������fout���Ăяo������1
_adpcm_wait	db	?		;ADPCM��`�̑��x

open_work	ends
