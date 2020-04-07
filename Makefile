 #
# Simple Makefile to compile our booloader
 #

BUILD		:=	build

GAS 		:=	as

LNK			:=	ld

GASFLAGS	:=

OBJEXT		:=	.o

ASMEXT		:=	.S

LINKER		:=	scdbreath.ld

RAWBIN		:=	scdbreath.bin

LNKFLAGS	:=	-n					\
				-T	$(LINKER)		\
				-o $(RAWBIN)		\
				--oformat binary	\

SRCDIR		:=	$(addprefix bootloader/,	\
							boot			\
							bootools		\
							scdbreath		\
				)

SOURCES		:=	$(wildcard $(addsuffix /*$(ASMEXT), $(SRCDIR)))

OBJECTS		:=	$(patsubst %$(ASMEXT), $(BUILD)/%$(OBJEXT), $(SOURCES))


all:	$(RAWBIN)

clean:
	@rm -rf	$(BUILD)

fclean:	clean
	@rm -f	$(RAWBIN)

run:
	qemu-system-i386 $(RAWBIN)

$(RAWBIN):	$(OBJECTS)
	@$(LNK) $(LNKFLAGS) $(OBJECTS)
	@-echo "   LNK    $(RAWBIN)"

$(BUILD)/%$(OBJEXT): %$(ASMEXT)
	@mkdir -p $(shell dirname $@)
	@$(GAS) $(GASFLAGS) -c $< -o $@
	@-echo "    AS    $@"