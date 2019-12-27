;
;	[PMP]	stop / mset / play
;

date	equ	"1997/01/29"

@code	segment	para	public	'@code'
	assume	cs:@code,ds:@code,es:@code

	org	100h

start:	jmp	pmp

	include	newpmd.inc
	include	diskpmd.inc
	include	pcmload.inc

myname	db	"PMP     COM"
pmp:	include	virus.inc

	mov	ax,cs
	mov	es,ax

	push	ds
	push	es
	mov	ds,ax
	print_mes	pmp_title_mes
	call	check_pmd
	jc	not_resident
	mov	ah,10h
	int	60h
	mov	bx,dx
	mov	bx,ds:-2[bx]
	cmp	ds:_pcm_access[bx],0
	jnz	pcm_access_error
	pop	es
	pop	ds

	mov	ax,ds:[2ch]	;環境segment
	mov	cs:[kankyo_seg],ax

	mov	si,80h
	cmp	byte ptr [si],0
	jz	usage

	inc	si
	call	space_cut

;==============================================================================
; 	コマンドラインから /optionの読みとり
;==============================================================================
	mov	cs:[memo_flg],1
	mov	cs:[pcm_flg],1

option_loop:
	lodsb
	cmp	al," "
	jz	option_loop
	jc	option_exit
	cmp	al,"/"
	jz	option_get
	cmp	al,"-"
	jnz	option_exit

option_get:
	lodsb
	and	al,11011111b	;小文字＞大文字変換
	cmp	al,"P"
	jz	pmd_play
	cmp	al,"S"
	jz	pmd_stop
	cmp	al,"F"
	jz	pmd_fade
	cmp	al,"E"
	jz	pmd_efcstop
	cmp	al,"A"
	jz	reset_pcmflg
	cmp	al,"O"
	jz	reset_memoflg
	jmp	usage

;==============================================================================
;	/A option ... Non read PCM
;==============================================================================
reset_pcmflg:
	mov	cs:[pcm_flg],0
	jmp	option_loop

;==============================================================================
;	/O option ... Non put Title
;==============================================================================
reset_memoflg:
	mov	cs:[memo_flg],0
	jmp	option_loop

;==============================================================================
;	/E option ... stop effects
;==============================================================================
pmd_efcstop:
	pmd	efcoff
	pmd	fm_efcoff
	mov	ax,cs
	mov	ds,ax
	print_mes	efcstop_mes
	msdos_exit

;==============================================================================
;	/P opiton ... play
;==============================================================================
pmd_play:
	mov	ax,cs
	mov	ds,ax
	print_mes	mstart_mes

	pmd	get_file_adr
	mov	bx,dx

	cmp	byte ptr [bx],0
	jz	pl_noput
	push	ds
	mov	ax,cs
	mov	ds,ax
	push	bx
	print_mes	mes_filename
	pop	bx
	pop	ds
pl_loop:
	mov	dl,[bx]
	inc	bx
	test	dl,dl
	jz	pl_exit
	mov	ah,2
	push	bx
	int	21h	;１文字表示
	pop	bx
	jmp	pl_loop
pl_exit:
	mov	ax,cs
	mov	ds,ax
	print_mes	mes_crlf
pl_noput:
	mov	ax,cs
	mov	ds,ax

	pmd	mstop
	cmp	[memo_flg],0
	jz	pp_non_pcmfile_put
	call	pcmfile_put
pp_non_pcmfile_put:
	cmp	[pcm_flg],0
	jz	pp_non_pcm_read
	call	pcm_read_main
pp_non_pcm_read:
	pmd	mstart
	cmp	[memo_flg],0
	jz	pp_non_memo_put
	call	memo_put
pp_non_memo_put:
	msdos_exit

;==============================================================================
;	/S opiton ... stop
;==============================================================================
pmd_stop:
	mov	ax,cs
	mov	ds,ax
	pmd	mstop
	print_mes	mstop_mes
	msdos_exit

;==============================================================================
;	/F opiton ... fadeout
;==============================================================================
pmd_fade:
	mov	ax,cs
	mov	ds,ax
	call	get_comline_number
	jnc	fade
	mov	al,16	;Default 16
fade:
	pmd	fout
	print_mes	fade_mes
	msdos_exit

;
;	コマンドラインから数値を読み込む(0-255)
;	IN. DS:SI to COMMAND_LINE
;	OUT.AL	  to NUMBER
;	    CY	  to Error_Flag
;
get_comline_number:
	xor	bx,bx

	lodsb
	sub	al,"0"
	cmp	al,10
	jnc	not_num
	mov	bl,al

num_loop:
	lodsb
	sub	al,"0"
	cmp	al,10
	jnc	numret
	add	bl,bl
	mov	ah,bl
	shl	bl,1
	shl	bl,1
	add	bl,ah
	add	bl,al
	jmp	num_loop
numret:
	dec	si
	mov	al,bl
	clc
	ret
not_num:
	dec	si
	xor	al,al
	stc
	ret

