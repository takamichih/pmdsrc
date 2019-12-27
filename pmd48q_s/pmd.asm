;==============================================================================
;	Professional Music Driver [P.M.D.] version 4.8
;					FOR PC98 (+ Speak Board)
;			By M.Kajihara
;==============================================================================

ver		equ	"4.8q"
vers		equ	48H
verc		equ	"q"
date		equ	"Aug.5th 1998"

mdata_def	equ	16
voice_def	equ	8
effect_def	equ	4
key_def		equ	1

ifndef	_myname
_myname		equ	"PMD     COM"
endif

ifndef	va
va		=	0	;�P�̎��u�`MSDOS�p
endif
ifndef	board2
board2		=	0	;�P�̎��{�[�h�Q/���������L��
endif
ifndef	adpcm
adpcm		=	0	;�P�̎�ADPCM�g�p
endif
ifndef	ademu
ademu		=	0	;�P�̎�ADPCM Emulate
endif
ifndef	pcm
pcm		=	0	;�P�̎�PCM�g�p
endif
ifndef	ppz
ppz		=	0	;�P�̎�PPZ8�g�p
endif
ifndef	sync
sync		=	0	;�P�̎�MIDISYNC�g�p
endif
ifndef	vsync
vsync		=	0	;�P�̎�VSync���~�߂�
endif
ifndef	resmes
resmes	equ	"PMD ver.",ver
endif

if	va+board2
fmvd_init	=	0
else
fmvd_init	=	16	;�X�W�͂W�W�����e�l������������
endif

;==============================================================================
;	INT 60H �d�l
;==============================================================================
;			input		output		remarks.
;	MUSIC_START	AH=00H		AH=255�ŏ�����	���t�̊J�n
;	MUSIC_STOP	AH=01H		AH=255�ŏ�����	���t�̒�~
;	FADEIN/OUT	AH=02H/AL=speed			speed=1�ōŒᑬ
;							speed=-��fadein
;	EFFECT_ON	AH=03H/AL=efcnum		���ʉ��̔���
;	EFFECT_OFF	AH=04H				���ʉ��̏���
;	GET_SYOUSETU	AH=05H		AX=syousetu	���t�J�n���ĉ����ߖڂ�
;	GET_MUSDAT_ADR	AH=06H		DS:DX=MDAT_ADR	�ȃf�[�^��ǂݍ��ޏꏊ
;	GET_TONDAT_ADR	AH=07H		DS:DX=TDAT_ADR	���F�f�[�^�̏ꏊ
;	GET_FOUT_VOL	AH=08H		AL=FOUT_VOL	255��FADEOUT�I��
;	BOARD_CHECK	AH=09H		AL=BOARD_CHK	0=PMD/1=B2/2=86/-1=�Ȃ�
;					AH=Vernum	PMD Version
;					DX=Vernum/chr	PMD Version
;	GET_STATUS	AH=0AH		AH=ST1/AL=ST2	STATUS�̎�荞��
;	GET_EFCDAT_ADR	AH=0BH		DS:DX=EDAT_ADR	FM���ʉ��f�[�^�̏ꏊ
;	FM_EFFECT_ON	AH=0CH/AL=efcnum		FM���ʉ�����
;	FM_EFFECT_OFF	AH=0DH				FM���ʉ�����
;	GET_PCM_ADR	AH=0EH		DS:DX=PCM_TABLE	PCM�e�[�u���̈ʒu
;	PCM_EFFECT_ON	AH=0FH/AL=efcnum		PCM���ʉ�����
;			DX=DeltaN
;			CH=Pan/CL=Volume
;	GET_WORKADR	AH=10H		DS:DX=WORK	WORK�̈ʒu
;	GET_FMEFC_NUM	AH=11H		AL=FMEFC_NUM	FM���ʉ��ԍ�(none=255)
;	GET_PCMEFC_NUM	AH=12H		AL=PCMEFC_NUM	PCM���ʉ��ԍ�(none=255)
;	SET_FM_INT	AH=13H				FM�������荞�ݎ��ɔ��
;			DS:DX=ADDRESS(0=cut)		���荞�ݐ��ݒ�
;	SET_EFC_INT	AH=14H				���ʉ����荞�ݎ��ɔ��
;			DS:DX=ADDRESS(0=cut)		���荞�ݐ��ݒ�
;	GET_PSGEFCNUM	AH=15H		AH=PSGEFCNUM	SSG���ʉ��ԍ�(none=0)
;					AL=EFFON	�� �D�揇��
;	GET_JOYSTICK	AH=16H		AL=JOYSTICK1	�W���C�X�e�B�b�N�Ǎ���
;					AH=JOYSTICK2	bit = xxBARLDU
;	GET_ppsdrv_FLAG	AH=17H		AL=ppsdrv_FLAG	ppsdrv�Ή��t���OREAD
;	SET_ppsdrv_FLAG	AH=18H				ppsdrv�Ή��t���OWRITE
;			AL=ppsdrv_FLAG
;	SET_FOUT_VOL	AH=19H				�S�̉��ʐݒ�(0�`255)
;			AL=FOUT_VOL
;	PAUSE on	AH=1AH				�|�[�Y
;	PAUSE off	AH=1BH				�|�[�Y����
;	FF_MUSIC	AH=1CH		AL=0/����	AL�̏��ߔԍ��܂ő�����
;			DX=���ߔԍ�	1=���ɉ߂��Ă�/2=�Ȓ�~��
;	GET_MEMO	AH=1DH		DS:DX=MEMOadr	�Ȓ��̃�����address��
;			AL=MEMO�ԍ�	00:00�͖���	���o��
;	PART_MASK	AH=1EH				�p�[�g�̃}�X�N/����
;			AL=PART�ԍ�(+80H)		+80H�Ń}�X�N����
;	GET_FM_INT	AH=1FH		DS:DX		FM�������荞�ݎ��ɔ��
;					(ADDRESS)	���荞�ݐ���擾
;	GET_EFC_INT	AH=20H		DS:DX		���ʉ����荞�ݎ��ɔ��
;					(ADDRESS)	���荞�ݐ���擾
;	GET_FILE_ADR	AH=21H		DS:DX(ADDRESS)	���t����File���ʒu�擾
;	GET_SIZE	AH=22H		AL=MUSDATA	�풓�T�C�Y�m�F
;					AH=VOICEDATA	(�j�a�P��)
;					DL=EFFECDATA
;==============================================================================

pmdvector	=	60h		;PMD�p�̊��荞�݃x�N�g��
ppsdrv		=	64h		;ppsdrv�̊��荞�݃x�N�g��
ppz_vec		=	7fh		;ppz8�̊��荞�݃x�N�g��

@code	segment	para	public	'@code'
	assume	cs:@code,ds:@code,es:@code,ss:@code

	org	100h

pmd	proc	near

	jmp	comstart

;==============================================================================
;	�l�r�|�c�n�r�R�[���̃}�N��
;==============================================================================

resident_exit	macro
		mov	ax,3100h
		int	21h
		endm

resident_cut	macro
		mov	ah,49h
		int	21h
		endm

get_psp 	macro
		mov	ah,51h
		int	21h
		endm

msdos_exit	macro
		mov	ax,4c00h
		int	21h
		endm

error_exit	macro	qq
		mov	ax,4c00h+qq
		int	21h
		endm

print_mes	macro	qq
		if	va
			push	si
			lea	si,qq
			mov	dh,80h
			mov	ah,02h
			int	83h
			pop	si
		else
			mov	dx,offset qq
			mov	ah,09h
			int	21h
		endif
		endm

print_dx	macro
		if	va
			push	si
			mov	si,dx
			mov	dh,80h
			mov	ah,02h
			int	83h
			pop	si
		else
			mov	ah,09h
			int	21h
		endif
		endm

debug		macro	qq
		push	es
		push	ax
		mov	ax,0a000h
		mov	es,ax
		inc	byte ptr es:[qq*2]
		pop	ax
		pop	es
		endm

debug2		macro	q1,q2
		push	es
		push	ax
		mov	ax,0a000h
		mov	es,ax
		mov	byte ptr es:[q1*2],q2
		pop	ax
		pop	es
		endm

debug_pcm	macro	qq
local		zzzz
		push	ax
		push	dx
		mov	dx,0a468h
		in	al,dx
		test	al,10h
		jz	zzzz
		debug	qq
zzzz:		pop	dx
		pop	ax
		endm

_wait		macro
		mov	cx,[wait_clock]
		loop	$
		endm

_waitP		macro
		push	cx
		mov	cx,[wait_clock]
		loop	$
		pop	cx
		endm

_rwait		macro			;���Y���A���o�͗pwait
		push	cx
		mov	cx,[wait_clock]
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx			;x32
		loop	$
		pop	cx
		endm

rdychk		macro			;Address out���p	break:ax
local		loop
		in	al,dx		;���ʓǂ�
loop:		in	al,dx
		test	al,al
		js	loop
		endm

_ppz		macro
local		exit
if		ppz
		cmp	[ppz_call_seg],2
		jc	exit
		call	dword ptr [ppz_call_ofs]
exit:
endif
		endm

;==============================================================================
;	�萔
;==============================================================================
if	va

ms_cmd		equ	188h		; �W�Q�T�X�}�X�^�|�[�g
ms_msk		equ	18ah		; �W�Q�T�X�}�X�^�^�}�X�N
sl_cmd		equ	184h		; �W�Q�T�X�X���[�u�|�[�g
sl_msk		equ	186h		; �W�Q�T�X�X���[�u�^�}�X�N

else

ms_cmd		equ	000h		; �W�Q�T�X�}�X�^�|�[�g
ms_msk		equ	002h		; �W�Q�T�X�}�X�^�^�}�X�N
sl_cmd		equ	008h		; �W�Q�T�X�X���[�u�|�[�g
sl_msk		equ	00ah		; �W�Q�T�X�X���[�u�^�}�X�N

endif

;==============================================================================
;	Program Start
;==============================================================================

int60_head:	jmp	short	int60_main
		db	'PMD'	;+2  �풓�`�F�b�N�p
		db	vers	;+5
		db	verc	;+6
int60ofs	dw	?	;+7
int60seg	dw	?	;+9
int5ofs		dw	?	;+11
int5seg		dw	?	;+13
maskpush	db	?	;+15
vector		dw	?	;+16
int_level	db	?	;+18

_p		equ	2
_m		equ	3
_d		equ	4
_vers		equ	5
_verc		equ	6
_int60ofs	equ	7
_int60seg	equ	9
_int5ofs	equ	11
_int5seg	equ	13
_maskpush	equ	15
_vector		equ	16
_int_level	equ	18

int60_main:
	inc	cs:[int60flag]
	cmp	ah,int60_max+1
	jnc	int60_error
	cmp	cs:[board],0
	jnz	int60_start
	jmp	int60_start_not_board
int60_exit:
	cli
	dec	cs:[int60flag]
	mov	cs:[int60_result],0
	iret
int60_error:
if	sync
	cmp	ah,-1
	jnz	no_sync
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	call	opnint_sub
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	dec	cs:[int60flag]
	iret
no_sync:
endif
	cli
	dec	cs:[int60flag]
	mov	cs:[int60_result],-1
	iret

;==============================================================================
;	�o�b�l�h���C�o�@�h�m�b�k�t�c�d
;==============================================================================
if	board2
 if	pcm
	include	pcmdrv86.asm
 endif
 if	adpcm
  if	ademu
	include	pcmdrve.asm
  else
	include	pcmdrv.asm
  endif
 endif
 if	ppz
	include	ppzdrv.asm
 endif
endif

;==============================================================================
;	�d�e�e�d�b�s�h���C�o�@�h�m�b�k�t�c�d
;==============================================================================
	include	efcdrv.asm

getss:
	mov	ax,cs:[syousetu]
	ret

getst:
	mov	ah,cs:[status]
	mov	al,cs:[status2]
	ret

fout:	mov	cs:[fadeout_speed],al
	ret

;==============================================================================
;	�e�l���ʉ����t���C��
;==============================================================================
fm_efcplay:
	mov	bx,[efcdat]
	mov	ax,254[bx]
	add	ax,bx
	mov	[prgdat_adr2],ax

	mov	di,offset part_e
if	board2
	push	[fm_port1]	;mmain��sel44��Ԃ�TimerA���荞�݂��������p��
	push	[fm_port2]	;�΍�
	mov	ah,[partb]
	mov	al,[fmsel]
	push	ax
	mov	[partb],3
	call	sel46		;������mmain�����Ă�sel46�̂܂�
	call	fmmain
	pop	ax
	mov	[partb],ah
	mov	[fmsel],al
	pop	[fm_port2]
	pop	[fm_port1]
else
	mov	al,[partb]
	push	ax
	mov	[partb],3
	call	fmmain
	pop	ax
	mov	[partb],al
endif
	cmp	byte ptr [si],80h
	jnz	not_end_fmefc
	cmp	leng[di],0
	jnz	not_end_fmefc
	call	fm_effect_off

not_end_fmefc:
	ret

;==============================================================================
;	���t�J�n
;==============================================================================
mstart_f:
	mov	al,[TimerAflag]
	or	al,[TimerBflag]
	jz	mstart
	or	[music_flag],1	;TA/TB�������� ���s���Ȃ�
	mov	[ah_push],-1
	ret
mstart:	
;------------------------------------------------------------------------------
;	���t��~
;------------------------------------------------------------------------------
	pushf
	cli
	and	[music_flag],0feh
	call	mstop
	popf

;------------------------------------------------------------------------------
;	���t����
;------------------------------------------------------------------------------
	call	data_init
	call	play_init
	mov	[fadeout_volume],0

if	board2*adpcm
 if	ademu
	mov	ax,1800h
	mov	[adpcm_emulate],al
	call	ppz8_call		;ADPCMEmulate OFF
	mov	bx,offset part10	;PCM��
	or	partmask[bx],10h	;Mask(bit4)
 else
;------------------------------------------------------------------------------
;	NEC��YM2608�Ȃ� PCM�p�[�g��MASK
;------------------------------------------------------------------------------
	cmp	[pcm_gs_flag],0
	jz	not_mask_pcm
	mov	bx,offset part10	;PCM��
	or	partmask[bx],4		;Mask(bit2)
not_mask_pcm:
 endif
endif
if	ppz
;------------------------------------------------------------------------------
;	PPZ8������
;------------------------------------------------------------------------------
	cmp	[ppz_call_seg],0
	jz	not_init_ppz8
	mov	ax,1901h
	int	ppz_vec		;�풓�����֎~
	xor	ah,ah
	int	ppz_vec
	mov	ah,6
	int	ppz_vec
not_init_ppz8:
endif
;------------------------------------------------------------------------------
;	OPN������
;------------------------------------------------------------------------------
	call	opn_init

;------------------------------------------------------------------------------
;	���y�̉��t���J�n
;------------------------------------------------------------------------------
	call	setint
	mov	[play_flag],1
	inc	[mstart_flag]
	ret

;==============================================================================
;	�e�p�[�g�̃X�^�[�g�A�h���X�y�я����l���Z�b�g
;==============================================================================
play_init:
	mov	si,[mmlbuf]
	mov	al,-1[si]
	mov	[x68_flg],al

	;�Q�D�U�ǉ���
	cmp	byte ptr [si],2*(max_part2+1)
	jz	not_prg

	mov	bx,[si+(2*(max_part2+1))]

	add	bx,si
	mov	[prgdat_adr],bx

	mov	[prg_flg],1
	jmp	prg

not_prg:
	mov	[prg_flg],0

prg:
	mov	cx,max_part2
	xor	dl,dl
	mov	bx,offset part_data_table

din0:	
	mov	di,[bx]	; di = part workarea
	inc	bx
	inc	bx
	lodsw		; ax = part start addr

	add	ax,[mmlbuf]
	xchg	ax,bx
	cmp	byte ptr [bx],80h	;�擪��80h�Ȃ牉�t���Ȃ�
	jnz	din1
	xor	bx,bx
din1:
	xchg	ax,bx
	mov	address[di],ax
	mov	leng[di],1		; ���ƂP�J�E���g�ŉ��t�J�n
	mov	al,-1
	mov	keyoff_flag[di],al	; ����keyoff��
	mov	mdc[di],al		; MDepth Counter (����)
	mov	mdc2[di],al		; //
	mov	_mdc[di],al		; //
	mov	_mdc2[di],al		; //
	mov	onkai[di],al		; rest
	mov	onkai_def[di],al	; rest

	cmp	dl,6
	jnc	din_not_fm

;	Part 0,1,2,3,4,5(FM1�`6)�̎�
	mov	volume[di],108		; FM  VOLUME DEFAULT= 108
	mov	fmpan[di],0c0h		; FM PAN = Middle
if	board2
	mov	slotmask[di],0f0h	; FM SLOT MASK
	mov	neiromask[di],0ffh	; FM Neiro MASK
else
	cmp	dl,3
	jnc	din_fm_mask		; OPN 3,4,5 ��neiro/slotmask��0�̂܂�
	mov	slotmask[di],0f0h	; FM SLOT MASK
	mov	neiromask[di],0ffh	; FM Neiro MASK
	jmp	init_exit
din_fm_mask:
	or	partmask[di],20h	; s0�̎�FM�}�X�N
endif
	jmp	init_exit

din_not_fm:
	cmp	dl,9
	jnc	din_not_psg

