;
;	Viruschk��ɂ��̎|�\������
;
	mov	dx,cs
	mov	ds,dx

	mov	dx,offset virus_mes
	dec	ax
	jz	vprint_end
	mov	dx,offset rename_mes
	jmp	vprint_end

rename_mes	db	"!����! ���sFile����rename����Ă��܂��B",13,10,"$"
virus_mes	db	"!�x��! �v���O�������E�C���X�ɐN����Ă���\��������܂��B",13,10,"$"

vprint_end:
	mov	ah,9
	int	21h