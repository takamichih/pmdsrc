;==============================================================================
;	���g��table 16.54kHz = o5g
;==============================================================================
fq	macro	data1,data2
	db	data1
	dw	data2
	endm

pcm_tune_data	label	byte
;		���g��*32+ ���Z�l(������) , ���Z�l(������)
	fq	0*32+0 ,02AB7h ;o1  4.13438 C 
	fq	0*32+0 ,02D41h ;o1  4.13438 C#
	fq	0*32+0 ,02FF2h ;o1  4.13438 D 
	fq	0*32+0 ,032CBh ;o1  4.13438 D#
	fq	0*32+0 ,035D1h ;o1  4.13438 E 
	fq	0*32+0 ,03904h ;o1  4.13438 F 
	fq	0*32+0 ,03C68h ;o1  4.13438 F#
	fq	0*32+0 ,03FFFh ;o1  4.13438 G 
	fq	0*32+0 ,043CEh ;o1  4.13438 G#
	fq	0*32+0 ,047D6h ;o1  4.13438 A 
	fq	0*32+0 ,04C1Bh ;o1  4.13438 A#
	fq	0*32+0 ,050A2h ;o1  4.13438 B 

	fq	0*32+0 ,0556Eh ;o2  4.13438 C 
	fq	0*32+0 ,05A82h ;o2  4.13438 C#
	fq	0*32+0 ,05FE4h ;o2  4.13438 D 
	fq	0*32+0 ,06597h ;o2  4.13438 D#
	fq	0*32+0 ,06BA2h ;o2  4.13438 E 
	fq	0*32+0 ,07209h ;o2  4.13438 F 
	fq	0*32+0 ,078D0h ;o2  4.13438 F#
	fq	0*32+0 ,07FFFh ;o2  4.13438 G 
	fq	0*32+0 ,0879Ch ;o2  4.13438 G#
	fq	0*32+0 ,08FACh ;o2  4.13438 A 
	fq	0*32+0 ,09837h ;o2  4.13438 A#
	fq	0*32+0 ,0A145h ;o2  4.13438 B 

	fq	0*32+0 ,0AADCh ;o3  4.13438 C 
	fq	0*32+0 ,0B504h ;o3  4.13438 C#
	fq	0*32+0 ,0BFC8h ;o3  4.13438 D 
	fq	0*32+0 ,0CB2Fh ;o3  4.13438 D#
	fq	0*32+0 ,0D744h ;o3  4.13438 E 
	fq	0*32+0 ,0E412h ;o3  4.13438 F 
	fq	0*32+0 ,0F1A1h ;o3  4.13438 F#
	fq	0*32+1 ,00000h ;o3  4.13438 G 
	fq	1*32+0 ,0CB6Bh ;o3  5.51250 G#
	fq	1*32+0 ,0D783h ;o3  5.51250 A 
	fq	1*32+0 ,0E454h ;o3  5.51250 A#
	fq	1*32+0 ,0F1E7h ;o3  5.51250 B 

	fq	2*32+0 ,0AADCh ;o4  8.26875 C 
	fq	2*32+0 ,0B504h ;o4  8.26875 C#
	fq	2*32+0 ,0BFC8h ;o4  8.26875 D 
	fq	2*32+0 ,0CB2Fh ;o4  8.26875 D#
	fq	2*32+0 ,0D744h ;o4  8.26875 E 
	fq	2*32+0 ,0E412h ;o4  8.26875 F 
	fq	2*32+0 ,0F1A1h ;o4  8.26875 F#
	fq	2*32+1 ,00000h ;o4  8.26875 G 
	fq	3*32+0 ,0CB6Bh ;o4 11.02500 G#
	fq	3*32+0 ,0D783h ;o4 11.02500 A 
	fq	3*32+0 ,0E454h ;o4 11.02500 A#
	fq	3*32+0 ,0F1E7h ;o4 11.02500 B 

	fq	4*32+0 ,0AADCh ;o5 16.53750 C 
	fq	4*32+0 ,0B504h ;o5 16.53750 C#
	fq	4*32+0 ,0BFC8h ;o5 16.53750 D 
	fq	4*32+0 ,0CB2Fh ;o5 16.53750 D#
	fq	4*32+0 ,0D744h ;o5 16.53750 E 
	fq	4*32+0 ,0E412h ;o5 16.53750 F 
	fq	4*32+0 ,0F1A1h ;o5 16.53750 F#
	fq	4*32+1 ,00000h ;o5 16.53750 G 
	fq	5*32+0 ,0CB6Bh ;o5 22.05000 G#
	fq	5*32+0 ,0D783h ;o5 22.05000 A 
	fq	5*32+0 ,0E454h ;o5 22.05000 A#
	fq	5*32+0 ,0F1E7h ;o5 22.05000 B 

	fq	6*32+0 ,0AADCh ;o6 33.07500 C 
	fq	6*32+0 ,0B504h ;o6 33.07500 C#
	fq	6*32+0 ,0BFC8h ;o6 33.07500 D 
	fq	6*32+0 ,0CB2Fh ;o6 33.07500 D#
	fq	6*32+0 ,0D744h ;o6 33.07500 E 
	fq	6*32+0 ,0E412h ;o6 33.07500 F 
	fq	6*32+0 ,0F1A1h ;o6 33.07500 F#
	fq	6*32+1 ,00000h ;o6 33.07500 G 
	fq	7*32+0 ,0CB6Bh ;o6 44.10000 G#
	fq	7*32+0 ,0D783h ;o6 44.10000 A 
	fq	7*32+0 ,0E454h ;o6 44.10000 A#
	fq	7*32+0 ,0F1E7h ;o6 44.10000 B 

	fq	7*32+1 ,0004Ah ;o7 44.10000 C 
	fq	7*32+1 ,00F87h ;o7 44.10000 C#
	fq	7*32+1 ,01FACh ;o7 44.10000 D 
	fq	7*32+1 ,030C7h ;o7 44.10000 D#
	fq	7*32+1 ,042E7h ;o7 44.10000 E 
	fq	7*32+1 ,0561Ch ;o7 44.10000 F 
	fq	7*32+1 ,06A72h ;o7 44.10000 F#
	fq	7*32+1 ,08000h ;o7 44.10000 G 
	fq	7*32+1 ,096D6h ;o7 44.10000 G#
	fq	7*32+1 ,0AF06h ;o7 44.10000 A 
	fq	7*32+1 ,0C8A8h ;o7 44.10000 A#
	fq	7*32+1 ,0E3CFh ;o7 44.10000 B 

	fq	7*32+2 ,00094h ;o8 44.10000 C 
	fq	7*32+2 ,01F0Eh ;o8 44.10000 C#
	fq	7*32+2 ,03F59h ;o8 44.10000 D 
	fq	7*32+2 ,0618Fh ;o8 44.10000 D#
	fq	7*32+2 ,085CEh ;o8 44.10000 E 
	fq	7*32+2 ,0AC38h ;o8 44.10000 F 
	fq	7*32+2 ,0D4E5h ;o8 44.10000 F#
	fq	7*32+3 ,00000h ;o8 44.10000 G 
	fq	7*32+3 ,02DACh ;o8 44.10000 G#
	fq	7*32+3 ,05E0Dh ;o8 44.10000 A 
	fq	7*32+3 ,09150h ;o8 44.10000 A#
	fq	7*32+3 ,0C79Eh ;o8 44.10000 B 