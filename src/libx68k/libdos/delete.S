| int _dos_delete (const char *);
.text
.even
.global _dos_delete
.type _dos_delete,@function
_dos_delete:
	move.l	%sp@(4), %sp@-
	.short	0xff41
	addq.l	#4, %sp
	rts
