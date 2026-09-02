ENTRY(_start)
PHDRS
{
  text PT_LOAD FLAGS(5);
  result PT_LOAD FLAGS(6);
}
SECTIONS
{
  . = 0x280;
  .text : { *(.text*) } :text
  .note.pto.isa : { KEEP(*(.note.pto.corpus)) } :text
  . = 0x380;
  .result : { *(.result*) } :result
  /DISCARD/ : { *(.note.pto.isa) }
}