option_exit:
	dec	si
;==============================================================================
; 	コマンドラインから.mのファイル名の取り込み
;==============================================================================

	xor	ah,ah
	mov	di,offset file_name
	mov	bp,di
g_mfn_loop:
	lodsb
	call	sjis_check	;in DISKPMD.INC
	jnc	g_mfn_notsjis
	stosb		;S-JIS漢字1byte目なら 無条件に書き込み
	movsb		;S-JIS漢字2byte目を転送
	jmp	g_mfn_loop
g_mfn_notsjis:
	cmp	al," "
	jz	g_mfn_next
	cmp	al,13
	jz	g_mfn_next
	cmp	al,"\"
	jnz	g_mfn_notyen
	mov	bp,di
	inc	bp
	xor	ah,ah
g_mfn_notyen:
	cmp	al,"."
	jnz	g_mfn_store
	mov	ah,1
g_mfn_store:
	stosb
	jmp	g_mfn_loop
g_mfn_next:
	dec	si
	or	ah,ah
	jnz	mfn_ofs_notset

	mov	ax,"M."
	stosw

mfn_ofs_notset:
	mov	byte ptr es:[di],0

;==============================================================================
; 	.mファイルの読み込み
;==============================================================================

	mov	ax,cs
	mov	ds,ax
	mov	dx,offset file_name	;ds:dx = filename
	mov	es,cs:[kankyo_seg]	;es    = 環境segment
	push	ds
	push	es
	push	di
	push	dx
	call	opnhnd
	pop	dx
	pop	di
	pop	es
	pop	ds
	jnc	read_main
	cmp	word ptr -2[di],"M."
	jnz	readerror

	mov	word ptr [di],"2"
	push	ds
	push	es
	push	di
	push	dx
	call	opnhnd		;".M2"
	pop	dx
	pop	di
	pop	es
	pop	ds
	jnc	read_main
	mov	word ptr [di],"Z"
	call	opnhnd		;".MZ"
	jc	readerror
read_main:

	pmd	get_file_adr
	mov	si,bp
	mov	di,dx
	mov	ax,ds
	mov	es,ax
	mov	ax,cs
	mov	ds,ax
	mov	cx,12
rm_fnset_loop:
	movsb
	cmp	byte ptr -1[si],0
	jz	rm_00
	loop	rm_fnset_loop
	mov	byte ptr es:[di],0
rm_00:
	mov	ax,cs
	mov	ds,ax

	PMD	MSTOP
	PMD	GET_EFC_ADR	;DS:DX = address
	mov	cx,dx
	PMD	GET_MUSIC_ADR	;DS:DX = address
	sub	cx,dx		;MAX EFCDATA_START - MUSDATA_START

	push	cx
	call	redhnd
	pop	cx
	pushf
	cmp	ax,cx
	jz	over_error
	call	clohnd
	jc	readerror
	popf
	jc	readerror

	jmp	pmd_play

;==============================================================================
;	PPZ/PPS/PCMファイルの読み込み
;==============================================================================
pcm_read_main:
	mov	al,-2
	pmd	get_memo
	or	dx,dx
	jz	ppzread_exit
	mov	bx,dx
	cmp	byte ptr ds:[bx],0
	jz	ppzread_exit
	mov	ax,bx			;DS:AX=filename
	mov	cl,3			;２つまとめ読み
	call	ppz_load		;in PCMLOAD.INC
ppzread_exit:

	mov	al,-1
	pmd	get_memo
	or	dx,dx
	jz	ppsread_exit
	mov	bx,dx
	cmp	byte ptr ds:[bx],0
	jz	ppsread_exit
	mov	ax,bx			;DS:AX=filename
	call	pps_load		;in PCMLOAD.INC
ppsread_exit:

	xor	al,al
	pmd	get_memo
	or	dx,dx
	jz	pcmread_exit
	mov	bx,dx
	cmp	byte ptr ds:[bx],0
	jz	pcmread_exit
	mov	di,offset pcm_data	;ES:DI=pcm_data_work
	mov	ax,bx			;DS:AX=filename
	call	pcm_all_load		;in PCMLOAD.INC
pcmread_exit:
	mov	ax,cs
	mov	ds,ax
	ret

;==============================================================================
;	#PPZFile / #PPSFile / #PCMFileの表示
;==============================================================================
pcmfile_put:
	mov	al,-2
	pmd	get_memo
	or	dx,dx
	jz	non_ppzfile
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],0
	jz	non_ppzfile
	print_mes	mes_ppzfile
	call	put_strings
non_ppzfile:

	mov	al,-1
	pmd	get_memo
	or	dx,dx
	jz	non_ppsfile
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],0
	jz	non_ppsfile
	print_mes	mes_ppsfile
	call	put_strings
non_ppsfile:

	xor	al,al
	pmd	get_memo
	or	dx,dx
	jz	non_pcmfile
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],0
	jz	non_pcmfile
	print_mes	mes_pcmfile
	call	put_strings
