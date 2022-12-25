| int _dos_kill_pr (void);
.text
.even
.global _dos_kill_pr
.type _dos_kill_pr,@function
_dos_kill_pr:
	.short	0xfff9
	rts
