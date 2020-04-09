.code16

.equ TMPBUFFER, 0x00009000

.global loadkernel

.section .text.boot

loadkernel:
    movw $__KERNEL_LBA_BLK_NBR, %cx
    movw $0x0000, .tgt_seg
    movw $TMPBUFFER, .tgt_off
    movl $__KERNEL_LBA_BLK_START, .src_blk
    movw $1, .rsectors
loadXsize:
    push %cx
    push %dx

    xorb %dh, %dh
    xor %esi, %esi
    movw $lba_struct, %si
    mov $0x42, %ah
    int $0x13
    mov $_error, %si
    jc loadperror

    movw $0x900, %ax
    movw %ax, %ds
    movw $0x1000, %ax
    movw %ax, %es

    movl $0x0, %esi
    movl .src_blk, %edi
    subl $__KERNEL_LBA_BLK_START, %edi
    imull $0x200, %edi
    movl $0x200, %ecx
    rep movsb

    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es

    pop %dx
    pop %cx
    loop loadXsize

    #ljmp $0x1000, $0x0

    ret

_error: .asciz "Error occured while loading kernel..."

lba_struct:
    .dap:      .byte  0x10
    .unused:   .byte  0
    .rsectors: .2byte 1
    .tgt_off:  .2byte 0
    .tgt_seg:  .2byte 0
    .src_blk:  .8byte 0

