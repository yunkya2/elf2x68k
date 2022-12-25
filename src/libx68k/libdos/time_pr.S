| long _dos_time_pr (void);
.text
.even
.global _dos_time_pr
.type _dos_time_pr,@function
_dos_time_pr:
	.short	0xfffe
	rts
