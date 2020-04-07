 #
# Simple Makefile to compile our booloader
 #

BUILD		:=	build

GAS 		:=	as

LNK			:=	ld

GASFLAGS	=

OBJEXT		:=	.o

ASMEXT		:=	.S

LINKER		:=	bootloader/scdbreath.ld

RAWBIN		:=	scdbreath.bin

LNKFLAGS	:=	-n					\
				-T $(LINKER)		\
				-o $(RAWBIN)		\
				--oformat binary

SRCDIR		:=	$(addprefix bootloader/,	\
							boot)
							#bootools		\
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
	qemu-system-i386 $(RAWBIN)

re:	fclean	all

$(RAWBIN):	$(OBJECTS)
	@$(LNK) $(LNKFLAGS) $(OBJECTS)
	@-echo "   LNK    $(RAWBIN)"

$(BUILD)/%$(OBJEXT): %$(ASMEXT)
	@mkdir -p $(shell dirname $@)
	@$(GAS) $(GASFLAGS) -c $< -o $@
	@-echo "    AS    $@"

checkup:
ifeq ($(lvl), core)
    GASFLAGS	+= --defsym scdbreath=0
else ifeq ($(lvl), scdbreath)
    GASFLAGS	+= --defsym scdbreath=1
else
    GASFLAGS	+= --defsym	scdbreath=0
endif