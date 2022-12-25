| int _iocs_dmamode (void);
.text
.even
.global _iocs_dmamode
.type _iocs_dmamode,@function
_iocs_dmamode:
	moveq	#0xffffff8d, %d0
	trap	#15
	rts
