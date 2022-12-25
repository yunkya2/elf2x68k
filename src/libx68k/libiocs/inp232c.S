| int _iocs_inp232c (void);
.text
.even
.global _iocs_inp232c
.type _iocs_inp232c,@function
_iocs_inp232c:
	moveq	#0x32, %d0
	trap	#15
	rts
