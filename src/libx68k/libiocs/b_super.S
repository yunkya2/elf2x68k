| int _iocs_b_super (int);
.text
.even
.global _iocs_b_super
.type _iocs_b_super,@function
_iocs_b_super:
	movea.l	%sp@+, %a0
	move.l	%sp@, %d0
	beq		1f
	move.l	%sp, %usp
1:
	movea.l	%d0, %a1
	moveq	#0xffffff81, %d0
	trap	#15
	jmp	%a0@
