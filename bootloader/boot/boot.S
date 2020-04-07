.code16

.equ BOOTSEG,  0x0
.equ MAGICMBR, 0xAA55

.equ RELOCATED, 0x0600

.equ PARTSTART, 0x430
.equ PARTNBR,   0x4
.equ PARTSIZE,  0x10

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
    cli

    mov $__BOOT_SECTOR_START, %sp

    mov $0x7C00, %si
    mov $RELOCATED, %di
    mov $0x0200, %cx
    rep movsb

    jmp over + RELOCATED

.equ over, . - 0x7C00

    pushw %dx # bios value

    sti

    mov $0x3, %ax
    int $0x10

    call biosCleanScreen

    mov $0x103, %ax
    mov $0x105, %cx
    int $0x10

    movw $_bootmsg, %si
    call bprintstr

    xorw %cx, %cx
    movw $(0x430 + RELOCATED), %bp # yes its the lastest register we got X)
    xorw %bx, %bx

    movb $0x1, bpartactive
dump_partition:
    pushw %bp
    cmpb $0x80, (%bp)
    jne printBasePart
    movb $0x1, bpartactive

    printBasePart:
        movw $_partbase, %si
        call bprintstr
        movb $0xE, %ah
        movb %cl, %al
        addb $0x31, %al
        int $0x10

        cmpb $0x1, bpartactive 
        jne endOfPartX

    printActive:
        mov $_active, %si
        call bprintstr

    endOfPartX:
        movb $0x0, bpartactive
        popw %bp
        addw PARTSIZE, %bp
        incw %cx
        cmpw $PARTNBR, %cx
        jne dump_partition

    xorw %si, %si
user_boot:
    mov $0x2, %ah
    mov $0x0, %bh
    mov %si, %dx
    imulw $0x100, %dx
    addw $(0x100 * 6 + 7), %dx
    int $0x10

    mov $0x0, %ah
    int $0x16

    cmp $0x011B, %ax # escape
    je biosKill

    cmp $0x1C0D, %ax # enter
    je booting

    cmp $0x4800, %ax # up arrow
    je moveup

    cmp $0x5000, %ax # down arrow
    je movedown

    jmp user_boot

    movedown:
        cmpw $0x3, %si
        je user_boot
        inc %si
        jmp user_boot

    moveup:
        cmpw $0x0, %si
        je user_boot
        dec %si
        jmp user_boot


booting:
    pushw %si
.if $scdbreath == 1
    jmp _scdbreath
.endif
    mov $0x2, %ah
    mov $0x0, %dx
    int $0x10

    call biosCleanScreen

    mov (430 + RELOCATED), %bp
    popw %si
    shlw $4, %si
    addw %si, %bp

    popw %dx
    movb %dl, (%bp)

    push %bp
    movb $0x0, 0x10(%bp)
    movb $0x5, 0x11(%bp)


    /* READ OUR SECTOR */
    mov $0x41, %ah
    mov $0x55AA, %bx
    int $0x13

read_sector:


.hang:
    jmp .hang

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
    int $0x10
    cmp $0x011B, %ax
    jne reDie

biosKill:
    int $0x19 # BIOS poweroff
    ljmp $0xf000,$0xfff0 # case error reset code

biosCleanScreen:
    movw $0x600, %ax
    movb $0x7, %bh
    xorw %cx, %cx
    movw $0x184F, %dx
    int $0x10
    ret

_bootmsg:  .asciz " *\r\n* SecondBreath bootloader\r\n *\r\n\n\n"
_partbase: .asciz "\r\n         Partition "
_active:   .asciz " (BOOTABLE)"
_error:    .asciz "Error occcured"
bpartactive: .byte 0x0

.fill 510-(.-_bootsector), 1, 0

.section .bootmagic, "ax"
.word MAGICMBR
