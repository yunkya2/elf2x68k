| int _dos_lock (int, int, int);
.text
.even
.global _dos_lock
.type _dos_lock,@function
_dos_lock:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	clr.w	%sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff8c
	bras	3f
2:
	.short	0xff5c
3:
	lea	%sp@(12), %sp
	rts
