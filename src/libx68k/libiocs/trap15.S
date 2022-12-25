| int _iocs_trap15 (struct iocs_regs *, struct iocs_regs *)
.text
.even
.global _iocs_trap15
.type _iocs_trap15,@function
_iocs_trap15:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	moveal	%sp@(48),%a0	| inregs
	moveml	%a0@,%d0-%d7/%a1-%a6
	trap	#15
	moveal	%sp@(52),%a0	| outregs
	moveml	%d0-%d7/%a1-%a6,%a0@
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts

