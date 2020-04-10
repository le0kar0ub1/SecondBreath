.macro V2P addr, reg
.if arch == 64
    mov \addr - 0xFFFFFFFF80000000, \reg
.else
    mov \addr - 0xC0000000, \reg
.endif
.endm
