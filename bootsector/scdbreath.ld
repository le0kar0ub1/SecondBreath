ENTRY(_bootloader)

PROVIDE(__BOOT_SECTOR_START     = 0x7C00);
PROVIDE(__BOOT_SECTOR_FORCE_END = 0x7E00);
PROVIDE(__BOOT_SCDBREATH_START  = 0x7E00);

PROVIDE(__KERNEL_START = 0x10000);

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
        *(.bioscall)
    }
    . = ALIGN(0x200);
    PROVIDE(__BOOT_SECTOR_END = .);

    . = __KERNEL_START;

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

    /DISCARD/:
    {
            *(*)
    }
}


