| int _iocs_adpcmsns (void);
.text
.even
.global _iocs_adpcmsns
.type _iocs_adpcmsns,@function
_iocs_adpcmsns:
	moveq	#0x66, %d0
	trap	#15
	rts
