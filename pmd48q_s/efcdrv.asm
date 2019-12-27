;
;	�o�r�f�@�h�����X�����ʉ��@���[�`��
;	�e�������@�v�s�Q�X�W
;
;	AL �� ���ʉ��m���D�����ā@�b�`�k�k����
;	ppsdrv������Ȃ炻������炷
;

effgo:	cmp	[ppsdrv_flag],0
	jz	effgo2
	or	al,80h
	cmp	[last_shot_data],al
	mov	[last_shot_data],al
	jnz	effgo2
	push	ax
	xor	ah,ah
	int	ppsdrv		;���O���������F�Ȃ�_���v
	pop	ax
effgo2:
	mov	[hosei_flag],3	;����/���ʕ␳���� (K part)
	jmp	eff_main
eff_on2:
	mov	[hosei_flag],1	;�����̂ݕ␳���� (n command)
	jmp	eff_main
eff_on:
	mov	[hosei_flag],0	;�␳���� (INT60)
eff_main:
	mov	bx,cs
	mov	ds,bx

	cmp	[effflag],0
	jz	eg_00
	ret		;���ʉ����g�p���Ȃ����[�h
eg_00:
	cmp	[ppsdrv_flag],0
	jz	eg_nonppsdrv
	or	al,al
	jns	eg_nonppsdrv

;	ppsdrv
	cmp	[effon],2
	jnc	effret		;�ʏ���ʉ��������͔��������Ȃ�

	mov	bx,offset part9	;PSG 3ch
	or	partmask[bx],2	;Part Mask
	mov	[effon],1	;�D��x�P(ppsdrv)
	mov	[psgefcnum],al	;���F�ԍ��ݒ� (80H�`)

	mov	bx,15
	mov	ah,[hosei_flag]
	ror	ah,1
	jnc	not_tone_hosei
	mov	bx,detune[di]
	mov	bh,bl		;BH = Detune�̉��� 8bit
	mov	bl,15
not_tone_hosei:
	ror	ah,1
	jnc	not_volume_hosei
	mov	ah,volume[di]
	cmp	ah,15
	jnc	fade_hosei
	mov	bl,ah		;BL = volume�l (0�`15)
fade_hosei:
	mov	ah,[fadeout_volume]
	test	ah,ah
	jz	not_volume_hosei
	push	ax
	mov	al,bl
	neg	ah
	mul	ah
	mov	bl,ah
	pop	ax
not_volume_hosei:
	test	bl,bl
	jz	ppsdrm_ret
	xor	bl,00001111b
	mov	ah,1
	and	al,7fh
	int	ppsdrv		;ppsdrv keyon
ppsdrm_ret:
	ret

;	TimerA
eg_nonppsdrv:
	mov	[psgefcnum],al
	xor	ah,ah
	mov	bx,ax
	add	bx,bx
	add	bx,ax
	add	bx,offset efftbl

	mov	al,[effon]
	cmp	al,[bx]		;�D�揇��
	ja	eg_ret

	cmp	[ppsdrv_flag],0
	jz	eok_nonppsdrv
	xor	ah,ah
	int	ppsdrv		;ppsdrv ����keyoff
eok_nonppsdrv:
	mov	si,+1[bx]
	add	si,offset efftbl
	mov	al,[bx]		;AL=�D�揇��
	push	ax
	mov	bx,offset part9	;PSG 3ch
	or	partmask[bx],2	;Part Mask
	call	efffor		;�P���ڂ𔭉�
	pop	ax
	mov	[effon],al	;�D�揇�ʂ�ݒ�(�����J�n)
eg_ret:
	ret

;
;	���[������@���񂻂��@�߂���	
; 	�e�������@�u�q�s�b
;

effplay:
	mov	dl,[effcnt]

	dec	[effcnt]
	jne	effsweep	;�V�����Z�b�g����Ȃ�

	mov	si,[effadr]
efffor:
	lodsb
	cmp	al,-1
	je	effend
	mov	[effcnt],al	;�J�E���g��

	mov	dh,4		;���g�����W�X�^
	pushf
	cli
	call	efsnd		;���g���Z�b�g
	mov	cl,dl
	call	efsnd		;���g���Z�b�g
	popf
	mov	ch,dl
	mov	[eswthz],cx

	mov	dl,[si]
	mov	[eswnhz],dl
	mov	dh,6
	call	efsnd		; �m�C�Y
	mov	[psnoi_last],dl

	lodsb			; �f�[�^
	mov	dl,al
	rol	dl,1
	rol	dl,1
	and	dl,00100100b
	pushf
	cli
	call	get07
	and	al,11011011b
	or	dl,al
	call	opnset44		;MIX CONTROLL...
	popf

	mov	dh,10
	call	efsnd		;�{�����[��
	call	efsnd		;�G���x���[�v���g��
	call	efsnd
	call	efsnd		;�G���x���[�vPATTARN

	lodsb
	cbw
	mov	[eswtst],ax	;�X�C�[�v���� (TONE)
	lodsb
	mov	[eswnst],al	;�X�C�[�v���� (NOISE)

	and	al,15
	mov	[eswnct],al	;�X�C�[�v�J�E���g (NOISE)

	mov	[effadr],si
effret:	ret

efsnd:	lodsb
	mov	dl,al
	call	opnset44
	inc	dh
	ret

effoff:
	mov	dx,cs
	mov	ds,dx
effend:
	cmp	[ppsdrv_flag],0
	jz	ee_nonppsdrv
	xor	ah,ah
	int	ppsdrv		;ppsdrv keyoff
ee_nonppsdrv:
	mov	dx,0a00h
	call	opnset44	;volume min
	mov	dh,7
	pushf
	cli
	call	get07
	mov	dl,al		;NOISE CUT
	and	dl,11011011b
	or	dl,00100100b
	call	opnset44
	popf
	mov	[effon],0
	mov	[psgefcnum],-1
	ret

;���i�̏���

effsweep:
	mov	ax,[eswthz]	;�X�C�[�v���g
	add	ax,[eswtst]
	mov	[eswthz],ax	;�X�C�[�v���g
	mov	dh,4		;REG
	mov	dl,al		;DATA
	pushf
	cli
	call	opnset44
	inc	dh
	mov	dl,ah
	call	opnset44

	call	get07
	mov	dl,al
	mov	dh,7
	call	opnset44
	popf

	mov	dl,[eswnst]
	or	dl,dl
	je	effret		;�m�C�Y�X�C�[�v����

	dec	[eswnct]
	jnz	effret

	mov	al,dl
	and	al,15
	mov	[eswnct],al

	sar	dl,1
	sar	dl,1
	sar	dl,1
	sar	dl,1
	add	[eswnhz],dl
	mov	dl,[eswnhz]
	mov	dh,6
	call	opnset44
	mov	[psnoi_last],dl
	ret

effadr		dw	?	;effect address
eswthz		dw	?	;�g�[���X�D�C�[�v���g��
eswtst		dw	?	;�g�[���X�D�C�[�v����
effcnt		db	?	;effect count
eswnhz		db	?	;�m�C�Y�X�D�C�[�v���g��
eswnst		db	?	;�m�C�Y�X�D�C�[�v����
eswnct		db	?	;�m�C�Y�X�D�C�[�v�J�E���g
effon		db	?	;���ʉ��@������
psgefcnum	db	?	;���ʉ��ԍ�
hosei_flag	db	?	;ppsdrv ����/�����␳�����邩�ǂ���
last_shot_data	db	?	;�Ō�ɔ���������PPSDRV���F