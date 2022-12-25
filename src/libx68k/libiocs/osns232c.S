| int _iocs_osns232c (void);
.text
.even
.global _iocs_osns232c
.type _iocs_osns232c,@function
_iocs_osns232c:
	moveq	#0x34, %d0
	trap	#15
	rts
