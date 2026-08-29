.section .text,"ax"
.globl _start
_start:
  .byte 0x11,0x00,0x00,0x00
  .byte 0x0f,0x00,0x00,0x00,0x01,0x00,0x00,0x00
.section .result,"aw"
.globl cross_model_result
cross_model_result: .zero 4
.globl cross_model_result_size
.set cross_model_result_size,4
