.code16

BOOTSEG  = 0x0
MAGICMBR = 0xAA55

.section .bootsector, "ax"

.global _bootsector

_bootsector:
    ljmp $BOOTSEG, $._bootsector

._bootsector:
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw %ax, %fs
    movw %ax, %gs
    xorw %sp, %sp
    cld

    mov $__BOOT_SECTOR_START, %sp

    pushl %edx # bios value

    sti

.if scdbreath == 0
    mov $0x3, %ax
    int $0x10

    movw $0x600, %ax
    movb $0x3, %bh
    xorw %cx, %cx
    movw $0x184F, %dx
    int $0x10

    mov $0x103, %ax
    mov $0x105, %cx
    int $0x10
.endif

    movw $_bootmsg, %si
    call bprintstr

    xorw %ax, %ax
    int  $0x16

.hang:
    jmp .hang

booterror:
    call bprintstr
    mov $_booterror, %si
    call bprintstr
    xorw %ax, %ax
    int $0x16
    jmp bioskill

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

bioskill:
    int $0x19 # BIOS poweroff
    ljmp $0xf000,$0xfff0 # case error reset code

_bootmsg: .asciz " *\r\n* Lightbeam legacy bootloader\r\n *\r\n\n"

_booterror_rd: .asciz "\n\rRead disk sectors failed..."
_booterror:    .asciz " Press any key to reboot\n\r"

.fill 510-(.-_bootsector), 1, 0

.section .bootmagic, "ax"
.word MAGICMBR