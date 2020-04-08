 #
# Simple Makefile to compile our booloader
 #

BUILD		:=	build

GAS 		:=	as

LNK			:=	ld

GASFLAGS	=

OBJEXT		:=	.o

ASMEXT		:=	.S

LINKER		:=	bootsector/scdbreath.ld

RAWBIN		:=	scdbreath.bin

LNKFLAGS	=	-n						\
				-T $(LINKER)			\
				-o $(RAWBIN)			\
				--oformat binary		\

SRCDIR		:=	$(addprefix bootsector/, 	\
							boot			\
							bootools		\
							scdbreath		\
				)

SOURCES		:=	$(wildcard $(addsuffix /*$(ASMEXT), $(SRCDIR)))

OBJECTS		:=	$(patsubst %$(ASMEXT), $(BUILD)/%$(OBJEXT), $(SOURCES))


all:	checkup	$(RAWBIN)

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

checkup:
ifeq ($(arch), x86)
    GASFLAGS	+= --32
    LNKFLAGS	+= -m elf_i386
else ifeq ($(arch), x64)
    LNKFLAGS	+= -m elf_x86_64
else
    GASFLAGS	+= --32
    LNKFLAGS	+= -m elf_i386
endif