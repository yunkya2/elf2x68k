| int _dos_super (int);
.text
.even
.global _dos_super
.type _dos_super,@function
_dos_super:
	movea.l	%sp@+, %a1
	.short	0xff20
	jmp	%a1@
