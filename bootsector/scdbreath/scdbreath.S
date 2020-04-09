.code16

/*
** Bootcode second breath
*/

.global loadperror
.global loadprintstr

.section .text.boothook, "ax"

# Top of the stack contain drive number
_scdbreath:
    pop %dx
    push %dx

    call _enableA20

    calll loadGdtBRealmode

    pop %dx
    push %dx
    call loadkernel

    movw $_bootms, %si
    call loadprintstr

hg: jmp hg

    ljmp $0x8, $pm32entry

loadperror:
    call loadprintstr
    mov $_booterror, %si
    call loadprintstr
    xorw %ax, %ax
    int $0x16
    jmp bioskill

loadprintstr:
    lodsb
    andb %al, %al
    jz   .endpr
    movb $0xe, %ah
    movw $7, %bx
    int  $0x10
    jmp  loadprintstr
.endpr:
    ret

bioskill:
    int $0x19 # BIOS poweroff
    ljmp $0xf000,$0xfff0 # case error reset code


_bootms: .asciz "\r\nKernel loaded successfuly :)"
_booterror: .asciz "\n\r  Press any key to reboot..."

/*
** GDT32
*/

.balign 8
_bootgdt32Desc:
    .word   _bootgdt32_end - _bootgdt32 - 1
    .long   _bootgdt32
_bootgdt32:
    .quad   0x0000000000000000  /* Reserved */
    .quad   0x00cf9a000000ffff  /* __KERNEL_CS */
    .quad   0x00cf92000000ffff  /* __KERNEL_DS */
_bootgdt32_end:

/* kernel informations */
scdbreath_bootloader:
.magic: 
    .long   0xF0C41E17  /* scdbreath magic */
kernel_size:
    .long   0x00000000  /* kernel image size */
kernel_load:
    .long   0x00000000  /* kernel load addr */
drive_number:
    .long   0x00000000  /* boot drive number */
setup_sectors:
    .long   0x0000000A  /* bootloader size in 512 byte blocks */

/*
** flushing gdt load for big real mode
*/

loadGdtBRealmode:
    cli
    pushw %ds
    pushw %es
    pushw %gs
    pushw %fs

    lgdt  _bootgdt32Desc

    movl  %cr0, %eax
    orb   $0x01, %al
    movl  %eax, %cr0

    movw  $0x10, %ax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %gs
    movw  %ax, %fs

    movl  %cr0, %eax
    andb  $0xFE, %al
    movl  %eax, %cr0

    popw  %fs
    popw  %gs
    popw  %es
    popw  %ds
    sti
    retl


/*
** Checkup A20
*/

_checkA20:
    pushf
    pushw %ds
    pushw %es
    pushw %di
    pushw %si
 
    xor %ax, %ax
    mov %ax, %es
 
    not %ax
    mov %ax, %ds
 
    mov $0x0500, %di
    mov $0x0510, %si
 
    movb %es:(%di), %al
    pushw %ax
 
    movb %ds:(%si), %al
    pushw %ax
 
    movb $0x00, %es:(%di)
    movb $0xFF, %ds:(%si)
 
    cmpb $0xFF, %es:(%di)
 
    popw %ax
    movb %al, %ds:(%si)
 
    popw %ax
    movb %al, %es:(%di)
 
    movw $0x0, %ax
    je check_a20_exit
 
    movw $0x1, %ax
 
check_a20_exit:
    popw %si
    popw %di
    popw %es
    popw %ds
    popf
 
    ret

/*
** Enable A20 (btw, the keyboard which will enable A20)
*/

_enableA20:

    pushl %eax

    .is_already_enable:
        call _checkA20
        cmp $1, %ax
        je .done

    .bios_method:
        mov $0x2401, %ax
        int $0x15

        call _checkA20
        cmp $1, %ax
        je .done

    .keyboard_method:
        cli

        call .a20wait
        mov $0xAD, %al
        out %al, $0x64

        call .a20wait
        mov $0xD0, %al
        out %al, $0x64

        call .a20wait2
        in $0x60, %al
        pushl %eax

        call .a20wait
        mov $0xD1, %al
        out %al, $0x64

        call .a20wait
        popl %eax
        or $2, %al
        out %al, $0x60

        call .a20wait
        mov $0xAE, %al
        out %al, $0x64

        call .a20wait
        sti

        jmp .done

    .a20wait:
        in $0x64, %al
        test $2, %al
        jnz .a20wait
        ret

    .a20wait2:
        in $0x64, %al
        test $1, %al
        jz .a20wait2
        ret

.done:
    popl %eax
    ret
