;==============================================================================
;	Loop $ �� ��ns���𒲂ׂ�	(pmdl.asm include�p)
;		output	ax	�P���loop $�̑���(ns)
;==============================================================================
waittest	proc

	push	bx
	push	cx
	push	dx
	push	ds
	push	es

;------------------------------------------------------------------------------
;	���݂� Timer�̃x�N�g��/�}�X�N��ۑ�
;------------------------------------------------------------------------------
	cli
	xor	ax,ax
	mov	es,ax
	mov	ax,cs
	mov	ds,ax

	mov	ax,es:[timervector*4]
	mov	[w_timerofs_push],ax
	mov	ax,es:[timervector*4+2]
	mov	[w_timerseg_push],ax

	in	al,ms_msk
	mov	[w_mmsk_push],al

;------------------------------------------------------------------------------
;	Timer�ȊO�̑S�Ă̊��荞�݂��֎~
;------------------------------------------------------------------------------
	mov	al,0feh
	out	ms_msk,al

;------------------------------------------------------------------------------
;	Timer�ݒ�
;------------------------------------------------------------------------------
ife	ibm
	test	byte ptr es:[501h],80h
	jz	tcg_5mhz
	mov	bx,200		;0.1ms Timer���荞�� (10ms=19968 8MHz�n)
	jmp	tcg_set
tcg_5mhz:
	mov	bx,246		;0.1ms Timer���荞�� (10ms=24576 5MHz�n)
tcg_set:
else
	mov	bx,119
endif
	mov	al,36h
	out	timer_comm,al
	mov	cx,10
	loop	$
	mov	al,bl
	out	timer_data,al
	mov	cx,10
	loop	$
	mov	al,bh
	out	timer_data,al

	mov	es:[timervector*4],offset timer_entry
	mov	es:[timervector*4+2],cs

;------------------------------------------------------------------------------
;	���胁�C��
;------------------------------------------------------------------------------
	xor	bx,bx		;Timer Counter
	mov	al,20h		;EOI Send�p
	mov	dx,50000
	mov	cx,dx
	even			;
	nop			;
	sti			;�����Ԓn�ɍ��킹��
	loop	$		;
	mov	cx,dx
	loop	$		;100000�� loop
	cli

;------------------------------------------------------------------------------
;	���荞�݂����ɖ߂�
;------------------------------------------------------------------------------
	mov	al,36h
	out	timer_comm,al
	mov	cx,10
	loop	$
	mov	al,0ffh		;�Œᑬ�ݒ�(1)
	out	timer_data,al
	mov	cx,10
	loop	$
	out	timer_data,al	;�Œᑬ�ݒ�(2)

	mov	al,[w_mmsk_push]
	out	ms_msk,al

	mov	ax,[w_timerofs_push]
	mov	es:[timervector*4],ax
	mov	ax,[w_timerseg_push]
	mov	es:[timervector*4+2],ax
	sti

	mov	ax,bx		;ax=1�񕪂�loop $

;------------------------------------------------------------------------------
;	�I��
;------------------------------------------------------------------------------
waittest_exit:
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	ret

;==============================================================================
;	timer Entry
;==============================================================================
timer_entry:
	inc	bx
	out	ms_cmd,al
	iret

;==============================================================================
;	Datas
;==============================================================================
w_timerofs_push	dw	?
w_timerseg_push	dw	?
w_mmsk_push	db	?

timervector	equ	08h		;timer.���荞��

waittest	endp