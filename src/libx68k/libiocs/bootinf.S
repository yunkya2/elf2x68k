| int __pure _iocs_bootinf (void) __attribute__((const));
.text
.even
.global _iocs_bootinf
.type _iocs_bootinf,@function
_iocs_bootinf:
	moveq	#0xffffff8e, %d0
	trap	#15
	rts
