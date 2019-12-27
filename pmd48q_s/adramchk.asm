;==============================================================================
;
;	ADPCM RAM CHECK for INCLUDE
;					output: cs:[pcm_gs_flag]
;
;==============================================================================

;==============================================================================
;	ADPCM-RAM��check
;==============================================================================
adpcm_ram_check:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax

	mov	al,[adpcm_wait]

	push	ax
	mov	[adpcm_wait],2
	mov	di,offset check_data
	mov	cx,16
	xor	ax,ax
rep	stosw
	mov	si,offset check_data
	call	pcmstore		;clear pcm(low speed)
	pop	ax
	jc	found_ymf288

	cmp	al,2
	jz	not_check_middle
	cmp	al,1
	jz	not_check_fast

	mov	[adpcm_wait],0		;����
	mov	si,offset check_code
	call	pcmstore		;CHECKcode��������
	call	pcmread
	call	pcmcompare
	jz	arc_found_exit
not_check_fast:

	mov	[adpcm_wait],1		;����
	mov	si,offset check_code
	call	pcmstore		;CHECKcode��������
	call	pcmread
	call	pcmcompare
	jz	arc_found_exit
not_check_middle:

	mov	[adpcm_wait],2		;�ᑬ
	mov	si,offset check_code
	call	pcmstore		;CHECKcode��������
	call	pcmread
	call	pcmcompare
	jnz	arc_no_exit

arc_found_exit:
	mov	[pcm_gs_flag],0		;���݂���
	ret

found_ymf288:
	mov	word ptr [mes_ongen1+2],"2F"
	mov	word ptr [mes_ongen1+4],"88"
arc_no_exit:
	mov	[pcm_gs_flag],1		;���݂��Ȃ�
	ret

;==============================================================================
;	�o�b�l�������փ��C������������CHECK�f�[�^�𑗂� (x8,����/�ᑬ�I���)
;		in.si	check_code offset
;==============================================================================
pcmstore:
	mov	dx,0001h
	call	opnset46

	mov	dx,1017h	;brdy�ȊO�̓}�X�N(=timer���荞�݂͊|����Ȃ�)
	call	opnset46
	mov	dx,1080h
	call	opnset46
	mov	dx,0060h
	call	opnset46
	mov	dx,0102h	;x8
	call	opnset46

	mov	dx,0cffh
	call	opnset46
	inc	dh
	call	opnset46

	mov	bx,01fffh	;Address 1FFFH
	mov	dh,002h
	mov	dl,bl
	call	opnset46
	inc	dh
	mov	dl,bh
	call	opnset46

	mov	dx,04ffh
	call	opnset46
	inc	dh
	call	opnset46

	mov	cx,32

	mov	dx,[fm2_port1]
	mov	bx,[fm2_port2]

	cmp	[adpcm_wait],0
	jz	fast_store
	cmp	[adpcm_wait],1
	jz	middle_store

;------------------------------------------------------------------------------
;	�ᑬ��`
;------------------------------------------------------------------------------
slow_store:
	cli
	in	al,dx
o4600z:	in	al,dx
	or	al,al
	js	o4600z

	mov	al,8	;PCMDAT	reg.
	out	dx,al
	push	cx
	mov	cx,[wait_clock]
	loop	$
	pop	cx

	xchg	bx,dx
	lodsb
	out	dx,al	;OUT	data
	sti
	xchg	dx,bx

	push	cx
	mov	cx,10000	;�ᑬ�̏ꍇ�̂�YMF288��check
	in	al,dx
o4601z:
	in	al,dx
	test	al,8		;BRDY	check
	jnz	o4601za
	loop	o4601z
	pop	cx
	call	pcmst_exit
	stc
	ret
o4601za:
	pop	cx
	in	al,dx
o4601zb:
	in	al,dx
	test	al,al	;BUSY	check
	jns	o4601zc
	in	al,dx
	jmp	o4601zb
o4601zc:

	mov	al,10h
	cli
	out	dx,al
	push	cx
	mov	cx,[wait_clock]
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
middle_store:
	call	cli_sub
o4600y:	in	al,dx
	or	al,al
	js	o4600y
	mov	al,8	;PCMDAT	reg.
	out	dx,al

middle_store_loop:
	push	cx
	mov	cx,[wait_clock]
	loop	$
	pop	cx

	xchg	bx,dx
	lodsb
	out	dx,al	;OUT	data
	xchg	bx,dx
o4601y:
	in	al,dx
	test	al,8	;BRDY	check
	jz	o4601y

	loop	middle_store_loop
	call	sti_sub

	jmp	pcmst_exit

;------------------------------------------------------------------------------
;	������`
;------------------------------------------------------------------------------
fast_store:

	call	cli_sub
