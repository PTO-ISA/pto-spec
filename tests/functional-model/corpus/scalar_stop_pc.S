.section .text,"ax"
.globl _start
_start:
  # C.MOVI R1, 10; C.MOVI R2, 15; ADD R1, R2.sw, ->R3
  .byte 0x96,0x0a,0xd6,0x13,0x85,0x81,0x20,0x00
  # HL.XORI R1, 0x800000, ->R1; C.MOVI R0, 0 (alignment pad)
  .byte 0x0e,0x80,0x95,0xc0,0x00,0x00,0x16,0x00
  # SW.PCR R3, [0x200] from TPC 0x110, signed word displacement 60.
  .byte 0x69,0xa0,0xc1,0x03
.section .result,"aw"
.globl cross_model_result
cross_model_result: .zero 4
.globl cross_model_result_size
.set cross_model_result_size,4
