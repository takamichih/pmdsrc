;==============================================================================
;	Loop $ が 何nsかを調べる	(pmdl.asm include用)
;		output	ax	１回のloop $の速さ(ns)
;==============================================================================
waittest	proc

	push	bx
	push	cx
	push	dx
	push	ds
	push	es

;------------------------------------------------------------------------------
;	現在の Timerのベクトル/マスクを保存
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
;	Timer以外の全ての割り込みを禁止
;------------------------------------------------------------------------------
	mov	al,0feh
	out	ms_msk,al

;------------------------------------------------------------------------------
;	Timer設定
;------------------------------------------------------------------------------
ife	ibm
	test	byte ptr es:[501h],80h
	jz	tcg_5mhz
	mov	bx,200		;0.1ms Timer割り込み (10ms=19968 8MHz系)
	jmp	tcg_set
tcg_5mhz:
	mov	bx,246		;0.1ms Timer割り込み (10ms=24576 5MHz系)
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
;	測定メイン
;------------------------------------------------------------------------------
	xor	bx,bx		;Timer Counter
	mov	al,20h		;EOI Send用
	mov	dx,50000
	mov	cx,dx
	even			;
	nop			;
	sti			;偶数番地に合わせる
	loop	$		;
	mov	cx,dx
	loop	$		;100000回 loop
	cli

;------------------------------------------------------------------------------
;	割り込みを元に戻す
;------------------------------------------------------------------------------
	mov	al,36h
	out	timer_comm,al
	mov	cx,10
	loop	$
	mov	al,0ffh		;最低速設定(1)
	out	timer_data,al
	mov	cx,10
	loop	$
	out	timer_data,al	;最低速設定(2)

	mov	al,[w_mmsk_push]
	out	ms_msk,al

	mov	ax,[w_timerofs_push]
	mov	es:[timervector*4],ax
	mov	ax,[w_timerseg_push]
	mov	es:[timervector*4+2],ax
	sti

	mov	ax,bx		;ax=1回分のloop $

;------------------------------------------------------------------------------
;	終了
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

timervector	equ	08h		;timer.割り込み

waittest	endp