o4600x:	in	al,dx
	or	al,al
	js	o4600x
	mov	al,8	;PCMDAT	reg.
	out	dx,al
	push	cx
	mov	cx,[wait_clock]
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
	call	opnset46
	mov	dx,1080h
	call	opnset46
	mov	dx,0001h
	call	opnset46

	clc
	ret

;------------------------------------------------------------------------------
;	RS-232C�ȊO�͊��荞�݂��֎~����
;	(FM����LSI �� ADDRESS�̕ύX�������Ȃ���)
;------------------------------------------------------------------------------
cli_sub:
	push	ax
	push	dx
	cli
	mov	dx,ms_msk
	in	al,dx
	mov	[mmask_push],al
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
	mov	dx,ms_msk
	mov	al,[mmask_push]
	out	dx,al
	sti
	pop	dx
	pop	ax
	ret

;==============================================================================
;	�o�b�l���������烁�C���������ւ�Check�f�[�^��荞��
;==============================================================================
pcmread:
	mov	dx,0001h
	call	opnset46

	mov	dx,1000h
	call	opnset46
	mov	dx,1080h
	call	opnset46
	mov	dx,0020h
	call	opnset46
	mov	dx,0102h	;x8
	call	opnset46
	mov	dx,0cffh
	call	opnset46
	inc	dh
	call	opnset46
	mov	bx,1fffh	;Address 1FFFH
	mov	dh,002h
	mov	dl,bl
	call	opnset46
	mov	dh,003h
	mov	dl,bh
	call	opnset46
	mov	dx,04ffh
	call	opnset46
	inc	dh
	call	opnset46

	call	pget
	call	pget

	mov	cx,32
	mov	di,offset check_data

pcr00:	mov	dx,[fm2_port1]
	cli
pcr00b:	in	al,dx
	test	al,al
	js	pcr00b
	mov	al,8
	out	dx,al

	in	al,dx
pcr01:	in	al,dx
	test	al,00001000b
	jz	pcr01

	in	al,dx
pcr02:	in	al,dx
	or	al,al
	js	pcr02

	mov	dx,[fm2_port2]
	in	al,dx
	sti
	stosb

	mov	dx,1080h
	call	opnset46

	loop	pcr00

	mov	dx,0001h
	call	opnset46

	ret

;==============================================================================
;	���ʓǂݗp
;==============================================================================
pget:	cli
	mov	dx,[fm2_port1]
pg00:	in	al,dx
	test	al,al
	js	pg00
	mov	al,008h
	out	dx,al

	push	cx
	mov	cx,[wait_clock]
	loop	$
	pop	cx

	mov	dx,[fm2_port2]
	in	al,dx
	sti
	mov	dx,1080h
	call	opnset46
	ret

;==============================================================================
;	Check Data��r
;		out. ZF=1�œ���
;==============================================================================
pcmcompare:
	mov	si,offset check_code
	mov	di,offset check_data
	mov	cx,32
rep	cmpsb
	ret

;			 12345678901234567890123456789012
check_code	db	"*+=-PMD ADPCM RAM Check Data-=+*"
check_data	db	32 dup(0)
mmask_push	db	?