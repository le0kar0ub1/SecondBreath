.code16

.global structkinfo

.section .kinfo, "awd"
structkinfo:
    .signature:             .4byte 0xF4C41E18
    .kernel_size:           .4byte __KERNEL_SIZE
    .kernel_phys_start:     .4byte __KERNEL_PHYS_LINK
    .kernel_virt_start:     .4byte __KERNEL_VIRT_LINK
