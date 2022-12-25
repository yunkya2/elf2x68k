| int _iocs_crtcras (const void *, int);
.text
.even
.global _iocs_crtcras
.type _iocs_crtcras,@function
_iocs_crtcras:
	movea.l	%sp@(4), %a1
	move.l	%sp@(8) , %d1
	moveq	#0x6d, %d0
	trap	#15
	rts
