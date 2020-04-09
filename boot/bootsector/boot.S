.code16

.equ BOOTSEG,  0x0
.equ MAGICMBR, 0xAA55

.equ RELOCATED, 0x0600

/*
** The bootloader entry point
** We just set load the rest of our bootloder
*/

.global _bootloader

.section .bootloader, "ax"

_bootloader:
    ljmp $BOOTSEG, $._bootloader

._bootloader:
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw %ax, %fs
    movw %ax, %gs
    xorw %sp, %sp
    cld

    mov $__BOOT_SECTOR_START, %sp

    push %dx # BIOS drive information

    sti

    mov $scdbreathpr, %si
    call bprintstr

    xorb %ah, %ah
    int $0x16

    /*
    ** We load the totality of our stage2 bootloader here 
    ** no security if overlaps occured -> fatal 
    */
    movw $__BOOT_SECTOR_BLK_NBR, %cx
    movw $0x7E00, .tgt_off
    clc
loadXsize:
    push %cx
    movw $1, .rsectors
    addw $1, .addrlow
    
    xor %esi, %esi
    movw $lba_struct, %si
    mov $0x42, %ah
    int $0x13
    jc perror

    pop %cx
    addw $0x200, .tgt_off
    loop loadXsize

    jmp 0x7E00 # jump to our second breath bootloader

    /* unreachable code */
    jmp biosKill

/* Tools */
bprintstr:
    lodsb
    andb %al, %al
    jz   .bendprint
    movb $0xe, %ah
    movw $7, %bx
    int  $0x10
    jmp  bprintstr
.bendprint:
    ret

perror:
    mov $_error, %si
    call bprintstr
reDie:
    xorb %ah, %ah
    int $0x16
    cmp $0x011B, %ax
    jne reDie

biosKill:
    int $0x19 # BIOS poweroff
    ljmp $0xf000,$0xfff0 # case error reset code

scdbreathpr: .asciz " *\n\r* SecondBreath legacy bootloader\n\r *\n\nPress any key to boot..."
_error: .asciz "Error occured while loading bootloader..."

lba_struct:
.dap:      .byte  0x10
.unused:   .byte  0
.rsectors: .2byte 1
.tgt_off:  .2byte 0
.tgt_seg:  .2byte 0
.addrlow:  .4byte 0
.addrhigh: .4byte 0

.fill 0x1FE - (. - _bootloader), 1, 0

.section .bootmagic, "ax"
.word MAGICMBR
