 #
# Simple Makefile to compile our bootloader
 #

BUILD		:=	build

GAS 		:=	as

LNK			:=	ld

GASFLAGS	=	-I .

OBJEXT		:=	.o

ASMEXT		:=	.S

RAWBIN		:=	$(BUILD)/scdbreath.bin

LNKFLAGS	=	-n							\
				-T $(LINKER)				\
				-o $(RAWBIN)				\
				-z max-page-size=0x1000		\
				--oformat binary			\

#LNKFLAGS	+=	--print-map			\
				--cref				\

SRCDIR		:=	$(addprefix boot/,			\
							bootsector		\
							bootools		\
							scdbreath		\
				)

SRCDIR 		+=	krn

SOURCES		:=	$(wildcard $(addsuffix /*$(ASMEXT), $(SRCDIR)))

OBJECTS		:=	$(patsubst %$(ASMEXT), $(BUILD)/%$(OBJEXT), $(SOURCES))


all:	config	$(RAWBIN)

clean:
	@rm -rf	$(BUILD)

fclean:	clean
	@rm -f	$(RAWBIN)

run:	re
	qemu-system-i386 -drive format=raw,file=$(RAWBIN)

re:	fclean	all

$(RAWBIN):	$(OBJECTS)
	@$(LNK) $(LNKFLAGS) $(OBJECTS)
	@-echo "   LNK    $(RAWBIN)"

$(BUILD)/%$(OBJEXT): %$(ASMEXT)
	@mkdir -p $(shell dirname $@)
	@$(GAS) $(GASFLAGS) -c $< -o $@
	@-echo "    AS    $@"

config:
ifeq ($(arch), x64)
    GASFLAGS	+= --64
    GASFLAGS	+= --defsym archsz=64
    LNKFLAGS	+= -m elf_x86_64
    LINKER		=	arch/x64/scdbreath.ld
else
    GASFLAGS	+= --32
    GASFLAGS	+= --defsym archsz=32
    LNKFLAGS	+= -m elf_i386
    LINKER		=	arch/x86/scdbreath.ld
endif