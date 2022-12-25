| int _iocs_pset (const struct _iocs_psetptr *);
.text
.even
.global _iocs_pset
.type _iocs_pset,@function
_iocs_pset:
	move.l	%sp@(4), %a1
	moveq	#0xffffffb6, %d0
	trap	#15
	rts
