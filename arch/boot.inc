.macro V2P addr, reg
    mov \addr, \reg
.if arch == 64
    sub $0xC0000000, \reg
.else
    sub $0xC0000000, \reg
.endif
.endm
