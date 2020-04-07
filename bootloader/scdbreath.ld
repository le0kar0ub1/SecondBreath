ENTRY(_bootsector)

PROVIDE(__BOOT_SECTOR_START    = 0x7C00);
PROVIDE(__BOOT_SCDBREATH_START = 0x7E00);

SECTIONS
{
	. = __BOOT_SECTOR_START;
	.init.boot :
	{
		*(.bootsector)
		*(.bootmagic)
	}
	. = __BOOT_SCDBREATH_START;
	.init.scdbreath :
	{
		*(.text.boot)
		*(.text.bootrdsector)
		*(.data.boot)
		*(.bioscall)
	}
	. = ALIGN(0x200);
	PROVIDE(__BOOT_SECTOR_END = .);

	.text : {}

	/DISCARD/:
	{ 
		*(*)
	}
}