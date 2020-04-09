.code16

.equ TMPBUFFER, 0x00009000

.global loadkernel

.section .text.boot

loadkernel:
    movw $__KERNEL_LBA_BLK_NBR, %cx
    movw $0x0000, .tgt_seg
    movw $TMPBUFFER, .tgt_off
    movw $__KERNEL_LBA_BLK_START, .src_blk
    subw $1, .src_blk
    movw $1, .rsectors
loadXsize:
    push %cx
    
    xor %esi, %esi
    movw $lba_struct, %si
    mov $0x42, %ah
    int $0x13
    mov $_error, %si
    jc loadperror

    #movw .tgt_off, %si
    #movw .src_blk, %di
    #imul $0x200, %di
    #mov $0x200, %cx
    #rep movsb

    pop %cx
    addw $1, .src_blk
    loop loadXsize

    call  0x10000
    ret

    jmp loadkernel

_error: .asciz "Error occured while loading kernel..."

lba_struct:
    .dap:      .byte  0x10
    .unused:   .byte  0
    .rsectors: .2byte 1
    .tgt_off:  .2byte 0
    .tgt_seg:  .2byte 0
    .src_blk:  .8byte 0

