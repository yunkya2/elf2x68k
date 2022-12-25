| int _iocs_wipe (void);
.text
.even
.global _iocs_wipe
.type _iocs_wipe,@function
_iocs_wipe:
	moveq	#0xffffffb5, %d0
	trap	#15
	rts
