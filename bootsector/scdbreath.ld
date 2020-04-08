ENTRY(_bootloader)

PROVIDE(__BOOT_SECTOR_START     = 0x7C00);
PROVIDE(__BOOT_SECTOR_FORCE_END = 0x7E00);
PROVIDE(__BOOT_SCDBREATH_START  = 0x7E00);

PROVIDE(__KERNEL_PHYS_LINK = 0x10000);
PROVIDE(__KERNEL_VIRT_LINK = 0xC0100000);

SECTIONS
{
    . = __BOOT_SECTOR_START;
    .init.boot :
    {
        *(.bootloader)
        *(.bootmagic)
    }
    . = __BOOT_SECTOR_FORCE_END;
    . = __BOOT_SCDBREATH_START;
    .init.scdbreath :
    {
        *(.text.boothook)
        *(.text.bootrdsector)
        *(.text.boot)
        *(.data.boot)
        *(.bioscall)
    }
    . = ALIGN(0x200);
    PROVIDE(__BOOT_SECTOR_LOAD_SIZE = (. - __BOOT_SCDBREATH_START) / 0x200);
    PROVIDE(__BOOT_SECTOR_END  = .);
    
    . = __KERNEL_VIRT_LINK;

    .text :
    {
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    .rodata :
    {
        *(.rodata)
    }

    .bss :
    {
        *(.bss)
    }

    /* 
    ** We do not use C code for now so,
    ** To be clean, if a section is not declared we DISCARD
    */
    /DISCARD/:
    {
        *(*)
    }
}