;	Part 6,7,8(PSG1�`3)�̎�
	mov	volume[di],8		; PSG VOLUME DEFAULT= 8
	mov	psgpat[di],7		; PSG = TONE
	mov	envf[di],3		; PSG ENV = NONE/normal
	jmp	init_exit

din_not_psg:
	jnz	din_not_pcm
if	board2
 if	adpcm
;	Part 9(OPNA/ADPCM)�̎�
	mov	volume[di],128		; PCM VOLUME DEFAULT= 128
	mov	fmpan[di],0c0h		; PCM PAN = Middle
 endif
 if	pcm
;	Part 9(OPNA/PCM)�̎�
	mov	volume[di],128		; PCM VOLUME DEFAULT= 128
	mov	fmpan[di],0
	mov	[pcm86_pan_flag],0	;Mid
	mov	[revpan],0		;�t��off
 endif
endif
	jmp	init_exit
din_not_pcm:

	cmp	dl,10
	jnz	not_rhythm
;	Part 10(Rhythm)�̎�
	mov	volume[di],15		; PPSDRV volume
	jmp	init_exit
not_rhythm:
init_exit:
	inc	dl
	loop	din0

;------------------------------------------------------------------------------
;	Rhythm �̃A�h���X�e�[�u�����Z�b�g
;------------------------------------------------------------------------------
	lodsw
	add	ax,[mmlbuf]
	mov	[radtbl],ax
	mov	[rhyadr],offset rhydmy

	ret

;==============================================================================
;	DATA AREA �� �C�j�V�����C�Y
;==============================================================================
data_init:
	xor	al,al
	mov	[fadeout_volume],al
	mov	[fadeout_speed],al
	mov	[fadeout_flag],al

data_init2:
	mov	cx,max_part1
	mov	di,offset part1
di_loop:
	push	cx
	mov	bx,di
	mov	dh,partmask[bx]
	mov	dl,keyon_flag[bx]
	mov	cx,type qq
	pushf
	cli
	xor	al,al
rep	stosb
	and	dh,0fh	;0dh		;�ꎞ,s,m,ADE�ȊO��
	mov	partmask[bx],dh		;partmask�̂ݕۑ�
	mov	keyon_flag[bx],dl	;keyon_flag�ۑ�
	mov	onkai[bx],-1		;onkai���x���ݒ�
	mov	onkai_def[bx],-1	;onkai���x���ݒ�
	popf
	pop	cx
	loop	di_loop

	xor	ax,ax
	mov	[tieflag],al
	mov	[status],al
	mov	[status2],al
	mov	[syousetu],ax
	mov	[opncount],al
	mov	[TimerAtime],al
	mov	[lastTimerAtime],al

	mov	di,offset omote_key1
	mov	cx,3
rep	stosw

	mov	[fm3_alg_fb],al
	mov	[af_check],al

	mov	[pcmstart],ax
	mov	[pcmstop],ax
	mov	[pcmrepeat1],ax
	mov	[pcmrepeat2],ax
	mov	[pcmrelease],8000h

	mov	[kshot_dat],ax
	mov	[rshot_dat],al
	mov	[last_shot_data],al

	mov	[slotdetune_flag],al
	mov	di,offset slot_detune1
	mov	cx,4
rep	stosw

	mov	[slot3_flag],al
	mov	[ch3mode],03fh

	mov	[fmsel],al

	mov	[syousetu_lng],96

	mov	ax,[fm1_port1]
	mov	[fm_port1],ax
	mov	ax,[fm1_port2]
	mov	[fm_port2],ax

	mov	al,[_fm_voldown]
	mov	[fm_voldown],al
	mov	al,[_ssg_voldown]
	mov	[ssg_voldown],al
	mov	al,[_pcm_voldown]
	mov	[pcm_voldown],al
if	ppz
	mov	al,[_ppz_voldown]
	mov	[ppz_voldown],al
endif
	mov	al,[_rhythm_voldown]
	mov	[rhythm_voldown],al

	mov	al,[_pcm86_vol]
	mov	[pcm86_vol],al

	ret

;==============================================================================
;	OPN INIT
;==============================================================================
opn_init:
	mov	dx,2983h
	call	opnset44

	mov	[psnoi],0
	cmp	[effon],0
	jnz	no_init_psnoi

	mov	dx,0600h	;PSG Noise
	call	opnset44
	mov	[psnoi_last],0
no_init_psnoi:
;==============================================================================
;	PAN/HARDLFO DEFAULT
;==============================================================================
ife	board2
	cmp	[ongen],0	;2203?
	jnz	init_2608
	ret
init_2608:
endif
if	board2
	mov	bx,2
	call	sel44		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v
pd01:
endif
	mov	dx,0b4c0h	;PAN=MID/HARDLFO=OFF
	mov	cx,3
pd00:
	cmp	[fm_effec_flag],0
	jz	pd02
	cmp	cx,1
	jnz	pd02
if	board2
	cmp	bx,1
	jz	pd03
endif
pd02:	call	opnset
pd03:	inc	dh
	loop	pd00

if	board2
	call	sel46		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v
	dec	bx
	jnz	pd01
	call	sel44		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v
endif

	mov	dx,02200h	;HARDLFO=OFF
	mov	[port22h],dl
	call	opnset44

if	board2
;==============================================================================
;	Rhythm Default = Pan : Mid , Vol : 15
;==============================================================================
	mov	di,offset rdat
	mov	cx,6
	mov	al,11001111b
rep	stosb
	mov	dx,10ffh
	call	opnset44	;Rhythm All Dump

;==============================================================================
;	���Y���g�[�^�����x���@�Z�b�g
;==============================================================================
rtlset:	
	mov	dl,48
	mov	al,[rhythm_voldown]
	test	al,al
	jz	rtlset2r
	shl	dl,1
	shl	dl,1	; 0-63 > 0-255
	neg	al
	mul	dl
	mov	dl,ah
	shr	dl,1
	shr	dl,1	; 0-255 > 0-63
rtlset2r:
	mov	[rhyvol],dl
	mov	dh,11h

	call	opnset44

;==============================================================================
;	�o�b�l�@reset & �k�h�l�h�s�@�r�d�s
;==============================================================================
 ife	ademu
	cmp	[pcm_gs_flag],1
	jz	pr_non_pcm
	mov	dx,0cffh
	call	opnset46
	mov	dx,0dffh
	call	opnset46
pr_non_pcm:
 endif
;==============================================================================
;	PPZ Pan Init.
;==============================================================================
 if	ppz+ademu
	mov	dx,5
	mov	ax,1300h
	mov	cx,8
ppz_pan_init_loop:
	mov	al,cl
	dec	al
	call	ppz8_call
	loop	ppz_pan_init_loop
 endif
else
	mov	dx,[fm2_port1]
	pushf
	cli
	rdychk
	mov	al,10h
	out	dx,al
	mov	dx,[fm2_port2]
	_wait
	mov	al,80h
	out	dx,al
	_wait
	mov	al,18h
	out	dx,al
	popf
endif
	ret

;==============================================================================
;	�l�t�r�h�b�@�r�s�n�o
;==============================================================================
mstop_f:
	mov	al,[TimerAflag]
	or	al,[TimerBflag]
	jz	_mstop
	or	[music_flag],2		;TA/TB�������� ���s���Ȃ�
	mov	[ah_push],-1
	ret
_mstop:	
	mov	[fadeout_flag],0	;�O������mstop�������ꍇ��0�ɂ���
mstop:	
	pushf
	cli
	and	[music_flag],0fdh
	xor	ax,ax
	mov	[play_flag],al
	mov	[pause_flag],al
	mov	[fadeout_speed],al
	dec	al
	mov	[status2],al
	mov	[fadeout_volume],al
	popf
	jmp	silence

;==============================================================================
;	MUSIC PLAYER MAIN [FROM TIMER-B]
;==============================================================================
mmain:
	mov	[loop_work],3

	cmp	[x68_flg],0
	jnz	mmain_fm

	mov	di,offset part7
	mov	[partb],1
	call	psgmain		;SSG1

	mov	di,offset part8
	mov	[partb],2
	call	psgmain		;SSG2

	mov	di,offset part9
	mov	[partb],3
	call	psgmain		;SSG3

mmain_fm:
if	board2
	call	sel46

	mov	di,offset part4
	mov	[partb],1
	call	fmmain		;FM4 OPNA

	mov	di,offset part5
	mov	[partb],2
	call	fmmain		;FM5 OPNA

	mov	di,offset part6
	mov	[partb],3
	call	fmmain		;FM6 OPNA

	call	sel44
endif
	mov	di,offset part1
	mov	[partb],1
	call	fmmain		;FM1

	mov	di,offset part2
	mov	[partb],2
	call	fmmain		;FM2

	mov	di,offset part3
	mov	[partb],3
	call	fmmain		;FM3

	mov	di,offset part3b
	call	fmmain		;FM3 �g���P

	mov	di,offset part3c
	call	fmmain		;FM3 �g���Q

	mov	di,offset part3d
	call	fmmain		;FM3 �g���R

	cmp	[x68_flg],0
	jnz	mmain_exit

	mov	di,offset part11
	call	rhythmmain	;RHYTHM

if	board2
	mov	di,offset part10
	call	pcmmain		;ADPCM/PCM (IN "pcmdrv.asm"/"pcmdrv86.asm")
endif
if	ppz
	mov	di,offset part10a
	mov	[partb],0
	call	ppzmain
	mov	di,offset part10b
	mov	[partb],1
	call	ppzmain
	mov	di,offset part10c
	mov	[partb],2
	call	ppzmain
	mov	di,offset part10d
	mov	[partb],3
	call	ppzmain
	mov	di,offset part10e
	mov	[partb],4
	call	ppzmain
	mov	di,offset part10f
	mov	[partb],5
	call	ppzmain
	mov	di,offset part10g
	mov	[partb],6
	call	ppzmain
	mov	di,offset part10h
	mov	[partb],7
	call	ppzmain
endif

mmain_exit:
	cmp	[loop_work],0
	jnz	mmain_loop
	ret

mmain_loop:
	mov	cx,max_part1
	mov	bx,offset part_data_table
mm_din0:	
	mov	di,[bx]	; di = part workarea
	inc	bx
	inc	bx
	cmp	loopcheck[di],3
	jz	mm_notset
	mov	loopcheck[di],0
mm_notset:
	loop	mm_din0

	cmp	[loop_work],3
	jz	mml_fin

	inc	[status2]
	cmp	[status2],-1	; -1�ɂ͂����Ȃ�
	jnz	mml_ret
	mov	[status2],1
mml_ret:
	ret
mml_fin:
	mov	[status2],-1
	ret

if	board2
;==============================================================================
;	���e�l�Z���N�g
;==============================================================================
sel46:	mov	ax,[fm2_port1]
	mov	[fm_port1],ax
	mov	ax,[fm2_port2]
	mov	[fm_port2],ax
	mov	[fmsel],1
	ret

;==============================================================================
;	�\�ɖ߂�
;==============================================================================
sel44:	mov	ax,[fm1_port1]
	mov	[fm_port1],ax
	mov	ax,[fm1_port2]
	mov	[fm_port2],ax
	mov	[fmsel],0
	ret
endif

;==============================================================================
;	�e�l�������t���C��
;==============================================================================
fmmain_ret:
	ret

fmmain:
	mov	si,[di]	; si = PART DATA ADDRESS
	test	si,si
	jz	fmmain_ret
	cmp	partmask[di],0
	jnz	fmmain_nonplay

	; ���� -1
	dec	leng[di]
	mov	al,leng[di]

	; KEYOFF CHECK & Keyoff
	test	keyoff_flag[di],3	; ����keyoff�������H
	jnz	mp0
	cmp	al,qdat[di]		; Q�l => �c��Length�l�� keyoff
	ja	mp0
	call	keyoff			; AL�͉󂳂Ȃ�
	mov	keyoff_flag[di],-1

mp0:	; LENGTH CHECK
	test	al,al
	jnz	mpexit
mp10:	and	lfoswi[di],0f7h		; Porta off

mp1:	; DATA READ
	lodsb
	cmp	al,80h
	jc	mp2
	jz	mp15

	; ELSE COMMANDS
	call	commands
	jmp	mp1

	; END OF MUSIC [ "L"�����������͂����ɖ߂� ]
mp15:	dec	si
	mov	[di],si
	mov	loopcheck[di],3
	mov	onkai[di],-1
	mov	bx,partloop[di]
	test	bx,bx
	jz	mpexit

	; "L"����������
	mov	si,bx
	mov	loopcheck[di],1
	jmp	mp1

mp2:	; F-NUMBER SET
	call	lfoinit
	call	oshift
	call	fnumset

	lodsb
	mov	leng[di],al
	call	calc_q

porta_return:
	cmp	volpush[di],0
	jz	mp_new
	cmp	onkai[di],-1
	jz	mp_new
	dec	[volpush_flag]
	jz	mp_new
	mov	[volpush_flag],0
	mov	volpush[di],0
mp_new:	call	volset
	call	otodasi
	call	keyon
	inc	keyon_flag[di]

	mov	[di],si
	xor	al,al
	mov	[tieflag],al
	mov	[volpush_flag],al
	mov	keyoff_flag[di],al
	cmp	byte ptr [si],0fbh	; '&'������ɂ�������keyoff���Ȃ�
	jnz	mnp_ret
	mov	keyoff_flag[di],2
	jmp	mnp_ret

mpexit:	; LFO & Portament & Fadeout ���� �����ďI��
if	board2
	cmp	hldelay_c[di],0
	jz	not_hldelay
	dec	hldelay_c[di]
	jnz	not_hldelay
	mov	dh,[partb]
	add	dh,0b4h-1
	mov	dl,fmpan[di]
	call	opnset	
not_hldelay:
endif
	cmp	sdelay_c[di],0
	jz	not_sdelay
	dec	sdelay_c[di]
	jnz	not_sdelay
	test	keyoff_flag[di],1	; ����keyoff�������H
	jnz	not_sdelay
	call	keyon
not_sdelay:
	mov	cl,lfoswi[di]
	test	cl,cl
	jz	nolfosw

	mov	al,cl
	and	al,8
	mov	[lfo_switch],al

	test	cl,3
	jz	not_lfo
	call	lfo
	jnc	not_lfo

	mov	al,cl
	and	al,3
	or	[lfo_switch],al
not_lfo:
	test	cl,30h
	jz	not_lfo2
	pushf
	cli
	call	lfo_change
	call	lfo
	jnc	not_lfo1
	call	lfo_change
	popf
	mov	al,lfoswi[di]
	and	al,30h
	or	[lfo_switch],al
	jmp	not_lfo2
not_lfo1:
	call	lfo_change
	popf
not_lfo2:
	test	[lfo_switch],19h
	jz	vols
	test	[lfo_switch],8
	jz	not_porta
	call	porta_calc
not_porta:
	call	otodasi

vols:
	test	[lfo_switch],22h
	jnz	vol_set
nolfosw:
	cmp	[fadeout_speed],0
	jz	mnp_ret
vol_set:
	call	volset
mnp_ret:
	mov	al,[loop_work]
	and	al,loopcheck[di]
	mov	[loop_work],al
	_ppz
	ret

;==============================================================================
;	Q�l�̌v�Z
;		break	dx
;==============================================================================
calc_q:
	cmp	byte ptr [si],0c1h	;&&
	jz	cq_sular
	mov	dl,qdata[di]
	cmp	qdatb[di],0
	jz	cq_set
	push	ax
	mov	al,leng[di]
	mul	qdatb[di]
	add	dl,ah
	pop	ax
cq_set:
	cmp	qdat3[di],0
	jz	cq_set2

;	Random-Q
	push	ax
	push	cx
	mov	al,qdat3[di]
	and	al,7fh
	cbw
	inc	ax
	push	dx
	call	rnd
	pop	dx
	test	qdat3[di],80h
	jnz	cqr_minus
	add	dl,al
	jmp	cqr_exit
cqr_minus:
	sub	dl,al
	jnc	cqr_exit
	xor	dl,dl
cqr_exit:
	pop	cx
	pop	ax

cq_set2:cmp	qdat2[di],0
	jz	cq_sete
	mov	dh,leng[di]
	sub	dh,qdat2[di]
	jc	cq_zero
	cmp	dl,dh
	jc	cq_sete
	mov	dl,dh		;�Œ�ۏ�gate�l�ݒ�
cq_sete:
	mov	qdat[di],dl
	ret
cq_sular:
	inc	si		;�X���[����
cq_zero:mov	qdat[di],0
	ret

;==============================================================================
;	�e�l�������t���C���F�p�[�g�}�X�N����Ă��鎞
;==============================================================================
fmmain_nonplay:
	mov	keyoff_flag[di],-1
	dec	leng[di]
	jnz	mnp_ret

	test	partmask[di],2		;bit1(FM���ʉ����H)��check
	jz	fmmnp_1
	cmp	[fm_effec_flag],0	;���ʉ��I���������H
	jnz	fmmnp_1
	and	partmask[di],0fdh	;bit1��clear
	jz	mp10			;partmask��0�Ȃ畜��������

fmmnp_1:
	lodsb
	cmp	al,80h
	jz	fmmnp_2
	jc	fmmnp_3
	call	commands
	jmp	fmmnp_1

fmmnp_2:
	; END OF MUSIC [ "L"�����������͂����ɖ߂� ]
	dec	si
	mov	[di],si
	mov	loopcheck[di],3
	mov	onkai[di],-1
	mov	bx,partloop[di]
	test	bx,bx
	jz	fmmnp_4

	; "L"����������
	mov	si,bx
	mov	loopcheck[di],1
	jmp	fmmnp_1

fmmnp_3:
	mov	fnum[di],0	;�x���ɐݒ�
	mov	onkai[di],-1
	mov	onkai_def[di],-1
	lodsb
	mov	leng[di],al	;�����ݒ�
	inc	keyon_flag[di]
	mov	[di],si

	dec	[volpush_flag]
	jz	fmmnp_4
	mov	volpush[di],0
fmmnp_4:
	mov	[tieflag],0
	mov	[volpush_flag],0
	jmp	mnp_ret

;==============================================================================
;	�r�r�f�����@���t�@���C��
;==============================================================================
psgmain_ret:
	ret

psgmain:
	mov	si,[di]		; si = PART DATA ADDRESS
	test	si,si
	jz	psgmain_ret
	cmp	partmask[di],0
	jnz	psgmain_nonplay

	; ���� -1
	dec	leng[di]
	mov	al,leng[di]

	; KEYOFF CHECK & Keyoff
	test	keyoff_flag[di],3	; ����keyoff�������H
	jnz	mp0p
	cmp	al,qdat[di]		; Q�l => �c��Length�l�� keyoff
	ja	mp0p
	call	keyoffp			; AL�͉󂳂Ȃ�
	mov	keyoff_flag[di],-1

mp0p:	; LENGTH CHECK
	test	al,al
	jnz	mpexitp
	and	lfoswi[di],0f7h		; Porta off

mp1p:	; DATA READ
	lodsb
	cmp	al,80h
	jc	mp2p
	jz	mp15p

	; ELSE COMMANDS
mp1cp:	call	commandsp
	jmp	mp1p

	; END OF MUSIC [ "L"�����������͂����ɖ߂� ]
mp15p:	dec	si
	mov	[di],si
	mov	loopcheck[di],3
	mov	onkai[di],-1
	mov	bx,partloop[di]
	test	bx,bx
	jz	mpexitp

	; "L"����������
	mov	si,bx
	mov	loopcheck[di],1
	jmp	mp1p

mp2p:	; TONE SET
	call	lfoinitp
	call	oshiftp
	call	fnumsetp

	lodsb
	mov	leng[di],al
	call	calc_q

porta_returnp:
	cmp	volpush[di],0
	jz	mp_newp
	cmp	onkai[di],-1
	jz	mp_newp
	dec	[volpush_flag]
	jz	mp_newp
	mov	[volpush_flag],0
	mov	volpush[di],0
mp_newp:call	volsetp
	call	otodasip
	call	keyonp
	inc	keyon_flag[di]

	mov	[di],si
	xor	al,al
	mov	[tieflag],al
	mov	[volpush_flag],al
	mov	keyoff_flag[di],al
	cmp	byte ptr [si],0fbh	; '&'������ɂ�������keyoff���Ȃ�
	jnz	mnp_ret
	mov	keyoff_flag[di],2
	jmp	mnp_ret

mpexitp:
	mov	cl,lfoswi[di]
	mov	al,cl
	and	al,8
	mov	[lfo_switch],al
	test	cl,cl
	jz	volsp
	test	cl,3
	jz	not_lfop
	call	lfop
	jnc	not_lfop
	mov	al,cl
	and	al,3
	or	[lfo_switch],al
not_lfop:
	test	cl,30h
	jz	not_lfop2
	pushf
	cli
	call	lfo_change
	call	lfop
	jnc	not_lfop1
	call	lfo_change
	popf
	mov	al,lfoswi[di]
	and	al,30h
	or	[lfo_switch],al
	jmp	not_lfop2
not_lfop1:
	call	lfo_change
	popf
not_lfop2:
	test	[lfo_switch],19h
	jz	volsp

	test	[lfo_switch],8
	jz	not_portap
	call	porta_calc
not_portap:
	call	otodasip
volsp:
	call	soft_env
	jc	volsp2
	test	[lfo_switch],22h
	jnz	volsp2
	cmp	[fadeout_speed],0
	jz	mnp_ret
volsp2:	call	volsetp
	jmp	mnp_ret

;==============================================================================
;	�r�r�f�������t���C���F�p�[�g�}�X�N����Ă��鎞
;==============================================================================
psgmain_nonplay:
	mov	keyoff_flag[di],-1
	dec	leng[di]
	jnz	mnp_ret

	and	lfoswi[di],0f7h		;Porta off
psgmnp_1:
	lodsb
	cmp	al,80h
	jz	psgmnp_2
	jc	psgmnp_4

	cmp	al,0dah			;Portament?
	jnz	psgmnp_3
	call	ssgdrum_check		;�̏ꍇ����SSG����Check
	jc	mp1cp			;�����̏ꍇ�̓��C���̏�����
psgmnp_3:
	call	commandsp
	jmp	psgmnp_1

	; END OF MUSIC [ "L"�����������͂����ɖ߂� ]
psgmnp_2:
	dec	si
	mov	[di],si
	mov	loopcheck[di],3
	mov	onkai[di],-1
	mov	bx,partloop[di]
	test	bx,bx
	jz	fmmnp_4

	; "L"����������
	mov	si,bx
	mov	loopcheck[di],1
	jmp	psgmnp_1

psgmnp_4:
	call	ssgdrum_check
	jnc	fmmnp_3
	jmp	mp2p			;SSG����

;==============================================================================
;	SSG�h������������SSG�𕜊������邩�ǂ���check
;		input	AL <- Command
;		output	cy=1 : ����������
;==============================================================================
ssgdrum_check:
	test	partmask[di],1		;bit0(SSG�}�X�N���H)��check
	jnz	sdrchk_2		;SSG�}�X�N���̓h�������~�߂Ȃ�
	test	partmask[di],2		;bit1(SSG���ʉ����H)��check
	jz	sdrchk_2		;SSG�h�����͖��ĂȂ�
	cmp	[effon],2		;SSG�h�����ȊO�̌��ʉ������Ă��邩�H
	jnc	sdrchk_2		;���ʂ̌��ʉ��͏����Ȃ�
	mov	ah,al			;AL�͉󂳂Ȃ�
	and	ah,0fh			;0DAH(portament)�̎���0AH�Ȃ̂ő��v
	cmp	ah,0fh			;�x���H
	jz	sdrchk_2		;�x���̎��̓h�����͎~�߂Ȃ�
	cmp	[effon],1		;SSG�h�����͂܂��Đ������H
	jnz	sdrchk_1		;���ɏ�����Ă���
	push	ax
	call	effend			;SSG�h����������
	pop	ax
sdrchk_1:
	and	partmask[di],0fdh	;bit1��clear
	jnz	sdrchk_2		;�܂������Ń}�X�N����Ă���
	stc
	ret				;partmask��0�Ȃ畜��������
sdrchk_2:
	clc
	ret

;==============================================================================
;	���Y���p�[�g�@���t�@���C��
;==============================================================================
rhythmmain_ret:
	ret

rhythmmain:
	mov	si,[di]		; si = PART DATA ADDRESS
	test	si,si
	jz	rhythmmain_ret

	; ���� -1
	dec	leng[di]
	jnz	mnp_ret

rhyms0:	
	mov	bx,[rhyadr]
rhyms00:
	mov	al,[bx]
	inc	bx
	cmp	al,0ffh
	jz	reom
	test	al,80h
	jnz	rhythmon

	mov	[kshot_dat],0	;rest

rlnset:	mov	al,[bx]
	inc	bx
	mov	[rhyadr],bx
	mov	leng[di],al
	inc	keyon_flag[di]
	jmp	fmmnp_4

reom:	
	lodsb
	cmp	al,080h
	jz	rfin
	jc	re00
	call	commandsr
	jmp	reom

re00:
	mov	[di],si
	xor	ah,ah
	add	ax,ax
	add	ax,[radtbl]
	mov	bx,ax
	mov	ax,[bx]
	add	ax,[mmlbuf]
	mov	[rhyadr],ax
	mov	bx,ax
	jmp	rhyms00

rfin:	dec	si
	mov	[di],si
	mov	loopcheck[di],3
	mov	bx,partloop[di]
	test	bx,bx
	jz	rf00
	; "L"����������
	mov	si,bx
	mov	loopcheck[di],1
	jmp	reom
rf00:
	mov	bx,offset rhydmy
	mov	[rhyadr],bx
	jmp	fmmnp_4

;==============================================================================
;	PSGؽ�� ON
;==============================================================================
rhythmon:
	test	al,01000000b
	jz	rhy_shot

	xchg	si,bx
	push	bx
	call	commandsr
	pop	bx
	xchg	bx,si
	jmp	rhyms00

rhy_shot:
	cmp	partmask[di],0
	jz	r_nonmask
	mov	[kshot_dat],0
	inc	bx
	jmp	rlnset		;mask����Ă���ꍇ

r_nonmask:
	mov	ah,al
	mov	al,[bx]
	inc	bx
	and	ax,03fffh
	mov	[kshot_dat],ax
	jz	rlnset
	mov	[rhyadr],bx

if	board2
	cmp	[kp_rhythm_flag],0
	jz	rsb210
	push	ax
	mov	bx,offset rhydat
	mov	cx,11
rsb2lp:	ror	ax,1
	jc	rshot
	inc	bx
	inc	bx
rsb200:	inc	bx
	loop	rsb2lp
	pop	ax
endif

rsb210:	mov	bx,ax

	cmp	[fadeout_volume],0
	jz	rpsg
if	board2
	cmp	[kp_rhythm_flag],0
	jz	rpps_check
	mov	dl,[rhyvol]
	call	volset2rf
rpps_check:
endif
	cmp	[ppsdrv_flag],0
	jz	roret		;fadeout��ppsdrv�łȂ甭�����Ȃ�

rpsg:	mov	al,-1
rolop:	inc	al
	shr	bx,1
	jc	rhygo
	jmp	rolop

rhygo:	push	di
	push	si
	push	bx
	push	ax
	call	effgo
	pop	ax
	pop	bx
	pop	si
	pop	di

	cmp	[ppsdrv_flag],0
	jz	roret
	test	bx,bx
	jz	roret
	jmp	rolop	;PPSDRV�Ȃ�Q���ڈȏ���炵�Ă݂�

roret:	mov	bx,[rhyadr]
	jmp	rlnset

if	board2

rshot:	mov	dx,[bx]
	xchg	dh,dl
	inc	bx
	inc	bx
	call	opnset44
	mov	dh,10h
	mov	dl,[bx]
	and	dl,[rhythmmask]
	jz	rsb200
	jns	rshot00
	mov	dl,10000100b
	call	opnset44
	mov	dl,00001000b
	and	dl,[rhythmmask]
	jz	rsb200
	_rwait
rshot00:
	call	opnset44
	jmp	rsb200

endif

;==============================================================================
;	�e�����R�}���h����
;==============================================================================
commands:
	mov	bx,offset cmdtbl
	jmp	command00

commandsr:
	mov	bx,offset cmdtblr
	jmp	command00

commandsp:
	mov	bx,offset cmdtblp

command00:
	cmp	al,com_end
	jc	out_of_commands
	not	al
	add	al,al
	xor	ah,ah
	add	bx,ax
	mov	ax,cs:[bx]
if	ppz
	push	ax
	_ppz
	pop	ax
endif
	jmp	ax

out_of_commands:
	dec	si
	mov	byte ptr [si],80h	;Part END
	ret

	even
cmdtbl:
	dw	com@		;0FFH
	dw	comq
	dw	comv
	dw	comt
	dw	comtie
	dw	comd
	dw	comstloop
	dw	comedloop
	dw	comexloop
	dw	comlopset
	dw	comshift
	dw	comvolup
	dw	comvoldown
	dw	lfoset
	dw	lfoswitch_f
	dw	jump4		;0F0H
	dw	comy		;0EFH
	dw	jump1
	dw	jump1
	; FOR SB2
	dw	panset
	dw	rhykey
	dw	rhyvs
	dw	rpnset
	dw	rmsvs		;0E8H
	;�ǉ� for V2.0
	dw	comshift2	;0E7H
	dw	rmsvs_sft	;0E6H
	dw	rhyvs_sft	;0E5H
	;
	dw	hlfo_delay	;0E4H
	;�ǉ� for V2.3
	dw	comvolup2	;0E3H
	dw	comvoldown2	;0E2H
	;�ǉ� for V2.4
	dw	hlfo_set	;0E1H
	dw	hlfo_onoff	;0E0H
	;
	dw	syousetu_lng_set	;0DFH
	;
	dw	vol_one_up_fm	;0DEH
	dw	vol_one_down	;0DDH
	;
	dw	status_write	;0DCH
	dw	status_add	;0DBH
	;
	dw	porta		;0DAH
	;
	dw	jump1		;0D9H
	dw	jump1		;0D8H
	dw	jump1		;0D7H
	;
	dw	mdepth_set	;0D6H
	;
	dw	comdd		;0d5h
	;
	dw	ssg_efct_set	;0d4h
	dw	fm_efct_set	;0d3h
	dw	fade_set	;0d2h
	;
	dw	jump1
	dw	jump1		;0d0h
	;
	dw	slotmask_set	;0cfh
	dw	jump6		;0ceh
	dw	jump5		;0cdh
	dw	jump1		;0cch
	dw	lfowave_set	;0cbh
	dw	lfo_extend	;0cah
	dw	jump1		;0c9h
	dw	slotdetune_set	;0c8h
	dw	slotdetune_set2	;0c7h
	dw	fm3_extpartset	;0c6h
	dw	volmask_set	;0c5h
	dw	comq2		;0c4h
	dw	panset_ex	;0c3h
	dw	lfoset_delay	;0c2h
	dw	jump0		;0c1h,sular
	dw	fm_mml_part_mask	;0c0h
	dw	_lfoset		;0bfh
	dw	_lfoswitch_f	;0beh
	dw	_mdepth_set	;0bdh
	dw	_lfowave_set	;0bch
	dw	_lfo_extend	;0bbh
	dw	_volmask_set	;0bah
	dw	_lfoset_delay	;0b9h
	dw	tl_set		;0b8h
	dw	mdepth_count	;0b7h
	dw	fb_set		;0b6h
	dw	slot_delay	;0b5h
	dw	jump16		;0b4h
	dw	comq3		;0b3h
	dw	comshift_master	;0b2h
	dw	comq4		;0b1h

com_end	equ	0b1h

cmdtblp:
	dw	jump1
	dw	comq
	dw	comv
	dw	comt
	dw	comtie
	dw	comd
	dw	comstloop
	dw	comedloop	;0F8H
	dw	comexloop
	dw	comlopset
	dw	comshift
	dw	comvolupp
	dw	comvoldownp
	dw	lfoset
	dw	lfoswitch
	dw	psgenvset	;0F0H
	dw	comy
	dw	psgnoise
	dw	psgsel
	;
	dw	jump1
	dw	rhykey
	dw	rhyvs
	dw	rpnset
	dw	rmsvs		;0E8H
	;
	dw	comshift2
	dw	rmsvs_sft
	dw	rhyvs_sft
	;
	dw	jump1
	;�ǉ� for V2.3
	dw	comvolupp2	;0E3H
	dw	comvoldownp2	;0E2H
	;
	dw	jump1		;0E1H
	dw	jump1		;0E0H
	;
	dw	syousetu_lng_set	;0DFH
	;
	dw	vol_one_up_psg	;0DEH
	dw	vol_one_down	;0DDH
	;
	dw	status_write	;0DCH
	dw	status_add	;0DBH
	;
	dw	portap		;0DAH
	;
	dw	jump1		;0D9H
	dw	jump1		;0D8H
	dw	jump1		;0D7H
	;
	dw	mdepth_set	;0D6H
	;
	dw	comdd		;0d5h
	;
	dw	ssg_efct_set	;0d4h
	dw	fm_efct_set	;0d3h
	dw	fade_set	;0d2h
	;
	dw	jump1
	dw	psgnoise_move	;0d0h
	;
	dw	jump1
	dw	jump6		;0ceh
	dw	extend_psgenvset;0cdh
	dw	detune_extend	;0cch
	dw	lfowave_set	;0cbh
	dw	lfo_extend	;0cah
	dw	envelope_extend	;0c9h
	dw	jump3		;0c8h
	dw	jump3		;0c7h
	dw	jump6		;0c6h
	dw	jump1		;0c5h
	dw	comq2		;0c4h
	dw	jump2		;0c3h
	dw	lfoset_delay	;0c2h
	dw	jump0		;0c1h,sular
	dw	ssg_mml_part_mask	;0c0h
	dw	_lfoset		;0bfh
	dw	_lfoswitch	;0beh
	dw	_mdepth_set	;0bdh
	dw	_lfowave_set	;0bch
	dw	_lfo_extend	;0bbh
	dw	jump1		;0bah
	dw	_lfoset_delay	;0b9h
	dw	jump2
	dw	mdepth_count	;0b7h
	dw	jump1
	dw	jump2
	dw	jump16		;0b4h
	dw	comq3		;0b3h
	dw	comshift_master	;0b2h
	dw	comq4		;0b1h

cmdtblr:
	dw	jump1
	dw	jump1
	dw	comv
	dw	comt
	dw	comtie
	dw	comd
	dw	comstloop
	dw	comedloop
	dw	comexloop
	dw	comlopset
	dw	jump1
	dw	comvolupp
	dw	comvoldownp
	dw	jump4
	dw	pdrswitch
	dw	jump4
	dw	comy
	dw	jump1
	dw	jump1
	;
	dw	jump1
	dw	rhykey
	dw	rhyvs
	dw	rpnset
	dw	rmsvs
	;
	dw	jump1
	dw	rmsvs_sft
	dw	rhyvs_sft
	;
	dw	jump1		;0E4H
	;
	dw	comvolupp2	;0E3H
	dw	comvoldownp2	;0E2H
	;
	dw	jump1		;0E1H
	dw	jump1		;0E0H
	;
	dw	syousetu_lng_set	;0DFH
	;
	dw	vol_one_up_psg	;0DEH
	dw	vol_one_down	;0DDH
	;
	dw	status_write	;0DCH
	dw	status_add	;0DBH
	;
	dw	jump1		;�|���^�����g���ʏ퉹���R�}���h��
	;
	dw	jump1		;0D9H
	dw	jump1		;0D8H
	dw	jump1		;0D7H
	;
	dw	jump2		;0D6H
	;
	dw	comdd		;0d5h
	;
	dw	ssg_efct_set	;0d4h
	dw	fm_efct_set	;0d3h
	dw	fade_set	;0d2h
	;
	dw	jump1
	dw	jump1		;0d0h
	;
	dw	jump1
	dw	jump6		;0ceh
	dw	jump5		;0cdh
	dw	jump1		;0cch
	dw	jump1
	dw	jump1
	dw	jump1
	dw	jump3
	dw	jump3
	dw	jump6
	dw	jump1		;0c5h
	dw	jump1
	dw	jump2		;0c3h
	dw	jump1
	dw	jump0		;0c1h,sular
	dw	rhythm_mml_part_mask		;0c0h
	dw	jump4		;0bfh
	dw	jump1		;0beh
	dw	jump2		;0bdh
	dw	jump1		;0bch
	dw	jump1		;0bbh
	dw	jump1		;0bah
	dw	jump1		;0b9h
	dw	jump2
	dw	jump1
	dw	jump1
	dw	jump2
	dw	jump16		;0b4h
	dw	jump1
	dw	jump1		;0b2h
	dw	jump1		;0b1h

jump16:
	add	si,10
jump6:
	inc	si
jump5:
	inc	si
jump4:
	inc	si
jump3:
	inc	si
jump2:
	inc	si
jump1:
	inc	si
jump0:
	ret

;==============================================================================
;	0c0h�̒ǉ�special����
;==============================================================================
special_0c0h:
	cmp	al,com_end_0c0h
	jc	out_of_commands
	not	al
	add	al,al
	xor	ah,ah
	mov	bx,ax
	mov	ax,cs:comtbl0c0h[bx]
	jmp	ax

comtbl0c0h	dw	vd_fm		;0ffh
		dw	_vd_fm
		dw	vd_ssg
		dw	_vd_ssg
		dw	vd_pcm
		dw	_vd_pcm
		dw	vd_rhythm
		dw	_vd_rhythm	;0f8h
		dw	pmd86_s
		dw	vd_ppz
		dw	_vd_ppz		;0f5h

com_end_0c0h	equ	0f7h

;==============================================================================
;	/s option����
;==============================================================================
pmd86_s:
	lodsb
	and	al,1
	mov	[pcm86_vol],al
	ret

;==============================================================================
;	�e��Voldown
;==============================================================================
vd_fm:	mov	bx,offset fm_voldown
vd_main:
	lodsb
	mov	[bx],al
	ret

vd_ssg:	mov	bx,offset ssg_voldown
	jmp	vd_main

vd_pcm:	mov	bx,offset pcm_voldown
	jmp	vd_main

vd_rhythm:
	mov	bx,offset rhythm_voldown
	jmp	vd_main

vd_ppz:
	mov	bx,offset ppz_voldown
	jmp	vd_main

_vd_fm:	mov	bx,offset fm_voldown
	mov	dx,offset _fm_voldown
_vd_main:
	lodsb
	test	al,al
	jz	_vd_reset
	js	_vd_sign
	add	[bx],al
	jnc	_vd_ret
	mov	byte ptr [bx],255
_vd_ret:
	ret
_vd_sign:
	add	[bx],al
	jc	_vd_ret
	mov	byte ptr [bx],0
	ret

_vd_reset:
	xchg	dx,bx
	mov	al,[bx]
	xchg	dx,bx
	mov	[bx],al
	ret

_vd_ssg:
	mov	bx,offset ssg_voldown
	mov	dx,offset _ssg_voldown
	jmp	_vd_main

_vd_pcm:
	mov	bx,offset pcm_voldown
	mov	dx,offset _pcm_voldown
	jmp	_vd_main

_vd_rhythm:
	mov	bx,offset rhythm_voldown
	mov	dx,offset _rhythm_voldown
	jmp	_vd_main

_vd_ppz:
	mov	bx,offset ppz_voldown
	mov	dx,offset _ppz_voldown
	jmp	_vd_main

;==============================================================================
;	slot keyon delay
;==============================================================================
slot_delay:
	lodsb
	and	al,0fh
	xor	al,0fh
	ror	al,1
	ror	al,1
	ror	al,1
	ror	al,1
	mov	sdelay_m[di],al
	lodsb
	mov	sdelay[di],al
	mov	sdelay_c[di],al
	ret

;==============================================================================
;	FB�ω�
;==============================================================================
fb_set:
	mov	dh,0b0h-1
	add	dh,[partb]		;dh=ALG/FB port address
	lodsb
	test	al,al
	js	_fb_set
fb_set2:		;in	al 00000xxx �ݒ肷��FB
	rol	al,1
	rol	al,1
	rol	al,1
fb_set3:		;in	al 00xxx000 �ݒ肷��FB
	cmp	[partb],3
	jnz	fb_notfm3
if	board2
	cmp	[fmsel],0
	jnz	fb_notfm3
else
	cmp	di,offset part_e
	jz	fb_notfm3
endif
	test	slotmask[di],10h	;slot1���g�p���Ă��Ȃ����
	jz	fb_ret			;�o�͂��Ȃ�
	mov	dl,[fm3_alg_fb]
	and	dl,7
	or	dl,al
	mov	[fm3_alg_fb],dl
	jmp	fb_exit

fb_notfm3:
	mov	dl,alg_fb[di]
	and	dl,07h
	or	dl,al
fb_exit:
	call	opnset
	mov	alg_fb[di],dl
fb_ret:	ret

_fb_set:test	al,01000000b
	jnz	_fb_sign
	and	al,7
_fb_sign:
	cmp	[partb],3
	jnz	_fb_notfm3
if	board2
	cmp	[fmsel],0
	jnz	_fb_notfm3
else
	cmp	di,offset part_e
	jz	_fb_notfm3
endif
	mov	dl,[fm3_alg_fb]
	jmp	_fb_next
_fb_notfm3:
	mov	dl,alg_fb[di]
_fb_next:
	ror	dl,1
	ror	dl,1
	ror	dl,1
	and	dl,7
	add	al,dl
	js	_fb_zero
	cmp	al,8
	jc	fb_set2
	mov	al,00111000b
	jmp	fb_set3
_fb_zero:
	xor	al,al
	jmp	fb_set3

;==============================================================================
;	TL�ω�
;==============================================================================
tl_set:
	mov	dh,40h-1
	add	dh,[partb]		;dh=TL FM Port Address
	lodsb
	mov	ah,al
	and	ah,0fh
	mov	ch,slotmask[di]		;ch=slotmask 43210000
	ror	ch,1
	ror	ch,1
	ror	ch,1
	ror	ch,1
	and	ah,ch			;ah=�ω�������slot 00004321
	mov	dl,[si]			;dl=�ω��l
	inc	si

	mov	bx,offset opnset
	cmp	partmask[di],0		;�p�[�g�}�X�N����Ă��邩�H
	jz	ts_00
	mov	bx,offset dummy_ret

ts_00:	test	al,al
	js	tl_slide

	and	dl,127
	ror	ah,1
	jnc	ts_01
	mov	slot1[di],dl
	call	bx
ts_01:	add	dh,8
	ror	ah,1
	jnc	ts_02
	mov	slot2[di],dl
	call	bx
ts_02:	sub	dh,4
	ror	ah,1
	jnc	ts_03
	mov	slot3[di],dl
	call	bx
ts_03:	add	dh,8
	ror	ah,1
	jnc	ts_04
	mov	slot4[di],dl
	call	bx
dummy_ret:
ts_04:	ret

;	���Εω�
tl_slide:
	mov	al,dl

	ror	ah,1
	jnc	tls_01
	mov	dl,slot1[di]
	add	dl,al
	jns	tls_0b
	xor	dl,dl
	test	al,al
	js	tls_0b
	mov	dl,127
tls_0b:	call	bx
	mov	slot1[di],dl

tls_01:	add	dh,8

	ror	ah,1
	jnc	tls_02
	mov	dl,slot2[di]
	add	dl,al
	jns	tls_1b
	xor	dl,dl
	test	al,al
	js	tls_1b
	mov	dl,127
tls_1b:	call	bx
	mov	slot2[di],dl

tls_02:	sub	dh,4

	ror	ah,1
	jnc	tls_03
	mov	dl,slot3[di]
	add	dl,al
	jns	tls_2b
	xor	dl,dl
	test	al,al
	js	tls_2b
	mov	dl,127
tls_2b:	call	bx
	mov	slot3[di],dl

tls_03:	add	dh,8

	ror	ah,1
	jnc	tls_04
	mov	dl,slot4[di]
	add	dl,al
	jns	tls_3b
	xor	dl,dl
	test	al,al
	js	tls_3b
	mov	dl,127
tls_3b:	call	bx
	mov	slot4[di],dl

tls_04:	ret

;==============================================================================
;	���t���p�[�g�̃}�X�Non/off
;==============================================================================
fm_mml_part_mask:
	lodsb
	cmp	al,2
	jnc	special_0c0h
	test	al,al
	jz	fm_mml_part_maskoff
	or	partmask[di],40h
	cmp	partmask[di],40h
	jnz	fmpm_ret
	call	silence_fmpart	;������
fmpm_ret:
	pop	ax		;commands
	jmp	fmmnp_1		;�p�[�g�}�X�N���̏����Ɉڍs

fm_mml_part_maskoff:
	and	partmask[di],0bfh
	jnz	fmpm_ret
	call	neiro_reset	;���F�Đݒ�
	pop	ax		;commands
	jmp	mp1		;�p�[�g����

ssg_mml_part_mask:
	lodsb
	cmp	al,2
	jnc	special_0c0h
	test	al,al
	jz	ssg_part_maskoff_ret
	or	partmask[di],40h
	cmp	partmask[di],40h
	jnz	smpm_ret
	call	psgmsk		;AL=07h AH=Maskdata
	mov	dh,7
	mov	dl,al
	or	dl,ah
	call	opnset44	;PSG keyoff
smpm_ret:
	pop	ax		;commandsp
	jmp	psgmnp_1

ssg_part_maskoff_ret:
	and	partmask[di],0bfh
	jnz	smpm_ret
	pop	ax		;commandsp
	jmp	mp1p		;�p�[�g����

rhythm_mml_part_mask:
	lodsb
	cmp	al,2
	jnc	special_0c0h
	test	al,al
	jz	rhythm_part_maskoff_ret
	or	partmask[di],40h
	ret
rhythm_part_maskoff_ret:
	and	partmask[di],0bfh
	ret

;==============================================================================
;	FM�����̉��F���Đݒ�
;==============================================================================
neiro_reset:
	cmp	neiromask[di],0
	jz	nr_ret

	mov	dl,voicenum[di]
	mov	bx,word ptr slot1[di]	;bh=s3 bl=s1
	mov	cx,word ptr slot2[di]	;ch=s4 cl=s2
	push	bx
	push	cx
	mov	[af_check],1
	call	neiroset		; ���F���A
	mov	[af_check],0
	pop	cx
	pop	bx
	mov	word ptr slot1[di],bx
	mov	word ptr slot2[di],cx

	mov	al,carrier[di]
	not	al
	and	al,slotmask[di]		;al<- TL���Đݒ肵�Ă���slot 4321xxxx
	jz	nr_exit

	mov	dh,4ch-1
	add	dh,[partb]		;dh=TL FM Port Address

	rol	al,1
	jnc	nr_s3
	mov	dl,ch		;slot 4
	call	opnset
nr_s3:
	sub	dh,8
	rol	al,1
	jnc	nr_s2
	mov	dl,bh		;slot 3
	call	opnset
nr_s2:
	add	dh,4
	rol	al,1
	jnc	nr_s1
	mov	dl,cl		;slot 2
	call	opnset
nr_s1:
	sub	dh,8
	rol	al,1
	jnc	nr_exit
	mov	dl,bl		;slot 1
	call	opnset

nr_exit:
if	board2
	mov	dh,[partb]
	add	dh,0b4h-1
	call	calc_panout
	call	opnset			; �p�����A
endif
nr_ret:
	ret

;==============================================================================
;	PDR��switch
;==============================================================================
pdrswitch:
	lodsb
	cmp	[ppsdrv_flag],0
	jz	pdrsw_ret
	mov	dl,al
	and	dl,1
	shr	al,1
	mov	ah,5
	int	ppsdrv
pdrsw_ret:
	ret

;==============================================================================
;	���ʃ}�X�Nslot�̐ݒ�
;==============================================================================
volmask_set:
	lodsb
	and	al,0fh
	jz	vms_zero
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1		;���4BIT�Ɉړ�
	or	al,0fh		;�O�ȊO���w�肵��=����4BIT���P�ɂ���
	mov	volmask[di],al
	jmp	ch3_setting

vms_zero:
	mov	al,carrier[di]
	mov	volmask[di],al	;�L�����A�ʒu��ݒ�
	jmp	ch3_setting

_volmask_set:
	lodsb
	and	al,0fh
	jz	_vms_zero
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1		;���4BIT�Ɉړ�
	or	al,0fh		;�O�ȊO���w�肵��=����4BIT���P�ɂ���
	mov	_volmask[di],al
	jmp	ch3_setting
_vms_zero:
	mov	al,carrier[di]
	mov	_volmask[di],al	;�L�����A�ʒu��ݒ�

;==============================================================================
;	�p�[�g�𔻕ʂ���ch3�Ȃ�mode�ݒ�
;==============================================================================
ch3_setting:
	cmp	[partb],3
	jnz	vms_not_p3
if	board2
	cmp	[fmsel],0
	jnz	vms_not_p3
else
	cmp	di,offset part_e
	jz	vms_not_p3
endif
	call	ch3mode_set	;FM3ch�̏ꍇ�̂� ch3mode�̕ύX����
	stc
	ret

vms_not_p3:
	clc
	ret

;==============================================================================
;	FM3ch �g���p�[�g�Z�b�g
;==============================================================================
fm3_extpartset:
	push	di

	lodsw
	test	ax,ax
	jz	fm3ext_part3c
	add	ax,[mmlbuf]
	mov	di,offset part3b
	call	fm3_partinit
fm3ext_part3c:
	lodsw
	test	ax,ax
	jz	fm3ext_part3d
	add	ax,[mmlbuf]
	mov	di,offset part3c
	call	fm3_partinit
fm3ext_part3d:
	lodsw
	test	ax,ax
	jz	fm3ext_exit
	add	ax,[mmlbuf]
	mov	di,offset part3d
	call	fm3_partinit
fm3ext_exit:
	pop	di
	ret

fm3_partinit:
	mov	address[di],ax
	mov	leng[di],1		; �� 1���� �� �ݿ� ���
	mov	al,-1
	mov	keyoff_flag[di],al	; ����keyoff��
	mov	mdc[di],al		; MDepth Counter (����)
	mov	mdc2[di],al		; //
	mov	_mdc[di],al		; //
	mov	_mdc2[di],al		; //
	mov	onkai[di],al		; rest
	mov	onkai_def[di],al	; rest
	mov	volume[di],108		; FM  VOLUME DEFAULT= 108
	mov	bx,offset part3
	mov	al,fmpan[bx]
	mov	fmpan[di],al		; FM PAN = CH3�Ɠ���
	or	partmask[di],20h	; s0�p partmask
	ret

;==============================================================================
;	Detune Extend Set
;==============================================================================
detune_extend:
	lodsb
	and	al,1
	and	extendmode[di],0feh
	or	extendmode[di],al
	ret

;==============================================================================
;	LFO Extend Set
;==============================================================================
lfo_extend:
	lodsb
	and	al,1
	rol	al,1
	and	extendmode[di],0fdh
	or	extendmode[di],al
	ret

;==============================================================================
;	Envelope Extend Set
;==============================================================================
envelope_extend:
	lodsb
	and	al,1
	rol	al,1
	rol	al,1
	and	extendmode[di],0fbh
	or	extendmode[di],al
	ret

;==============================================================================
;	LFO��Wave�I��
;==============================================================================
lfowave_set:
	lodsb
	mov	lfo_wave[di],al
	ret

;==============================================================================
;	PSG Envelope set (Extend)
;==============================================================================
extend_psgenvset:
	lodsb
	and	al,1fh
	mov	eenv_ar[di],al
	lodsb
	and	al,1fh
	mov	eenv_dr[di],al
	lodsb
	and	al,1fh
	mov	eenv_sr[di],al
	lodsb
	mov	ah,al
	and	al,0fh
	mov	eenv_rr[di],al
	rol	ah,1
	rol	ah,1
	rol	ah,1
	rol	ah,1
	and	ah,0fh
	xor	ah,0fh
	mov	eenv_sl[di],ah
	lodsb
	and	al,0fh
	mov	eenv_al[di],al

	cmp	envf[di],-1
	jz	not_set_count		;�m�[�}�����g���Ɉڍs�������H
	mov	envf[di],-1
	mov	eenv_count[di],4	;RR
	mov	eenv_volume[di],0	;Volume
not_set_count:
	ret

;==============================================================================
;	Slot Detune Set(����)
;==============================================================================
slotdetune_set2:
	cmp	[partb],3	;�e�l3CH�ڂ����w��o���Ȃ�
	jnz	jump3
if	board2
	cmp	[fmsel],1	;���ł͎w��o���Ȃ�
	jz	jump3
endif
	lodsb
	mov	bl,al
	lodsw
	ror	bl,1
	jnc	sds2_slot2
	add	[slot_detune1],ax
sds2_slot2:
	ror	bl,1
	jnc	sds2_slot3
	add	[slot_detune2],ax
sds2_slot3:
	ror	bl,1
	jnc	sds2_slot4
	add	[slot_detune3],ax
sds2_slot4:
	ror	bl,1
	jnc	sds_check
	add	[slot_detune4],ax
	jmp	sds_check

;==============================================================================
;	Slot Detune Set
;==============================================================================
slotdetune_set:
	cmp	[partb],3	;�e�l3CH�ڂ����w��o���Ȃ�
	jnz	jump3
if	board2
	cmp	[fmsel],1	;���ł͎w��o���Ȃ�
	jz	jump3
else
	cmp	di,offset part_e
	jz	jump3
endif
	lodsb
	mov	bl,al
	lodsw
	ror	bl,1
	jnc	sds_slot2
	mov	[slot_detune1],ax
sds_slot2:
	ror	bl,1
	jnc	sds_slot3
	mov	[slot_detune2],ax
sds_slot3:
	ror	bl,1
	jnc	sds_slot4
	mov	[slot_detune3],ax
sds_slot4:
	ror	bl,1
	jnc	sds_check
	mov	[slot_detune4],ax
sds_check:
	mov	ax,[slot_detune1]
	or	ax,[slot_detune2]
	or	ax,[slot_detune3]
	or	ax,[slot_detune4]	;�S���O���H
	jz	sdf_set
	mov	al,1
sdf_set:
	mov	[slotdetune_flag],al

;==============================================================================
;	FM3��mode��ݒ肷��
;==============================================================================
ch3mode_set:
	mov	al,1
	cmp	di,offset part3
	jz	cmset_00
	inc	al
	cmp	di,offset part3b
	jz	cmset_00
	mov	al,4
	cmp	di,offset part3c
	jz	cmset_00
	mov	al,8
cmset_00:
	test	slotmask[di],0f0h	;s0
	jz	cm_clear
	cmp	slotmask[di],0f0h
	jnz	cm_set
	test	volmask[di],0fh
	jz	cm_clear
	test	lfoswi[di],1
	jnz	cm_set
cm_noset1:
	test	_volmask[di],0fh
	jz	cm_clear
	test	lfoswi[di],10h
	jnz	cm_set
cm_clear:
	xor	al,0ffh
	and	[slot3_flag],al
	jnz	cm_set2
cm_clear2:
	cmp	[slotdetune_flag],1
	jz	cm_set2
	mov	ah,03fh
	jmp	cm_set_main
cm_set:
	or	[slot3_flag],al
cm_set2:mov	ah,07fh

cm_set_main:
ife	board2
	test	partmask[di],2		;Effect/�p�[�g�}�X�N����Ă��邩�H
	jnz	cm_nowefcplaying
endif
	cmp	ah,[ch3mode]
	jz	cm_exit		;�ȑO�ƕύX�����Ȃ牽�����Ȃ�
	mov	[ch3mode],ah
	mov	dh,27h
	mov	dl,ah
	and	dl,11001111b	;Reset�͂��Ȃ�
	call	opnset44

;	���ʉ����[�h�Ɉڂ����ꍇ�͂���ȑO��FM3�p�[�g�ŉ�����������
	cmp	ah,3fh
	jz	cm_exit
	cmp	di,offset part3
	jz	cm_exit
cm_otodasi:
	push	bp
	mov	bp,di
	push	di
	mov	di,offset part3
	call	otodasi_cm
cm_3bchk:
	cmp	bp,offset part3b
	jz	cm_exit2
	mov	di,offset part3b
	call	otodasi_cm
cm_3cchk:
	cmp	bp,offset part3c
	jz	cm_exit2
	mov	di,offset part3c
	call	otodasi_cm
cm_exit2:
	pop	di
	pop	bp
cm_exit:
	ret

otodasi_cm:
	cmp	partmask[di],0
	jnz	ocm_ret
	call	otodasi
ocm_ret:
	ret

ife	board2
cm_nowefcplaying:
	mov	[ch3mode_push],ah
	ret
endif

;==============================================================================
;	FM slotmask set
;==============================================================================
slotmask_set:
	lodsb
	mov	ah,al
	and	al,0fh
	jz	sm_not_car
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1
	mov	carrier[di],al
	jmp	sm_set

sm_not_car:
	cmp	[partb],3
	jnz	sm_notfm3
if	board2
	cmp	[fmsel],0
	jnz	sm_notfm3
else
	cmp	di,offset part_e
	jz	sm_notfm3
endif
	mov	bl,[fm3_alg_fb]
	jmp	sm_car_set

sm_notfm3:
	mov	dl,voicenum[di]
	push	ax
	call	toneadr_calc
	pop	ax
	mov	bl,24[bx]

sm_car_set:
	xor	bh,bh
	and	bl,7
	add	bx,offset carrier_table
	mov	al,[bx]
	mov	carrier[di],al
sm_set:
	and	ah,0f0h
	cmp	slotmask[di],ah
	jz	sm_no_change

	mov	slotmask[di],ah
	test	ah,0f0h
	jnz	sm_noset_pm
	or	partmask[di],20h	;s0�̎��p�[�g�}�X�N
	jmp	sms_ns
sm_noset_pm:
	and	partmask[di],0dfh	;s0�ȊO�̎��p�[�g�}�X�N����
sms_ns:
	call	ch3_setting	;FM3ch�̏ꍇ�̂� ch3mode�̕ύX����
	jnc	sms_nms

;	ch3�Ȃ�A����ȑO��FM3�p�[�g��keyon����
	cmp	di,offset part3
	jz	sm_exit
	push	bp
	mov	bp,di
	push	di
	mov	di,offset part3
	call	keyon_sm
sm_3bchk:
	cmp	bp,offset part3b
	jz	sm_exit2
	mov	di,offset part3b
	call	keyon_sm
sm_3cchk:
	cmp	bp,offset part3c
	jz	sm_exit2
	mov	di,offset part3c
	call	keyon_sm
sm_exit2:
	pop	di
	pop	bp
sm_exit:

sms_nms:
	xor	ah,ah
	mov	al,slotmask[di]
	rol	al,1	;slot4
	jnc	sms_n4
	or	ah,00010001b
sms_n4:
	rol	al,1	;slot3
	jnc	sms_n3
	or	ah,01000100b
sms_n3:
	rol	al,1	;slot2
	jnc	sms_n2
	or	ah,00100010b
sms_n2:
	rol	al,1	;slot1
	jnc	sms_n1
	or	ah,10001000b
sms_n1:
	mov	neiromask[di],ah

	pop	bx	;commands
	cmp	partmask[di],0
	jz	mp1	;�p�[�g����
	jmp	fmmnp_1

sm_no_change:
	ret

keyon_sm:
	cmp	partmask[di],0
	jnz	ksm_ret
	test	keyoff_flag[di],1	;keyon�����H
	jnz	ksm_ret			;keyoff��
	call	keyon
ksm_ret:
	ret

;==============================================================================
;	ssg effect
;==============================================================================
ssg_efct_set:
	lodsb
	cmp	partmask[di],0
	jnz	ses_ret
	test	al,al
	jz	ses_off
	push	si
	push	di
	call	eff_on2
	pop	di
	pop	si
ses_ret:
	ret
ses_off:
	push	si
	push	di
	call	effoff
	pop	di
	pop	si
	ret

;==============================================================================
;	fm effect
;==============================================================================
fm_efct_set:
	lodsb
	cmp	partmask[di],0
	jnz	ses_ret	;��
	test	al,al
	jz	fes_off
if	board2
	mov	bh,[fmsel]
endif
	mov	bl,[partb]
	push	bx
	push	si
	push	di
	call	fm_effect_on
	pop	di
	pop	si
	pop	ax
	mov	[partb],al
if	board2
	test	ah,ah
	jz	sel44
	jmp	sel46
else
	ret
endif
fes_off:
if	board2
	mov	bh,[fmsel]
endif
	mov	bl,[partb]
	push	bx
	push	si
	push	di
	call	fm_effect_off
	pop	di
	pop	si
	pop	ax
	mov	[partb],al
if	board2
	test	ah,ah
	jz	sel44
	jmp	sel46
else
	ret
endif
;==============================================================================
;	fadeout
;==============================================================================
fade_set:
	mov	[fadeout_flag],1
	lodsb
	jmp	fout

;==============================================================================
;	LFO depth +- set
;==============================================================================
mdepth_set:
	lodsb
	mov	mdspd[di],al
	mov	mdspd2[di],al
	lodsb
	mov	mdepth[di],al
	ret

mdepth_count:
	lodsb
	or	al,al
	js	mdc_lfo2
	jnz	mdc_no_deca
	dec	al	;255
mdc_no_deca:
	mov	mdc[di],al
	mov	mdc2[di],al
	ret
mdc_lfo2:
	and	al,7fh
	jnz	mdc_no_decb
	dec	al	;255
mdc_no_decb:
	mov	_mdc[di],al
	mov	_mdc2[di],al
	ret

;==============================================================================
;	�|���^�����g�v�Z�Ȃ̂�
;==============================================================================
porta_calc:
	mov	ax,porta_num2[di]
	add	porta_num[di],ax
	cmp	porta_num3[di],0
	jz	pc_ret
	js	pc_minus
	dec	porta_num3[di]
	inc	porta_num[di]
	ret
pc_minus:
	inc	porta_num3[di]
	dec	porta_num[di]
pc_ret:
	ret

;==============================================================================
;	�|���^�����g(FM)
;==============================================================================
porta:
	cmp	partmask[di],0
	jnz	porta_notset
	lodsb

	call	lfoinit
	call	oshift
	call	fnumset

	mov	ax,fnum[di]
	push	ax
	mov	al,onkai[di]
	push	ax

	lodsb
	call	oshift
	call	fnumset
	mov	bx,fnum[di]	;bx=�|���^�����g���fnum�l

	pop	cx
	mov	onkai[di],cl
	pop	cx
	mov	fnum[di],cx	;cx=�|���^�����g����fnum�l

	xor	ax,ax
	push	cx
	push	bx
	and	ch,38h
	and	bh,38h
	sub	bh,ch		;���octarb - ����octarb
	jz	not_octarb
	sar	bh,1
	sar	bh,1
	sar	bh,1
	mov	al,bh
	cbw			;ax=octarb��
	mov	bx,26ah
	imul	bx		;(dx)ax = 26ah * octarb��
not_octarb:
	pop	bx
	pop	cx

	and	cx,7ffh
	and	bx,7ffh
	sub	bx,cx
	add	ax,bx		;ax=26ah*octarb�� + ������

	mov	bl,[si]
	inc	si
	mov	leng[di],bl
	call	calc_q

	xor	bh,bh
	cwd
	idiv	bx		;ax=(26ah*ovtarb�� + ������) / ����

	mov	porta_num2[di],ax	;��
	mov	porta_num3[di],dx	;�]��
	or	lfoswi[di],8		;Porta ON

	pop	ax	;commands
	jmp	porta_return

porta_notset:
	lodsb	;�ŏ��̉�����ǂݔ�΂�	(Mask��)
	ret

;==============================================================================
;	�|���^�����g(PSG)
;==============================================================================
portap:
	cmp	partmask[di],0
	jnz	porta_notset

	lodsb
	call	lfoinitp
	call	oshiftp
	call	fnumsetp

	mov	ax,fnum[di]
	push	ax
	mov	al,onkai[di]
	push	ax

	lodsb
	call	oshiftp
	call	fnumsetp
	mov	ax,fnum[di]	; ax = �|���^�����g���psg_tune�l

	pop	bx
	mov	onkai[di],bl
	pop	bx		; bx = �|���^�����g����psg_tune�l
	mov	fnum[di],bx

	sub	ax,bx		; ax = psg_tune��

	mov	bl,[si]
	inc	si
	mov	leng[di],bl
	call	calc_q

	xor	bh,bh
	cwd
	idiv	bx		; ax = psg_tune�� / ����

	mov	porta_num2[di],ax	;��
	mov	porta_num3[di],dx	;�]��
	or	lfoswi[di],8		;Porta ON

	pop	ax	;commandsp
	jmp	porta_returnp

;==============================================================================
;	�r�s�`�s�t�r�ɒl���o��
;==============================================================================
status_write:
	lodsb
	mov	[status],al
	ret

;==============================================================================
;	�r�s�`�s�t�r�ɒl�����Z
;==============================================================================
status_add:
	lodsb
	mov	bx,offset status
	add	al,[bx]
	mov	[bx],al
	ret

;==============================================================================
;	�{�����[�������̈�����ύX�i�u�Q�D�V�g�����j
;==============================================================================
vol_one_up_fm:
	lodsb
	add	al,volume[di]
	cmp	al,128
	jc	vo_vset	
	mov	al,127
vo_vset:inc	al
	mov	volpush[di],al
	mov	[volpush_flag],1
	ret

vol_one_up_psg:
	lodsb
	add	al,volume[di]
	cmp	al,16
	jc	vo_vset
	mov	al,15
	jmp	vo_vset

vol_one_up_pcm:
	lodsb
	add	al,volume[di]
	jc	voup_over
vmax_check:
	cmp	al,255
	jc	vo_vset
voup_over:
	mov	al,254
	jmp	vo_vset

vol_one_down:
	lodsb
	mov	ah,al
	mov	al,volume[di]
	sub	al,ah
	jnc	vmax_check
	xor	al,al
	jmp	vo_vset

;==============================================================================
;	�e�l�����n�[�h�k�e�n�̐ݒ�i�u�Q�D�S�g�����j
;==============================================================================
hlfo_set:
	lodsb

if	board2
	mov	ah,al

	mov	al,fmpan[di]
	and	al,11000000b
	or	al,ah
	mov	fmpan[di],al

	cmp	[partb],3
	jnz	hlfoset_notfm3
	cmp	[fmsel],0
	jnz	hlfoset_notfm3
	;2608�̎��݂̂Ȃ̂� part_e�͂��肦�Ȃ�

;	FM3�̏ꍇ�� 4�̃p�[�g���Đݒ�
	push	di
	mov	di,offset part3
	mov	fmpan[di],al
	mov	di,offset part3b
	mov	fmpan[di],al
	mov	di,offset part3c
	mov	fmpan[di],al
	mov	di,offset part3d
	mov	fmpan[di],al
	pop	di

hlfoset_notfm3:
	cmp	partmask[di],0		;�p�[�g�}�X�N����Ă��邩�H
	jnz	hlfo_exit

	mov	dh,[partb]
	add	dh,0b4h-1
	call	calc_panout
	call	opnset
endif
hlfo_exit:
	ret

;==============================================================================
;	�e�l�����n�[�h�k�e�n�̃X�C�b�`�i�u�Q�D�S�g�����j
;==============================================================================
hlfo_onoff:
	lodsb
if	board2
	mov	dl,al
	mov	dh,022h
	mov	[port22h],dl
	jmp	opnset44
else
	ret
endif

;==============================================================================
;	�e�l�����n�[�h�k�e�n�̃f�B���C�ݒ�
;==============================================================================
hlfo_delay:
	lodsb
if	board2
	mov	hldelay[di],al
endif
	ret

;==============================================================================
;	COMMAND 'Z' �i���߂̒����̕ύX�j
;==============================================================================
syousetu_lng_set:
	lodsb
	mov	[syousetu_lng],al
	ret

;==============================================================================
;	COMMAND '@' [PROGRAM CHANGE]
;==============================================================================
com@:
	lodsb
	mov	voicenum[di],al
	mov	dl,al
	cmp	partmask[di],0		;�p�[�g�}�X�N����Ă��邩�H
	jnz	com@_mask
	jmp	neiroset

com@_mask:
	call	toneadr_calc
	mov	dl,24[bx]
	mov	alg_fb[di],dl	;alg/fb�ݒ�
	add	bx,4
	call	neiroset_tl	;tl�ݒ�(NO break dl)

;	FM3ch�ŁA�}�X�N����Ă����ꍇ�Afm3_alg_fb��ݒ�
	cmp	[partb],3
	jnz	com@_exit
	cmp	neiromask[di],0
	jz	com@_exit
if	board2
	cmp	[fmsel],0
	jz	com@_afset
else
	cmp	di,offset part_e
	jnz	com@_afset
endif
com@_exit:
	ret

com@_afset:	;in. dl = alg/fb
	test	slotmask[di],10h	;slot1���g�p���Ă��Ȃ����
	jnz	com@_notslot1
	mov	al,[fm3_alg_fb]
	and	al,00111000b		;fb�͑O�̒l���g�p
	and	dl,00000111b
	or	dl,al
com@_notslot1:
	mov	[fm3_alg_fb],dl
	mov	alg_fb[di],al
	ret

;==============================================================================
;	COMMAND 'q' [STEP-GATE CHANGE]
;==============================================================================
comq:
	lodsb
	mov	qdata[di],al
	mov	qdat3[di],0
	ret
comq3:
	lodsb
	mov	qdat2[di],al
	ret
comq4:
	lodsb
	mov	qdat3[di],al
	ret

;==============================================================================
;	COMMAND 'Q' [STEP-GATE CHANGE 2]
;==============================================================================
comq2:
	lodsb
	mov	qdatb[di],al
	ret

;==============================================================================
;	COMMAND 'V' [VOLUME CHANGE]
;==============================================================================
comv:	
	lodsb
	mov	volume[di],al
	ret

;==============================================================================
;	COMMAND 't' [TEMPO CHANGE1]
;	COMMAND 'T' [TEMPO CHANGE2]
;	COMMAND 't�}' [TEMPO CHANGE ����1]
;	COMMAND 'T�}' [TEMPO CHANGE ����2]
;==============================================================================
comt:	lodsb
	cmp	al,251
	jnc	comt_sp0
comt_exit1:
	mov	[tempo_d],al	;T (FC)
	mov	[tempo_d_push],al
	jmp	calc_tb_tempo

comt_sp0:
	inc	al
	jnz	comt_sp1

	lodsb			;t (FC FF)
comt_exit2c:		
	cmp	al,18
	jnc	comt_exit2
comt_2c_over:
	mov	al,18
comt_exit2:
	mov	[tempo_48],al
	mov	[tempo_48_push],al
	jmp	calc_tempo_tb

comt_sp1:
	inc	al
	lodsb
	jnz	comt_sp2

	mov	ah,[tempo_d_push]	;T�} (FC FE)
	test	al,al
	js	comt_sp1_minus
	add	al,ah
	jnc	comt_sp1_exitc
	mov	al,250
	jmp	comt_exit1
