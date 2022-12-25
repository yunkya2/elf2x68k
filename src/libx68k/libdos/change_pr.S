| void _dos_change_pr (void);
.text
.even
.global _dos_change_pr
.type _dos_change_pr,@function
_dos_change_pr:
	.short	0xffff
	rts
