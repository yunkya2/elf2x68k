| int _dos_s_process (int, int, int, int);
.text
.even
.global _dos_s_process
.type _dos_s_process,@function
_dos_s_process:
	movem.l	%sp@(4), %d0-%d1/%a0-%a1
	movem.l	%d1/%a0-%a1, %sp@-
	move.w	%d0, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xffaf
	bras	3f
2:
	.short	0xff7f
3:
	lea	%sp@(14), %sp
	rts
