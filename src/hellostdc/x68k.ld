/* Default linker script, for normal executables */
OUTPUT_FORMAT("elf32-m68k", "elf32-m68k", "elf32-m68k")
OUTPUT_ARCH(m68k)
ENTRY(_start)
SECTIONS
{
  .text  0x000000 : {
     *(.init)
    *(.text)
    *(.text.*)
     *(.fini)
    . = ALIGN (4);
     etext = .;
     _etext = .;
  }
  .data  SIZEOF(.text) + ADDR(.text) :
  {
     __ctors_start = . ;
     *(.ctors)
     __ctors_end = . ;
     __dtors_start = . ;
     *(.dtors)
     __dtors_end = . ;
    KEEP(SORT(*)(.ctors))
    KEEP(SORT(*)(.dtors))
    *(.data)
    *(.data*)
    *(.rodata)  /* We need to include .rodata here if gcc is used */
    *(.rodata*) /* with -fdata-sections.  */
    *(.gcc_exc*)
    ___EH_FRAME_BEGIN__ = . ;
    *(.eh_fram*)
    ___EH_FRAME_END__ = . ;
    . = ALIGN (4);
     edata = .;
     _edata = .;
  }
  .bss  SIZEOF(.data) + ADDR(.data) :
  {
    *(.bss)
    *(COMMON)
    . = ALIGN (2);
     end = .;
     _end = .;
  }
  .comment 0 (NOLOAD) : { [ .comment ] [ .ident ] }
  .stab 0 (NOLOAD) : { [ .stab ] }
  .stabstr 0 (NOLOAD) : { [ .stabstr ] }
}
