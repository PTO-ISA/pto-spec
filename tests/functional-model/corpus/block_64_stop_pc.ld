PHDRS { text PT_LOAD FLAGS(5); result PT_LOAD FLAGS(6); }
SECTIONS { . = 0x280; .text : { *(.text*) } :text . = 0x200; .result : { *(.result*) } :result }
