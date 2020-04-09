.code32

.global _start

.section .krnhook, "ax"
_start:
    mov $working, %esi
    sub $0xC0000000, %esi
    call directPrint

hang:
    jmp hang

directPrint:
    push %edi
    push %eax
    mov $0xb8000, %edi

    directPrintLoop:
        movb (%esi), %al
        cmp $0x0, %al
        je endDirectPrintLoop
        movb $0x4F, 1(%edi)
        movb %al, (%edi)
        inc %esi
        add $0x2, %edi
        jmp directPrintLoop
    endDirectPrintLoop:

    pop %eax
    pop %edi
    ret

.section .data
working: .asciz "it's working <3"
