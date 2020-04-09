OUTPUT_FORMAT(binary)
ENTRY(_bootloader)

PROVIDE(__BOOT_SECTOR_START     = 0x7C00);
PROVIDE(__BOOT_SECTOR_FORCE_END = 0x7E00);
PROVIDE(__BOOT_SCDBREATH_START  = 0x7E00);

PROVIDE(__KERNEL_OFFSET_LINK = 0x00010000);
PROVIDE(__KERNEL_LOAD_LINK   = 0x00017C00);
PROVIDE(__KERNEL_PHYS_LINK   = 0x00010000);
PROVIDE(__KERNEL_VIRT_LINK   = 0xC0010000);
PROVIDE(__KERNEL_TRUTH_TRANS = 0xC0000000);

MEMORY
{
    boot (rwx) : ORIGIN = 0x00007C00, LENGTH = 2K
    krn  (rwx) : ORIGIN = 0xC0010000, LENGTH = 4M
}

SECTIONS
{
    . = __BOOT_SECTOR_START;
    .init.boot :
    {
        KEEP(*(.bootloader))
        KEEP(*(.bootmagic))
    } > boot
    . = __BOOT_SECTOR_FORCE_END;

    . = __BOOT_SCDBREATH_START;
    .init.scdbreath :
    {
        KEEP(*(.text.boothook))
        KEEP(*(.text.boot))
        KEEP(*(.data.boot))
        KEEP(*(.bioscall))
    } > boot

    . = ALIGN(0x200);
    PROVIDE(__BOOT_SECTOR_BLK_NBR = ((. - __BOOT_SCDBREATH_START) / 0x200) + 1);
    PROVIDE(__BOOT_SECTOR_END  = .);

    . = __KERNEL_VIRT_LINK;

    PROVIDE(__KERNEL_LBA_BLK_START = __KERNEL_OFFSET_LINK / 0x200);

    PROVIDE(_PHYS_SECTION_TEXT_START = . - __KERNEL_VIRT_LINK);
    .text __KERNEL_VIRT_LINK + _PHYS_SECTION_TEXT_START : AT(__KERNEL_LOAD_LINK + _PHYS_SECTION_TEXT_START)
    {
        KEEP(*(.krnhook))
        KEEP(*(.text))
    } > krn
    PROVIDE(_PHYS_SECTION_TEXT_END = . - __KERNEL_VIRT_LINK);

    PROVIDE(_PHYS_SECTION_DATA_START = . - __KERNEL_VIRT_LINK);
    .data __KERNEL_VIRT_LINK + _PHYS_SECTION_DATA_START : AT(__KERNEL_LOAD_LINK + _PHYS_SECTION_DATA_START)
    {
        KEEP(*(.data))
    } > krn
    PROVIDE(_PHYS_SECTION_DATA_END = . - __KERNEL_VIRT_LINK);

    PROVIDE(_PHYS_SECTION_RODATA_START = . - __KERNEL_VIRT_LINK);
    .rodata __KERNEL_VIRT_LINK + _PHYS_SECTION_RODATA_START : AT(__KERNEL_LOAD_LINK + _PHYS_SECTION_RODATA_START)
    {
        KEEP(*(.rodata))
    } > krn
    PROVIDE(_PHYS_SECTION_RODATA_END = . - __KERNEL_VIRT_LINK);

    PROVIDE(_PHYS_SECTION_BSS_START = . - __KERNEL_VIRT_LINK);
    .bss __KERNEL_VIRT_LINK + _PHYS_SECTION_BSS_START : AT(__KERNEL_LOAD_LINK + _PHYS_SECTION_BSS_START)
    {
        KEEP(*(.bss))
    } > krn
    PROVIDE(_PHYS_SECTION_BSS_END = . - __KERNEL_VIRT_LINK);

    PROVIDE(__KERNEL_PHYS_END = . - __KERNEL_VIRT_LINK);
    PROVIDE(__KERNEL_VIRT_END = .);

    . = ALIGN(0x200);
    PROVIDE(__KERNEL_LBA_BLK_NBR = ((. - __KERNEL_VIRT_LINK) / 0x200) + 1);
    PROVIDE(__KERNEL_SIZE = __KERNEL_PHYS_END - __KERNEL_PHYS_LINK);

    /* 
    ** We do not use C code for now so,
    ** To be clean, if a section is not declared we DISCARD
    */

    /DISCARD/ :
    { 
        *(*) 
    }
}