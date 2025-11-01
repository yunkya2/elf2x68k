| int _dos_rename (const char *, const char *);
.text
.even
.global _dos_rename
.type _dos_rename,@function
_dos_rename:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff86
	addq.l	#8, %sp
	rts
