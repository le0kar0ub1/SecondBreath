.code16

.global loadkernel

.section .text.boot

loadkernel:
    jmp loadkernel

_error: .asciz "Error occured while loading kernel..."

lba_struct:
    .dap:      .byte  0x10
    .unused:   .byte  0
    .rsectors: .2byte 1
    .tgt_off:  .2byte 0
    .tgt_seg:  .2byte 0
    .addrlow:  .4byte 0
    .addrhigh: .4byte 0

