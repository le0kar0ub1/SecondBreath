# SecondBreath

x86 DOS bootloader wroten in GNU syntax assembly.

One of many minimal bootloader (which load the Kernel in higher half).

# Dependencies

  * `make` (dev under V4.3)

  * `as` (dev under V2.34)

  * `ld` (dev under V2.34)

# Build

`make arch=$ARCH`

Where `$ARCH` is the arch you want to target.

Available are `x86` and `x64` (defaulting to x86 if unset).

# x86 MEMORY MAP

| Binary Offset        | Virtual Address      | Description
|----------------------|----------------------|-------------
| `0x0` - `0x200`      | `0x7C00` - `0x7E00`  | DOS bootloader
| `0x200` - `0x8400`   | `0x7E00` - `0x10000` | Bootloader second breath
| `0x10000` - `...`    | `0xC0010000` - `...` | Kernel

# x64 MEMORY MAP

| Binary Offset        | Virtual Address              | Description
|----------------------|------------------------------|-------------
| `0x0` - `0x200`      | `0x7C00` - `0x7E00`          | DOS bootloader
| `0x200` - `0x8400`   | `0x7E00` - `0x10000`         | Bootloader second breath
| `0x10000` - `...`    | `0xFFFFFFFF80010000` - `...` | Kernel

# Bootloader work

[X] Load the `stage 2` bootloader
[X] Enable `A20` by all means
[X] Load the `GDT32`
[ ] Enable `Protected Mode`
[X] Load the totality of the kernel at `0x10000`
[ ] Setup some informations for kernel usage (ACPI/..)
[ ] Transfer control to the kernel

# Epilogue

Just for the fun.

Feel free to fork, use, improve.