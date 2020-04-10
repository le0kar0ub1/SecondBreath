.code16

.equ TMPBUFFER, 0x00009000

.global loadkernel

.section .text.boot

loadkernel:
    xorw %cx, %cx
loadXsize:
    push %cx
    push %dx

    movw $0x0000, .tgt_seg
    movw $TMPBUFFER, .tgt_off
    movl $__KERNEL_LBA_BLK_START, .src_blk
    addw %cx, .src_blk
    movw $1, .rsectors

    xorb %dh, %dh
    xor %esi, %esi
    movw $lba_struct, %si
    mov $0x42, %ah
    int $0x13
    mov $_error, %si
    jc loadperror

    movw $0x900, %ax
    movw %ax, %ds

    cmpw $128, %cx
    jg increase

    movw $0x1000, %ax
    movw %ax, %es

    movl %ecx, %edi
    imul $0x200, %edi

transfer:
    movl $0x0, %esi
    movl $0x200, %ecx
    rep movsb

    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es

    pop %dx
    pop %cx

    incw %cx
    cmpw $__KERNEL_LBA_BLK_NBR, %cx
    jne loadXsize

    ret


/* 
** INCREASE OUR SEGMENT
*/
increase:
    movw $0xFFFF, %ax
    movw %ax, %es

    movl %ecx, %edi
    sub $128, %edi
    imul $0x200, %edi
    movb $4, (%esi)

    jmp transfer

_error: .asciz "Error occured while loading kernel..."

lba_struct:
    .dap:      .byte  0x10
    .unused:   .byte  0
    .rsectors: .2byte 1
    .tgt_off:  .2byte 0
    .tgt_seg:  .2byte 0
    .src_blk:  .8byte 0