comt_sp1_minus:
	add	al,ah
	jc	comt_sp1_exitc
	xor	al,al
comt_sp1_exitc:
	cmp	al,251
	jc	comt_exit1
	mov	al,250
	jmp	comt_exit1

comt_sp2:
	mov	ah,[tempo_48_push]	;t�} (FC FD)
	test	al,al
	js	comt_sp2_minus
	add	al,ah
	jnc	comt_exit2
	mov	al,255
	jmp	comt_exit2
comt_sp2_minus:
	add	al,ah
	jnc	comt_2c_over
	jmp	comt_exit2c

;==============================================================================
;	T->t �ϊ�
;		input	[tempo_d]
;		output	[tempo_48]
;==============================================================================
calc_tb_tempo:
;	TEMPO = 112CH / [ 256 - TB ]	timerB -> tempo
	xor	bl,bl
	sub	bl,[tempo_d]
	mov	al,255
	cmp	bl,18
	jc	ctbt_exit
	mov	ax,112ch
	div	bl
	test	ah,ah
	jns	ctbt_exit
	inc	al		;�l�̌ܓ�
ctbt_exit:
	mov	[tempo_48],al
	mov	[tempo_48_push],al
	ret

;==============================================================================
;	t->T �ϊ�
;		input	[tempo_48]
;		output	[tempo_d]
;==============================================================================
calc_tempo_tb:
;	TB = 256 - [ 112CH / TEMPO ]	tempo -> timerB
	mov	bl,[tempo_48]
	xor	al,al
	cmp	bl,18
	jc	cttb_exit
	mov	ax,112ch
	div	bl
	xor	dl,dl
	sub	dl,al
	mov	al,dl
	test	ah,ah
	jns	cttb_exit
	dec	al	;�l�̌ܓ�
cttb_exit:
	mov	[tempo_d],al
	mov	[tempo_d_push],al
	ret

;==============================================================================
;	COMMAND '&' [�^�C]
;==============================================================================
comtie:
	or	[tieflag],1
	ret

;==============================================================================
;	COMMAND 'D' [������]
;==============================================================================
comd:	lodsw
	mov	detune[di],ax
	ret

;==============================================================================
;	COMMAND 'DD' [����������]
;==============================================================================
comdd:	lodsw
	add	detune[di],ax
	ret

;==============================================================================
;	COMMAND '[' [ٰ�� ����]
;==============================================================================
comstloop:
	lodsw
	mov	bx,ax
	mov	ax,[mmlbuf]
	cmp	di,offset part_e
	jnz	comst_nonefc
	mov	ax,[efcdat]
comst_nonefc:
	add	bx,ax
	inc	bx
	mov	byte ptr [bx],0
	ret	

;==============================================================================
;	COMMAND	']' [ٰ�� ����]
;==============================================================================
comedloop:
	lodsb
	test	al,al
	jz	muloop	; 0 �� Ѽޮ��� ٰ��
	mov	ah,al
	inc	byte ptr [si]
	lodsb
	cmp	ah,al
	jnz	reloop
	inc	si
	inc	si
	ret
muloop:	inc	si
	mov	loopcheck[di],1
reloop:	lodsw
	inc	ax
	inc	ax
	mov	bx,[mmlbuf]
	cmp	di,offset part_e
	jnz	comed_nonefc
	mov	bx,[efcdat]
comed_nonefc:
	add	ax,bx
	mov	si,ax
	ret		

;==============================================================================
;	COMMAND	':' [ٰ�� �ޯ���]
;==============================================================================
comexloop:
	lodsw
	mov	bx,ax
	mov	ax,[mmlbuf]
	cmp	di,offset part_e
	jnz	comex_nonefc
	mov	ax,[efcdat]
comex_nonefc:
	add	bx,ax
	mov	dl,[bx]
	dec	dl
	inc	bx
	cmp	dl,[bx]
	jz	loopexit
	ret
loopexit:
	add	bx,3
	mov	si,bx
	ret

;==============================================================================
;	COMMAND 'L' [�ض�� ٰ�� ���]
;==============================================================================
comlopset:
	mov	partloop[di],si
	ret

;==============================================================================
;	COMMAND '_' [�ݶ� ���]
;==============================================================================
comshift:	
	lodsb
	mov	shift[di],al
	ret

;==============================================================================
;	COMMAND '__' [���Γ]��]
;==============================================================================
comshift2:
	lodsb
	add	al,shift[di]
	mov	shift[di],al
	ret

;==============================================================================
;	COMMAND '_M' [Master�]���l]
;==============================================================================
comshift_master:
	lodsb
	mov	shift_def[di],al
	ret

;==============================================================================
;	COMMAND ')' [VOLUME UP]
;==============================================================================
	;	�e�n�q�@�e�l
comvolup:
	mov	al,volume[di]
	add	al,4
volupck:
	cmp	al,128
	jc	vset
	mov	al,127
vset:	mov	volume[di],al
	ret

	;�����t��
comvolup2:
	lodsb
	add	al,volume[di]
	jmp	volupck

	;	�e�n�q�@�o�r�f
comvolupp:
	mov	al,volume[di]	
	inc	al
volupckp:
	cmp	al,16
	jc	vset
	mov	al,15
	jmp	vset

	;�����t��
comvolupp2:
	lodsb
	add	al,volume[di]
	jmp	volupckp

;==============================================================================
;	COMMAND '(' [VOLUME DOWN]
;==============================================================================
	;	�e�n�q�@�e�l
comvoldown:
	mov	al,volume[di]
	sub	al,4
	jnc	vset
	xor	al,al
	jmp	vset

	;�����t��
comvoldown2:
	lodsb
	mov	ah,al
	mov	al,volume[di]
	sub	al,ah
	jnc	vset
	xor	al,al
	jmp	vset

	;	�e�n�q�@�o�r�f
comvoldownp:
	mov	al,volume[di]
	test	al,al
	jz	vset
	dec	al
	jmp	vset

	;�����t��
comvoldownp2:
	lodsb
	mov	ah,al
	mov	al,volume[di]
	sub	al,ah
	jnc	vset
	xor	al,al
	jmp	vset

;==============================================================================
;	�k�e�n�Q�p����
;==============================================================================
_lfoset:
	mov	ax,offset lfoset
_lfo_main:
	pushf
	cli
	push	ax
	call	lfo_change
	pop	ax
	call	ax
	call	lfo_change
	popf
	ret

_mdepth_set:
	mov	ax,offset mdepth_set
	jmp	_lfo_main

_lfowave_set:
	mov	ax,offset lfowave_set
	jmp	_lfo_main

_lfo_extend:
	mov	ax,offset lfo_extend
	jmp	_lfo_main

_lfoset_delay:
	mov	ax,offset lfoset_delay
	jmp	_lfo_main

_lfoswitch:
	lodsb
	and	al,7
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1
	and	lfoswi[di],08fh
	or	lfoswi[di],al
	call	lfo_change
	call	lfoinit_main
	jmp	lfo_change

_lfoswitch_f:
	call	_lfoswitch
	jmp	ch3_setting

;==============================================================================
;	LFO1<->LFO2 change
;==============================================================================
lfo_change:
	mov	ax,lfodat[di]
	xchg	ax,_lfodat[di]
	mov	lfodat[di],ax

	mov	cl,4
	rol	lfoswi[di],cl
	rol	extendmode[di],cl

	mov	ax,word ptr delay[di]
	xchg	ax,word ptr _delay[di]
	mov	word ptr delay[di],ax

	mov	ax,word ptr step[di]
	xchg	ax,word ptr _step[di]
	mov	word ptr step[di],ax

	mov	ax,word ptr delay2[di]
	xchg	ax,word ptr _delay2[di]
	mov	word ptr delay2[di],ax

	mov	ax,word ptr step2[di]
	xchg	ax,word ptr _step2[di]
	mov	word ptr step2[di],ax

	mov	ax,word ptr mdepth[di]
	xchg	ax,word ptr _mdepth[di]
	mov	word ptr mdepth[di],ax

	mov	al,mdspd2[di]
	mov	ah,lfo_wave[di]
	xchg	ax,word ptr _mdspd2[di]
	mov	mdspd2[di],al
	mov	lfo_wave[di],ah

	mov	ax,word ptr mdc[di]
	xchg	ax,word ptr _mdc[di]
	mov	word ptr mdc[di],ax
	
	ret

;==============================================================================
;	LFO ���Ұ� ���
;==============================================================================
lfoset:	lodsb
	mov	delay[di],al
	mov	delay2[di],al
	lodsb
	mov	speed[di],al
	mov	speed2[di],al
	lodsb
	mov	step[di],al
	mov	step2[di],al
	lodsb
	mov	time[di],al
	mov	time2[di],al
	jmp	lfoinit_main

lfoset_delay:
	lodsb
	mov	delay[di],al
	mov	delay2[di],al
	jmp	lfoinit_main

;==============================================================================
;	LFO SWITCH
;==============================================================================
lfoswitch:
	lodsb
	test	al,11111000b
	jz	ls_00
	mov	al,1
ls_00:
	and	al,7
	and	lfoswi[di],0f8h
	or	lfoswi[di],al
	jmp	lfoinit_main

lfoswitch_f:
	call	lfoswitch
	jmp	ch3_setting

;==============================================================================
;	PSG ENVELOPE SET
;==============================================================================
psgenvset:
	lodsb
	mov	pat[di],al
	mov	patb[di],al
	lodsb
	mov	pv2[di],al
	lodsb
	mov	pr1[di],al
	mov	pr1b[di],al
	lodsb
	mov	pr2[di],al
	mov	pr2b[di],al
	cmp	envf[di],-1
	jnz	not_set_count2		;�g�����m�[�}���Ɉڍs�������H
	mov	envf[di],2	;RR
	mov	penv[di],-15	;Volume
not_set_count2:
	ret

;==============================================================================
;	'y' COMMAND [��¶� ����� ����]
;==============================================================================
comy:
	lodsw
	mov	dh,al
	mov	dl,ah
	jmp	opnset

;==============================================================================
;	'w' COMMAND [PSG NOISE Ͳ�� ���ʽ�]
;==============================================================================
psgnoise:
	lodsb
	mov	[psnoi],al
	ret
psgnoise_move:
	lodsb
	add	al,[psnoi]
	test	al,al
	jns	pnm_nminus
	xor	al,al
pnm_nminus:
	cmp	al,32
	jc	pnm_set
	mov	al,31
pnm_set:
	mov	[psnoi],al
	ret

;==============================================================================
;	'P' COMMAND [PSG TONE/NOISE/MIX SET]
;==============================================================================
psgsel:
	lodsb
	mov	psgpat[di],al
	ret

;==============================================================================
;	'p' COMMAND [FM PANNING SET]
;==============================================================================
panset:
	lodsb
if	board2
panset_main:
	ror	al,1
	ror	al,1
	and	al,11000000b
	mov	ah,al	;ah <- pan data
	mov	al,fmpan[di]
	and	al,00111111b
	or	al,ah
	mov	fmpan[di],al

	cmp	[partb],3
	jnz	panset_notfm3
	cmp	[fmsel],0
	jnz	panset_notfm3

