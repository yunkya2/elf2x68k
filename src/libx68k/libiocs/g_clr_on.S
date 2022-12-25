| void _iocs_g_clr_on (void);
.text
.even
.global _iocs_g_clr_on
.type _iocs_g_clr_on,@function
_iocs_g_clr_on:
	moveq	#0xffffff90, %d0
	trap	#15
	rts
