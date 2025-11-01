/* Default linker script, for normal executables */
OUTPUT_FORMAT("elf32-m68k", "elf32-m68k", "elf32-m68k")
OUTPUT_ARCH(m68k)
ENTRY(_start)
SECTIONS
{
  .text : {
    KEEP (*(.header))
    *(.text .text.*)

    . = ALIGN(0x4);
    /* These are for running static constructors and destructors under ELF.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))

    *(.rodata .rodata.*)

    . = ALIGN(0x4);
    *(.gcc_except_table .gcc_except_table.*)

    . = ALIGN(0x4);
    *(.eh_frame)

    . = ALIGN(0x4);
    __INIT_SECTION__ = . ;
    LONG (0x4e560000)   /* linkw %fp,#0 */
    *(.init)
    SHORT (0x4e5e)      /* unlk %fp */
    SHORT (0x4e75)      /* rts */

    __FINI_SECTION__ = . ;
    LONG (0x4e560000)   /* linkw %fp,#0 */
    *(.fini)
    SHORT (0x4e5e)      /* unlk %fp */
    SHORT (0x4e75)      /* rts */

     _etext = .;
     *(.lit)
  }

  .data : {
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.*)
    _edata = .;
  }

  .bss : {
    . = ALIGN(0x4);
    __bss_start = . ;
    *(.shbss)
    *(.bss .bss.*)
    *(COMMON)
    *(.stack .stack.*)
    _end =  ALIGN (0x8);
    __end = _end;
    PROVIDE(end = .);
  }

  .comment 0 (NOLOAD) : { [ .comment ] [ .ident ] }
  .stab 0 (NOLOAD) : { [ .stab ] }
  .stabstr 0 (NOLOAD) : { [ .stabstr ] }
}
