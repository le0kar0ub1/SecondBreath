.code16

.equ BOOTSEG,  0x0
.equ MAGICMBR, 0xAA55

.equ RELOCATED, 0x0600

.global _bootloader

.section .bootloader, "ax"

.macro SYMRELOC sym
    $(\sym - 0x7C00 + 0x0600)
.endm

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

    pushw %dx # BIOS drive information

    sti

    movw $0x1, .rsectors
    movw $0x7E00, .tgt_off
    movw $1, .addrlow
    
    xor %esi, %esi
    movw $lba_struct, %si
    mov $0x42, %ah
    clc
    int $0x13
    jc perror

    jmp 0x7E00

    mov $scdbreathpr, %si
    call bprintstr

hang:
    jmp hang

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

scdbreathpr: .asciz "hello from secondbreath legacy bootloader"
_error: .asciz "Error occured"

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