;	FM3�̏ꍇ�� 4�̃p�[�g���Đݒ�
	push	di
	mov	di,offset part3
	mov	fmpan[di],al
	mov	di,offset part3b
	mov	fmpan[di],al
	mov	di,offset part3c
	mov	fmpan[di],al
	mov	di,offset part3d
	mov	fmpan[di],al
	pop	di

panset_notfm3:
	cmp	partmask[di],0		;�p�[�g�}�X�N����Ă��邩�H
	jnz	panset_exit

	mov	dl,al
	mov	dh,[partb]
	add	dh,0b4h-1
	call	calc_panout
	call	opnset
endif
panset_exit:
	ret

if	board2
;==============================================================================
;	0b4h�`�ɐݒ肷��f�[�^���擾 out.dl
;==============================================================================
calc_panout:
	mov	dl,fmpan[di]
	cmp	hldelay_c[di],0
	jz	cpo_ret
	and	dl,0c0h		;HLFO Delay���c���Ă�ꍇ�̓p���̂ݐݒ�
cpo_ret:
	ret
endif
;==============================================================================
;	Pan setting Extend
;==============================================================================
panset_ex:
	lodsb
	inc	si	;�t��flag�͓ǂݔ�΂�
if	board2
	test	al,al
	jz	pex_mid
	js	pex_left
	mov	al,2
	jmp	panset_main
pex_mid:
	mov	al,3
	jmp	panset_main
pex_left:
	mov	al,1
	jmp	panset_main
else
	ret
endif

;==============================================================================
;	"\?" COMMAND [ OPNA Rhythm Keyon/Dump ]
;==============================================================================
rhykey:
if	board2
	mov	dh,10h
	lodsb
	and	al,[rhythmmask]
	jz	rhst_ret
	mov	dl,al

	cmp	[fadeout_volume],0
	jz	rk_00
	push	dx
	mov	dl,[rhyvol]
	call	volset2rf
	pop	dx
rk_00:
	test	dl,dl
	js	rhyset

	mov	al,dl
	mov	bx,offset rdat
	push	dx
	mov	cx,6
	mov	dh,18h
rklp:	ror	al,1
	jnc	rk00
	mov	dl,[bx]
	call	opnset44
rk00:	inc	bx
	inc	dh
	loop	rklp
	pop	dx

rhyset:
	call	opnset44
	test	dl,dl
	jns	rhst_00
	mov	bx,offset rdump_bd
	call	rflag_inc
	not	dl
	and	[rshot_dat],dl
	jmp	rhst_ret2
rhst_00:
	mov	bx,offset rshot_bd
	call	rflag_inc
	or	[rshot_dat],dl
rhst_ret2:
	cmp	byte ptr [si],0ebh
	jnz	rhst_ret
	_rwait
rhst_ret:
	ret
rflag_inc:
	mov	al,dl
	mov	cx,6
ri_loop:
	ror	al,1
	jnc	ri_not
	inc	byte ptr [bx]
ri_not:	inc	bx
	loop	ri_loop
	ret

else
	inc	si
	ret
endif

;==============================================================================
;	"\v?n" COMMAND
;==============================================================================
rhyvs:
if	board2
	lodsb

	mov	cl,0c0h

	mov	dl,1fh
	and	dl,al
rs002:
	rol	al,1
	rol	al,1
	rol	al,1
	and	al,07h
	mov	bx,offset rdat-1
	mov	dh,al

	xor	ah,ah
	add	bx,ax

	mov	al,18h-1
	add	al,dh
	mov	dh,al
	mov	al,[bx]
	and	al,cl
	or	dl,al
	mov	[bx],dl
	jmp	opnset44

else
	inc	si
	ret
endif

rhyvs_sft:
if	board2
	lodsb
	mov	bx,offset rdat-1
	mov	dh,al

	xor	ah,ah
	add	bx,ax

	add	dh,18h-1
	mov	al,[bx]
	and	al,00011111b
	mov	dl,al
	lodsb
	add	al,dl
	cmp	al,32
	jc	rvss00
	test	al,80h
	jnz	rvss01

	mov	al,31
	jmp	rvss00
rvss01:	xor	al,al
rvss00:	and	al,00011111b
	mov	dl,al
	mov	al,[bx]
	and	al,11100000b
	or	dl,al
	mov	[bx],dl
	jmp	opnset44
else
	inc	si
	inc	si
	ret
endif

;==============================================================================
;	"\p?" COMMAND
;==============================================================================
rpnset:
if	board2

	lodsb
	mov	ah,al
	mov	cl,1fh
	and	ah,3
	ror	ah,1
	ror	ah,1
	mov	dl,ah
	jmp	rs002
else
	inc	si
	ret
endif

;==============================================================================
;	"\Vn" COMMAND
;==============================================================================
rmsvs:
if	board2
	lodsb

	mov	dl,al
	mov	al,[rhythm_voldown]
	test	al,al
	jz	volset2r
	neg	al
	mul	dl
	mov	dl,ah
volset2r:
	mov	[rhyvol],dl

volset2rf:
	mov	dh,11h
	mov	al,[fadeout_volume]
	test	al,al
	jz	vs2r_000
	neg	al
	mul	dl
	mov	dl,ah
vs2r_000:
	jmp	opnset44
else
	inc	si
	ret
endif

rmsvs_sft:
if	board2
	mov	dh,11h
	lodsb
	mov	dl,al
	mov	al,[rhyvol]
	add	al,dl
	cmp	al,64
	jc	rmss00
	test	al,80h
	jnz	rmss01
	mov	al,63
	jmp	rmss00
rmss01:	xor	al,al
rmss00:	mov	dl,al
	jmp	volset2r
else
	inc	si
	ret
endif

;==============================================================================
;	SHIFT[di] ���ڒ�����
;==============================================================================
oshift:
oshiftp:
	cmp	al,0fh	;�x��
	jz	osret
	mov	dl,shift[di]
	add	dl,shift_def[di]
	test	dl,dl
	jz	osret
	
	mov	bl,al
	and	bl,0fh
	and	al,0f0h
	ror	al,1
	ror	al,1
	ror	al,1
	ror	al,1
	mov	bh,al	;bh=OCT bl=ONKAI

	test	dl,80h
	jz	shiftplus
	;
	; - γ�� ���
	;
shiftminus:
	add	bl,dl
	jc	sfm2
sfm1:	dec	bh
	add	bl,12
	jnc	sfm1
sfm2:	mov	al,bh
	ror	al,1
	ror	al,1
	ror	al,1
	ror	al,1
	or	al,bl
	ret
	;
	; + γ�� ���
	;
shiftplus:
	add	bl,dl
spm1:	cmp	bl,0ch
	jc	spm2
	inc	bh
	sub	bl,12
	jmp	spm1
spm2:	mov	al,bh
	ror	al,1
	ror	al,1
	ror	al,1
	ror	al,1
	or	al,bl
osret:	ret

;==============================================================================
;	�e�l�@BLOCK,F-NUMBER SET
;		INPUTS	-- AL [KEY#,0-7F]
;==============================================================================
fnumset:
	mov	ah,al
	and	ah,0fh
	cmp	ah,0fh
	jz	fnrest	; �x���̏ꍇ
	mov	onkai[di],al

	;
	; BLOCK/FNUM CALICULATE
	;
	mov	ch,al
	ror	ch,1
	and	ch,38h	; ch=BLOCK

	mov	bl,al
	and	bl,0fh	; bl=ONKAI

	mov	bh,0
	add	bx,bx
	mov	ax,fnum_data[bx]
	;
	; BLOCK SET
	;
	or	ah,ch
	mov	fnum[di],ax
	ret
fnrest:	
	mov	onkai[di],-1
	test	lfoswi[di],11h
	jnz	fnr_ret
	mov	fnum[di],0	;����LFO���g�p
fnr_ret:
	ret
	;
	; PSG TUNE SET
	;
fnumsetp:
	mov	ah,al
	and	ah,0fh
	cmp	ah,0fh
	jz	fnrest	; ���� �� FNUM � 0 � ���
	mov	onkai[di],al

	mov	cl,al
	ror	cl,1
	ror	cl,1
	ror	cl,1
	ror	cl,1
	and	cl,0fh	;cl=oct

	mov	bl,al
	and	bl,0fh
	mov	bh,0	;bx=onkai

	add	bx,bx
	mov	ax,psg_tune_data[bx]

	shr	ax,cl
	jnc	pt_non_inc
	inc	ax
pt_non_inc:

	mov	fnum[di],ax

	ret

;==============================================================================
;	Set [ FNUM/BLOCK + DETUNE + LFO ]
;==============================================================================
otodasi:
	mov	ax,fnum[di]
	test	ax,ax
	jnz	od_00
	ret
od_00:
	cmp	slotmask[di],0
	jz	od_exit
	mov	cx,ax
	and	cx,3800h	; cx=BLOCK
	and	ah,7		; ax=FNUM

	;
	; Portament/LFO/Detune SET
	;
	add	ax,porta_num[di]
	add	ax,detune[di]

	mov	dh,[partb]
	cmp	dh,3		;Ch 3
	jnz	od_non_ch3
if	board2
	cmp	[fmsel],0
	jnz	od_non_ch3
else
	cmp	di,offset part_e
	jz	od_non_ch3
endif
	cmp	[ch3mode],3fh
	jnz	ch3_special

od_non_ch3:
	test	lfoswi[di],1
	jz	od_not_lfo1
	add	ax,lfodat[di]
od_not_lfo1:
	test	lfoswi[di],10h
	jz	od_not_lfo2
	add	ax,_lfodat[di]
od_not_lfo2:
	call	fm_block_calc

	;
	; SET BLOCK/FNUM TO OPN
	;	input CX:AX

	or	ax,cx	;AX=block/Fnum
	add	dh,0a4h-1
	mov	dl,ah
	pushf
	cli
	call	opnset
	sub	dh,4
	mov	dl,al
	call	opnset
	popf
od_exit:
	ret

;==============================================================================
;	ch3=���ʉ����[�h ���g�p����ꍇ�̉����ݒ�
;			input CX:block AX:fnum
;==============================================================================
ch3_special:
	push	si
	mov	si,cx		;si=block

	mov	bl,slotmask[di]	;bl=slot mask 4321xxxx
	mov	cl,lfoswi[di]	;cl=lfoswitch
	mov	bh,volmask[di]	;bh=lfo1 mask 4321xxxx
	test	bh,0fh
	jnz	c3s_00
	mov	bh,0f0h		;all
c3s_00:	mov	ch,_volmask[di]	;ch=lfo2 mask 4321xxxx
	test	ch,0fh
	jnz	ns_sl4
	mov	ch,0f0h		;all

;	slot	4
ns_sl4:	rol	bl,1
	jnc	ns_sl3
	push	ax
	add	ax,[slot_detune4]
	rol	bh,1
	jnc	ns_sl4b
	test	cl,1
	jz	ns_sl4b
	add	ax,lfodat[di]
ns_sl4b:
	rol	ch,1
	jnc	ns_sl4c
	test	cl,10h
	jz	ns_sl4c
	add	ax,_lfodat[di]
ns_sl4c:
	push	cx
	mov	cx,si
	call	fm_block_calc
	or	ax,cx
	pop	cx
	mov	dh,0a6h
	mov	dl,ah
	pushf
	cli
	call	opnset
	mov	dh,0a2h
	mov	dl,al
	call	opnset
	popf
	pop	ax

;	slot	3
ns_sl3:	rol	bl,1
	jnc	ns_sl2
	push	ax
	add	ax,[slot_detune3]
	rol	bh,1
	jnc	ns_sl3b
	test	cl,1
	jz	ns_sl3b
	add	ax,lfodat[di]
ns_sl3b:
	rol	ch,1
	jnc	ns_sl3c
	test	cl,10h
	jz	ns_sl3c
	add	ax,_lfodat[di]
ns_sl3c:
	push	cx
	mov	cx,si
	call	fm_block_calc
	or	ax,cx
	pop	cx
	mov	dh,0ach
	mov	dl,ah
	pushf
	cli
	call	opnset
	mov	dh,0a8h
	mov	dl,al
	call	opnset
	popf
	pop	ax

;	slot	2
ns_sl2:	rol	bl,1
	jnc	ns_sl1
	push	ax
	add	ax,[slot_detune2]
	rol	bh,1
	jnc	ns_sl2b
	test	cl,1
	jz	ns_sl2b
	add	ax,lfodat[di]
ns_sl2b:
	rol	ch,1
	jnc	ns_sl2c
	test	cl,10h
	jz	ns_sl2c
	add	ax,_lfodat[di]
ns_sl2c:
	push	cx
	mov	cx,si
	call	fm_block_calc
	or	ax,cx
	pop	cx
	mov	dh,0aeh
	mov	dl,ah
	pushf
	cli
	call	opnset
	mov	dh,0aah
	mov	dl,al
	call	opnset
	popf
	pop	ax

;	slot	1
ns_sl1:	rol	bl,1
	jnc	ns_exit
	add	ax,[slot_detune1]
	rol	bh,1
	jnc	ns_sl1b
	test	cl,1
	jz	ns_sl1b
	add	ax,lfodat[di]
ns_sl1b:
	rol	ch,1
	jnc	ns_sl1c
	test	cl,10h
	jz	ns_sl1c
	add	ax,_lfodat[di]
ns_sl1c:
	mov	cx,si
	call	fm_block_calc
	or	ax,cx
	mov	dh,0adh
	mov	dl,ah
	pushf
	cli
	call	opnset
	mov	dh,0a9h
	mov	dl,al
	call	opnset
	popf
ns_exit:
	pop	si
	ret

;==============================================================================
;	FM������detune�ŃI�N�^�[�u���ς�鎞�̏C��
;		input	CX:block / AX:fnum+detune
;		output	CX:block / AX:fnum
;==============================================================================
fm_block_calc:
	test	ax,ax
od0:	js	od1
	cmp	ax,26ah
	jc	od1
	;
	cmp	ax,26ah*2	;04d2h
	jc	od2
	;
	add	cx,0800h	;oct.up
	cmp	cx,4000h
	jz	od05
	sub	ax,26ah		;4d2h-26ah
	jmp	od0
od05:	; ӳ �ڲ�ޮ� ����Ų��
	mov	cx,3800h
	cmp	ax,800h
	jc	od_ret
	mov	ax,7ffh		;04d2h
od_ret:	ret
	;
od1:	
	sub	cx,0800h	;oct.down
	jc	od15
	add	ax,26ah		;4d2h-26ah
	jmp	od0
od15:	; ӳ �ڲ�ޮ� ����Ų��
	xor	cx,cx
	test	ax,ax
	js	od16
	cmp	ax,8	;4
	jnc	od2
od16:	mov	ax,8	;4
	;
od2:	ret

;==============================================================================
;	�o�r�f�@�����ݒ�
;==============================================================================
otodasip:
	mov	ax,fnum[di]
	test	ax,ax
	jnz	od_00p
	ret

od_00p:
	;
	; PSG Portament set
	;
	add	ax,porta_num[di]

	;
	; PSG Detune/LFO set
	;
	test	extendmode[di],1
	jnz	od_ext_detune

	sub	ax,detune[di]
	test	lfoswi[di],1
	jz	od_notlfo1
	sub	ax,lfodat[di]
od_notlfo1:
	test	lfoswi[di],10h
	jz	tonesetp
	sub	ax,_lfodat[di]
	jmp	tonesetp

od_ext_detune:	;�g��DETUNE(DETUNE)�̌v�Z
	push	ax
	mov	bx,detune[di]
	test	bx,bx
	jz	od_ext_lfo	;LFO��
	imul	bx
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	test	dx,dx
	js	extdet_minus
	inc	dx
	jmp	extdet_set
extdet_minus:
	dec	dx
extdet_set:
	pop	ax
	sub	ax,dx	; Detune�����炷
	push	ax

od_ext_lfo:	;�g��DETUNE(LFO)�̌v�Z
	xor	dx,dx
	test	lfoswi[di],11h
	jz	extlfo_set
	xor	dx,dx
	test	lfoswi[di],1
	jz	od_ext_notlfo1
	mov	dx,lfodat[di]
od_ext_notlfo1:
	test	lfoswi[di],10h
	jz	od_ext_notlfo2
	add	dx,_lfodat[di]
od_ext_notlfo2:
	test	dx,dx
	jz	extlfo_set
	imul	dx
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	test	dx,dx
	js	extlfo_minus
	inc	dx
	jmp	extlfo_set
extlfo_minus:
	dec	dx
extlfo_set:
	pop	ax
	sub	ax,dx	;LFO�����炷
	;
	; TONE SET
	;
tonesetp:
if	1			;�ˌ�mix�ł�0
	cmp	ax,1000h
	jc	tsp_01
	test	ax,ax
	js	tsp_00
	mov	ax,0fffh
	jmp	tsp_01
tsp_00:	xor	ax,ax
endif
tsp_01:	mov	dh,[partb]
	dec	dh
	add	dh,dh
	mov	dl,al
	pushf
	cli
	call	opnset44
	inc	dh
	mov	dl,ah
	call	opnset44
	popf
	ret

;==============================================================================
;	�e�l�@�u�n�k�t�l�d�@�r�d�s
;==============================================================================
;------------------------------------------------------------------------------
;	�X���b�g���̌v�Z & �o�� �}�N��
;			in.	dl	����TL�l
;				dh	Out���郌�W�X�^
;				al	���ʕϓ��l ���S=80h
;------------------------------------------------------------------------------
volset_slot	macro
local	vsl_noover1,vsl_noover2
	add	al,dl
	jnc	vsl_noover1
	mov	al,255
vsl_noover1:
	sub	al,80h
	jnc	vsl_noover2
	xor	al,al
vsl_noover2:
	mov	dl,al
	call	opnset
	endm

;------------------------------------------------------------------------------
;	�e�l���ʐݒ胁�C��
;------------------------------------------------------------------------------
volset:	
	mov	bl,slotmask[di]		;bl<- slotmask
	test	bl,bl
	jnz	vs_exec
	ret				;SlotMask��0�̎�
vs_exec:
	mov	al,volpush[di]
	test	al,al
	jz	vs_00a
	dec	al
	jmp	vs_00
vs_00a:	mov	al,volume[di]
vs_00:	mov	cl,al

	cmp	di,offset part_e
	jz	fmvs			;���ʉ��̏ꍇ��voldown/fadeout�e������

;------------------------------------------------------------------------------
;	����down�v�Z
;------------------------------------------------------------------------------
	mov	al,[fm_voldown]
	test	al,al
	jz	fm_fade_calc
	neg	al
	mul	cl
	mov	cl,ah

;------------------------------------------------------------------------------
;	Fadeout�v�Z
;------------------------------------------------------------------------------
fm_fade_calc:
	mov	al,[fadeout_volume]
	cmp	al,2
	jc	fmvs
	shr	al,1	;50%������Ώ[��
	neg	al
	mul	cl
	mov	cl,ah

;------------------------------------------------------------------------------
;	���ʂ�carrier�ɐݒ� & ����LFO����
;		input	cl to Volume[0-127]
;			bl to SlotMask
;------------------------------------------------------------------------------
fmvs:
	xor	bh,bh			;Vol Slot Mask
	mov	ch,bl			;ch=SlotMask Push

	push	si
	mov	si,offset vol_tbl

	mov	word ptr [si],8080h
	mov	word ptr 2[si],8080h

	not	cl			;cl=carrier�ɐݒ肷�鉹��+80H(add)
	and	bl,carrier[di]		;bl=����   ��ݒ肷��SLOT xxxx0000b
	or	bh,bl

	rol	bl,1
	jnc	fmvs_01
	mov	[si],cl
fmvs_01:inc	si

	rol	bl,1
	jnc	fmvs_02
	mov	[si],cl
fmvs_02:inc	si

	rol	bl,1
	jnc	fmvs_03
	mov	[si],cl
fmvs_03:inc	si

	rol	bl,1
	jnc	fmvs_04
	mov	[si],cl
fmvs_04:sub	si,3

	cmp	cl,255		;����0?
	jz	fmvs_no_lfo

	test	lfoswi[di],2
	jz	fmvs_not_vollfo1
	mov	bl,volmask[di]
	and	bl,ch			;bl=����LFO��ݒ肷��SLOT xxxx0000b
	or	bh,bl
	mov	ax,lfodat[di]		;ax=����LFO�ϓ��l(sub)
	call	fmlfo_sub

fmvs_not_vollfo1:

	test	lfoswi[di],20h
	jz	fmvs_no_lfo
	mov	bl,_volmask[di]
	and	bl,ch			;bh=����LFO��ݒ肷��SLOT xxxx0000b
	or	bh,bl
	mov	ax,_lfodat[di]		;ax=����LFO�ϓ��l(sub)
	call	fmlfo_sub

fmvs_no_lfo:
	mov	dh,4ch-1
	add	dh,[partb]		;dh=FM Port Address

	lodsb
	rol	bh,1
	jnc	fmvm_01
	mov	dl,slot4[di]
	volset_slot

fmvm_01:sub	dh,8
	lodsb
	rol	bh,1
	jnc	fmvm_02
	mov	dl,slot3[di]
	volset_slot

fmvm_02:add	dh,4
	lodsb
	rol	bh,1
	jnc	fmvm_03
	mov	dl,slot2[di]
	volset_slot

fmvm_03:rol	bh,1
	jnc	fmvm_04
	sub	dh,8
	lodsb
	mov	dl,slot1[di]
	volset_slot

fmvm_04:pop	si
	ret

vol_tbl	db	0,0,0,0

;------------------------------------------------------------------------------
;	����LFO�p�T�u
;------------------------------------------------------------------------------
fmlfo_sub:
	push	cx
	mov	cx,4
fmlfo_loop:
	rol	bl,1
	jnc	fml_exit
	test	al,al
	js	fmls_minus
	sub	[si],al
	jnc	fml_exit
	mov	byte ptr [si],0
	jmp	fml_exit
fmls_minus:
	sub	[si],al
	jc	fml_exit
	mov	byte ptr [si],0ffh
fml_exit:
	inc	si
	loop	fmlfo_loop
	pop	cx
	sub	si,4
	ret

;==============================================================================
;	�o�r�f�@�u�n�k�t�l�d�@�r�d�s
;==============================================================================
volsetp:
	cmp	envf[di],3
	jz	volsetp_ret
	cmp	envf[di],-1
	jnz	vsp_00
	cmp	eenv_count[di],0
	jnz	vsp_00
volsetp_ret:
	ret
vsp_00:
	mov	al,volpush[di]
	test	al,al
	jz	vsp_01a
	dec	al
	jmp	vsp_01
vsp_01a:mov	al,volume[di]
vsp_01:	mov	dl,al

;------------------------------------------------------------------------------
;	����down�v�Z
;------------------------------------------------------------------------------
	mov	al,[ssg_voldown]
	test	al,al
	jz	psg_fade_calc
	neg	al
	mul	dl
	mov	dl,ah

;------------------------------------------------------------------------------
;	Fadeout�v�Z
;------------------------------------------------------------------------------
psg_fade_calc:
	mov	al,[fadeout_volume]
	test	al,al
	jz	psg_env_calc
	neg	al
	mul	dl
	mov	dl,ah

;------------------------------------------------------------------------------
;	ENVELOPE �v�Z
;------------------------------------------------------------------------------
psg_env_calc:
	test	dl,dl	;����0?
	jz	pv_out

	cmp	envf[di],-1
	jnz	normal_pvset
	mov	al,dl	;�g���� ����=dl*(eenv_vol+1)/16
	mov	dl,eenv_volume[di]
	test	dl,dl
	jz	pv_min
	inc	dl
	mul	dl
	mov	dl,al
	shr	dl,1
	shr	dl,1
	shr	dl,1
	shr	dl,1
	jnc	pv1
	inc	dl
	jmp	pv1

normal_pvset:
	add	dl,penv[di]
	jns	pv0
pv_min:	xor	dl,dl
pv0:	jz	pv_out		;0�ɂȂ����特��LFO�͊|���Ȃ�
	cmp	dl,16
	jc	pv1
	mov	dl,15

;------------------------------------------------------------------------------
;	����LFO�v�Z
;------------------------------------------------------------------------------
pv1:	test	lfoswi[di],22h
	jz	pv_out

	xor	ax,ax
	test	lfoswi[di],2
	jz	pv_nolfo1
	mov	ax,lfodat[di]
pv_nolfo1:
	test	lfoswi[di],20h
	jz	pv_nolfo2
	add	ax,_lfodat[di]
pv_nolfo2:

	xor	dh,dh
	add	dx,ax
	jns	pv10
	xor	dl,dl
	jmp	pv_out
pv10:	cmp	dx,16
	jc	pv_out
	mov	dl,15

;------------------------------------------------------------------------------
;	�o��
;------------------------------------------------------------------------------
pv_out:
	mov	dh,[partb]
	add	dh,8-1
	jmp	opnset44

;==============================================================================
;	�e�l�@�j�d�x�n�m
;==============================================================================
keyon:
	cmp	onkai[di],-1
	jnz	ko1
keyon_ret:
	ret			; ���� � ķ
ko1:
	mov	dh,28h
	mov	dl,[partb]
	dec	dl
	xor	bh,bh
	mov	bl,dl
if	board2
	cmp	[fmsel],bh	;0
	jnz	ura_keyon
endif
	add	bx,offset omote_key1
	mov	al,[bx]
	or	al,slotmask[di]
	cmp	sdelay_c[di],0
	jz	no_sdm
	and	al,sdelay_m[di]
no_sdm:	mov	[bx],al
	or	dl,al
	jmp	opnset44
if	board2
ura_keyon:
	add	bx,offset ura_key1
	mov	al,[bx]
	or	al,slotmask[di]
	cmp	sdelay_c[di],0
	jz	no_sdm2
	and	al,sdelay_m[di]
no_sdm2:mov	[bx],al
	or	dl,al
	or	dl,00000100b	;Ura Port
	jmp	opnset44
endif

;==============================================================================
;	�o�r�f�@�j�d�x�n�m
;==============================================================================
keyonp:
	cmp	onkai[di],-1
	jnz	ko1p
	ret			; ���� � ķ
ko1p:
	pushf
	cli
	call	psgmsk		;AL=07h AH=Maskdata
	or	al,ah
	and	ah,psgpat[di]
	not	ah
	and	al,ah
	mov	dh,7
	mov	dl,al
	call	opnset44
	popf
	;
	; PSG ɲ�� ���ʽ� � ���
	;
	mov	dl,[psnoi]
	cmp	dl,[psnoi_last]
	jz	psnoi_ret	;�����Ȃ��`���Ȃ�
	test	[psgefcnum],80h
	jz	psnoi_ret	;PSG���ʉ��������͕ύX���Ȃ�
	mov	dh,6
	call	opnset44
	mov	[psnoi_last],dl
psnoi_ret:
	ret

;==============================================================================
;	�o�r�f07h�|�[�g��KEYON/OFF���� (07H��ǂ݁A�}�X�N����l���Z�o)
;		OUTPUT ... al <- 07h Read Data
;			   ah <- Mask Data
;==============================================================================
psgmsk:
	mov	cl,[partb]
	xor	al,al
	stc
	rcl	al,cl
	mov	ah,al
	shl	al,1
	shl	al,1
	shl	al,1
	or	ah,al

	jmp	get07

;==============================================================================
;	KEY OFF
;		don't Break AL
;==============================================================================
keyoff:
	cmp	onkai[di],-1
	jnz	kof1
	ret			; ���� � ķ
kof1:
	mov	dh,28h
	mov	dl,[partb]
	dec	dl
	xor	bh,bh
	mov	bl,dl
if	board2
	cmp	[fmsel],0
	jnz	ura_keyoff
endif
	add	bx,offset omote_key1
	mov	cl,slotmask[di]
	not	cl
	and	cl,[bx]
	mov	[bx],cl
	or	dl,cl
	jmp	opnset44

if	board2
ura_keyoff:
	add	bx,offset ura_key1
	mov	cl,slotmask[di]
	not	cl
	and	cl,[bx]
	mov	[bx],cl
	or	dl,cl
	or	dl,00000100b	;FM Ura Port
	jmp	opnset44
endif

keyoffp:
	cmp	onkai[di],-1
	jnz	kofp1
	ret			; ���� � ķ
kofp1:
	cmp	envf[di],-1
	jz	kofp1_ext
	mov	envf[di],2
	ret
kofp1_ext:
	mov	eenv_count[di],4
	ret

;==============================================================================
;	���F�̐ݒ�
;		INPUTS	-- [PARTB]			
;			-- dl [TONE_NUMBER]
;			-- di [PART_DATA_ADDRESS]
;==============================================================================
neiroset:
	call	toneadr_calc
	call	silence_fmpart
	jnc	neiroset_main

;	neiromask=0�̎� (TL��work�̂ݐݒ�)
	add	bx,4
	jmp	neiroset_tl

;==============================================================================
;	���F�ݒ胁�C��
;==============================================================================
;------------------------------------------------------------------------------
;	AL/FB��ݒ�
;------------------------------------------------------------------------------
neiroset_main:
	mov	dh,0b0h-1
	add	dh,[partb]
	mov	dl,24[bx]

	cmp	[af_check],0	;ALG/FB�͐ݒ肵�Ȃ�mode���H
	jz	no_af
	mov	dl,alg_fb[di]
no_af:
	cmp	[partb],3
	jnz	nss_notfm3
if	board2
	cmp	[fmsel],0
	jnz	nss_notfm3
else
	cmp	di,offset part_e
	jz	nss_notfm3
endif
	cmp	[af_check],0	;ALG/FB�͐ݒ肵�Ȃ�mode���H
	jz	set_fm3_alg_fb

	mov	dl,[fm3_alg_fb]
	jmp	nss_notfm3

set_fm3_alg_fb:
	test	slotmask[di],10h	;slot1���g�p���Ă��Ȃ����
	jnz	nss_notslot1
	mov	al,[fm3_alg_fb]
	and	al,00111000b		;fb�͑O�̒l���g�p
	and	dl,00000111b
	or	dl,al
nss_notslot1:
	mov	[fm3_alg_fb],dl
nss_notfm3:
	call	opnset
	mov	alg_fb[di],dl
	and	dl,7	;dl=algo

;------------------------------------------------------------------------------
;	Carrier�̈ʒu�𒲂ׂ� (VolMask�ɂ��ݒ�)
;------------------------------------------------------------------------------
check_carrier:
	push	bx
	xor	bh,bh
	mov	bl,dl
	add	bx,offset carrier_table
	mov	al,[bx]
	test	volmask[di],0fh
	jnz	not_set_volmask	; Volmask�l��0�ȊO�̏ꍇ�͐ݒ肵�Ȃ�
	mov	volmask[di],al
not_set_volmask:
	test	_volmask[di],0fh
	jnz	not_set_volmask2
	mov	_volmask[di],al
not_set_volmask2:
	mov	carrier[di],al
	mov	ah,[bx+8]	; slot2/3�̋t�]�f�[�^(not�ς�)
	pop	bx

	mov	al,neiromask[di]
	and	ah,al		;AH=TL�p��mask / AL=���̑��p��mask

;------------------------------------------------------------------------------
;	�e���F�p�����[�^��ݒ� (TL�̓��W�����[�^�̂�)
;------------------------------------------------------------------------------
	mov	dh,30h-1
	add	dh,[partb]

	mov	cx,4	;DT/ML
ns01:	mov	dl,[bx]
	inc	bx
	rol	al,1
	jnc	ns_ns
	call	opnset
ns_ns:	add	dh,4
	loop	ns01

	mov	cx,4	;TL
ns01b:	mov	dl,[bx]
	inc	bx
	rol	ah,1
	jnc	ns_nsb
	call	opnset
ns_nsb:	add	dh,4
	loop	ns01b

	mov	cx,16	;�c��
ns01c:	mov	dl,[bx]
	inc	bx
	rol	al,1
	jnc	ns_nsc
	call	opnset
ns_nsc:	add	dh,4
	loop	ns01c

;------------------------------------------------------------------------------
;	SLOT����TL�����[�N�ɕۑ�
;------------------------------------------------------------------------------
	sub	bx,20
neiroset_tl:
	push	si
	push	di
	mov	si,bx
	add	di,slot1
	movsw
	movsw
	pop	di
	pop	si
	ret

;==============================================================================
;	TONE DATA START ADDRESS ���v�Z
;		input	dl	tone_number
;		output	bx	address
;==============================================================================
toneadr_calc:
	cmp	[prg_flg],0
	jnz	prgdat_get
	cmp	di,offset part_e
	jz	prgdat_get
	mov	bx,[tondat]
	mov	al,dl
	xor	ah,ah
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	bx,ax
	ret
prgdat_get:
	mov	bx,[prgdat_adr]
	cmp	di,offset part_e
	jnz	gpd_loop
	mov	bx,[prgdat_adr2]	;FM���ʉ��̏ꍇ
gpd_loop:
	cmp	[bx],dl
	jz	gpd_exit
	add	bx,26
	jmp	gpd_loop
gpd_exit:
	inc	bx
	ret

;==============================================================================
;	[PartB]�̃p�[�g�̉��������ɏ��� (TL=127 and RR=15 and KEY-OFF)
;		cy=1 ��� �S�X���b�gneiromask����Ă���
;==============================================================================
silence_fmpart:
	mov	al,neiromask[di]
	test	al,al
	jz	sfm_exit
	push	dx
	mov	dh,[partb]
	add	dh,40h-1

	mov	cx,4
	mov	dl,127	; TL = 127 / RR=15
ns00c:	rol	al,1
	jnc	ns00d
	call	opnset
	add	dh,40h
	call	opnset
	sub	dh,40h
ns00d:	add	dh,4
	loop	ns00c

	push	bx
	call	kof1	; KEY OFF
	pop	bx
	pop	dx
	clc
	ret
sfm_exit:
	stc
	ret

;==============================================================================
;	�k�e�n����
;		Don't Break cl
;		output		cy=1	�ω���������
;==============================================================================
lfo:	
lfop:
	cmp	delay[di],0
	jz	lfo1
	dec	delay[di]	;cy=0
lfo_ret:
	ret
lfo1:
	test	extendmode[di],2	;TimerA�ƍ��킹�邩�H
	jz	lfo_normal		;��������Ȃ��Ȃ疳������lfo����
	mov	ch,[TimerAtime]
	sub	ch,[lastTimerAtime]
	jz	lfo_ret			;�O��̒l�Ɠ����Ȃ牽�����Ȃ� cy=0
	mov	ax,lfodat[di]
	push	ax
lfo_loop:
	call	lfo_main
	dec	ch
	jnz	lfo_loop
	jmp	lfo_check

lfo_normal:
	mov	ax,lfodat[di]
	push	ax
	call	lfo_main
lfo_check:
	pop	ax
	cmp	ax,lfodat[di]
	jnz	lfo_stc_ret
	ret	;c=0
lfo_stc_ret:
	stc
	ret

lfo_main:
	cmp	speed[di],1
	jz	lfo2
	cmp	speed[di],-1
	jz	lfom_ret
	dec	speed[di]
lfom_ret:
	ret
lfo2:
	mov	al,speed2[di]
	mov	speed[di],al
	
	mov	bl,lfo_wave[di]
	test	bl,bl
	jz	lfo_sankaku
	cmp	bl,4
	jz	lfo_sankaku
	cmp	bl,2
	jz	lfo_kukei
	cmp	bl,6
	jz	lfo_oneshot
	cmp	bl,5
	jnz	not_sankaku

;	�O�p�g		lfowave = 0,4,5
	mov	al,step[di]
	mov	ah,al
	or	ah,ah
	jns	lfo2ns
	neg	ah
lfo2ns:	imul	ah	;lfowave=5�̏ꍇ 1step = step�~�bstep�b
	jmp	lfo20

lfo_sankaku:
	mov	al,step[di]
	cbw
lfo20:	add	lfodat[di],ax
	jnz	lfo21
	call	md_inc
lfo21:
	mov	al,time[di]
	cmp	al,255
	jz	lfo3
	dec	al
	jnz	lfo3
	mov	al,time2[di]
	cmp	bl,4
	jz	lfo22
	add	al,al	;lfowave=0,5�̏ꍇ time�𔽓]���Q�{�ɂ���
lfo22:	mov	time[di],al
	mov	al,step[di]
	neg	al
	mov	step[di],al
	ret
lfo3:
	mov	time[di],al
	ret

not_sankaku:
	dec	bl
	jnz	not_nokogiri
;	�m�R�M���g	lfowave = 1,6
	mov	al,step[di]
	cbw
	add	lfodat[di],ax

	mov	al,time[di]
	cmp	al,-1
	jz	nk_lfo3
	dec	al
	jnz	nk_lfo3
	neg	lfodat[di]
	call	md_inc
	mov	al,time2[di]
	add	al,al
nk_lfo3:
	mov	time[di],al
	ret

lfo_oneshot:
;	�����V���b�g	lfowave = 6
	mov	al,time[di]
	test	al,al
	jz	lfoone_ret
	cmp	al,-1
	jz	lfoone_nodec
	dec	al
	mov	time[di],al
lfoone_nodec:
	mov	al,step[di]
	cbw
	add	lfodat[di],ax
lfoone_ret:
	ret

lfo_kukei:
;	��`�g		lfowave = 2
	mov	al,step[di]
	imul	time[di]
	mov	lfodat[di],ax
	call	md_inc
	neg	step[di]
	ret

not_nokogiri:
;	�����_���g	lfowave = 3
	mov	al,step[di]
	test	al,al
	jns	ns_plus
	neg	al
ns_plus:
	mul	time[di]
	push	ax
	push	cx
	add	ax,ax
	call	rnd
	pop	cx
	pop	bx
	sub	ax,bx
	mov	lfodat[di],ax

;==============================================================================
;	MD�R�}���h�̒l�ɂ����STEP�l��ύX
;==============================================================================
md_inc:
	dec	mdspd[di]
	jnz	md_exit
	mov	al,mdspd2[di]
	mov	mdspd[di],al

	mov	al,mdc[di]
	test	al,al
	jz	md_exit		;count =0
	js	mdi21		;count > 127 (255)
	dec	al
	mov	mdc[di],al

mdi21:	mov	al,step[di]
	test	al,al
	jns	mdi22
	neg	al
	add	al,mdepth[di]
	js	mdi21_ov
	neg	al
mdi21_s:
	mov	step[di],al
md_exit:
	ret

mdi21_ov:
	xor	al,al
	test	mdepth[di],80h
	jnz	mdi21_s
	mov	al,-127
	jmp	mdi21_s

mdi22:
	add	al,mdepth[di]
	js	mdi22_ov
mdi22_s:
	mov	step[di],al
	ret
mdi22_ov:
	xor	al,al
	test	mdepth[di],80h
	jnz	mdi22_s
	mov	al,+127
	jmp	mdi22_s

;==============================================================================
;	�����������[�`��	INPUT : AX=MAX_RANDOM
;				OUTPUT: AX=RANDOM_NUMBER
;==============================================================================
rnd:
	mov	cx,ax
	mov	ax,259
	mul	[seed]
	add	ax,3
	and	ax,32767

	mov	[seed],ax
	mul	cx
	mov	cx,32767
	div	cx
	ret
seed	dw	?

;==============================================================================
;	�k�e�n�Ƃo�r�f�^�o�b�l�̃\�t�g�E�G�A�G���x���[�v�̏�����
;==============================================================================
;==============================================================================
;	�o�r�f�^�o�b�l�����p�@Entry
;==============================================================================
lfoinitp:
	mov	ah,al	; ���� � ķ � INIT �Ų�
	and	ah,0fh
	cmp	ah,0ch
	jnz	lip_00
	mov	al,onkai_def[di]
	mov	ah,al
	and	ah,0fh
lip_00:	mov	onkai_def[di],al
	cmp	ah,0fh
	jz	lfo_exit
	mov	porta_num[di],0	;�|���^�����g�͏�����

	test	[tieflag],1	; ϴ �� & � ķ � INIT �Ų�
	jnz	lfo_exit

;==============================================================================
;	�\�t�g�E�G�A�G���x���[�v������
;==============================================================================
seinit:
	cmp	envf[di],-1
	jz	extenv_init
	mov	envf[di],0
	mov	penv[di],0
	mov	ah,patb[di]
	mov	pat[di],ah
	test	ah,ah
	jnz	lfin2
	mov	envf[di],1	;ATTACK=0 ... ��� Decay �
	mov	ah,pv2[di]	;
	mov	penv[di],ah	;
lfin2:	mov	ah,pr1b[di]
	mov	pr1[di],ah
	mov	ah,pr2b[di]
	mov	pr2[di],ah
	jmp	lfin1

;	�g��ssg_envelope�p
extenv_init:
	mov	ah,eenv_ar[di]
	sub	ah,16
	mov	eenv_arc[di],ah
	mov	ah,eenv_dr[di]
	sub	ah,16
	jns	eei_dr_notx
	add	ah,ah
eei_dr_notx:
	mov	eenv_drc[di],ah
	mov	ah,eenv_sr[di]
	sub	ah,16
	jns	eei_sr_notx
	add	ah,ah
eei_sr_notx:
	mov	eenv_src[di],ah
	mov	ah,eenv_rr[di]
	add	ah,ah
	sub	ah,16
	mov	eenv_rrc[di],ah

	mov	ah,eenv_al[di]
	mov	eenv_volume[di],ah

	mov	eenv_count[di],1
	push	ax
	call	ext_ssgenv_main	;�ŏ��̂P��
	pop	ax
	jmp	lfin1

;==============================================================================
;	�e�l�����p�@Entry
;==============================================================================
lfoinit:
	mov	ah,al	; ���� � ķ � INIT �Ų�
	and	ah,0fh
	cmp	ah,0ch
	jnz	li_00
	mov	al,onkai_def[di]
	mov	ah,al
	and	ah,0fh
li_00:	mov	onkai_def[di],al
	cmp	ah,0fh
	jz	lfo_exit
	mov	porta_num[di],0	;�|���^�����g�͏�����

	test	[tieflag],1	; ϴ �� & � ķ � INIT �Ų�
	jz	lfin1

lfo_exit:
	test	lfoswi[di],3	; LFO�g�p�����H
	jz	le_no_one_lfo1	; �O�� & �̏ꍇ -> 1�� LFO����
	push	ax
	call	lfo
	pop	ax
le_no_one_lfo1:
	test	lfoswi[di],30h	; LFO�g�p�����H
	jz	le_no_one_lfo2	; �O�� & �̏ꍇ -> 1�� LFO����
	push	ax
	pushf
	cli
	call	lfo_change
	call	lfo
	call	lfo_change
	popf
	pop	ax
le_no_one_lfo2:
	ret

;==============================================================================
;	�k�e�n������
;==============================================================================
lfin1:
if	board2
	mov	ah,hldelay[di]
	mov	hldelay_c[di],ah
	test	ah,ah
	jz	non_hldelay
	mov	dh,[partb]
	add	dh,0b4h-1
	mov	dl,fmpan[di]
	and	dl,0c0h		;HLFO = OFF
	call	opnset
non_hldelay:
endif
	mov	ah,sdelay[di]
	mov	sdelay_c[di],ah

	mov	cl,lfoswi[di]
	test	cl,3
	jz	li_lfo1_exit	; LFO�͖��g�p
	test	cl,4		;keyon�񓯊���?
	jnz	li_lfo1_next
	call	lfoinit_main
li_lfo1_next:
	push	ax
	call	lfo
	pop	ax
li_lfo1_exit:

	test	cl,30h
	jz	li_lfo2_exit	; LFO�͖��g�p
	test	cl,40h		;keyon�񓯊���?
	jnz	li_lfo2_next
	push	ax
	pushf
	cli
	call	lfo_change
	call	lfoinit_main
	call	lfo_change
	popf
	pop	ax

li_lfo2_next:
	push	ax
	pushf
	cli
	call	lfo_change
	call	lfo
	call	lfo_change
	popf
	pop	ax
li_lfo2_exit:
	ret

lfoinit_main:
	mov	lfodat[di],0

	mov	dx,word ptr delay2[di]
	mov	word ptr delay[di],dx
	mov	dx,word ptr step2[di]
	mov	word ptr step[di],dx
	mov	dl,mdc2[di]
	mov	mdc[di],dl

	cmp	lfo_wave[di],2	;��`�g�܂���
	jz	lim_first
	cmp	lfo_wave[di],3	;�����_���g�̏ꍇ��
	jnz	lim_nofirst
lim_first:
	mov	speed[di],1	;delay�����LFO���|����悤�ɂ���
	ret
lim_nofirst:
	inc	speed[di]	;����ȊO�̏ꍇ��delay�����speed�l�� +1
	ret

;==============================================================================
;	�o�r�f�^�o�b�l�̃\�t�g�E�G�A�G���x���[�v
;==============================================================================
soft_env:
	test	extendmode[di],4	;TimerA�ƍ��킹�邩�H
	jz	soft_env_main		;��������Ȃ��Ȃ疳������senv����
	mov	ch,[TimerAtime]
	sub	ch,[lastTimerAtime]
	jz	senv_ret		;�O��̒l�Ɠ����Ȃ牽�����Ȃ�	cy=0
	xor	cl,cl
senv_loop:
	call	soft_env_main
	jnc	sel00
	mov	cl,1
sel00:	dec	ch
	jnz	senv_loop
	ror	cl,1		;cy setting
senv_ret:
	ret

soft_env_main:
	cmp	envf[di],-1
	jz	ext_ssgenv_main

	mov	dl,penv[di]
	call	soft_env_sub
	cmp	dl,penv[di]
	jz	sem_ret	;cy=0
	stc
sem_ret:ret

soft_env_sub:
	cmp	envf[di],0
	jnz	se1
	;
	; Attack
	;
	dec	pat[di]
	jnz	se2
	mov	envf[di],1
	mov	al,pv2[di]
	mov	penv[di],al
	stc
	ret
se1:
	cmp	envf[di],2
	jz	se3
	;
	; Decay
	;
	cmp	pr1[di],0
	jz	se2		;�c�q���O�̎��͌������Ȃ�
	dec	pr1[di]
	jnz	se2
	mov	al,pr1b[di]
	mov	pr1[di],al
	dec	penv[di]

se4:	cmp	penv[di],-15
	jnc	se2
	cmp	penv[di],15
	jc	se2
se5:	mov	penv[di],-15
se2:	ret
	;
	; Release
	;
se3:	cmp	pr2[di],0
	jz	se5		;�q�q���O�̎��͂����ɉ�����
	dec	pr2[di]
	jnz	se2
	mov	al,pr2b[di]
	mov	pr2[di],al
	dec	penv[di]
	jmp	se4

;	�g����
ext_ssgenv_main:
	mov	ah,eenv_count[di]
	test	ah,ah
	jnz	esm_main2
esm_ret:ret	;cy=0

esm_main2:
	mov	dl,eenv_volume[di]
	call	esm_sub
	cmp	dl,eenv_volume[di]
	jz	esm_ret	;cy=0
	stc
	ret

esm_sub:
esm_ar_check:
	dec	ah
	jnz	esm_dr_check
;
;	[[[ Attack Rate ]]]
;
	mov	al,eenv_arc[di]
	dec	al
	js	arc_count_check	;0�ȉ��̏ꍇ�̓J�E���gCHECK
	inc	al
	add	eenv_volume[di],al
	cmp	eenv_volume[di],15
	jnc	esm_ar_next
	mov	ah,eenv_ar[di]
	sub	ah,16
	mov	eenv_arc[di],ah
	ret
esm_ar_next:
	mov	eenv_volume[di],15
	inc	eenv_count[di]
	cmp	eenv_sl[di],15	;SL=0�̏ꍇ�͂���SR��
	jnz	esm_ret
	inc	eenv_count[di]
	ret
arc_count_check:
	cmp	eenv_ar[di],0	;AR=0?
	jz	esm_ret
	inc	eenv_arc[di]
	ret

esm_dr_check:
	dec	ah
	jnz	esm_sr_check
;
;	[[[ Decay Rate ]]]
;
	mov	al,eenv_drc[di]
	dec	al
	js	drc_count_check	;0�ȉ��̏ꍇ�̓J�E���gCHECK
	inc	al
	sub	eenv_volume[di],al
	mov	al,eenv_sl[di]
	jc	dr_slset
	cmp	eenv_volume[di],al
	jc	dr_slset
	mov	ah,eenv_dr[di]
	sub	ah,16
	jns	esm_dr_notx
	add	ah,ah
esm_dr_notx:
	mov	eenv_drc[di],ah
	ret
dr_slset:
	mov	eenv_volume[di],al
	inc	eenv_count[di]
	ret
drc_count_check:
	cmp	eenv_dr[di],0	;DR=0?
	jz	esm_ret
	inc	eenv_drc[di]
	ret

esm_sr_check:
	dec	ah
	jnz	esm_rr
;
;	[[[ Sustain Rate ]]]
;
	mov	al,eenv_src[di]
	dec	al
	js	src_count_check	;0�ȉ��̏ꍇ�̓J�E���gCHECK
	inc	al
	sub	eenv_volume[di],al
	jnc	esm_sr_exit
	mov	eenv_volume[di],0
esm_sr_exit:
	mov	ah,eenv_sr[di]
	sub	ah,16
	jns	esm_sr_notx
	add	ah,ah
esm_sr_notx:
	mov	eenv_src[di],ah
	ret
src_count_check:
	cmp	eenv_sr[di],0	;SR=0?
	jz	esm_ret
	inc	eenv_src[di]
	ret

esm_rr:
;
;	[[[ Release Rate ]]]
;
	mov	al,eenv_rrc[di]
	dec	al
	js	rrc_count_check	;0�ȉ��̏ꍇ�̓J�E���gCHECK
	inc	al
	sub	eenv_volume[di],al
	jnc	esm_rr_exit
	mov	eenv_volume[di],0
esm_rr_exit:
	mov	ah,eenv_rr[di]
	add	ah,ah
	sub	ah,16
	mov	eenv_rrc[di],ah
	ret
rrc_count_check:
	cmp	eenv_rr[di],0	;RR=0?
	jz	esm_ret
	inc	eenv_rrc[di]
	ret

;==============================================================================
;	FADE IN / OUT ROUTINE
;
;		FROM Timer-A
;==============================================================================
fadeout:
	cmp	[pause_flag],1	;pause����fadeout���Ȃ�
	jz	fade_exit
	mov	al,[fadeout_speed]
	test	al,al
	jz	fade_exit
	js	fade_in
	add	al,[fadeout_volume]
	jc	fadeout_end
	mov	[fadeout_volume],al
	ret
fadeout_end:
	mov	[fadeout_volume],255
	mov	[fadeout_speed],0
	cmp	[fade_stop_flag],1
	jnz	fade_exit
	or	[music_flag],2
fade_exit:
	ret

fade_in:
	add	al,[fadeout_volume]
	jnc	fadein_end
	mov	[fadeout_volume],al
	ret
fadein_end:
	mov	[fadeout_volume],0
	mov	[fadeout_speed],0
if	board2
	mov	dl,[rhyvol]
	call	volset2rf
endif
	ret

;==============================================================================
;	�C���^���v�g�@�ݒ�
;	FM������p
;==============================================================================
setint:
	pushf
	cli	;���荞�݋֎~
	;
	; �n�o�m���荞�ݏ����ݒ�
	;
	mov	[tempo_d],200		; TIMER B SET
	mov	[tempo_d_push],200
	call	calc_tb_tempo
	call	settempo_b

	mov	dx,2500h
	call	opnset44
	mov	dx,2400h	; TIMER A SET (9216��s�Œ�)
	call	opnset44	; ��Ԓx���Ē��x����

	mov	dh,27h
	mov	dl,00111111b	; TIMER ENABLE
	call	opnset44

	popf

	;
	;�@���߃J�E���^���Z�b�g
	;
	xor	ax,ax
	mov	[opncount],al
	mov	[syousetu],ax
	mov	[syousetu_lng],96

	ret

;==============================================================================
;	ALL SILENCE
;==============================================================================
silence:
if	board2
	call	sel44		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v
	mov	ah,2
endif
oploop:
	cmp	[fm_effec_flag],1
	jnz	opi_nef
if	board2
	cmp	ah,1
	jnz	opi_nef
endif
	mov	bx,offset fmoff_ef
	jmp	opi_ef
opi_nef:
	mov	bx,offset fmoff_nef
opi_ef:
opi0:	mov	dh,[bx]
	inc	bx
	cmp	dh,-1
	jz	opi1b
	add	dh,80h
	mov	dl,0ffh		; FM Release = 15
	call	opnset
	jmp	opi0
opi1b:
if	board2
	push	ax
	call	sel46		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v
	pop	ax
	dec	ah
	jnz	oploop
endif
	
	mov	dx,2800h	; FM KEYOFF
	mov	cx,3
ife	board2
	cmp	[fm_effec_flag],1
	jnz	opi1
	dec	cx
endif
opi1:	call	opnset44
	inc	dl
	loop	opi1

if	board2
	mov	dx,2804h	; FM KEYOFF [URA]
	cmp	[fm_effec_flag],1
	mov	cx,3
	jnz	opi2
	dec	cx
opi2:	call	opnset44
	inc	dl
	loop	opi2
endif

	cmp	[effon],0
	jnz	psg_ef
	cmp	[ppsdrv_flag],0
	jz	opi_nonppsdrv
	xor	ah,ah
	int	ppsdrv		; ppsdrv keyoff

opi_nonppsdrv:
	mov	dx,07bfh	; PSG KEYOFF
	call	opnset44
	jmp	s_pcm
psg_ef:
	pushf
	cli
	call	get07
	mov	dl,al
	and	dl,00111111b
	or	dl,10011011b
	mov	dh,07h
	call	opnset44
	popf

s_pcm:
if	board2
	cmp	[pcmflag],0	; PCM���ʉ����������H
	jnz	pcm_ef

 if	adpcm
  ife	ademu
	cmp	[pcm_gs_flag],1
	jz	pcm_ef
	mov	dx,0102h	; PAN=0 / x8 bit mode
	call	opnset46
	mov	dx,0001h	; PCM RESET
	call	opnset46
  endif
 endif
	mov	dx,1080h	;TA/TB/EOS �� RESET
	call	opnset46
	mov	dx,1018h	;TIMERB/A/EOS�̂�bit�ω�����
	call	opnset46	;(NEC�����ł��ꉞ���s)

 if	pcm
	call	stop_86pcm
 endif
pcm_ef:
 if	ppz
	cmp	[ppz_call_seg],0
	jz	_not_ppz8

	mov	ah,12h
	int	ppz_vec		;FIFO���荞�ݒ�~

	mov	ax,0200h
ppz_off_loop:
	push	ax
	int	ppz_vec		;ppz keyoff
	pop	ax
	inc	al
	cmp	al,8
	jc	ppz_off_loop

_not_ppz8:
 endif
endif
	ret

fmoff_nef	db	0,1,2,4,5,6,8,9,10,12,13,14,-1
fmoff_ef	db	0,1,4,5,8,9,12,13,-1

;==============================================================================
;	SET DATA TO OPN
;		INPUTS ---- D,E
;==============================================================================
;
;	�\
;
opnset44:
	push	ax
	push	dx
	push	bx
	mov	bx,dx

	mov	dx,[fm1_port1]
	pushf
	cli
	rdychk
	mov	al,bh
	out	dx,al
	_waitP
	mov	dx,[fm1_port2]
	mov	al,bl
	out	dx,al
	popf

	pop	bx
	pop	dx
	pop	ax
	ret

if	board2
;
;	��
;
opnset46:
	push	ax
	push	bx
	push	dx
	mov	bx,dx

	mov	dx,[fm2_port1]
	pushf
	cli
	rdychk
	mov	al,bh
	out	dx,al
	_waitP
	mov	dx,[fm2_port2]
	mov	al,bl
	out	dx,al
	popf

	pop	dx
	pop	bx
	pop	ax
	ret
endif
;
;	�\�^��
;
opnset:	
	push	ax
	push	bx
	push	dx
	mov	bx,dx

	mov	dx,[fm_port1]
	pushf
	cli
	rdychk
	mov	al,bh
	out	dx,al
	_waitP
	mov	dx,[fm_port2]
	mov	al,bl
	out	dx,al
	popf

	pop	dx
	pop	bx
	pop	ax
	ret

;==============================================================================
;	READ PSG 07H Port
;		cli���Ă��痈�邱��
;==============================================================================
get07:	push	dx
	mov	dx,[fm1_port1]
	rdychk
	mov	al,7
	out	dx,al
	_waitP			;PSG Read Wait
	mov	dx,[fm1_port2]
	in	al,dx
	pop	dx
	ret

;==============================================================================
;	�h�m�s�U�O�g�̃��C��
;==============================================================================
int60_start:
	cld

	push	es
	push	bx
	push	cx
	push	si
	push	di

	mov	si,ds
	push	cs:[ds_push]
	mov	cs:[ds_push],si

	mov	si,cs
	mov	ds,si
	mov	es,si

	push	word ptr [ah_push]
	mov	[al_push],al
	mov	[ah_push],ah
	push	[dx_push]
	mov	[dx_push],dx

;	TimerA/B �ē�check
	mov	bl,ah
	xor	bh,bh
	mov	bl,reint_chk[bx]
	ror	bl,1
	jnc	non_chk_TimerB
	cmp	[TimerBflag],0
	jnz	reint_error
non_chk_TimerB:
	ror	bl,1
	jnc	non_chk_TimerA
	cmp	[TimerAflag],0
	jnz	reint_error
non_chk_TimerA:
	ror	bl,1
	jnc	non_chk_int60
	cmp	[int60flag],1
	jnz	reint_error
non_chk_int60:

	cmp	[disint],1
	jz	I60_not_sti
	sti
I60_not_sti:
	add	ah,ah
	mov	bl,ah
	mov	si,int60_jumptable[bx]
	call	si

	mov	dx,[dx_push]
	mov	ax,[ds_push]
	mov	ds,ax
	mov	al,cs:[al_push]
	mov	ah,cs:[ah_push]

	pop	cs:[dx_push]
	pop	word ptr cs:[ah_push]
	pop	cs:[ds_push]

	pop	di
	pop	si
	pop	cx
	pop	bx
	pop	es

	jmp	int60_exit

reint_error:
	cmp	[disint],1
	jz	Rei_not_sti
	sti
Rei_not_sti:

	mov	dx,[dx_push]
	mov	ax,[ds_push]
	mov	ds,ax
	mov	al,cs:[al_push]
	mov	ah,cs:[ah_push]

	pop	cs:[dx_push]
	pop	word ptr cs:[ah_push]
	pop	cs:[ds_push]

	pop	di
	pop	si
	pop	cx
	pop	bx
	pop	es

	jmp	int60_error

;	�ē�check�pcode / bit0=TimerBint 1=TimerAint 2=INT60
reint_chk	db	4,4,0,6,6,0,0,0,0,0,0,0,7,7,0,5
		db	0,0,0,0,0,0,0,0,7,0,5,5,7,0,7,0
		db	0,0

int60_jumptable	label	word
	dw	mstart_f	;0
	dw	mstop_f		;1
	dw	fout		;2
	dw	eff_on		;3
	dw	effoff		;4
	dw	get_ss		;5
	dw	get_musdat_adr	;6
	dw	get_tondat_adr	;7
	dw	get_fv		;8
	dw	drv_chk		;9
	dw	get_status	;A
	dw	get_efcdat_adr	;B
	dw	fm_effect_on	;C
	dw	fm_effect_off	;D
	dw	get_pcm_adr	;E
if	board2
	dw	pcm_effect	;F
else
	dw	nothing		;F
endif
	dw	get_workadr	;10
	dw	get_fmefc_num	;11
	dw	get_pcmefc_num	;12
	dw	set_fm_int	;13
	dw	set_efc_int	;14
	dw	get_psgefcnum	;15
	dw	get_joy		;16
	dw	get_ppsdrv_flag	;17
	dw	set_ppsdrv_flag	;18
	dw	set_fv		;19
	dw	pause_on	;1A
	dw	pause_off	;1B
	dw	ff_music	;1C
	dw	get_memo	;1D
	dw	part_mask	;1E
	dw	get_fm_int	;1F
	dw	get_efc_int	;20
	dw	get_mus_name	;21
	dw	get_size	;22
int60_max	equ	22h

get_ss:			;5
	call	getss
	mov	[al_push],al
	mov	[ah_push],ah
	ret

get_musdat_adr:		;6
	mov	ax,cs
	mov	[ds_push],ax
	mov	ax,[mmlbuf]
	dec	ax
	mov	[dx_push],ax
	ret

get_tondat_adr:		;7
	mov	ax,cs
	mov	[ds_push],ax
	mov	ax,[tondat]
	mov	[dx_push],ax
	ret

get_efcdat_adr:		;7
	mov	ax,cs
	mov	[ds_push],ax
	mov	ax,[efcdat]
	mov	[dx_push],ax
	ret

get_fv:			;8
	mov	al,[fadeout_volume]
	mov	[al_push],al
	ret

set_fv:			;19
	mov	[fadeout_volume],al
if	board2
	test	al,al
	jnz	set_fv_ret
	mov	dl,[rhyvol]
	call	volset2rf
set_fv_ret:
endif
	ret

drv_chk:
if	board2
 if	ppz
  if	ademu
	mov	[al_push],5
  else
	mov	[al_push],4
  endif
 else
  if	pcm
	mov	[al_push],2
  else
	mov	[al_push],1
  endif
 endif
else
	mov	[al_push],0
endif
	mov	ah,vers
	mov	al,verc
	mov	[ah_push],ah
	mov	[dx_push],ax
	ret

get_status:
	call	getst
	mov	[al_push],al
	mov	[ah_push],ah
	ret

get_pcm_adr:
	mov	ax,cs
	mov	[ds_push],ax
	mov	[dx_push],offset pcm_table
	ret

get_workadr:
	mov	ax,cs
	mov	[ds_push],ax
	mov	[dx_push],offset part_data_table
	ret

get_fmefc_num:
	mov	al,[fm_effec_num]
	mov	[al_push],al
	ret

get_pcmefc_num:
	mov	al,[pcm_effec_num]
	mov	[al_push],al
	ret

set_fm_int:
	mov	ax,[ds_push]
	mov	[fmint_seg],ax
	mov	bx,[dx_push]
	mov	[fmint_ofs],bx
	or	[intfook_flag],1
	or	[rescut_cant],80h	;�풓�����֎~�t���O���Z�b�g
	or	ax,bx
	jnz	sfi_ret
	and	[intfook_flag],0feh
	and	[rescut_cant],7fh
sfi_ret:
	ret

set_efc_int:
	mov	ax,[ds_push]
	mov	[efcint_seg],ax
	mov	bx,[dx_push]
	mov	[efcint_ofs],bx
	or	[intfook_flag],2
	or	[rescut_cant],40h	;�풓�����֎~�t���O���Z�b�g
	or	ax,bx
	jnz	sei_ret
	and	[intfook_flag],0fdh
	and	[rescut_cant],0bfh
sei_ret:
	ret

get_fm_int:
	mov	ax,[fmint_seg]
	mov	[ds_push],ax
	mov	ax,[fmint_ofs]
	mov	[dx_push],ax
	ret

get_efc_int:
	mov	ax,[efcint_seg]
	mov	[ds_push],ax
	mov	ax,[efcint_ofs]
	mov	[dx_push],ax
	ret

get_psgefcnum:
	mov	al,[psgefcnum]
	mov	[ah_push],al
	mov	al,[effon]
	mov	[al_push],al
	ret

get_ppsdrv_flag:
	mov	al,[ppsdrv_flag]
	mov	[al_push],al
	ret

set_ppsdrv_flag:
	mov	[ppsdrv_flag],0

	xor	ax,ax
	mov	es,ax
	les	bx,es:[ppsdrv*4]
	cmp	word ptr es:2[bx],"MP"
	jnz	spf_exit
	cmp	byte ptr es:4[bx],"P"
	jnz	spf_exit

	mov	al,[al_push]
	mov	[ppsdrv_flag],al
spf_exit:
	ret

get_mus_name:	;21h
	mov	ax,offset mus_filename
	mov	[dx_push],ax
	mov	[ds_push],cs
	ret

get_size:	;22h
	mov	al,[mmldat_lng]
	mov	[al_push],al
	mov	al,[voicedat_lng]
	mov	[ah_push],al
	mov	al,[effecdat_lng]
	mov	byte ptr [dx_push],al
	ret

;==============================================================================
;	Joystick Data Get
;==============================================================================
get_joy:
	pushf
	cli
	call	get07
	mov	dl,al
	and	dl,03fh
	or	dl,080h
	mov	dh,07
	call	opnset44	;mode set
	popf

	mov	dx,[fm1_port1]
	pushf
	cli
	rdychk
	mov	al,0fh
	out	dx,al
	_wait			;PSG Read Wait
	mov	dx,[fm1_port2]
	in	al,dx		;input now
	and	al,0fh
	or	al,80h
	out	dx,al		;joystick init (1)
	popf

	mov	dx,[fm1_port1]
	pushf
	cli
	rdychk
	mov	al,0eh
	out	dx,al
	_wait			;PSG Read Wait
	mov	dx,[fm1_port2]
	in	al,dx
	popf
	and	al,3fh		;joystick data (1)
	mov	[al_push],al

	mov	dx,[fm1_port1]
	pushf
	cli
	rdychk
	mov	al,0fh
	out	dx,al
	_wait			;PSG Read Wait
	mov	dx,[fm1_port2]
	in	al,dx		;input now
	and	al,0fh
	or	al,0c0h
	out	dx,al		;joystick init (2)
	popf

	mov	dx,[fm1_port1]
	pushf
	cli
	rdychk
	mov	al,0eh
	out	dx,al
	_wait			;PSG Read Wait
	mov	dx,[fm1_port2]
	in	al,dx
	popf
	and	al,3fh		;joystick data (2)

	mov	[ah_push],al

	ret

;==============================================================================
;	Pause on
;==============================================================================
pause_on:
	cmp	[play_flag],0
	jz	pauon_exit
	mov	[play_flag],0
	mov	[pause_flag],1
	call	silence
pauon_exit:
	ret

;==============================================================================
;	Pause off
;==============================================================================
pause_off:
	cmp	[play_flag],0
	jnz	pauoff_exit2
	cmp	[pause_flag],1
	jnz	pauoff_exit2

if	board2
	call	sel44		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v
endif
	mov	di,offset part1
	mov	dl,voicenum[di]
	mov	[partb],1
	call	neiro_reset
	mov	di,offset part2
	mov	dl,voicenum[di]
	mov	[partb],2
	call	neiro_reset
ife	board2
	cmp	[fm_effec_flag],1
	jz	pauoff_exit
endif
	mov	di,offset part3
	mov	dl,voicenum[di]
	mov	[partb],3
	call	neiro_reset
	mov	di,offset part3b
	mov	dl,voicenum[di]
	call	neiro_reset
	mov	di,offset part3c
	mov	dl,voicenum[di]
	call	neiro_reset
	mov	di,offset part3d
	mov	dl,voicenum[di]
	call	neiro_reset

if	board2
	call	sel46		;mmain�ɂ͔�΂Ȃ��󋵉��Ȃ̂ő��v

	mov	di,offset part4
	mov	[partb],1
	mov	dl,voicenum[di]
	call	neiro_reset

	mov	di,offset part5
	mov	[partb],2
	mov	dl,voicenum[di]
	call	neiro_reset

	cmp	[fm_effec_flag],1
	jz	pauoff_exit

	mov	di,offset part6
	mov	[partb],3
	mov	dl,voicenum[di]
	call	neiro_reset
endif

pauoff_exit:
	mov	[pause_flag],0
	mov	[play_flag],1
pauoff_exit2:
	ret

;==============================================================================
;	����������̎��o��
;==============================================================================
get_memo:
	mov	si,[mmlbuf]
	cmp	word ptr [si],1ah
	jnz	getmemo_errret	;���F���Ȃ�file=�����̃A�h���X�擾�s�\
	add	si,18h
	mov	si,[si]
	add	si,[mmlbuf]
	sub	si,4
	mov	bx,2[si]		;bh=0feh,bl=ver
	cmp	bl,40h			;Ver4.0 & 00H�̏ꍇ
	jz	getmemo_exec
	cmp	bh,0feh
	jnz	getmemo_errret		;Ver.4.1�ȍ~�� 0feh
	cmp	bl,41h
	jc	getmemo_errret		;MC version 4.1�ȑO��������Error
getmemo_exec:
	cmp	bl,42h			;Ver.4.2�ȍ~���H
	jc	getmemo_oldver41
	inc	al			;�Ȃ�al�� +1 (0FFH��#PPSFile)
getmemo_oldver41:
	cmp	bl,48h			;Ver.4.8�ȍ~���H
	jc	getmemo_oldver47
	inc	al			;�Ȃ�al�� +1 (0FEH��#PPZFile)
getmemo_oldver47:

	mov	si,[si]
	add	si,[mmlbuf]
	inc	al

getmemo_loop:
	mov	dx,[si]
	test	dx,dx
	jz	getmemo_errret
	inc	si
	inc	si
	dec	al
	jnz	getmemo_loop

getmemo_exit:
	add	dx,[mmlbuf]
	mov	[ds_push],cs
	mov	[dx_push],dx
	ret

getmemo_errret:
	mov	[ds_push],0
	mov	[dx_push],0
	ret

;==============================================================================
;	�Ȃ̓�����
;		input	DX <- ���ߔԍ�
;		output	AL <- return code	0:����I��
;						1:���̏��߂܂ŋȂ��Ȃ�
;						2:�Ȃ����t����Ă��Ȃ�
;==============================================================================
ff_music:
	push	dx
	mov	dx,[mask_adr]
	pushf
	cli
	in	al,dx
	or	al,[mask_data]
	out	dx,al			;FM���荞�݂��֎~
	popf
	pop	dx

	call	ff_music_main
	mov	[al_push],al

	mov	dx,[mask_adr]
	pushf
	cli
	in	al,dx
	and	al,[mask_data2]
	out	dx,al			;FM���荞�݂�����
	popf
	ret

ff_music_main:
	cmp	[status2],255
	jz	ffm_exit2

	mov	[skip_flag],1
	cmp	dx,[syousetu]
	jnbe	ffm_main

	mov	[skip_flag],2
	push	dx
	cmp	[effon],1
	jnz	ff_no_ssg_dr
	call	effend		;ssgdrums cut
ff_no_ssg_dr:
	call	data_init2
	call	play_init
	call	opn_init
	pop	dx

	test	dx,dx
	jnz	ffm_main
	call	silence
	jmp	ffm_exit0b

ffm_main:
	push	dx
	call	maskon_all
if	board2
	mov	dx,10ffh
	call	opnset44		;Rhythm������S��Dump
endif
	pop	dx

	mov	ah,[fadeout_volume]
	mov	al,[rhythmmask]
	mov	[fadeout_volume],255
	mov	[rhythmmask],0

	push	ax
	push	bp
	mov	bp,dx
ffm_loop:
	call	mmain
	call	syousetu_count
	cmp	[status2],255
	jz	ffm_exit1
	cmp	bp,[syousetu]
	jnbe	ffm_loop
	pop	bp
	pop	ax

	mov	[fadeout_volume],ah
	mov	[rhythmmask],al
if	board2
	test	ah,ah
	jnz	ffm_exit0
	mov	dl,[rhyvol]
	call	volset2rf
endif
ffm_exit0:
	call	maskoff_all
ffm_exit0b:
	mov	dl,[ff_tempo]
	dec	dl		;ff���1���Ȃ�tempo
	call	stb_ff
	xor	al,al
	jmp	ffm_exit
ffm_exit1:
	pop	bp
	pop	ax
	call	maskoff_all
	mov	al,1
	jmp	ffm_exit
ffm_exit2:
	mov	al,2
ffm_exit:
	mov	[skip_flag],0
	ret

;==============================================================================
;	�S�p�[�g�ꎞ�}�X�N
;==============================================================================
maskon_all:
	mov	si,offset part_table
	mov	cx,max_part1
	mov	di,offset part1
maskon_loop:
if	ppz
	lodsb
	cmp	al,-1
	jnz	monl_main
	add	si,6		;skip Rhythm & Effects(for PPZ parts)
monl_main:
else
	inc	si
endif
	lodsw			;ah=���� al=partb
	or	partmask[di],80h
	cmp	partmask[di],80h
	jnz	maskon_next	;���ɑ��Ń}�X�N����Ă�
	push	cx
	push	di
	push	si
	call	maskon_main	;1�p�[�g�}�X�N
	pop	si
	pop	di
	pop	cx
maskon_next:
	add	di,type qq
	loop	maskon_loop
	ret

;==============================================================================
;	�S�p�[�g�ꎞ�}�X�N����
;==============================================================================
maskoff_all:
	mov	si,offset part_table
	mov	cx,max_part1
	mov	di,offset part1
maskoff_loop:
if	ppz
	lodsb
	cmp	al,-1
	jnz	moffl_main
	add	si,6		;skip Rhythm & Effects(for PPZ parts)
moffl_main:
else
	inc	si
endif
	lodsw			;ah=���� al=partb
	and	partmask[di],7fh
	jnz	maskoff_next	;�܂����Ń}�X�N����Ă�
	push	cx
	push	di
	push	si
	call	maskoff_main	;1�p�[�g���A
	pop	si
	pop	di
	pop	cx
maskoff_next:
	add	di,type qq
	loop	maskoff_loop
	ret

;==============================================================================
;	�p�[�g�̃}�X�N & Keyoff
;==============================================================================
part_mask:
	mov	ah,al
	and	ah,7fh
if	ppz
	cmp	ah,16+8
else
	cmp	ah,16
endif
	jnc	pm_ret
	test	al,al
	js	part_on
	xor	bh,bh
	mov	bl,al
	add	bl,bl
	add	bl,al
	add	bx,offset part_table
	mov	dl,[bx]		;dl <- Part�ԍ�
	test	dl,dl
	js	rhythm_mask
	inc	bx
	mov	ax,[bx]		;AH=���� AL=partb

	xor	bh,bh
	mov	bl,dl
	add	bx,bx
	add	bx,offset part_data_table
	mov	di,[bx]
	mov	dl,partmask[di]
	or	partmask[di],1
	test	dl,dl
	jnz	pm_ret		;���Ƀ}�X�N����Ă���
	cmp	[play_flag],0
	jz	pm_ret		;�Ȃ��~�܂��Ă���

maskon_main:
	test	ah,ah
	jz	pm_fm1
	dec	ah
if	board2
	jz	pm_fm2
endif
	dec	ah
	jz	pm_ssg
	dec	ah
if	board2
	jz	pm_pcm
endif
	dec	ah
	jz	pm_drums
if	ppz
	dec	ah
	jz	pm_ppz
endif
pm_ret:
	ret
pm_fm1:
	pushf
	cli
	mov	[partb],al
if	board2
	call	sel44
endif
	call	silence_fmpart	;���������ɏ���
	popf
	ret

if	board2
pm_fm2:
	pushf
	cli
	mov	[partb],al
	call	sel46
	call	silence_fmpart	;���������ɏ���
	popf
	ret
endif

pm_drums:
	cmp	[psgefcnum],11
	jnc	pm_ssg_ret
	jmp	effend
pm_ssg:
	pushf
	cli
	mov	[partb],al
	call	psgmsk		;AL=07h AH=Maskdata
	mov	dh,7
	mov	dl,al
	or	dl,ah
	call	opnset44	;PSG keyoff
	popf
pm_ssg_ret:
	ret

if	board2
pm_pcm:
 if	adpcm
  if	ademu
	cmp	[adpcm_emulate],1
	jnz	pmpcm_noadpcm
	mov	ax,0207h
	call	ppz8_call	; PPZ8 ch7 ������~
pmpcm_noadpcm:
  else
	pushf
	cli
	mov	dx,0102h	; PAN=0 / x8 bit mode
	call	opnset46
	mov	dx,0001h	; PCM RESET
	call	opnset46
	popf
  endif
 endif
 if	pcm
	call	stop_86pcm
 endif
	ret
endif
if	ppz
pm_ppz:
if	ademu
	cmp	al,7
	jnz	pmppz_exec
	cmp	[adpcm_emulate],1
	jz	pmppz_noexec
pmppz_exec:
endif
	mov	ah,2
	call	ppz8_call	;ppz stop (al=partb)
pmppz_noexec:
	ret
endif

rhythm_mask:
	mov	[rhythmmask],00h	;Rhythm������Mask
if	board2
	mov	dx,10ffh
	call	opnset44		;Rhythm������S��Dump
endif
	ret

;==============================================================================
;	�p�[�g�̃}�X�N���� & FM�������F�ݒ�	in.AH=part�ԍ�
;==============================================================================
part_on:
	xor	bh,bh
	mov	bl,ah
	add	bl,bl
	add	bl,ah
	add	bx,offset part_table
	mov	dl,[bx]		;dl <- Part�ԍ�
	test	dl,dl
	js	rhythm_on
	inc	bx
	mov	ax,[bx]		;AH=���� AL=partb

	xor	bh,bh
	mov	bl,dl
	add	bx,bx
	add	bx,offset part_data_table
	mov	di,[bx]
	cmp	partmask[di],0
	jz	po_ret		;�}�X�N����ĂȂ�
	and	partmask[di],0feh
	jnz	po_ret		;���ʉ��ł܂��}�X�N����Ă���
	cmp	[play_flag],0
	jz	po_ret		;�Ȃ��~�܂��Ă���

maskoff_main:
	test	ah,ah
	jz	po_fm1	;FM�����̏ꍇ��
if	board2
	dec	ah
	jz	po_fm2	;���F�ݒ菈��
endif
po_ret:
	ret
po_fm1:
	mov	dl,voicenum[di]
	pushf
	cli
	mov	[partb],al
if	board2
	call	sel44
endif
	cmp	address[di],0
	jz	pof1_not_set
	call	neiro_reset
pof1_not_set:
	popf
	ret

if	board2
po_fm2:
	mov	dl,voicenum[di]
	pushf
	cli
	mov	[partb],al
	call	sel46
	cmp	address[di],0
	jz	pof2_not_set
	call	neiro_reset
pof2_not_set:
	popf
	ret
endif
rhythm_on:
	mov	[rhythmmask],0ffh	;Rhythm������Mask����
	ret

if	board2
 if	ppz
;			Part�ԍ�,Partb,�����ԍ�
part_table	db	00,1,0	;A
		db	01,2,0	;B
		db	02,3,0	;C
		db	03,1,1	;D
		db	04,2,1	;E
		db	05,3,1	;F
		db	06,1,2	;G
		db	07,2,2	;H
		db	08,3,2	;I
		db	09,1,3	;J
		db	10,3,4	;K
		db	11,3,0	;c2
		db	12,3,0	;c3
		db	13,3,0	;c4
		db	-1,0,-1	;Rhythm
		db	22,3,1	;Effect
		db	14,0,5	;PPZ1
		db	15,1,5	;PPZ2
		db	16,2,5	;PPZ3
		db	17,3,5	;PPZ4
		db	18,4,5	;PPZ5
		db	19,5,5	;PPZ6
		db	20,6,5	;PPZ7
		db	21,7,5	;PPZ8
 else
;			Part�ԍ�,Partb,�����ԍ�
part_table	db	00,1,0	;A
		db	01,2,0	;B
		db	02,3,0	;C
		db	03,1,1	;D
		db	04,2,1	;E
		db	05,3,1	;F
		db	06,1,2	;G
		db	07,2,2	;H
		db	08,3,2	;I
		db	09,1,3	;J
		db	10,3,4	;K
		db	11,3,0	;c2
		db	12,3,0	;c3
		db	13,3,0	;c4
		db	-1,0,-1	;Rhythm
		db	14,3,1	;Effect
 endif
else
;			Part�ԍ�,Partb,�����ԍ�
part_table	db	00,1,0	;A
		db	01,2,0	;B
		db	02,3,0	;C
		db	03,3,0	;c2
		db	04,3,0	;c3
		db	05,3,0	;c4
		db	06,1,2	;G
		db	07,2,2	;H
		db	08,3,2	;I
		db	09,1,3	;J
		db	10,3,4	;K
		db	03,3,0	;c2
		db	04,3,0	;c3
		db	05,3,0	;c4
		db	-1,0,-1	;Rhythm
		db	11,3,0	;Effect
endif

;==============================================================================
;	�{�[�h���Ȃ���
;==============================================================================
int60_start_not_board:

	cld

	push	es
	push	bx
	push	cx
	push	si
	push	di

	mov	bx,ds
	push	cs:[ds_push]
	mov	cs:[ds_push],bx

	mov	bx,cs
	mov	ds,bx
	mov	es,bx

	push	word ptr [ah_push]
	mov	[al_push],al
	mov	[ah_push],ah
	push	[dx_push]
	mov	[dx_push],dx

	add	ah,ah
	mov	bl,ah
	xor	bh,bh
	mov	si,n_int60_jumptable[bx]
	call	si

	mov	dx,[dx_push]
	mov	ax,[ds_push]
	mov	ds,ax
	mov	al,cs:[al_push]
	mov	ah,cs:[ah_push]

	pop	cs:[dx_push]
	pop	word ptr cs:[ah_push]
	pop	cs:[ds_push]

	pop	di
	pop	si
	pop	cx
	pop	bx
	pop	es

	jmp	int60_exit

n_int60_jumptable	label	word
	dw	nothing		;0
	dw	nothing		;1
	dw	nothing		;2
	dw	nothing		;3
	dw	nothing		;4
	dw	get_255		;5
	dw	get_musdat_adr	;6
	dw	get_tondat_adr	;7
	dw	get_255		;8
	dw	drv_chk2	;9
	dw	get_65535	;A
	dw	get_efcdat_adr	;B
	dw	nothing		;C
	dw	nothing		;D
	dw	get_pcm_adr	;E
	dw	nothing		;F
	dw	get_workadr	;10
	dw	get_255		;11
	dw	get_255		;12
	dw	nothing		;13
	dw	nothing		;14
	dw	get_65535	;15
	dw	get_65535	;16
	dw	get_255		;17
	dw	nothing		;18
	dw	nothing		;19
	dw	nothing		;1A
	dw	nothing		;1B
	dw	nothing		;1C
	dw	get_memo	;1D
	dw	nothing		;1E
	dw	get_fm_int	;1F
	dw	get_efc_int	;20
	dw	get_mus_name	;21
	dw	get_size	;22

get_255:
	mov	[al_push],255
nothing:
	ret
get_65535:
	mov	[ah_push],255
	jmp	get_255

drv_chk2:
	mov	ah,vers
	mov	al,verc
	mov	[ah_push],ah
	mov	[dx_push],ax
	jmp	get_255

;==============================================================================
;	�e�l���ʉ����[�`��
;==============================================================================

;==============================================================================
;	����
;		input	AL to number_of_data
;==============================================================================
fm_effect_on:
	pushf
	cli
	cmp	[fm_effec_flag],0
	jz	not_e_flag

	push	ax
	call	fm_effect_off
	pop	ax

not_e_flag:
	mov	[fm_effec_num],al
	mov	[fm_effec_flag],1	; ���ʉ��������Ă�

	mov	[partb],3
ife	board2
	mov	di,offset part3
	or	partmask[di],2		; Part Mask
	mov	di,offset part3b
	or	partmask[di],2		; Part Mask
	mov	di,offset part3c
	or	partmask[di],2		; Part Mask
	mov	di,offset part3d
	or	partmask[di],2		; Part Mask
else
	mov	di,offset part6
	or	partmask[di],2		; Part Mask
endif

	xor	bh,bh
	mov	bl,[fm_effec_num]	; bx = effect no.
	mov	di,offset part_e
	mov	cx,type qq
	xor	al,al
rep	stosb				; PartData ������

	add	bx,bx
	add	bx,[efcdat]
	mov	ax,[bx]
	add	ax,[efcdat]

	mov	di,offset part_e
	mov	address[di],ax		; �A�h���X�̃Z�b�g
	mov	leng[di],1		; ����1�J�E���g�ŉ��t�J�n
	mov	volume[di],108		; FM  VOLUME DEFAULT= 108
	mov	slotmask[di],0f0h	; FM  SLOTMASK
	mov	neiromask[di],0ffh	; FM  Neiro MASK
if	board2
	mov	dl,0c0h
	mov	fmpan[di],dl		; FM PAN = Middle
	mov	dh,0b6h
	call	sel46			;������mmain�����Ă�sel46�̂܂�
	call	opnset
else
	mov	al,[ch3mode]
	mov	[ch3mode_push],al
	mov	[ch3mode],3fh
endif

	popf
	ret

;==============================================================================
;	����
;==============================================================================
fm_effect_off:
	pushf
	cli

	cmp	[fm_effec_flag],0
	jz	feo_ret

	mov	[fm_effec_num],-1
	mov	[fm_effec_flag],0	; ���ʉ��~�߂Ă�

if	board2
	call	sel46			;������mmain�����Ă�sel46�̂܂�
endif
	mov	di,offset part_e
	mov	[partb],3
	call	silence_fmpart

	cmp	[play_flag],0
	jz	feo_ret		;�Ȃ��~�܂��Ă���

if	board2
	mov	di,offset part6
	mov	dl,voicenum[di]
	call	neiro_reset
else
	mov	di,offset part3
	mov	dl,voicenum[di]
	call	neiro_reset
	mov	di,offset part3b
	mov	dl,voicenum[di]
	call	neiro_reset
	mov	di,offset part3c
	mov	dl,voicenum[di]
	call	neiro_reset
	mov	di,offset part3d
	mov	dl,voicenum[di]
	call	neiro_reset

	mov	al,[ch3mode_push]
	mov	[ch3mode],al
	mov	dh,27h
	mov	dl,al
	and	dl,11001111b	;Reset�͂��Ȃ�
	call	opnset44
endif
feo_ret:
	popf
	ret

;==============================================================================
;	PPZ8 Interrupt Routine (FMint���荞�ݒ�)
;==============================================================================
if	ppz
;;ppzint:	push	ds
;;	push	ax
;;	push	dx
;;	mov	ax,cs
;;	mov	ds,ax
;;	call	eoi_send	;EOI�𑗂�
;;	call	dword ptr [ppz_call_ofs]
;;	pop	dx
;;	pop	ax
;;	pop	ds
;;	iret
endif

;==============================================================================
;	OPN Interrupt Routine
;==============================================================================
	even
if	vsync
	dw	0	;PMD86��PMD86V�Ŋ��荞�݃x�N�g�������炷
endif
opnint:	
	cli
	cld
if	ppz
;;	cmp	cs:[int5_flag],0
;;	jnz	ppzint
endif
	inc	cs:[int5_flag]
	push	ax
	mov	cs:[ss_push],ss
	mov	cs:[sp_push],sp
	mov	ax,cs
	mov	ss,ax
	mov	sp,offset _stack-2
	push	dx
	push	ds
	mov	ds,ax

;------------------------------------------------------------------------------
;	8259/INT5��mask
;------------------------------------------------------------------------------
if	ppz
;;	cmp	[ppz_call_seg],2
;;	jnc	mask_skip
endif
	mov	dx,[mask_adr]
	in	al,dx
	jmp	$+2
	or	al,[mask_data]
	out	dx,al
mask_skip:

if	vsync
	jmp	$+2
	jmp	$+2
	in	al,2
	push	ax
	or	al,4
	out	2,al	;VSync STOP
endif

	call	eoi_send	;EOI�𑗂�

;------------------------------------------------------------------------------
;	���荞�݂������Ă��邩�ǂ�����check & ���s
;------------------------------------------------------------------------------
INT_check:

if	pcm
;------------------------------------------------------------------------------
;	FIFO��check
;------------------------------------------------------------------------------
	mov	dx,0a468h
	in	al,dx
	test	al,010h		;FIFO���荞�݂��H
	jz	not_fifo
	call	fifo_main
	jmp	INT_check	;�ŏ�������Ȃ���
not_fifo:
endif

;------------------------------------------------------------------------------
;	PPZ8��check
;------------------------------------------------------------------------------
	_ppz

;------------------------------------------------------------------------------
;	TimerA/B��check
;------------------------------------------------------------------------------
	mov	dx,[fm1_port1]
	rdychk
	and	al,3
	jz	opnint_fin	;Timer���荞�݂����Ă��Ȃ�
	call	FM_Timer_main
	jmp	INT_check	;�ŏ�������Ȃ���

;------------------------------------------------------------------------------
;	OPN���荞�ݏI��
;------------------------------------------------------------------------------
opnint_fin:
	cmp	[maskpush],0
	jnz	int5_no_fook

;------------------------------------------------------------------------------
;	�풓�O�Ɏg�p���Ă���int5���[�`��������
;------------------------------------------------------------------------------
int5_fook:
	pushf
	call	dword ptr [int5ofs]
;------------------------------------------------------------------------------
;	Check Timer
;------------------------------------------------------------------------------
	mov	dx,[fm1_port1]
	rdychk
	and	al,3
	jnz	INT_check	;���Ȃ���
;------------------------------------------------------------------------------
;	Check FIFO
;------------------------------------------------------------------------------
if	pcm
	mov	dx,0a468h
	in	al,dx
	test	al,10h
	jnz	INT_check	;���Ȃ���
endif
int5_no_fook:
;------------------------------------------------------------------------------
;	���荞�݋֎~
;------------------------------------------------------------------------------
	cli

;------------------------------------------------------------------------------
;	8259/INT5 Mask����
;------------------------------------------------------------------------------
if	vsync
	in	al,2
	pop	dx
	or	dl,11111011b
	and	al,dl
	out	2,al	;VSync ���A
	jmp	$+2
endif
if	ppz
;;	cmp	[ppz_call_seg],2
;;	jnc	maskreset_skip
endif
	mov	dx,[mask_adr]
	in	al,dx
	jmp	$+2
	and	al,[mask_data2]
	out	dx,al
maskreset_skip:

;------------------------------------------------------------------------------
;	�����܂�
;------------------------------------------------------------------------------
	pop	ds
	pop	dx
	mov	ss,cs:[ss_push]
	mov	sp,cs:[sp_push]
	pop	ax
	dec	cs:[int5_flag]
	iret

;==============================================================================
;	EOI�𑗂�
;==============================================================================
eoi_send:
	mov	dx,[eoi_adr]
	mov	al,[eoi_data]
	out	dx,al		;(����EOI)FM������INT�̂�EOI

	cmp	dx,ms_cmd	;Master��������
	jz	eoi_1		;Slave��ISR�𒲂ׂȂ�
	mov	al,0bh
	mov	dx,sl_cmd
	out	dx,al
	jmp	$+2
	in	al,dx		;Slave��ISR��ǂ�
	test	al,al
	jnz	eoi_1		;Slave�ɃT�[�r�X���̊��荞�݂��c���Ă���
	mov	dx,ms_cmd
	mov	al,67h		;Master ��EOI
	out	dx,al
eoi_1:	ret

;==============================================================================
;	FM TimerA/B ���� Main
;		*Timer�����Ă��鎖���m�F���Ă�����ŗ��邱�ƁB
;		 push���Ă��郌�W�X�^�� ax/dx/ds �̂݁B
;==============================================================================
FM_Timer_main:
	push	cx
;------------------------------------------------------------------------------
;	Timer Reset
;	�����ɂe�l���荞�� Timer AorB �ǂ��炪��������ǂݎ��
;------------------------------------------------------------------------------
	mov	dx,[fm1_port1]
	rdychk
	mov	al,27h
	out	dx,al
	_wait
	mov	ah,[ch3mode]	;ah = 27h�ɏo�͂���l
	in	al,dx	;rdychk	;al = status
	xchg	ah,al		;ah = status / al=27h�ɏo�͂���l
	mov	dx,[fm1_port2]
	out	dx,al		;Timer Reset

	and	ah,3		;ah = TimerA/B flag

;------------------------------------------------------------------------------
;	���荞�݋���
;------------------------------------------------------------------------------
	cmp	[disint],1
	jz	not_sti
	sti
not_sti:

;------------------------------------------------------------------------------
;	�ǂ��炪�������ŏꍇ��������
;------------------------------------------------------------------------------
	push	bx
	push	si
	push	di
	push	es

	mov	bx,cs
	mov	es,bx

	dec	ah		;Timer A���H
	jz	TimerA_int	;Timer A�̕�������
	dec	ah		;Timer B���H
	jz	TimerB_int	;Timer B�̕�������

	call	TimerB_main	;����
TimerA_int:
	call	TimerA_main
	jmp	exit_Timer

TimerB_int:
	call	TimerB_main
exit_Timer:
	pop	es
	pop	di
	pop	si
	pop	bx
	pop	cx
	cli
	ret

;==============================================================================
;	TimerB�̏���[���C��]
;==============================================================================
TimerB_main:
if	sync
	ret
opnint_sub:
endif
	mov	[TimerBflag],1

	cmp	[music_flag],0
	jz	not_mstop

	test	[music_flag],1
	jz	not_mstart
	call	mstart
not_mstart:
	test	[music_flag],2
	jz	not_mstop
	call	mstop
not_mstop:

	cmp	[play_flag],0
	jz	not_play

	call	mmain
	call	settempo_b
	call	syousetu_count
	mov	al,[TimerAtime]
	mov	[lastTimerAtime],al
not_play:
	mov	[TimerBflag],0

	test	[intfook_flag],1
	jz	TimerB_nojump
	call	dword ptr [fmint_ofs]
TimerB_nojump:
	ret

;==============================================================================
;	TimerA�̏���[���C��]
;==============================================================================
TimerA_main:
	mov	[TimerAflag],1

	inc	[TimerAtime]

	mov	al,[TimerAtime]
	and	al,7
	jnz	not_fade
	call	fadeout		;Fadeout����
	call	rew		;Rew����

not_fade:
	cmp	[effon],0
	jz	not_psgeffec
	cmp	[ppsdrv_flag],0
	jz	ta_not_ppsdrv
	test	[psgefcnum],80h
	jnz	not_psgeffec	;ppsdrv�̕��Ŗ炵�Ă���
ta_not_ppsdrv:
	call	effplay		;SSG���ʉ�����

not_psgeffec:
	cmp	[fm_effec_flag],0
	jz	not_fmeffec
	call	fm_efcplay	;FM���ʉ�����
not_fmeffec:

	cmp	[key_check],0
	jz	vtc000
	cmp	[play_flag],0
	jz	vtc000

if	va
	in	al,8
	mov	ah,[esc_sp_key]
	test	ah,al
	jnz	vtc000
	in	al,9
	test	al,10000000b
	jnz	vtc000
else
	xor	ax,ax
	mov	es,ax
	mov	bx,052ah
	mov	al,[esc_sp_key]
	and	al,byte ptr es:0eh[bx]
	cmp	al,[esc_sp_key]
	jnz	vtc000
	test	byte ptr es:[bx],00000001b	;esc
	jz	vtc000
	mov	ax,cs
	mov	es,ax
endif
	or	[music_flag],2		;����TimerB��MSTOP
	mov	[fadeout_flag],0	;CTRL+ESC�Ŏ~�߂�=�O������
vtc000:
	mov	[TimerAflag],0

	test	[intfook_flag],2
	jz	TimerA_nojump
	call	dword ptr [efcint_ofs]
TimerA_nojump:
	ret

;==============================================================================
;	���߂̃J�E���g
;==============================================================================
syousetu_count:
	mov	al,[opncount]
	inc	al
	cmp	al,[syousetu_lng]
	jnz	sc_ret
	xor	al,al
	inc	[syousetu]
sc_ret:	mov	[opncount],al
	ret

;==============================================================================
;	�e���|�ݒ�
;==============================================================================
settempo_b:
	mov	ah,[grph_sp_key]
	call	check_grph
	jnc	stb_n
	mov	dl,[ff_tempo]
	jmp	stb_ff

stb_n:	mov	dl,[tempo_d]
stb_ff:	cmp	dl,[TimerB_speed]
	jz	stb_ret
	mov	[TimerB_speed],dl
	mov	dh,26h
	jmp	opnset44

stb_ret:
	ret

;==============================================================================
;	�����߂�����
;==============================================================================
rew:	mov	ah,[rew_sp_key]
	call	check_grph
	jnc	rew_ret

	mov	dx,[syousetu]
	mov	al,[syousetu_lng]
	shr	al,1
	shr	al,1
	cmp	[opncount],al
	jnc	ff_music_main
	test	dx,dx
	jz	ff_music_main
	dec	dx
	jmp	ff_music_main

rew_ret:
	ret

;==============================================================================
;	GRPH key check
;		in	AH	sp_key
;		out	CY	1�ŉ�����Ă���
;==============================================================================
check_grph:
	cmp	[key_check],0	;cy=0
	jnz	cgr_main
	ret

cgr_main:
if	va
	in	al,8
	test	ah,al		;cy=0
	jnz	cgr_ret
	test	al,00010000b	;cy=0
	jnz	cgr_ret
	stc
cgr_ret:
	ret
else
	mov	cx,es
	xor	bx,bx
	mov	es,bx
	mov	bx,052ah+0eh
	mov	al,ah
	and	al,byte ptr es:[bx]
	cmp	al,ah
	jnz	cgr_ret
	test	byte ptr es:[bx],00001000b	;grph
	jz	cgr_ret
	mov	es,cx
	stc
	ret
cgr_ret:
	mov	es,cx
	clc
	ret
endif

;==============================================================================
;	�ݶ� DATA
;==============================================================================
fnum_data	label	word

	dw	026ah	; C
	dw	028fh	; D-
	dw	02b6h	; D
	dw	02dfh	; E-
	dw	030bh	; E
	dw	0339h	; F
	dw	036ah	; G-
	dw	039eh	; G
	dw	03d5h	; A-
	dw	0410h	; A
	dw	044eh	; B-
	dw	048fh	; B

psg_tune_data	label	word

	dw	0ee8h	; C
	dw	0e12h	; D-
	dw	0d48h	; D
	dw	0c89h	; E-
	dw	0bd5h	; E
	dw	0b2bh	; F
	dw	0a8ah	; G-
	dw	09f3h	; G
	dw	0964h	; A-
	dw	08ddh	; A
	dw	085eh	; B-
	dw	07e6h	; B

;==============================================================================
;	�e�l���F�̃L�����A�̃e�[�u��
;==============================================================================
carrier_table	label	byte
	db	10000000b,10000000b,10000000b,10000000b
	db	10100000b,11100000b,11100000b,11110000b

	db	11101110b,11101110b,11101110b,11101110b
	db	11001100b,10001000b,10001000b,00000000b

;==============================================================================
;	���ʉ��f�[�^�@�h�m�b�k�t�c�d
;==============================================================================
efftbl		label	word
	include effect.inc
efftblend	label	word

;==============================================================================
;	WORK AREA
;==============================================================================
fm_port1	dw	?		;FM���� I/O port work (1)
fm_port2	dw	?		;FM���� I/O port work (2)
ds_push		dw	?		;INT60�p ds push
dx_push		dw	?		;INT60�p dx push
ah_push		db	?		;INT60�p ah push
al_push		db	?		;INT60�p al push
partb		db	?		;�������p�[�g�ԍ�
tieflag		db	?		;&�̃t���O
volpush_flag	db	?		;���̂P������down�p��flag
rhydmy		db	?		;R part �_�~�[���t�f�[�^
fmsel		db	?		;FM �\�������@flag
omote_key1	db	?		;FM keyondata�\1
omote_key2	db	?		;FM keyondata�\2
omote_key3	db	?		;FM keyondata�\3
ura_key1	db	?		;FM keyondata��1
ura_key2	db	?		;FM keyondata��2
ura_key3	db	?		;FM keyondata��3
loop_work	db	?		;Loop Work
ppsdrv_flag	db	?		;ppsdrv flag
prgdat_adr2	dw	?		;�ȃf�[�^�����F�f�[�^�擪�Ԓn(���ʉ��p)
pcmrepeat1	dw	?		;PCM�̃��s�[�g�A�h���X1
pcmrepeat2	dw	?		;PCM�̃��s�[�g�A�h���X2
pcmrelease	dw	?		;PCM��Release�J�n�A�h���X
lastTimerAtime	db	?		;��O�̊��荞�ݎ���TimerATime�l
music_flag	db	?		;B0:����MSTART 1:����MSTOP ��Flag
slotdetune_flag	db	?		;FM3 Slot Detune���g���Ă��邩
slot3_flag	db	?		;FM3 Slot�� �v���ʉ����[�h�t���O
eoi_adr		dw	?		;EOI��send����I/O�A�h���X
eoi_data	db	?		;EOI�p�̃f�[�^
mask_adr	dw	?		;Mask������I/O�A�h���X
mask_data	db	?		;Mask�p�̃f�[�^(Or��Mask)
mask_data2	db	?		;Mask�p�̃f�[�^(And��Mask����)
ss_push		dw	?		;FMint�� SS��push
sp_push		dw	?		;FMint�� SP��push
fm3_alg_fb	db	?		;FM3ch�̍Ō�ɒ�`�������F��alg/fb
af_check	db	?		;FM3ch��alg/fb��ݒ肷�邩���Ȃ���flag
ongen		db	?		;���� 0=����/2203 1=2608
lfo_switch	db	?		;�Ǐ�LFO�X�C�b�`

rhydat:					;�h�����X�p���Y���f�[�^
	;	PT  PAN/VOLUME	KEYON
	db	18h,11011111b,	00000001b	;�o�X
	db	19h,11011111b,	00000010b	;�X�l�A
	db	1ch,01011111b,	00010000b	;�^��[LOW]
	db	1ch,11011111b,	00010000b	;�^��[MID]
	db	1ch,10011111b,	00010000b	;�^��[HIGH]
	db	1dh,11010011b,	00100000b	;����
	db	19h,11011111b,	00000010b	;�N���b�v
	db	1bh,10011100b,	10001000b	;C�n�C�n�b�g
	db	1ah,10011101b,	00000100b	;O�n�C�n�b�g
	db	1ah,11011111b,	00000100b	;�V���o��
	db	1ah,01011110b,	00000100b	;RIDE�V���o��

	even
;	
open_work	label	byte
mmlbuf		dw	?		;Musicdata��address+1
tondat		dw	?		;Voicedata��address
efcdat		dw	?		;FM  Effecdata��address
fm1_port1	dw	?		;FM���� I/O port (�\1)
fm1_port2	dw	?		;FM���� I/O port (�\2)
fm2_port1	dw	?		;FM���� I/O port (��1)
fm2_port2	dw	?		;FM���� I/O port (��2)
fmint_ofs	dw	?		;FM���荞�݃t�b�N�A�h���X offset
fmint_seg	dw	?		;FM���荞�݃t�b�N�A�h���X address
efcint_ofs	dw	?		;���ʉ����荞�݃t�b�N�A�h���X offset
efcint_seg	dw	?		;���ʉ����荞�݃t�b�N�A�h���X address
prgdat_adr	dw	?		;�ȃf�[�^�����F�f�[�^�擪�Ԓn
radtbl		dw	?		;R part offset table �擪�Ԓn
rhyadr		dw	?		;R part ���t���Ԓn
rhythmmask	db	?		;Rhythm�����̃}�X�N x8c/10h��bit�ɑΉ�
board		db	?		;FM�����{�[�h����^�Ȃ�flag
key_check	db	?		;ESC/GRPH key Check flag
fm_voldown	db	?		;FM voldown ���l
ssg_voldown	db	?		;PSG voldown ���l
pcm_voldown	db	?		;PCM voldown ���l
rhythm_voldown	db	?		;RHYTHM voldown ���l
prg_flg		db	?		;�ȃf�[�^�ɉ��F���܂܂�Ă��邩flag
x68_flg		db	?		;OPM flag
status		db	?		;status1
status2		db	?		;status2
tempo_d		db	?		;tempo (TIMER-B)
fadeout_speed	db	?		;Fadeout���x
fadeout_volume	db	?		;Fadeout����
tempo_d_push	db	?		;tempo (TIMER-B) / �ۑ��p
syousetu_lng	db	?		;���߂̒���
opncount	db	?		;�ŒZ�����J�E���^
TimerAtime	db	?		;TimerA�J�E���^
effflag		db	?		;PSG���ʉ�����on/off flag
psnoi		db	?		;PSG noise���g��
psnoi_last	db	?		;PSG noise���g��(�Ō�ɒ�`�������l)
fm_effec_num	db	?		;��������FM���ʉ��ԍ�
fm_effec_flag	db	?		;FM���ʉ�������flag (1)
disint		db	?		;FM���荞�ݒ��Ɋ��荞�݂��֎~���邩flag
pcmflag		db	?		;PCM���ʉ�������flag
pcmstart	dw	?		;PCM���F��start�l
pcmstop		dw	?		;PCM���F��stop�l
pcm_effec_num	db	?		;��������PCM���ʉ��ԍ�
_pcmstart	dw	?		;PCM���ʉ���start�l
_pcmstop	dw	?		;PCM���ʉ���stop�l
_voice_delta_n	dw	?		;PCM���ʉ���delta_n�l
_pcmpan		db	?		;PCM���ʉ���pan
_pcm_volume	db	?		;PCM���ʉ���volume
rshot_dat	db	?		;���Y������ shot flag
rdat		db	6 dup (?)	;���Y������ ����/�p���f�[�^
rhyvol		db	00111100b	;���Y���g�[�^�����x��
kshot_dat	dw	?		;�r�r�f���Y�� shot flag
ssgefcdat	dw	efftbl		;PSG Effecdata��address
ssgefclen	dw	efftblend-efftbl;PSG Effecdata�̒���
play_flag	db	?		;play flag
pause_flag	db	?		;pause flag
fade_stop_flag	db	0		;Fadeout�� MSTOP���邩�ǂ����̃t���O
kp_rhythm_flag	db	?		;K/Rpart��Rhythm������炷��flag
TimerBflag	db	0		;TimerB���荞�ݒ��H�t���O
TimerAflag	db	0		;TimerA���荞�ݒ��H�t���O
int60flag	db	0		;INT60H���荞�ݒ��H�t���O
int60_result	db	0		;INT60H�̎��sErrorFlag
pcm_gs_flag	db	?		;ADPCM�g�p ���t���O (0�ŋ���)
esc_sp_key	db	?		;ESC +?? Key Code
grph_sp_key	db	?		;GRPH+?? Key Code
rescut_cant	db	?		;�풓�����֎~�t���O
slot_detune1	dw	?		;FM3 Slot Detune�l slot1
slot_detune2	dw	?		;FM3 Slot Detune�l slot2
slot_detune3	dw	?		;FM3 Slot Detune�l slot3
slot_detune4	dw	?		;FM3 Slot Detune�l slot4
wait_clock	dw	?		;FM ADDRESS-DATA�� Loop $�̉�
wait1_clock	dw	?		;loop $ �P�̑��x
ff_tempo	db	?		;�����莞��TimerB�l
pcm_access	db	0		;PCM�Z�b�g���� 1
TimerB_speed	db	?		;TimerB�̌��ݒl(=ff_tempo�Ȃ�ff��)
fadeout_flag	db	?		;��������fout���Ăяo������1
adpcm_wait	db	?		;ADPCM��`�̑��x
revpan		db	?		;PCM86�t��flag
pcm86_vol	db	?		;PCM86�̉��ʂ�SPB�ɍ��킹�邩?
syousetu	dw	?		;���߃J�E���^
int5_flag	db	0		;FM�������荞�ݒ��H�t���O
port22h		db	0		;OPN-PORT 22H �ɍŌ�ɏo�͂����l(hlfo)
tempo_48	db	?		;���݂̃e���|(clock=48 t�̒l)
tempo_48_push	db	?		;���݂̃e���|(����/�ۑ��p)
rew_sp_key	db	?		;GRPH+?? (rew) Key Code
intfook_flag	db	?		;int_fook��flag B0:TB B1:TA
skip_flag	db	?		;normal:0 �O��SKIP��:1 ���SKIP��:2
_fm_voldown	db	?		;FM voldown ���l (�ۑ��p)
_ssg_voldown	db	?		;PSG voldown ���l (�ۑ��p)
_pcm_voldown	db	?		;PCM voldown ���l (�ۑ��p)
_rhythm_voldown	db	?		;RHYTHM voldown ���l (�ۑ��p)
_pcm86_vol	db	?		;PCM86�̉��ʂ�SPB�ɍ��킹�邩? (�ۑ��p)
mstart_flag	db	0		;mstart���鎞�ɂP�ɂ��邾����flag
mus_filename	db	13 dup(0)	;�Ȃ�FILE���o�b�t�@
mmldat_lng	db	?		;�ȃf�[�^�o�b�t�@�T�C�Y(KB)
voicedat_lng	db	?		;���F�f�[�^�o�b�t�@�T�C�Y(KB)
effecdat_lng	db	?		;���ʉ��f�[�^�o�b�t�@�T�C�Y(KB)
rshot_bd	db	?		;���Y������ shot inc flag (BD)
rshot_sd	db	?		;���Y������ shot inc flag (SD)
rshot_sym	db	?		;���Y������ shot inc flag (CYM)
rshot_hh	db	?		;���Y������ shot inc flag (HH)
rshot_tom	db	?		;���Y������ shot inc flag (TOM)
rshot_rim	db	?		;���Y������ shot inc flag (RIM)
rdump_bd	db	?		;���Y������ dump inc flag (BD)
rdump_sd	db	?		;���Y������ dump inc flag (SD)
rdump_sym	db	?		;���Y������ dump inc flag (CYM)
rdump_hh	db	?		;���Y������ dump inc flag (HH)
rdump_tom	db	?		;���Y������ dump inc flag (TOM)
rdump_rim	db	?		;���Y������ dump inc flag (RIM)
ch3mode		db	?		;ch3 Mode
ch3mode_push	db	?		;ch3 Mode(���ʉ��������ppush�̈�)
ppz_voldown	db	?		;PPZ8 voldown ���l
_ppz_voldown	db	?		;PPZ8 voldown ���l (�ۑ��p)
ppz_call_ofs	dw	?		;PPZ8call�p far call address
ppz_call_seg	dw	?		;seg�l��PPZ8�풓check�����˂�,0�Ŕ�풓
p86_freq	db	8		;PMD86��PCM�Đ����g��
if	pcm*board2
p86_freqtable	dw	offset pcm_tune_data
else
p86_freqtable	dw	0		;PMD86��PCM�Đ����g��table�ʒu
endif
adpcm_emulate	db	0		;PMDPPZE��ADPCM�G�~�����[�g����

;	���t���̃f�[�^�G���A

qq	struc
address		dw	?	; 2 �ݿ���� � ���ڽ
partloop	dw	?       ; 2 �ݿ� �� �ܯ�ķ � ���ػ�
leng		db	?       ; 1 ɺ� LENGTH
qdat		db	?       ; 1 gatetime (q/Q�l���v�Z�����l)
fnum		dw	?       ; 2 �ݿ���� � BLOCK/FNUM
detune		dw	?       ; 2 ������
lfodat		dw	?       ; 2 LFO DATA
porta_num	dw	?	; 2 �|���^�����g�̉����l�i�S�́j
porta_num2	dw	?	; 2 �|���^�����g�̉����l�i���j
porta_num3	dw	?	; 2 �|���^�����g�̉����l�i�]��j
volume		db	?       ; 1 VOLUME
shift		db	?       ; 1 �ݶ� ��� � ���
delay		db	?       ; 1 LFO	[DELAY] 
speed		db	?       ; 1	[SPEED]
step		db	?       ; 1	[STEP]
time		db	?       ; 1	[TIME]
delay2		db	?       ; 1	[DELAY_2]
speed2		db	?       ; 1	[SPEED_2]
step2		db	?       ; 1	[STEP_2]
time2		db	?       ; 1	[TIME_2]
lfoswi		db	?       ; 1 LFOSW. B0/tone B1/vol B2/���� B3/porta
				;          B4/tone B5/vol B6/����
volpush		db	? 	; 1 Volume PUSHarea
mdepth		db	?	; 1 M depth
mdspd		db	?	; 1 M speed
mdspd2		db	?	; 1 M speed_2
envf		db	?       ; 1 PSG ENV. [START_FLAG] / -1��extend
eenv_count	db	?	; 1 ExtendPSGenv/No=0 AR=1 DR=2 SR=3 RR=4
eenv_ar		db	?	; 1 		/AR		/��pat
eenv_dr		db	?	; 1		/DR		/��pv2
eenv_sr		db	?	; 1		/SR		/��pr1
eenv_rr		db	?	; 1		/RR		/��pr2
eenv_sl		db	?	; 1		/SL
eenv_al		db	?	; 1		/AL
eenv_arc	db	?	; 1		/AR�̃J�E���^	/��patb
eenv_drc	db	?	; 1		/DR�̃J�E���^
eenv_src	db	?	; 1		/SR�̃J�E���^	/��pr1b
eenv_rrc	db	?	; 1		/RR�̃J�E���^	/��pr2b
eenv_volume	db	?	; 1		/Volume�l(0�`15)/��penv
extendmode	db	?	; 1 B1/Detune B2/LFO B3/Env Normal/Extend
fmpan		db	? 	; 1 FM Panning + AMD + PMD
psgpat		db	?       ; 1 PSG PATTERN [TONE/NOISE/MIX]
voicenum	db	?	; 1 ���F�ԍ�
loopcheck	db	?	; 1 ���[�v������P �I��������R
carrier		db	?	; 1 FM Carrier
slot1		db	?       ; 1 SLOT 1 � TL
slot3		db	?       ; 1 SLOT 3 � TL
slot2		db	?       ; 1 SLOT 2 � TL
slot4		db	?       ; 1 SLOT 4 � TL
slotmask	db	?	; 1 FM slotmask
neiromask	db	?	; 1 FM ���F��`�pmaskdata
lfo_wave	db	?	; 1 LFO�̔g�`
partmask	db	?	; 1 PartMask b0:�ʏ� b1:���ʉ� b2:NECPCM�p
				;   b3:none b4:PPZ/ADE�p b5:s0�� b6:m b7:�ꎞ
keyoff_flag	db	?	; 1 Keyoff�������ǂ�����Flag
volmask		db	?	; 1 ����LFO�̃}�X�N
qdata		db	?	; 1 q�̒l
qdatb		db	?	; 1 Q�̒l
hldelay		db	?	; 1 HardLFO delay
hldelay_c	db	?	; 1 HardLFO delay Counter
_lfodat		dw	?       ; 2 LFO DATA
_delay		db	?       ; 1 LFO	[DELAY] 
_speed		db	?       ; 1	[SPEED]
_step		db	?       ; 1	[STEP]
_time		db	?       ; 1	[TIME]
_delay2		db	?       ; 1	[DELAY_2]
_speed2		db	?       ; 1	[SPEED_2]
_step2		db	?       ; 1	[STEP_2]
_time2		db	?       ; 1	[TIME_2]
_mdepth		db	?	; 1 M depth
_mdspd		db	?	; 1 M speed
_mdspd2		db	?	; 1 M speed_2
_lfo_wave	db	?	; 1 LFO�̔g�`
_volmask	db	?	; 1 ����LFO�̃}�X�N
mdc		db	?	; 1 M depth Counter (�ϓ��l)
mdc2		db	?	; 1 M depth Counter
_mdc		db	?	; 1 M depth Counter (�ϓ��l)
_mdc2		db	?	; 1 M depth Counter
onkai		db	?	; 1 ���t���̉��K�f�[�^ (0ffh:rest)
sdelay		db	?	; 1 Slot delay
sdelay_c	db	?	; 1 Slot delay counter
sdelay_m	db	?	; 1 Slot delay Mask
alg_fb		db	?	; 1 ���F��alg/fb
keyon_flag	db	?	; 1 �V���K/�x���f�[�^������������inc
qdat2		db	?	; 1 q �Œ�ۏؒl
fnum2		dw	?	; 2 ppz8/pmd86�pfnum�l���
onkai_def	db	?	; 1 ���t���̉��K�f�[�^ (�]�������O / ?fh:rest)
shift_def	db	?	; 1 �}�X�^�[�]���l
qdat3		db	?	; 1 q Random
		db	?	; dummy
qq	ends

qqq	struc
		db	offset eenv_ar dup(?)
pat		db	?	; 1 ��SSGENV	/Normal pat
pv2		db	?	; 1		/Normal pv2
pr1		db	?	; 1		/Normal pr1
pr2		db	?	; 1		/Normal pr2
		db	?
		db	?
patb		db	?	; 1		/Normal patb
		db	?
pr1b		db	?	; 1		/Normal pr1b
pr2b		db	?	; 1		/Normal pr2b
penv		db	?	; 1		/Normal penv
qqq	ends

if	board2
 if	ppz
max_part1	equ	14+8	;�O�N���A���ׂ��p�[�g��
max_part2	equ	11	;���������ׂ��p�[�g��
 else
max_part1	equ	14	;�O�N���A���ׂ��p�[�g��
max_part2	equ	11	;���������ׂ��p�[�g��
 endif
else
max_part1	equ	11
max_part2	equ	11
endif
fm		equ	0
fm2		equ	1
psg		equ	2
rhythm		equ	3

	even

	dw	open_work
part_data_table:
	dw	part1
	dw	part2
	dw	part3
if	board2
	dw	part4
	dw	part5
	dw	part6
else
	dw	part3b
	dw	part3c
	dw	part3d
endif
	dw	part7
	dw	part8
	dw	part9
	dw	part10
	dw	part11
if	board2
	dw	part3b
	dw	part3c
	dw	part3d
endif
if	ppz
	dw	part10a
	dw	part10b
	dw	part10c
	dw	part10d
	dw	part10e
	dw	part10f
	dw	part10g
	dw	part10h
endif
	dw	part_e

part1	db	type qq dup( ? )
part2	db	type qq dup( ? )
part3	db	type qq dup( ? )
if	board2
part4	db	type qq dup( ? )
part5	db	type qq dup( ? )
part6	db	type qq dup( ? )
else
part3b	db	type qq dup( ? )
part3c	db	type qq dup( ? )
part3d	db	type qq dup( ? )
endif
part7	db	type qq dup( ? )
part8	db	type qq dup( ? )
part9	db	type qq dup( ? )
part10	db	type qq dup( ? )
part11	db	type qq dup( ? )
if	board2
part3b	db	type qq dup( ? )
part3c	db	type qq dup( ? )
part3d	db	type qq dup( ? )
endif
if	ppz
part10a	db	type qq dup( ? )
part10b	db	type qq dup( ? )
part10c	db	type qq dup( ? )
part10d	db	type qq dup( ? )
part10e	db	type qq dup( ? )
part10f	db	type qq dup( ? )
part10g	db	type qq dup( ? )
part10h	db	type qq dup( ? )
endif
part_e	db	type qq dup( ? )

	even
pcm_table	label	word
if	board2
 if	adpcm
  ife	ademu
pcmends		dw	26H	;�ŏ���start��26H����
pcmadrs		dw	2*256 dup (0)
pcmfilename	db	128 dup(0)
  endif
 endif
 if	pcm
pcmst_ofs	dw	0
pcmst_seg	dw	0
pcmadrs		db	6*256 dup (0)
 endif
endif
		db	"�����͂r�s�`�b�j�G���A�ł��B����"
		db	"���o�l�c�������p���ĉ������Ă���"
		db	"���X�A�ǂ������肪�Ƃ��������܂�"
		db	"(^^)�B�����o�O�炵������������"
		db	"�܂�����A���ׂȎ��ł��\���܂���"
		db	"�̂ŁA���񎄂܂ł����A���肢��"
		db	"�܂���(^^)�B��PMDBBS [03(3395)96"
		db	"00] @PMD �{�[�h�܂�     by KAJA."
_stack:
dataarea	label	word
		db	0		;
		dw	12 dup (18h)	; �����f�[�^
		db	80h		;

;==============================================================================
;	�풓�I���V�[�P���X(��풓���擪�ʒu�Ɉړ�)
;==============================================================================
resident_exit_end:
	push	dx

	mov	ax,cs
	mov	es,ax
;	���F�G���A�̏�����
	cmp	[voicedat_lng],0
	jz	not_vinit
	mov	di,[tondat]
	xor	cl,cl
	mov	ch,[voicedat_lng]
	shl	cx,1
	xor	ax,ax
rep	stosw
not_vinit:

;	Init Effect Data
	cmp	[effecdat_lng],0
	jz	not_einit
	mov	di,[efcdat]
	mov	ax,0100h
	mov	cx,128
rep	stosw
	mov	byte ptr [di],80h
not_einit:

	pop	dx
	resident_exit

;==============================================================================
;	�o�l�c�R�}���h�X�^�[�g
;==============================================================================
comstart:
ife	va
	include	virus.inc		;�E�C���Xcheck
	jmp	coms_main
myname	db	_myname
coms_main:
endif
	cld
	push	ds

	mov	ax,cs
	mov	ds,ax
	print_mes	mes_title	;�^�C�g���\��

	pop	ds

	mov	cs:[opt_sp_push],0

;==============================================================================
;	�o�l�c�풓CHECK
;==============================================================================
	xor	ax,ax
	mov	es,ax
	les	bx,es:[pmdvector*4]	;ES = PMD seg

	cmp	word ptr es:_p[bx],"MP"
	jnz	resident_main
	cmp	byte ptr es:_d[bx],"D"
	jnz	resident_main

	push	ds
	mov	ah,10h
	int	60h
	mov	si,dx
	mov	si,-2[si]
	cmp	byte ptr es:[si+(board-open_work)],0
	pop	ds
	jz	change_main

;	�풓���Ă���/�����L��̎��� FMint vector��opnint:�Ɠ��ꂩ�ǂ���check
	mov	si,es:_vector[bx]
	push	ds
	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[si]
	pop	ds
	cmp	ax,offset opnint
	jz	change_main	;(ES=PMD seg)

	jmp	pmderr_1	;�풓����FM���荞�݃x�N�g�����Ⴄ

;==============================================================================
;	�풓����
;==============================================================================
resident_main:
;==============================================================================
;	�I�v�V���������ݒ�
;==============================================================================
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	xor	ax,ax

	mov	[mmldat_lng],mdata_def		;Default 16K
	mov	[voicedat_lng],voice_def	;Default 8K
	mov	[effecdat_lng],effect_def	;Default 4K
	mov	[key_check],key_def		;Keycheck ON
	mov	[fm_voldown],fmvd_init	;FM_VOLDOWN
	mov	[_fm_voldown],fmvd_init	;FM_VOLDOWN
	mov	[ssg_voldown],al	;SSG_VOLDOWN
	mov	[_ssg_voldown],al	;SSG_VOLDOWN
	mov	[pcm_voldown],al	;PCM_VOLDOWN
	mov	[_pcm_voldown],al	;PCM_VOLDOWN
	mov	[ppz_voldown],al	;PPZ_VOLDOWN
	mov	[_ppz_voldown],al	;PPZ_VOLDOWN
	mov	[rhythm_voldown],al	;RHYTHM_VOLDOWN
	mov	[_rhythm_voldown],al	;RHYTHM_VOLDOWN
	mov	[kp_rhythm_flag],-1	;SSGDRUM��RHYTHM������炷�� FLAG

	mov	di,offset rshot_bd
	mov	cx,6
rep	stosw

	mov	di,offset part1
	mov	cx,max_part1 * type qq
rep	stosb

	mov	[disint],al		;INT Disable FLAG
	mov	[rescut_cant],al	;�풓�����֎~ FLAG
	mov	[adpcm_wait],al		;ADPCM��`���x
	mov	[pcm86_vol],al		;PCM���ʍ��킹
	mov	[_pcm86_vol],al		;PCM���ʍ��킹
	mov	[fade_stop_flag],1	;FADEOUT��MSTOP���邩 FLAG
	mov	[ppsdrv_flag],-1	;PPSDRV FLAG
if	va
	mov	[grph_sp_key],80h	;GRPH+CTRL key code
	mov	[rew_sp_key],40h	;GPPH+SHIFTkey code
	mov	[esc_sp_key],80h	;ESC +CTRL key code
else
	mov	[grph_sp_key],10h	;GRPH+CTRL key code
	mov	[rew_sp_key],1		;GPPH+SHIFTkey code
	mov	[esc_sp_key],10h	;ESC +CTRL key code
	mov	[port_sel],-1		;�|�[�g�I�� = ����
endif
	mov	[ff_tempo],250
	mov	[music_flag],al
	mov	[message_flag],1

;==============================================================================
;	�e�l������check (INT/PORT�I��)
;==============================================================================
	cli
	call	fm_check
	sti

	pop	ds	; DS = PSP segment

;==============================================================================
;	�I�v�V��������荞��
;==============================================================================
	push	ds

	mov	es,ds:[2ch]
	mov	si,offset pmdopt_txt
	call	search_env		;"PMDOPT=" ����
	jc	no_user

	mov	si,di
	mov	ax,es
	mov	ds,ax		;ds:si=���ϐ��ʒu
	mov	ax,cs
	mov	es,ax

	mov	bx,offset resident_option
	call	_set_option
	jmp	no_user

_set_option:
	mov	cs:[opt_sp_push],sp
	call	set_option
	mov	cs:[opt_sp_push],0
	ret

no_user:
	mov	ax,cs
	mov	es,ax	; ES = Code segment
	pop	ds
	mov	si,offset 80h

	cmp	byte ptr [si],0
	jz	resmes_set		;�I�v�V��������
	inc	si			;ds:si = command line

	mov	bx,offset resident_option
	call	set_option

	mov	al,es:[mmldat_lng]
	cmp	al,1
	jc	pmderr_2
	add	al,es:[voicedat_lng]
	jc	pmderr_3
	add	al,es:[effecdat_lng]
	jc	pmderr_3
	cmp	al,40+1
	jnc	pmderr_3

;==============================================================================
;	vmap�G���A��"PMD"�����񏑍���
;==============================================================================
resmes_set:
	mov	ax,ds
	mov	es,ax	;ES = PSP  segment
	mov	ax,cs
	mov	ds,ax	;DS = Code segment
	mov	si,offset resident_mes
	mov	di,offset 80h
	mov	al,offset rmes_end-resident_mes
	stosb
resmesset_loop:
	movsb
	cmp	byte ptr -1[di],0
	jnz	resmesset_loop

;==============================================================================
;	Memory Check & Init
;==============================================================================
memchk_init:
	mov	ax,es
	dec	ax
	mov	es,ax		;ES = MCB segment
	mov	di,es:[3]	;di = max size
	mov	ax,cs
	mov	es,ax

	mov	dx,offset dataarea+16
	shr	dx,1
	shr	dx,1
	shr	dx,1
	shr	dx,1	;/16

	xor	al,al
	mov	ah,[mmldat_lng]
	shr	ax,1
	shr	ax,1	;*64	(64 P.G.Size = 1 K.Byte)
	xor	bl,bl
	mov	bh,[voicedat_lng]
	shr	bx,1
	shr	bx,1	;*64
	xor	cl,cl
	mov	ch,[effecdat_lng]
	shr	cx,1
	shr	cx,1	;*64
	add	dx,ax
	add	dx,bx
	add	dx,cx

	mov	[resident_size],dx

	cmp	di,dx
	jc	pmderr_7

;==============================================================================
;	�ȃf�[�^�C���F�f�[�^�i�[�Ԓn��ݒ�
;==============================================================================
	mov	ax,offset dataarea+1
	mov	[mmlbuf],ax
	dec	ax

	mov	bh,[mmldat_lng]
	xor	bl,bl
	shl	bx,1
	shl	bx,1
	add	ax,bx
	mov	[tondat],ax

	mov	bh,[voicedat_lng]
	xor	bl,bl
	shl	bx,1
	shl	bx,1
	add	ax,bx
	mov	[efcdat],ax

;==============================================================================
;	���ʉ�/FMINT/EFCINT��������
;==============================================================================
	xor	ax,ax
	mov	[fmint_seg],ax
	mov	[fmint_ofs],ax
	mov	[efcint_seg],ax
	mov	[efcint_ofs],ax
	mov	[intfook_flag],al
	mov	[skip_flag],al
	mov	[effon],al
	mov	[fm_effec_flag],al
	mov	[pcmflag],al
	dec	al
	mov	[psgefcnum],al
	mov	[fm_effec_num],al
	mov	[pcm_effec_num],al

;==============================================================================
;	���荞�ݐݒ�
;==============================================================================
	cmp	[board],0
	jz	not_set_opnvec

;==============================================================================
;	OPN ������
;==============================================================================
	call	int_init

;------------------------------------------------------------------------------
;	088/188/288/388 (��INT�ԍ��̂�) �������ݒ�
;------------------------------------------------------------------------------
if	va
	mov	ax,2900h
	call	opnset44
	mov	ax,2400h
	call	opnset44
	mov	ax,2500h
	call	opnset44
	mov	ax,2600h
	call	opnset44
	mov	ax,273fh
	call	opnset44
else
	mov	cx,4
	mov	dx,088h

opninit_loop:
	push	cx

	mov	ah,-1
	mov	cx,256
opninit_loop2:
	in	al,dx
	and	ah,al
	test	ah,ah
	jns	opninit_exec
	loop	opninit_loop2
	jmp	opninit_next	;��������

opninit_exec:
	pushf
	cli
	rdychk
	mov	al,0eh
	out	dx,al
	mov	cx,256
	loop	$
	add	dx,2
	in	al,dx
	popf
	sub	dx,2
	and	al,0c0h
	cmp	al,[opn_0eh]	;int�ԍ����r
	jnz	opninit_next	;���v�Ȃ珉�������Ȃ�

	mov	ax,2900h
	call	opnset_fmc
	mov	ax,2400h
	call	opnset_fmc
	mov	ax,2500h
	call	opnset_fmc
	mov	ax,2600h
	call	opnset_fmc
	mov	ax,273fh
	call	opnset_fmc

opninit_next:
	pop	cx
	inc	dh
	loop	opninit_loop
endif

;==============================================================================
;	�n�o�m�@���荞�݃x�N�g���@�ޔ�
;==============================================================================
	cli
	xor	ax,ax
	mov	es,ax
	mov	bx,[vector]
	les	bx,es:[bx]
	mov	[int5ofs],bx
	mov	[int5seg],es

;==============================================================================
;	�n�o�m�@���荞�݃x�N�g���@�ݒ�
;==============================================================================
	mov	es,ax
	mov	bx,[vector]
	mov	es:[bx],offset opnint
	mov	es:[bx+2],cs
not_set_opnvec:

;==============================================================================
;	INT60 ���荞�݃x�N�g���@�ޔ�
;==============================================================================
	cli
	xor	ax,ax
	mov	es,ax
	les	bx,es:[pmdvector*4]
	mov	[int60ofs],bx
	mov	[int60seg],es

;==============================================================================
;	INT60 ���荞�݃x�N�g���@�ݒ�
;==============================================================================
	mov	es,ax
	mov	es:[pmdvector*4],offset int60_head
	mov	es:[pmdvector*4+2],cs

;==============================================================================
;	�n�o�m���荞�݊J�n
;==============================================================================
	call	opnint_start
	sti

;==============================================================================
;	Wait�񐔕\��
;==============================================================================
	cmp	[message_flag],0
	jz	not_key_mes

	print_mes	mes_wait1
	mov	ax,[wait_clock]
	call	print_16
	print_mes	mes_wait2
	mov	ax,[wait_clock]
	mul	[wait1_clock]
	call	print_16
	print_mes	mes_wait3

;==============================================================================
;	�I������
;==============================================================================
	print_mes	mes_exit

	cmp	[key_check],0
	jz	not_key_mes
	print_mes	mes_key
not_key_mes:

;==============================================================================
;	�������
;==============================================================================
if	va
	mov	ax,cs:[002ch]
	dec	ax
	mov	es,ax
	mov	ax,cs
	cmp	ax,es:[1]	;����owner��pmd�łȂ����
	jnz	not_cut_env	;������Ȃ�
endif
	mov	es,cs:[002ch]	;ES=����segment
	resident_cut		;�������
not_cut_env:

;==============================================================================
;	�f�[�^�G���A���m��
;==============================================================================
	mov	dx,[resident_size]
	jmp	resident_exit_end	;�풓�I��

;==============================================================================
;	�e�l�����{�[�h����/PORT/INT�`�F�b�N
;==============================================================================
fm_check:
;------------------------------------------------------------------------------
;	�|�[�g��ݒ�
;------------------------------------------------------------------------------
	push	es
	call	port_check
	pop	es
	jc	not_fmboard

	mov	ax,[fm1_port1]
	mov	[fm_port1],ax
	mov	ax,[fm1_port2]
	mov	[fm_port2],ax
ife	va
	add	ah,"0"
	mov	[port_num],ah
endif

;------------------------------------------------------------------------------
;	Wait�ݒ�
;------------------------------------------------------------------------------
	call	wait_check
	mov	[wait1_clock],ax
	mov	[wait_clock],cx

;------------------------------------------------------------------------------
;	ADPCM��RAM check
;------------------------------------------------------------------------------
if	board2*adpcm
	mov	dx,2983h
	call	opnset44		;2608 on
 if	ademu
	mov	[pcm_gs_flag],1		;ADPCM�͎g�p���Ȃ�
 else
	call	adpcm_ram_check		;in ADRAMCHK.ASM
 endif
else
	mov	[pcm_gs_flag],1		;ADPCM�͎g�p���Ȃ�
endif
	mov	[board],1
	ret

not_fmboard:
	mov	[board],0
	cmp	[message_flag],0
	jz	nfm_ret
	print_mes	mes_warning
	print_mes	mes_not_board
nfm_ret:
	ret

;==============================================================================
;	INT init
;==============================================================================
int_init:
;------------------------------------------------------------------------------
;	INT�ԍ���ǂݏo���Đݒ�
;------------------------------------------------------------------------------
	mov	dx,[fm1_port1]
	pushf
	cli
	rdychk
	mov	al,7
	out	dx,al
	_wait			;PSG Write Wait
	mov	dx,[fm1_port2]
	mov	al,3fh
	out	dx,al
	popf

	mov	dx,[fm1_port1]	;2
	pushf
	cli
	rdychk
	mov	al,0eh
	out	dx,al
	_wait			;PSG Read Wait
	mov	dx,[fm1_port2]
	in	al,dx
	popf
	and	al,0c0h
ife	va
	mov	[opn_0eh],al
endif
	rol	al,1
	rol	al,1
	add	al,al
	add	al,al
	xor	ah,ah
	mov	bx,offset vector_table
	add	bx,ax
	mov	al,[bx]
	mov	[int_num],al
	mov	al,[bx+1]
	mov	[int_level],al
	mov	ax,[bx+2]
	mov	[vector],ax

	cmp	[message_flag],0
	jz	pps_chk

	print_mes	mes_int

	xor	bh,bh
	mov	bl,[ongen]
	add	bx,bx
	add	bx,offset ongen_sel
	mov	dx,[bx]
	print_dx

ife	ademu
 if	board2*pcm
	print_mes	mes_pcm
 endif
 if	board2*adpcm
	xor	bh,bh
	mov	bl,[pcm_gs_flag]
	add	bx,bx
	add	bx,offset pcm_sel
	mov	dx,[bx]
	print_dx
 endif
endif
	print_mes	mes_int2

;------------------------------------------------------------------------------
;	ppsdrv/ppz8�풓CHECK
;------------------------------------------------------------------------------
pps_chk:
	cmp	[ppsdrv_flag],-1
	jz	pps_check
	cmp	[kp_rhythm_flag],-1
	jnz	ppschk_exit
	mov	al,[ppsdrv_flag]
	xor	al,1
	mov	[kp_rhythm_flag],al
	jmp	ppschk_exit

pps_check:
	call	ppsdrv_check
	jc	ppschk_01
	mov	[ppsdrv_flag],1
	cmp	[kp_rhythm_flag],-1
	jnz	ppschk_exit
	mov	[kp_rhythm_flag],0
	jmp	ppschk_exit
ppschk_01:
	mov	[ppsdrv_flag],0
	cmp	[kp_rhythm_flag],-1
	jnz	ppschk_exit
	mov	[kp_rhythm_flag],1
	jmp	ppschk_exit

ppschk_exit:
	cmp	[message_flag],0
	jz	ppschk_end
	cmp	[ppsdrv_flag],1
	jnz	ppschk_end
	print_mes	mes_ppsdrv
ppschk_end:
if	ppz
	call	ppz8_check
	jc	ppzchk_end
	mov	es:[ppz_call_seg],1
	mov	ax,0410h
	int	ppz_vec
	mov	ah,es:[int_level]
	add	ah,8
	cmp	al,ah
	jnz	ppzchk_next
	push	es
	mov	ax,0409h
	int	ppz_vec
	mov	ax,es
	pop	es
	mov	es:[ppz_call_ofs],bx
	mov	es:[ppz_call_seg],ax
ppzchk_next:
	mov	ax,1901h
	int	ppz_vec		;�풓�����֎~
	cmp	[message_flag],0
	jz	mask_eoi_set
	print_mes	mes_ppz8
ppzchk_end:
endif
;------------------------------------------------------------------------------
;	MASK/EOI�̏o�͐�̐ݒ�
;------------------------------------------------------------------------------
mask_eoi_set:
	mov	al,[int_level]
	test	al,8		;Slave?
	jnz	i6s_slave

;	Master�̏ꍇ
	mov	dx,ms_msk
	mov	[mask_adr],dx	;Mask��Master��
	mov	cl,al
	inc	cl
	xor	ah,ah
	stc
	rcl	ah,cl
	mov	[mask_data],ah	;Mask����f�[�^
	not	ah
	mov	[mask_data2],ah	;Mask��������f�[�^
	mov	dx,ms_cmd
	mov	[eoi_adr],dx	;EOI��Master��Send����
	and	al,7
	or	al,60h
	mov	[eoi_data],al	;����EOI + ���荞�݃x�N�g�� ������

	jmp	i6s_intexit

;	Slave�̏ꍇ
i6s_slave:
	and	al,7		;AL=INTLevel
	mov	dx,sl_msk
	mov	[mask_adr],dx	;Mask��Slave��
	mov	cl,al
	inc	cl
	xor	ah,ah
	stc
	rcl	ah,cl
	mov	[mask_data],ah	;Mask����f�[�^
	not	ah
	mov	[mask_data2],ah	;Mask��������f�[�^
	mov	dx,sl_cmd
	mov	[eoi_adr],dx	;EOI��Slave��Send����
	or	al,60h
	mov	[eoi_data],al	;����EOI + ���荞�݃x�N�g�� ������

i6s_intexit:
	mov	ax,cs
	mov	es,ax
	ret

;==============================================================================
;	ppsdrv�풓CHECK
;==============================================================================
ppsdrv_check:
	push	es
	push	ax
	push	bx

	xor	ax,ax
	mov	es,ax
	les	bx,es:[ppsdrv*4]
	cmp	word ptr es:2[bx],"MP"
	jnz	non_ppsdrv
	cmp	byte ptr es:4[bx],"P"
	jnz	non_ppsdrv

	clc
ppsdrvchk_exit:
	pop	bx
	pop	ax
	pop	es
	ret
non_ppsdrv:
	stc
	jmp	ppsdrvchk_exit

if	ppz
;==============================================================================
;	ppz8�풓CHECK
;==============================================================================
ppz8_check:
	push	es
	push	ax
	push	bx

	xor	ax,ax
	mov	es,ax
	les	bx,es:[ppz_vec*4]
	cmp	word ptr es:2[bx],"PP"
	jnz	non_ppz8
	cmp	word ptr es:4[bx],"8Z"
	jnz	non_ppz8
	clc
ppz8_chk_ret:
	pop	bx
	pop	ax
	pop	es
	ret
non_ppz8:
	stc
	jmp	ppz8_chk_ret
endif

;==============================================================================
;	�n�o�m���荞�݋�����
;==============================================================================
opnint_start:
	cmp	[board],0
	jz	not_opnint_start	;�{�[�h���Ȃ�
	mov	ax,cs
	mov	es,ax
	mov	di,offset part1
	mov	cx,max_part1*type qq
	xor	al,al
rep	stosb				;Partwork All Reset
	dec	al
	mov	[rhythmmask],255	;Rhythm Mask����
	mov	[rhydmy],al		;R part Dummy�p
	call	data_init
	call	opn_init
	mov	dx,07bfh		;07hPort Init
	call	opnset44
	call	mstop
	call	setint
	mov	al,[int_level]
	call	intset
if	va
	in	al,32h
	jmp	$+2
	and	al,7fh
	out	32h,al
endif
	mov	dx,2983h
	call	opnset44
not_opnint_start:
	ret

ife	va
;==============================================================================
;	OPN out for 088/188/288/388 INIT�p
;		input	ah	reg
;			al	data
;			dx	port
;==============================================================================
opnset_fmc:
	pushf
	cli
	mov	cx,256
	loop	$
	xchg	ah,al
	out	dx,al
	mov	cx,256
	loop	$
	add	dx,2
	xchg	ah,al
	out	dx,al
	sub	dx,2
	popf
	ret
endif
;==============================================================================
;	FM�����|�[�g�𒲂ׂ�
;		output	fm1_port1/fm1_port2/fm2_port1/fm2_port2
;			ongen/epson_flag
;			cy=1�Ń{�[�h����
;==============================================================================
port_check:
if	va
	mov	[fm1_port1],44h
	mov	[fm1_port2],45h
	mov	[fm2_port1],46h
	mov	[fm2_port2],47h
	mov	[epson_flag],0
;------------------------------------------------------------------------------
;	VA+NORM �� check	(PMDVA1)
;------------------------------------------------------------------------------
	mov	[ongen],0
	cli
	mov	cx,100
	loop	$
	mov	dx,44h
	mov	al,0bh
	out	dx,al
	mov	cx,100
	loop	$
	inc	dx
	mov	al,0aah
	out	dx,al
	mov	cx,100
	loop	$
	in	al,dx
	sti
	cmp	al,0aah
	jnz	pc_error
;------------------------------------------------------------------------------
;	VA+BOARD2 �� check	(PMDVA)
;------------------------------------------------------------------------------
	cli
	mov	cx,100
	loop	$
	mov	dx,44h
	mov	al,-1
	out	dx,al
	inc	dx
	mov	cx,100
	loop	$
	in	al,dx
	sti
	dec	al
 if	board2
	jnz	pc_error
 else
	jnz	va_norm_ret
 endif
	mov	[ongen],1
va_norm_ret:
	clc
	ret
else
 if	board2
  if	pcm+ppz
;------------------------------------------------------------------------------
;	98+86B �� check		(PMD86/PMDPPZ)	86�{�[�h��p
;------------------------------------------------------------------------------
	jmp	check_86b
  else
;------------------------------------------------------------------------------
;	98+SPB �� check		(PMDB2)
;------------------------------------------------------------------------------
	call	check_spb
	jc	check_86b
	ret
  endif
 else
;------------------------------------------------------------------------------
;	98+NORM �� check	(PMD)
;------------------------------------------------------------------------------
	call	check_spb
	jnc	norm_ret
	call	check_86b
	jnc	norm_ret

	mov	[ongen],0

	mov	ah,4		;088->188->288->388�̏���check
	mov	dx,088h

	cmp	[port_sel],-1
	jz	checkloop_norm
	mov	dh,[port_sel]
	mov	ah,1

checkloop_norm:
	cli
	mov	cx,100
	loop	$
	mov	al,0bh
	out	dx,al
	mov	cx,100
	loop	$
	add	dx,2
	mov	al,0aah
	out	dx,al
	mov	cx,100
	loop	$
	in	al,dx
	sti
	sub	dx,2
	cmp	al,0aah
	jz	set_port

	dec	ah
	jz	pc_error
	add	dx,100h
	jmp	checkloop_norm

norm_ret:
	clc
	ret
 endif

;------------------------------------------------------------------------------
;	86B�̑���check
;------------------------------------------------------------------------------
check_86b:
	mov	[ongen],1
	mov	[epson_flag],0
;	86B ����check & MASK
	mov	ax,0fd80h
	mov	es,ax
	cmp	word ptr es:[2],02a27h	;EPSON�@�H
	jnz	not_epson0
	mov	[epson_flag],1
	cmp	byte ptr es:[4],6	;PC-286VE�ȑO�H
	jc	pc_error		;�Ȃ�86�{�[�h����
not_epson0:
	mov	dx,0a460h	;NEC OPNA ID port
	in	al,dx
	cmp	al,-1
	jz	pc_error
	out	5fh,al
	and	al,0fch
	out	dx,al		;NEC OPNA off

	mov	ah,2
	mov	dx,188h		;188->288�̏���check

	cmp	[port_sel],-1
	jz	checkloop_86b
	mov	dh,[port_sel]
	mov	ah,1

checkloop_86b:
	cli
	mov	al,-1
	mov	cx,100
	loop	$
	out	dx,al
	add	dx,2
	mov	cx,100
	loop	$
	in	al,dx
	sti
	sub	dx,2
	dec	al		;YM2608���ǂ�����check
	jnz	checkexit_86b
	add	dx,4
	in	al,dx
	mov	bl,al
	add	dx,2
	in	al,dx
	sub	dx,6
	and	al,bl
	inc	al		;x8C/x8E��mask����Ă��邩�ǂ���check
	jz	init_86b

checkexit_86b:
	dec	ah
	jz	pc_error
	inc	dh
	jmp	checkloop_86b

;------------------------------------------------------------------------------
;	86B �����ݒ�
;------------------------------------------------------------------------------
init_86b:
	push	dx
	mov	dx,0a460h	;NEC OPNA ID port
	cli
	in	al,dx
	out	5fh,al
	and	al,0fch
	or	al,1
	out	dx,al		;NEC OPNA on

	mov	dx,0a66eh
	in	al,dx
	out	5fh,al
	and	al,0feh			; a66e b0 : mute 1:���� 0:���Ȃ�
	out	dx,al
	cmp	[epson_flag],0
	jz	not_init_gdc
	mov	al,1
	out	6eh,al			;(T_T)EPSON�@�� display 24KHz Mode
not_init_gdc:
if	pcm
	call	stop_86pcm
endif
	sti
	pop	dx
	jmp	set_port

ife	pcm
;------------------------------------------------------------------------------
;	SPB��check
;------------------------------------------------------------------------------
check_spb:
	mov	[ongen],1
	mov	[epson_flag],0
;	86B ����check & MASK
	mov	ax,0fd80h
	mov	es,ax
	cmp	word ptr es:[2],02a27h	;EPSON�@�H
	jnz	not_epson1
	mov	[epson_flag],1
	cmp	byte ptr es:[4],6	;PC-286VE�ȑO�H
	jc	not_86b1		;�Ȃ�86�{�[�h����
not_epson1:
	mov	dx,0a460h	;NEC OPNA ID port
	in	al,dx
	cmp	al,-1
	jz	not_86b1
	out	5fh,al
	and	al,0fch
	out	dx,al		;NEC OPNA off
not_86b1:
	mov	ah,4		;088->188->288->388�̏���check
	mov	dx,088h

	cmp	[port_sel],-1
	jz	checkloop_spb
	mov	dh,[port_sel]
	mov	ah,1

checkloop_spb:
	cli
	mov	al,-1
	mov	cx,100
	loop	$
	out	dx,al
	add	dx,2
	mov	cx,100
	loop	$
	in	al,dx
	sti
	sub	dx,2
	dec	al		;YM2608���ǂ�����check
	jnz	checkexit_spb
	add	dx,4
	in	al,dx
	mov	bl,al
	add	dx,2
	in	al,dx
	sub	dx,6
	and	al,bl
	inc	al		;x8C/x8E��mask����Ă��Ȃ����ǂ���check
	jnz	set_port

checkexit_spb:
	dec	ah
	jz	pc_error
	add	dx,100h
	jmp	checkloop_spb
endif

;------------------------------------------------------------------------------
;	�|�[�g�ݒ�
;------------------------------------------------------------------------------
set_port:
	mov	[fm1_port1],dx
	add	dx,2
	mov	[fm1_port2],dx
	add	dx,2
	mov	[fm2_port1],dx
	add	dx,2
	mov	[fm2_port2],dx
	clc
	ret
endif
;------------------------------------------------------------------------------
;	������������Ȃ�����
;------------------------------------------------------------------------------
pc_error:
	stc
	ret

;==============================================================================
;	�풓���Ă������̃X�e�[�^�X�\���^�ύX����
;		input	DS:PSP_seg / ES:PMD_seg
;==============================================================================
change_main:
;==============================================================================
;	�I�v�V��������荞��
;==============================================================================
	mov	si,offset 80h

	cmp	byte ptr [si],0
	jz	put_status		;�I�v�V��������
	inc	si			;ds:si = command line

	mov	bx,offset status_option
	call	set_option

	mov	ax,cs
	mov	ds,ax	;DS = Code_seg
	print_mes	changemes_0

;==============================================================================
;	Status�̕\��
;		in.	ES	PMD_seg
;==============================================================================
put_status:
	mov	ax,cs
	mov	ds,ax	;DS = Code_seg

;	�ȃf�[�^�o�b�t�@�T�C�Y
	print_mes	changemes_01
	mov	al,es:[mmldat_lng]
	call	put8

;	���F�f�[�^�o�b�t�@�T�C�Y
	print_mes	changemes_02
	mov	al,es:[voicedat_lng]
	call	put8

;	���ʉ��f�[�^�o�b�t�@�T�C�Y
	print_mes	changemes_03
	mov	al,es:[effecdat_lng]
	call	put8

;	FM����    ���ʒ����l
	print_mes	changemes_1
	mov	al,es:[_fm_voldown]
	call	put8
	print_mes	crlf

;	SSG����   ���ʒ����l
	print_mes	changemes_2
	mov	al,es:[_ssg_voldown]
	call	put8
	print_mes	crlf

if	board2
;	PCM����   ���ʒ����l
	print_mes	changemes_3
	mov	al,es:[_pcm_voldown]
	call	put8
	print_mes	crlf
if	ppz
	print_mes	changemes_3z
	mov	al,es:[_ppz_voldown]
	call	put8
	print_mes	crlf
endif
;	RHYTHM�������ʒ����l
	print_mes	changemes_4
	mov	al,es:[_rhythm_voldown]
	call	put8
	print_mes	crlf

;	SSG�h�����������ɓ�����RHYTHM������炷��
	print_mes	changemes_5
	mov	dx,offset changemes_5a
	cmp	es:[kp_rhythm_flag],0
	jnz	change5_put
	mov	dx,offset changemes_5b
change5_put:
	print_dx
endif

;	GRPH/ESC�L�[�ő�����/�Ȃ̒�~�̐���
	print_mes	changemes_6
	mov	dx,offset changemes_6a
	cmp	es:[key_check],0
	jnz	change6_put
	mov	dx,offset changemes_6b
change6_put:
	print_dx

;	ESC �Ɠ����Ɏg�p����L�[�ݒ�l
	print_mes	changemes_7
	mov	al,es:[esc_sp_key]
if	va
	rol	al,1
	rol	al,1
	rol	al,1
	and	al,00000111b
endif
	call	put8
	print_mes	crlf

;	GRPH�Ɠ����Ɏg�p����L�[�ݒ�l
	print_mes	changemes_8
	mov	al,es:[grph_sp_key]
if	va
	rol	al,1
	rol	al,1
	rol	al,1
	and	al,00000111b
endif
	call	put8
	print_mes	crlf

;	GRPH�Ɠ����Ɏg�p����L�[�ݒ�l
	print_mes	changemes_8b
	mov	al,es:[rew_sp_key]
if	va
	rol	al,1
	rol	al,1
	rol	al,1
	and	al,00000111b
endif
	call	put8
	print_mes	crlf

;	�t�F�[�h�A�E�g��ɋȂ̉��t���~���邩
	print_mes	changemes_9
	mov	dx,offset changemes_6a
	cmp	es:[fade_stop_flag],0
	jnz	change9_put
	mov	dx,offset changemes_6b
change9_put:
	print_dx

;	FM/INT60���荞�ݒ��Ɋ��荞�݂��֎~���邩
	print_mes	changemes_10
	mov	dx,offset changemes_6a
	cmp	es:[disint],0
	jnz	change10_put
	mov	dx,offset changemes_6b
change10_put:
	print_dx

;	PPSDRV���g�p���邩
	print_mes	changemes_11
	mov	dx,offset changemes_6a
	cmp	es:[ppsdrv_flag],0
	jnz	change11_put
	mov	dx,offset changemes_6b
change11_put:
	print_dx

if	ppz
;	PPZ8���g�p���邩
	print_mes	changemes_11_
	mov	dx,offset changemes_6a
	cmp	es:[ppz_call_seg],0
	jnz	change11__put
	mov	dx,offset changemes_6b
change11__put:
	print_dx
endif

;	FM�����o�͎��̃E�G�C�g
	print_mes	changemes_12
	mov	ax,es:[wait_clock]
	call	print_16
	print_mes	changemes_12a
	mov	ax,es:[wait_clock]
	mul	es:[wait1_clock]
	call	print_16
	print_mes	changemes_12b

;	�����莞��TimerB�l
	print_mes	changemes_13
	xor	ah,ah
	mov	al,es:[ff_tempo]
	call	print_16
	print_mes	crlf

if	board2*adpcm
 ife	ademu
;	ADPCM��`���x
	print_mes	changemes_14
	mov	dx,offset changemes_14a
	cmp	es:[adpcm_wait],0
	jz	change14_put
	mov	dx,offset changemes_14b
	cmp	es:[adpcm_wait],1
	jz	change14_put
	mov	dx,offset changemes_14c
change14_put:
	print_dx
 endif
endif
if	board2*pcm
;	ADPCM�ɍ��킹�邩�ݒ�
	print_mes	changemes_15
	mov	dx,offset changemes_15a
	cmp	es:[_pcm86_vol],0
	jz	change15_put
	mov	dx,offset changemes_15b
change15_put:
	print_dx

;	PCM�Đ����g��
	print_mes	changemes_16
	xor	dx,dx
	mov	dl,es:[p86_freq]
	add	dx,dx
	add	dx,dx
	add	dx,dx
	add	dx,offset changemes_16a
	print_dx
	cmp	es:[p86_freq],8
	jz	change16_exit
	print_mes	changemes_16b
change16_exit:
endif
	msdos_exit	;�I��

;==============================================================================
;	���l�̕\�� 8bit
;		input	AL
;==============================================================================
put8:
	xor	ah,ah
	mov	dl,100
	call	p8_oneset
	mov	dl,10
	call	p8_oneset
	add	al,"0"
	mov	dl,al
	mov	ah,2
	int	21h	;�P�����\��
	ret
p8_oneset:
	mov	dh,"0"
p8_ons0:sub	al,dl
	jc	p8_ons1
	inc	dh
	jmp	p8_ons0
p8_ons1:add	al,dl
	test	ah,ah
	jnz	p8_ons2
	cmp	dh,"0"
	jz	p8_ons3
p8_ons2:push	dx
	push	ax
	mov	dl,dh
	mov	ah,2
	int	21h	;�P�����\��
	pop	ax
	pop	dx
	mov	ah,1
	inc	di
p8_ons3:
	ret

;==============================================================================
;	�������
;	����֎~�t���O��check
;==============================================================================
resident_cut_main:
	xor	ax,ax
	mov	es,ax
	les	bx,es:[pmdvector*4]	; ES:BX=PMD seg/offset
	cmp	es:[rescut_cant],0	;SET_FM_(EFC_)INT�g�p�����H
	jz	rescut_main
cantcut_res:
	mov	ax,cs
	mov	ds,ax
	print_mes	cantcut_mes	;�풓�����o���Ȃ�
	error_exit	1

;==============================================================================
;	������ďI��
;==============================================================================
rescut_main:
	cli			;���荞�݋֎~
	
	call	ppsdrv_check
	jnc	rs_fmefc_cut
	mov	ax,1800h
	int	pmdvector	;PPSDRV���풓���ĂȂ�������Ή��t���Oreset
rs_fmefc_cut:
	mov	ah,11h
	int	pmdvector
	inc	al
	jz	rs_non_fmefc
	mov	ah,0dh
	int	pmdvector	;�e�l���ʉ��̒�~
rs_non_fmefc:

	mov	ah,15h
	int	pmdvector
	test	al,al
	jz	rs_non_ssgefc
	mov	ah,04h
	int	pmdvector	;�o�r�f���ʉ��̒�~
rs_non_ssgefc:

	mov	ah,1
	int	pmdvector	;���t�̒�~

	call	vector_ret
	sti			;���荞�݋���
	jc	pmderr_4	;����ł��Ȃ�

if	ppz
	call	ppz8_check
	jc	rs_no_ppz
	mov	ax,1900h
	int	ppz_vec		;�풓��������
rs_no_ppz:
endif
	print_mes	mes_cut
	msdos_exit

;==============================================================================
;�@	OPN�����荞�ݐ؂����
;==============================================================================
vector_ret:
	xor	ax,ax
	mov	es,ax
	les	bx,es:[pmdvector*4]	; ES:BX=PMD seg/offset

	cmp	es:[board],0
	jz	not_cut_opnvec

	mov	al,es:_int_level[bx]
	call	intpop			; OPN���荞�݃}�X�N�����ɖ߂�

	mov	ax,es:[fm1_port1]	; FM1_port1
	mov	[fm1_port1],ax
	mov	ax,es:[fm1_port2]	; FM1_port2
	mov	[fm1_port2],ax
	mov	dx,2730h		; FM int RESET
	call	opnset44

	;�h�m�s�T���荞�݃x�N�g�������ɖ߂�
	xor	ax,ax
	mov	ds,ax
	mov	cx,es:_int5ofs[bx]
	mov	dx,es:_int5seg[bx]
	push	bx
	mov	bx,es:_vector[bx]
	mov	ds:[bx],cx
	mov	ds:[bx+2],dx
	pop	bx

not_cut_opnvec:
	;�h�m�s�U�O���荞�݃x�N�g�������ɖ߂�
	xor	ax,ax
	mov	ds,ax
	mov	cx,es:_int60ofs[bx]
	mov	dx,es:_int60seg[bx]
	mov	ds:[pmdvector*4],cx
	mov	ds:[pmdvector*4+2],dx

	mov	ax,cs
	mov	ds,ax
	resident_cut	;�����������

	ret

;==============================================================================
;	Interrupt set&push	(master/slave ���p)
;		input	al	:Interrupt Level
;==============================================================================
intset:
	mov	cl,al
	mov	dx,ms_msk
	cmp	cl,8	;master?
	jc	intset2
	sub	cl,8
	in	al,dx
if	va
	jmp	$+2
else
	out	5fh,al
endif
	and	al,7fh	;Slave�̏ꍇ = Master��IR7(Slave)��Mask������
	out	dx,al
	mov	dx,sl_msk
intset2:
	inc	cl
	xor	al,al
	stc
	rcl	al,cl

	not	al
	mov	bl,al

	in	al,dx
	mov	ah,al	;AH=�O��maskregister
	and	al,bl
	out	dx,al	;�Y��IR�̃}�X�N������

	not	bl	;BL=�Ώ�bit�݂̂P�ɂȂ�
	and	ah,bl	;�Ώ�bit�̂� 0��1 ����0�ɂȂ�
	mov	cs:[maskpush],ah	;0�Ȃ�g�p�� 0�ȊO�Ȃ�g�p���ĂȂ�����

	ret

;==============================================================================
;	Interrupt pop	(master/slave ���p)
;		input	al	:Interrupt Level
;==============================================================================
intpop:
	mov	dx,ms_msk
	cmp	al,8	;master?
	jc	intpop2
	sub	al,8
	mov	dx,sl_msk
intpop2:
	in	al,dx
	push	es
	push	ax
	push	bx
	xor	ax,ax
	mov	es,ax
	les	bx,es:[pmdvector*4]
	mov	cl,es:_maskpush[bx]
	pop	bx
	pop	ax
	pop	es
	or	al,cl	;���ɖ߂�
	out	dx,al
	ret

;==============================================================================
;	�I�v�V��������
;		input	cs:bx	option_data
;			ds:si	command_line
;			es	pmd_segment
;==============================================================================
set_option:
	lodsb
	cmp	al,"/"
	jz	option
	cmp	al,"-"
	jz	option
	cmp	al," "
	jc	so_ret
	jz	set_option
	jmp	usage
so_ret:	ret

option:
	lodsb
	and	al,11011111b	;���������啶��
	push	bx
	sub	bx,3
oc_loop:
	add	bx,3
	cmp	byte ptr cs:[bx],0
	jz	usage
	cmp	al,byte ptr cs:[bx]
	jnz	oc_loop
	mov	ax,cs:1[bx]
	call	ax
	pop	bx
	jmp	set_option

;==============================================================================
;	/M option
;==============================================================================
muslng_get:
	call	get_comline_number
	jc	usage
	mov	es:[mmldat_lng],al
	ret

;==============================================================================
;	/V option
;==============================================================================
voilng_get:
	call	get_comline_number
	jc	usage
	mov	es:[voicedat_lng],al
	ret

;==============================================================================
;	/E option
;==============================================================================
efclng_get:
	call	get_comline_number
	jc	usage
	mov	es:[effecdat_lng],al
	ret

;==============================================================================
;	/D? option
;==============================================================================
fmvd_set:
	lodsb
	mov	dl,al
	push	dx
	call	get_comline_number
	pop	dx
	jc	usage
	and	dl,11011111b
	cmp	dl,"S"
	jz	psgvd_set
	cmp	dl,"P"
	jz	pcmvd_set
	cmp	dl,"R"
	jz	rhythmvd_set
	cmp	dl,"Z"
	jz	ppzvd_set
	cmp	dl,"F"
	jnz	usage

;==============================================================================
;	/DF option
;==============================================================================
	mov	es:[fm_voldown],al
	mov	es:[_fm_voldown],al
	ret

;==============================================================================
;	/DS option
;==============================================================================
psgvd_set:
	mov	es:[ssg_voldown],al
	mov	es:[_ssg_voldown],al
	ret

;==============================================================================
;	/DP option
;==============================================================================
pcmvd_set:
	mov	es:[pcm_voldown],al
	mov	es:[_pcm_voldown],al
	ret

;==============================================================================
;	/DZ option
;==============================================================================
ppzvd_set:
	mov	es:[ppz_voldown],al
	mov	es:[_ppz_voldown],al
	ret

;==============================================================================
;	/DR option
;==============================================================================
rhythmvd_set:
	mov	es:[rhythm_voldown],al
	mov	es:[_rhythm_voldown],al
	ret

;==============================================================================
;	/K option
;==============================================================================
keycheck:
	lodsb
	cmp	al,"-"
	jz	kck_minus
	and	al,11011111b
	cmp	al,"G"
	jz	grph_special_set
	cmp	al,"R"
	jz	rew_special_set
	cmp	al,"E"
	jz	esc_special_set
	dec	si
	mov	es:[key_check],0
	ret
kck_minus:
	mov	es:[key_check],1
	ret

;==============================================================================
;	/KG option
;==============================================================================
grph_special_set:
	call	get_comline_number
if	va
	ror	al,1
	ror	al,1
	ror	al,1
	and	al,11100000b
endif
	mov	es:[grph_sp_key],al
	ret

;==============================================================================
;	/KR option
;==============================================================================
rew_special_set:
	call	get_comline_number
if	va
	ror	al,1
	ror	al,1
	ror	al,1
	and	al,11100000b
endif
	mov	es:[rew_sp_key],al
	ret

;==============================================================================
;	/KE option
;==============================================================================
esc_special_set:
	call	get_comline_number
if	va
	ror	al,1
	ror	al,1
	ror	al,1
	and	al,11100000b
endif
	mov	es:[esc_sp_key],al
	ret

;==============================================================================
;	/I option
;==============================================================================
disint_set:
	cmp	byte ptr ds:[si],"-"
	jz	dins_minus
	mov	es:[disint],1
	ret
dins_minus:
	inc	si
	mov	es:[disint],0
	ret

;==============================================================================
;	/N option
;==============================================================================
notshot_set:
	cmp	byte ptr ds:[si],"-"
	jz	nshs_minus
	mov	es:[kp_rhythm_flag],0
	ret
nshs_minus:
	inc	si
	mov	es:[kp_rhythm_flag],1
	ret

;==============================================================================
;	/F option
;==============================================================================
notstop_set:
	cmp	byte ptr ds:[si],"-"
	jz	nsts_minus
	mov	es:[fade_stop_flag],0
	ret
nsts_minus:
	inc	si
	mov	es:[fade_stop_flag],1
	ret

;==============================================================================
;	/P option
;==============================================================================
ppsdrv_reset:
	cmp	byte ptr ds:[si],"-"
	jz	pdrrs_minus
pdrrs_none:
	mov	es:[ppsdrv_flag],0
	ret
pdrrs_minus:
	inc	si
	call	ppsdrv_check
	jc	pdrrs_none
	mov	es:[ppsdrv_flag],1
	ret

;==============================================================================
;	/Z option
;==============================================================================
ppz_reset:
if	ppz
	pushf
	cli
endif

	cmp	byte ptr ds:[si],"-"
	jz	ppz_minus

if	ppz
	call	ppz8_check
	jc	ppz_none

	mov	ah,12h
	int	ppz_vec		;FIFO���荞�ݒ�~

	mov	ax,0200h
z_ppz_off_loop:
	push	ax
	int	ppz_vec		;ppz keyoff
	pop	ax
	inc	al
	cmp	al,8
	jc	z_ppz_off_loop

	mov	ax,1900h
	int	ppz_vec		;�풓��������

ppz_none:
	mov	es:[ppz_call_ofs],0
	mov	es:[ppz_call_seg],0
	popf
endif
	ret

ppz_minus:
	inc	si
if	ppz
	call	ppz8_check
	jc	ppz_none
	mov	es:[ppz_call_seg],1
	mov	ax,0410h
	int	ppz_vec
	mov	ah,es:[int_level]
	add	ah,8
	cmp	al,ah
	jnz	ppzm_next
	push	es
	mov	ax,0409h
	int	ppz_vec
	mov	ax,es
	pop	es
	mov	es:[ppz_call_ofs],bx
	mov	es:[ppz_call_seg],ax
ppzm_next:
	mov	ax,1901h
	int	ppz_vec		;�풓�����֎~
	popf
endif
	ret

;==============================================================================
;	/W option
;==============================================================================
waitclk_set:
	call	get_comline_number
	jc	wait_newset
	test	al,al
	jz	usage
	xor	ah,ah
	mov	es:[wait_clock],ax
	ret
wait_newset:
	call	wait_check
	mov	es:[wait1_clock],ax
	mov	es:[wait_clock],cx
	ret

;==============================================================================
;	/G option
;==============================================================================
fftempo_set:
	call	get_comline_number
	jc	fft_newset
	test	al,al
	jz	usage
	mov	es:[ff_tempo],al
	ret
fft_newset:
	mov	es:[ff_tempo],250
	ret

;==============================================================================
;	/A option
;==============================================================================
adpcmwait_set:
	call	get_comline_number
	cmp	al,3
	jnc	usage
	mov	es:[adpcm_wait],al
	ret

;==============================================================================
;	/S option
;==============================================================================
pcm86vol_set:
	cmp	byte ptr ds:[si],"-"
	jz	p8v_minus
	mov	es:[pcm86_vol],1
	mov	es:[_pcm86_vol],1
	ret
p8v_minus:
	inc	si
	mov	es:[pcm86_vol],0
	mov	es:[_pcm86_vol],0
	ret

;==============================================================================
;	/O option
;==============================================================================
portsel_set:
	call	get_comline_number
	jc	usage
ife	va
	cmp	al,4
	jnc	usage
	mov	es:[port_sel],al
	push	ds
	push	si
	mov	ax,cs
	mov	ds,ax
	call	fm_check
	pop	si
	pop	ds
endif
	ret

;==============================================================================
;	/C option
;==============================================================================
message_clear_set:
	mov	[message_flag],0
	ret

;==============================================================================
;	�R�}���h���C�����琔�l��ǂݍ���(0-255)
;	IN. DS:SI to COMMAND_LINE
;	OUT.AL	  to NUMBER
;	    CY	  to Error_Flag
;==============================================================================
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

;==============================================================================
;	���l�̕\�� 16bit
;		input	AX
;==============================================================================
print_16:
	xor	dh,dh
	mov	bx,10000
	call	p16_oneset
	mov	bx,1000
	call	p16_oneset
	mov	bx,100
	call	p16_oneset
	mov	bx,10
	call	p16_oneset
	add	al,"0"
	mov	dl,al
	mov	ah,2
	int	21h	;�P�����\��
	ret

p16_oneset:
	mov	dl,"0"
onp0:	sub	ax,bx
	jc	onp1
	inc	dl
	jmp	onp0
onp1:	add	ax,bx

	test	dh,dh
	jnz	onp2
	cmp	dl,"0"
	jz	onp3
onp2:
	push	ax
	push	dx
	mov	ah,2
	int	21h	;�P�����\��
	pop	dx
	pop	ax
	inc	di
	mov	dh,1
onp3:
	ret

;==============================================================================
;	���̌���
;			input	si	���ϐ���+"="+0
;				es	��segment
;			output	es:di	����address
;				cy	1�Ȃ疳��
;==============================================================================
search_env:
	xor	di,di
	mov	cx,si
se_loop1:
	mov	dx,di
se_loop2:
	cmpsb
	jnz	se_next
	cmp	byte ptr -1[si],"="
	jnz	se_loop2
	clc		;es:di = "="�̎�������
	ret
se_next:
	mov	si,cx
	mov	di,dx
se_loop3:
	inc	di
	cmp	byte ptr es:-1[di],0
	jnz	se_loop3
	cmp	byte ptr es:[di],0
	jnz	se_loop1
	stc
	ret

;==============================================================================
;	Error����
;==============================================================================
pmderr_1:
	mov	dx,offset pmderror_mes1
	jmp	pmderr_main

pmderr_2:
	mov	dx,offset pmderror_mes2
	jmp	pmderr_main

pmderr_3:
	mov	dx,offset pmderror_mes3
	jmp	pmderr_main

pmderr_4:
	mov	dx,offset pmderror_mes4
	jmp	pmderr_main

pmderr_5:
	mov	dx,offset pmderror_mes5
	jmp	pmderr_main

pmderr_6:
	mov	dx,offset pmderror_mes6
	jmp	pmderr_main

pmderr_7:
	mov	dx,offset pmderror_mes7
	jmp	pmderr_main

pmderr_main:
	mov	ax,cs
	mov	ds,ax
	mov	ah,9
	int	21h
	error_exit	1

;==============================================================================
;	HZ or USAGE
;==============================================================================
hz_usage:
	lodsb
	and	al,11011111b
	cmp	al,"Z"
	jz	hz_set
usage:
	mov	ax,cs
	mov	ds,ax
	cmp	[opt_sp_push],0
	jz	no_kankyo
	print_mes	mes_warning
	print_mes	mes_kankyo
	mov	sp,[opt_sp_push]
	mov	cs:[opt_sp_push],0
	ret

no_kankyo:
	print_mes	mes_usage
	error_exit	255

;==============================================================================
;	/HZ PCM���g���Œ�ݒ�
;==============================================================================
hz_set:
	call	get_comline_number
	jc	usage
	cmp	al,9
	jnc	usage
if	board2*pcm
	mov	es:[p86_freq],al
	mov	bl,al
	cmp	al,8
	mov	ax,offset pcm_tune_data
	jz	hzset_00
	xor	bh,bh
	mov	ax,288
	mul	bx
	add	ax,offset hzdata
hzset_00:
	push	si
	mov	si,ax			;ds:si=���݂�pmd86��pcm_tune_data
	mov	di,offset pcm_tune_data	;es:di=�풓���Ă���pmd86��pcm_tune_data
	mov	cx,288/2
rep	movsw
	pop	si
endif
	ret

;==============================================================================
;	Wait��check
;==============================================================================
wait_check:
ife	va
	include	wait.inc
else
	mov	ax,1580		;V30 8MHz (9801VX/RA�̒l)
	mov	cx,2		;��
	mov	bx,1580*2	;��clock
	cmp	es:[ongen],0
	jz	va_not_ym2608
	ret
va_not_ym2608:
	mov	cx,3		;��
	mov	bx,1580*3	;��clock
	ret
endif

;==============================================================================
;	ADPCM Check PRG.include
;==============================================================================
if	board2*adpcm
 ife	ademu
	include	adramchk.asm
 endif
endif

;==============================================================================
;	DATAAREA(��풓��)
;==============================================================================
if	va
eof	equ	0
else
eof	equ	"$"
endif

mes_warning	db	07,"WARNING:$"
if	board2
 if	pcm+ppz
mes_not_board	db	"YM2608+PCM ��������܂���D",13,10,eof
 else
mes_not_board	db	"YM2608+ADPCM ��������܂���D",13,10,eof
 endif
else
mes_not_board	db	"�e�l�����{�[�h����������Ă��܂���D",13,10,eof
endif

mes_cut		db	"�풓�������܂����D",13,10,eof

mes_title	db	"�l���������@�c�����������@�o.�l.�c. for PC9801/88VA Version ",ver
ifdef	_optnam
		db	_optnam
endif
		db	13,10
		db	"Copyright (C)1989,",date," by M.Kajihara(KAJA).",13,10,13,10,eof

mes_int		db	"Int "
int_num		db	" ,Port "
if	va
		db	"44H"
else
port_num	db	" 88H"
endif
		db	"(",eof
mes_int2	db	")���g�p���܂��D",13,10,eof
ongen_sel	dw	mes_ongen0,mes_ongen1
mes_ongen0	db	"YM2203",eof
mes_ongen1	db	"YM2608",eof

if	board2*adpcm
pcm_sel		dw	mes_adpcm,mes_only
mes_adpcm	db	"+ADPCM",eof
mes_only	db	" only",eof
endif

if	board2*pcm
mes_pcm		db	"+PCM",eof
endif

mes_ppsdrv	db	"PPSDRV(INT64H)�ɑΉ����܂��D",13,10,eof
if	ppz
mes_ppz8	db	"PPZ8(INT7FH)�ɑΉ����܂��D",13,10,eof
endif
mes_wait1	db	"FM����LSI REG-DATA�� Waitloop��: ",eof
mes_wait2	db	"�� (�� ",eof
mes_wait3	db	"ns)",13,10,eof

cantcut_mes	db	"���ݏ풓�����͋֎~����Ă��܂��DPMD�֘ATSR���ɉ�����ĉ������D",13,10,eof
pmderror_mes1	db	"�풓����FM���荞�݃x�N�g�����Ⴂ�܂��D",13,10,eof
pmderror_mes2	db	"�ȃf�[�^�o�b�t�@�� 1KB �ȏ�ɂ��ĉ������D",13,10,eof
pmderror_mes3	db	"��+���F+���ʉ��f�[�^�̍��v�� 40KB �ȓ��ɂ��ĉ������D",13,10,eof
pmderror_mes4	db	"����Ɏ��s���܂����D",13,10,eof
pmderror_mes5	db	"�o�l�c�͏풓���Ă��܂���D",13,10,eof
pmderror_mes6	db	"�ύX�o���Ȃ��I�v�V�������w�肵�Ă��܂��D",13,10,eof
pmderror_mes7	db	"���������m�ۏo���܂���B",13,10,eof

mes_exit	db	"�풓���܂����D",13,10
		db	"INT 60H��PMD�𑀍�\�ł��D",13,10
		db	eof

mes_key		db	"ESC/GRPH�L�[�ŋȂ̒�~�A�����肪�\�ł��D",13,10,eof

mes_kankyo	db	"���ϐ� PMDOPT �̐ݒ�Ɍ�肪����܂��D",13,10,eof

mes_usage	db	"Usage:",9,"PMD"
if	va
		db	"VA"
 ife	board2
		db	"1"
 endif
else
 if	board2
  if pcm
		db	"86"
  else
   if ppz
		db	"PPZ"
   else
		db	"B2"
   endif
   if ademu
		db	"E"
   endif
  endif
 endif
endif
		db	" [/option[���l]][/option[���l]]..",13,10
		db	"Option:"
		db	9,"  /Mn  �ȃf�[�^      �o�b�t�@�T�C�Y�w��(KB�P��)Def.=16",13,10
		db	9,"  /Vn  ���F�f�[�^    �o�b�t�@�T�C�Y�w��(KB�P��)Def.= 8",13,10
		db	9,"  /En  FM���ʉ��f�[�^�o�b�t�@�T�C�Y�w��(KB�P��)Def.= 4",13,10
ife	va
		db	9,"  /On  FM���� PORT�w�� 0=088H 1=188H 2=288H 3=388H Def.=auto",13,10
endif
		db	9,"* /DFn FM������    ���ʒ����l�ݒ�(�ő�0�`�ŏ�255)Def.="
if	 board2
		db	" 0",13,10
else
		db	"16",13,10
endif
		db	9,"* /DSn SSG������   ���ʒ����l�ݒ�(�ő�0�`�ŏ�255)Def.= 0",13,10
if	board2
		db	9,"* /DPn PCM������   ���ʒ����l�ݒ�(�ő�0�`�ŏ�255)Def.= 0",13,10
if	ppz
		db	9,"* /DZn PPZ8   ��   ���ʒ����l�ݒ�(�ő�0�`�ŏ�255)Def.= 0",13,10
endif
		db	9,"* /DRn RHYTHM�����̉��ʒ����l�ݒ�(�ő�0�`�ŏ�255)Def.= 0",13,10
		db	9,"* /N(-)SSG�h�����Ɠ����Ƀ��Y��������炳�Ȃ�(�炷)",13,10
endif
		db	9,"* /K(-)ESC/GRPH�L�[�ŋȂ̒�~/����������Ȃ�(����)",13,10
if	va
		db	9,"* /KEn MSTOP/ESC �Ɠ����Ɏg�p����L�[�̐ݒ� Def.=4",13,10
		db	9,"* /KGn FF   /GRPH�Ɠ����Ɏg�p����L�[�̐ݒ� Def.=4",13,10
		db	9,"* /KRn REW  /GRPH�Ɠ����Ɏg�p����L�[�̐ݒ� Def.=2",13,10
		db	9,9,"�ݒ�l: 1=�� 2=SHIFT 4=CTRL (���Z���ĕ����w���)",13,10
else
		db	9,"* /KEn MSTOP/ESC �Ɠ����Ɏg�p����L�[�̐ݒ� Def.=16",13,10
		db	9,"* /KGn FF   /GRPH�Ɠ����Ɏg�p����L�[�̐ݒ� Def.=16",13,10
		db	9,"* /KRn REW  /GRPH�Ɠ����Ɏg�p����L�[�̐ݒ� Def.=1",13,10
		db	9,9,"�ݒ�l: 1=SHIFT 2=CAPS 4=�� 16=CTRL (���Z���ĕ����w���)",13,10
endif
		db	9,"* /F(-)�t�F�[�h�A�E�g��ɋȂ��~���Ȃ�(����)",13,10
		db	9,"* /I(-)FM/INT60���荞�ݒ��͊��荞�݂��֎~����(���Ȃ�)",13,10
		db	9,"* /P(-)PPSDRV�ɑΉ����Ȃ�(�풓���Ă�����Ή�����)",13,10
if	ppz
		db	9,"* /Z(-)PPZ8�ɑΉ����Ȃ�(�풓���Ă�����Ή�����)",13,10
endif
		db	9,"* /Wn  FM����REG-DATA�Ԃ�Wait�񐔂̐ݒ�(1�`255,���l�ȗ����͎�������)",13,10
		db	9,"* /Gn  GRPH�L�[�ɂ�鑁�����TimerB�l Def.=250",13,10
if	board2*adpcm
 ife	ademu
		db	9,"* /An  ADPCM��`���x 0=���� 1=���� 2=�ᑬ Def.=Auto",13,10
 endif
endif
if	board2*pcm
		db	9,"* /S(-)PCM�p�[�g�d�l��PMDB2�ɍ��킹��(���킹�Ȃ�)",13,10
		db	9,"* /HZn PCM���g��(0�`8,4.13/5.52/8.27/11.03/16.54/22.05/33.08/44.10/����)",13,10
endif
		db	9,"  /R   �풓��������",9,9,"/H   �w���v�̕\��",13,10
		db	9,"(* �̕t����option�͏풓��ɍĐݒ�\, - �͊��ʓ��ɐݒ�)",eof

changemes_0	db	"�ݒ��ύX���܂����D",13,10
crlf		db	13,10,eof
changemes_01	db	"�@----- ���݂̐ݒ� -----",13,10
		db	"�E�ȁ@�@�f�[�^�o�b�t�@�T�C�Y:",eof
changemes_02	db	"KB",13,10,"�E���F�@�f�[�^�o�b�t�@�T�C�Y:",eof
changemes_03	db	"KB",13,10,"�E���ʉ��f�[�^�o�b�t�@�T�C�Y:",eof
changemes_1	db	"KB",13,10,"�EFM����    ���ʒ����l:",eof
changemes_2	db	"�ESSG����   ���ʒ����l:",eof
if	board2
changemes_3	db	"�EPCM����   ���ʒ����l:",eof
if	ppz
changemes_3z	db	"�EPPZ8      ���ʒ����l:",eof
endif
changemes_4	db	"�ERHYTHM�������ʒ����l:",eof
changemes_5	db	"�ESSG�h�����������ɓ�����RHYTHM�������",eof
changemes_5a	db	"��",13,10,eof
changemes_5b	db	"���Ȃ�",13,10,eof
endif
changemes_6	db	"�EGRPH/ESC�L�[�ő�����/�Ȃ̒�~�𐧌�",eof
changemes_6a	db	"����",13,10,eof
changemes_6b	db	"���Ȃ�",13,10,eof
changemes_7	db	"�EMSTOP/ESC �Ɠ����Ɏg�p����L�[�ݒ�l:",eof
changemes_8	db	"�EFF   /GRPH�Ɠ����Ɏg�p����L�[�ݒ�l:",eof
changemes_8b	db	"�EREW  /GRPH�Ɠ����Ɏg�p����L�[�ݒ�l:",eof
changemes_9	db	"�E�t�F�[�h�A�E�g��ɋȂ̉��t���~",eof
changemes_10	db	"�EFM/INT60���荞�ݒ��Ɋ��荞�݂��֎~",eof
changemes_11	db	"�EPPSDRV���g�p",eof
changemes_11_	db	"�EPPZ8  ���g�p",eof
changemes_12	db	"�EFM����LSI REG-DATA�� Waitloop��: ",eof
changemes_12a	db	"��(�� ",eof
changemes_12b	db	"ns)",13,10,eof
changemes_13	db	"�EGRPH�ɂ�鑁���莞��TimerB�l: ",eof
if	board2*adpcm
 ife	ademu
changemes_14	db	"�EADPCM��`���x: ",eof
changemes_14a	db	"����",13,10,eof
changemes_14b	db	"����",13,10,eof
changemes_14c	db	"�ᑬ",13,10,eof
 endif
endif
if	board2*pcm
changemes_15	db	"�EPCM�p�[�g�d�l��PMDB2�ɍ��킹",eof
changemes_15a	db	"�Ȃ�",13,10,eof
changemes_15b	db	"��",13,10,eof
changemes_16	db	"�EPCM�Đ����g��: ",eof
changemes_16a	db	"4.13438",eof
		db	"5.51250",eof
		db	"8.26875",eof
		db	"11.0250",eof
		db	"16.5375",eof
		db	"22.0500",eof
		db	"33.0750",eof
		db	"44.1000",eof
		db	"�����I��",13,10,eof
changemes_16b	db	"KHz �Œ�",13,10,eof
endif

vector_table	db	"0",03
		dw	0bh*4		;int0
		db	"6",13
		dw	15h*4		;int6
		db	"4",10
		dw	12h*4		;int4
		db	"5",12
		dw	14h*4		;int5

;	�풓���鎞�̃I�v�V����
resident_option	db	"H"
		dw	hz_usage
		db	"M"
		dw	muslng_get
		db	"V"
		dw	voilng_get
		db	"E"
		dw	efclng_get
		db	"K"
		dw	keycheck
		db	"D"
		dw	fmvd_set
		db	"I"
		dw	disint_set
		db	"N"
		dw	notshot_set
		db	"F"
		dw	notstop_set
		db	"P"
		dw	ppsdrv_reset
		db	"Z"
		dw	ppz_reset
		db	"W"
		dw	waitclk_set
		db	"G"
		dw	fftempo_set
		db	"A"
		dw	adpcmwait_set
		db	"S"
		dw	pcm86vol_set
		db	"O"
		dw	portsel_set
		db	"R"
		dw	pmderr_5
		db	"C"
		dw	message_clear_set
		db	0

;	���ɏ풓�ς݂̎��̃I�v�V����
status_option	db	"H"
		dw	hz_usage
		db	"R"
		dw	resident_cut_main
		db	"K"
		dw	keycheck
		db	"D"
		dw	fmvd_set
		db	"I"
		dw	disint_set
		db	"N"
		dw	notshot_set
		db	"F"
		dw	notstop_set
		db	"P"
		dw	ppsdrv_reset
		db	"Z"
		dw	ppz_reset
		db	"W"
		dw	waitclk_set
		db	"G"
		dw	fftempo_set
		db	"A"
		dw	adpcmwait_set
		db	"S"
		dw	pcm86vol_set
		db	"M"
		dw	pmderr_6
		db	"V"
		dw	pmderr_6
		db	"E"
		dw	pmderr_6
		db	"Y"
		dw	pmderr_6
		db	"O"
		dw	pmderr_6
		db	"C"
		dw	message_clear_set
		db	0

resident_mes	db	resmes,0
rmes_end	label	byte

pmdopt_txt	db	"PMDOPT=",0

if	board2*pcm
hzdata:	include	hzdata.inc
endif

ife	va
	include	viruschk.inc
endif

epson_flag	db	?		;EPSON�@�Ȃ�1
ife	va
port_sel	db	?		;�I���|�[�g
opn_0eh		db	?
endif

message_flag	db	?
opt_sp_push	dw	?
resident_size	dw	?

pmd	endp

@code	ends
end	pmd