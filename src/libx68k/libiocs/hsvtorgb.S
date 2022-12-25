| int __pure _iocs_hsvtorgb (int, int, int) __attribute__((const));
.text
.even
.global _iocs_hsvtorgb
.type _iocs_hsvtorgb,@function
_iocs_hsvtorgb:
	move.b	%sp@(7), %d1
	swap	%d1
	move.b	%sp@(11), %d1
	lsl.w	#8, %d1
	move.b	%sp@(15), %d1
	and.l	#0x00ff1f1f, %d1
	moveq	#0x12, %d0
	trap	#15
	rts
