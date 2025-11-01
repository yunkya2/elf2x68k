| void *_dos_s_malloc0 (int, int);
.text
.even
.global _dos_s_malloc0
.type _dos_s_malloc0,@function
_dos_s_malloc0:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %d0
	or.w	#0x8000, %d0
	move.w	%d0, %sp@-
	.short	0xffad
	lea	%sp@(10), %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
