| int __pure _iocs_romver (void) __attribute__((const));
.text
.even
.global _iocs_romver
.type _iocs_romver,@function
_iocs_romver:
	moveq	#0xffffff8f, %d0
	trap	#15
	rts