non_pcmfile:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	ret

;==============================================================================
;	メモ文字列の表示
;==============================================================================
memo_put:
	mov	al,1
	pmd	get_memo
	or	dx,dx
	jz	non_title
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],0
	jz	non_title
	print_mes	mes_title
	call	put_strings
non_title:

	mov	al,2
	pmd	get_memo
	or	dx,dx
	jz	non_composer
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],0
	jz	non_composer
	print_mes	mes_composer
	call	put_strings
non_composer:

	mov	al,3
	pmd	get_memo
	or	dx,dx
	jz	non_arranger
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],0
	jz	non_arranger
	print_mes	mes_arranger
	call	put_strings
non_arranger:

	mov	al,4
memo_loop:
	pmd	get_memo
	or	dx,dx
	jz	non_memo
	push	cs
	push	ds
	pop	es
	pop	ds
	mov	si,dx
	cmp	byte ptr es:[si],"/"
	jz	non_memo
	push	ax
	print_mes	mes_memo
	call	put_strings
	pop	ax
	inc	al
	jmp	memo_loop
non_memo:

	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	ret

;==============================================================================
;	メモ文字列の１行表示
;		Input	si	M_adr
;==============================================================================
put_strings:
	mov	dl,es:[si]
	or	dl,dl
	jz	ps_exit
	mov	ah,2
	int	21h
	inc	si
	jmp	put_strings
ps_exit:
	print_mes	mes_crlf
	ret

;==============================================================================
; 	command lineのスペースを飛ばす
;
;		in	ds:si = command line point
;==============================================================================
space_cut:
	cmp	byte ptr [si]," "
	jnz	sc_ret
	inc	si
	jmp	space_cut
sc_ret:
	ret

;==============================================================================
;	usage
;==============================================================================
USAGE:
	MOV	AX,CS
	MOV	DS,AX
	PRINT_MES	pmp_USAGE_MES
	error_EXIT	1

;==============================================================================
;	Not Resident PMD
;==============================================================================
not_resident:
	MOV	AX,CS
	MOV	DS,AX
	PRINT_MES	notres_mes
	error_EXIT	1

;==============================================================================
;	ADPCM access error
;==============================================================================
pcm_access_error:
	MOV	AX,CS
	MOV	DS,AX
	PRINT_MES	pcm_access_mes
	error_EXIT	1

;==============================================================================
;	read error
;==============================================================================
readerror:
	MOV	AX,CS
	MOV	DS,AX
	PRINT_MES	read_error_mes
	error_EXIT	1

;==============================================================================
;	music buffer over error
;==============================================================================
over_error:
	MOV	AX,CS
	MOV	DS,AX
	PRINT_MES	over_error_mes
	error_EXIT	1

;==============================================================================
;	Datas
;==============================================================================

read_error_mes	db	"ファイルが見つかりません。",13,10,"$"

mstart_MES	DB	"演奏を開始します。",13,10,13,10,"$"

Mstop_MES	DB	"演奏を停止します。"
mes_crlf	db	13,10,"$"

mes_filename	db	"Filename : $"
mes_ppzfile	db	"PPZFile  : $"
mes_ppsfile	db	"PPSFile  : $"
mes_pcmfile	db	"PCMFile  : $"
mes_title	db	"Title    : $"
mes_composer	db	"Composer : $"
mes_arranger	db	"Arranger : $"
mes_memo	db	"         : $"

fade_MES	DB	"フェードアウトを開始します。",13,10,"$"

efcstop_mes	db	"FM/SSG効果音を停止しました。",13,10,"$"

notres_mes	db	"ＰＭＤが常駐していません。",13,10,"$"

pcm_access_mes	db	"ＡＤＰＣＭがアクセス中です。",13,10,"$"

over_error_mes	db	"曲データバッファが足りません。",13,10,"$"

pmp_USAGE_MES	DB	"Usage:  pmp /{P|S|Fn|E}",13,10
		db	"     or pmp [/{A|O}] filename[.M/.M2/.MZ]",13,10,13,10
		db	"Option: /P   ... (pcmset/)play(/put)",13,10
		db	"        /S   ... stop",13,10
		db	"        /Fn  ... fadeout (n=speed def.=16)",13,10
		db	"        /E   ... stop SSG/FM Effects",13,10
		db	"        /A   ... not set PPS/PCM file",13,10
		db	"        /O   ... not put Title Messages",13,10
		db	"   filename  ... stop/load(/pcmset)/play(/put)",13,10
		db	"$"

pmp_title_mes	db	"Professional Music Driver [P.M.D.] player for PMD ver.4.8l～",13,10
		db	"                  Programmed by M.Kajihara ",date,13,10,13,10,"$"

memo_flg	db	0
pcm_flg		db	0

	include	viruschk.inc	;ウイルス感染check

kankyo_seg	dw	?
memo_strings	db	256 dup(?)
FILE_NAME	DB	128 dup(?)
pcm_data	db	32*1024 dup(?)

@code	ends
end	start
