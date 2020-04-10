.code16

.equ TMPBUFFER, 0x00009000

.global loadkernel

.section .text.boot

loadkernel:
    xor %ecx, %ecx
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

    movl $TMPBUFFER, %esi
    movl %ecx, %edi
    imull $0x200, %edi
    addl $0x10000, %edi
    movl $0x200, %ecx
transfer:
    movb (%esi), %al
    movb %al, (%edi)
    incl %esi
    incl %edi
    loop transfer

    pop %dx
    pop %cx

    incw %cx
    cmpw $__KERNEL_LBA_BLK_NBR, %cx
    jne loadXsize

    ret

_error: .asciz "Error occured while loading kernel..."

lba_struct:
    .dap:      .byte  0x10
    .unused:   .byte  0
    .rsectors: .2byte 1
    .tgt_off:  .2byte 0
    .tgt_seg:  .2byte 0
    .src_blk:  .8byte 0

