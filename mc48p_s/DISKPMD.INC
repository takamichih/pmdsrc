;==============================================================================
;	Read File
;	INPUT	FILENAME TOP	to DS:AX
;		ADDRESS		to DS:DX
;		kankyo_seg	to ES
;	OUTPUT	CX 		to LENGTH of FILE
;		Cy		to Error
;==============================================================================
diskread	proc
	push	es
	push	ds
	push	dx
	push	bx
	push	ax
	push	si
	push	di
	xchg	ax,dx	;DS:DX=filename
	push	ds
	push	ax
	call	opnhnd
	pop	dx
	pop	ds	;DS:DX=Address
	jc	diskread_stc_ret
	mov	cx,-1	;Max 65535 bytes
	call	redhnd
	mov	cx,ax	;CX=Read Bytes
	jc	diskread_stc_ret
	push	cx
	call	clohnd
	pop	cx
	jc	diskread_stc_ret
	pop	di
	pop	si
	pop	ax
	pop	bx
	pop	dx
	pop	ds
	pop	es
	ret

diskread_stc_ret:
	pop	di
	pop	si
	pop	ax
	pop	bx
	pop	dx
	pop	ds
	pop	es
	stc
	ret
diskread	endp

;==============================================================================
;	Write File
;	INPUT	FILENAME TOP	to DS:AX
;		ADDRESS		to DS:DX
;		LENGTH		to CX
;	OUTPUT	CX		to Write Length
;		Cy		to Error
;==============================================================================
diskwrite	proc
	push	es
	push	ds
	push	dx
	push	bx
	push	ax
	push	si
	push	di
	xchg	ax,dx	;DS:DX=Filename
	push	ds
	push	ax
	push	cx
	call	makhnd
	pop	cx	;CX=Write Length
	pop	dx
	pop	ds	;DS:DX=Address
	jc	diskwrite_stc_ret
	call	wrihnd
	jc	diskwrite_stc_ret
	push	cx
	call	clohnd
	pop	cx
	jc	diskwrite_stc_ret
	pop	di
	pop	si
	pop	ax
	pop	bx
	pop	dx
	pop	ds
	pop	es
	ret

diskwrite_stc_ret:
	pop	di
	pop	si
	pop	ax
	pop	bx
	pop	dx
	pop	ds
	pop	es
	stc
	ret
diskwrite	endp

;==============================================================================
;	open handle	(環境変数"PMD"をサーチ)
;		in DS:DX filename
;		   ES    環境segment
;
;	!注!	ds,esも破壊します。
;==============================================================================
opnhnd	proc
	mov	ax,3d00h
	push	es
	push	ds
	push	dx
	int	21h
	pop	dx
	pop	ds
	pop	es
	jc	oh_search
	mov	cs:[fhand],ax
	ret

;------------------------------------------------------------------------------
;	ファイル名中に"\"/":"があったらそこの後ろまで飛ばす
;------------------------------------------------------------------------------
oh_search:
	push	ds
	push	es
	pop	ds
	pop	es
	mov	bx,dx
	xor	si,si	;DS:SI=環境 / ES:BX=filename
oh_ys_loop:
	mov	al,es:[bx]
	inc	bx
	call	sjis_check
	jnc	oh_ys_notsjis
	inc	bx	;Sjis 2byte目を飛ばす
	jmp	oh_ys_loop
oh_ys_notsjis:
	or	al,al
	jz	oh_ys_exit
	cmp	al,":"
	jz	oh_ys_jump
	cmp	al,"\"
	jnz	oh_ys_loop
oh_ys_jump:
	mov	dx,bx
	jmp	oh_ys_loop
oh_ys_exit:
	mov	bx,dx
;------------------------------------------------------------------------------
;	環境変数"PMD"を探す
;------------------------------------------------------------------------------
oh_search_loop:
	cmp	word ptr [si],"MP"
	jnz	oh_next_search
	cmp	word ptr 2[si],"=D"
	jz	oh_set_path
;------------------------------------------------------------------------------
;	次の環境変数まで飛ばす ないならcy=1でret
;------------------------------------------------------------------------------
oh_next_search:
	inc	si
	cmp	byte ptr -1[si],0
	jnz	oh_next_search
	cmp	byte ptr [si],0	;最後か？
	jnz	oh_search_loop
	stc	;環境変数"PMD"が無い
	ret

;------------------------------------------------------------------------------
;	パス名とfile名を設定
;------------------------------------------------------------------------------
oh_set_path:
	add	si,4
osp_loop1:
	mov	di,offset oh_filename
	xor	ah,ah	;ah = ShiftJIS check code
osp_loop2:
	cmp	byte ptr [si],0	;終端か？
	jz	oh_set_filename
	lodsb
	cmp	al,";"		;区切り記号か？
	jz	oh_set_filename
	xor	ah,ah
	call	sjis_check
	jnc	non_sjis
	mov	ah,1
	mov	cs:[di],al
	inc	di
	lodsb	;S-JIS 2byte目をget
non_sjis:
	mov	cs:[di],al
	inc	di
	jmp	osp_loop2
oh_set_filename:
	or	ah,ah		;最後に転送したのがS-JIS漢字なら
	jnz	oh_set_yen	;\記号を無条件に設定
	mov	al,cs:-1[di]
	cmp	al,"\"
	jz	oh_not_set_yen
	cmp	al,":"		; "A:"等の場合は\記号は付加しない
	jz	oh_not_set_yen
oh_set_yen:
	mov	byte ptr cs:[di],"\"	; "\"が無かったら書く
	inc	di
oh_not_set_yen:
	push	bx
osf_loop:
	mov	al,es:[bx]
	inc	bx
	mov	cs:[di],al
	inc	di
	or	al,al
	jnz	osf_loop
	pop	bx

	push	ds
	push	es
	push	bx
	push	si
	mov	ax,cs
	mov	ds,ax
	mov	dx,offset oh_filename
	mov	ax,3d00h
	int	21h
	pop	si
	pop	bx
	pop	es
	pop	ds
	jnc	oh_found_ret
	cmp	byte ptr [si],0	;環境終端まで来たか？
	jnz	osp_loop1
	stc	;ファイルが見つからない
	ret

oh_found_ret:
	mov	cs:[fhand],ax
	ret

opnhnd	endp

;==============================================================================
;	al が shiftJIS 1byte目かどうかcheck
;			output	cy=1	ShiftJIS
;==============================================================================
sjis_check	proc
	or	al,al
	jns	sjc_clc_ret
	push	ax
	sub	al,20h
	test	al,40h
	pop	ax
	jz	sjc_clc_ret
	stc
	ret
sjc_clc_ret:
	clc
	ret
sjis_check	endp

;==============================================================================
;	read handle
;		in  DS:DX address / CX read bytes
;		out AX read_bytes
;==============================================================================
redhnd	proc
	mov	bx,cs:[fhand]
	mov	ah,3fh
	int	21h
	ret
redhnd	endp

;==============================================================================
;	close handle
;==============================================================================
clohnd	proc
	mov	ah,3eh
	mov	bx,cs:[fhand]
	int	21h
	ret
clohnd	endp

;==============================================================================
;	make handle
;		in DS:DX filename
;==============================================================================
makhnd	proc
	mov	ah,3ch
	xor	cx,cx
	int	21h
	mov	cs:[fhand],ax
	ret
makhnd	endp

;==============================================================================
;	write handle
;		in DS:DX address / CX write bytes
;==============================================================================
wrihnd	proc
	mov	ah,40h
	mov	bx,cs:[fhand]
	int	21h
	ret
wrihnd	endp

fhand		dw	?
oh_filename	db	128 dup(?)
