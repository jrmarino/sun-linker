#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2010 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Copyright 2019 Joyent, Inc.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

LIBRARY =	libld.a
VERS =		.4

COMOBJS =	debug.o		globals.o	util.o

COMOBJS32 =	args32.o	entry32.o	exit32.o	groups32.o \
		ldentry32.o	ldlibs32.o	ldmachdep32.o	ldmain32.o \
		libs32.o	files32.o	map32.o		map_core32.o \
		map_support32.o	map_v232.o	order32.o	outfile32.o \
		place32.o	relocate32.o	resolve32.o	sections32.o \
		sunwmove32.o	support32.o	syms32.o	update32.o \
		unwind32.o	version32.o	wrap32.o

COMOBJS64 =	args64.o	entry64.o	exit64.o	groups64.o \
		ldentry64.o	ldlibs64.o	ldmachdep64.o	ldmain64.o \
		libs64.o	files64.o	map64.o		map_core64.o \
		map_support64.o	map_v264.o	order64.o	outfile64.o \
		place64.o	relocate64.o	resolve64.o	sections64.o \
		sunwmove64.o	support64.o	syms64.o	update64.o \
		unwind64.o	version64.o	wrap64.o

SGSCOMMONOBJ =	alist.o		assfail.o	findprime.o	string_table.o \
		strhash.o
AVLOBJ =	avl.o

# Relocation engine objects.
G_MACHOBJS32 =	doreloc_sparc_32.o doreloc_x86_32.o
G_MACHOBJS64 =	doreloc_sparc_64.o doreloc_x86_64.o

# Target specific objects (sparc/sparcv9)
L_SPARC_MACHOBJS32 =	machrel.sparc32.o	machsym.sparc32.o
L_SPARC_MACHOBJS64 =	machrel.sparc64.o	machsym.sparc64.o

# Target specific objects (i386/amd64)
E_X86_COMMONOBJ =	leb128.o
L_X86_MACHOBJS32 =	machrel.intel32.o
L_X86_MACHOBJS64 =	machrel.amd64.o

# All target specific objects rolled together
E_COMMONOBJ =	$(E_SPARC_COMMONOBJ) \
	$(E_X86_COMMONOBJ)
L_MACHOBJS32 =	$(L_SPARC_MACHOBJS32) \
	$(L_X86_MACHOBJS32)
L_MACHOBJS64 =	$(L_SPARC_MACHOBJS64) \
	$(L_X86_MACHOBJS64)


BLTOBJ =	msg.o
ELFCAPOBJ =	elfcap.o

OBJECTS =	$(BLTOBJ) $(G_MACHOBJS32) $(G_MACHOBJS64) \
		$(L_MACHOBJS32) $(L_MACHOBJS64) \
		$(COMOBJS) $(COMOBJS32) $(COMOBJS64) \
		$(SGSCOMMONOBJ) $(E_COMMONOBJ) $(AVLOBJ) $(ELFCAPOBJ)

include		$(SRC)/lib/Makefile.lib
include		$(SRC)/cmd/sgs/Makefile.com

SRCDIR =	$(SGSHOME)/libld
MAPFILEDIR =	$(SRCDIR)/common

CERRWARN += -_gcc=-Wno-unused-value
CERRWARN += -_gcc=-Wno-parentheses
CERRWARN += $(CNOWARN_UNINIT)
CERRWARN += -_gcc=-Wno-switch
CERRWARN += -_gcc=-Wno-char-subscripts
CERRWARN += -_gcc=-Wno-type-limits
$(RELEASE_BUILD)CERRWARN += -_gcc=-Wno-unused

SMOFF += no_if_block

# Location of the shared relocation engines maintained under usr/src/uts.
#
KRTLD_I386 = $(SRC)/uts/$(VAR_PLAT_i386)/krtld
KRTLD_AMD64 = $(SRC)/uts/$(VAR_PLAT_amd64)/krtld
KRTLD_SPARC = $(SRC)/uts/$(VAR_PLAT_sparc)/krtld


CPPFLAGS +=	-DUSE_LIBLD_MALLOC -I$(SRC)/lib/libc/inc \
		    -I$(SRC)/uts/common/krtld -I$(SRC)/uts/sparc \
		    $(VAR_LIBLD_CPPFLAGS)
LDLIBS +=	$(CONVLIBDIR) -lconv $(LDDBGLIBDIR) -llddbg \
		    $(ELFLIBDIR) -lelf $(DLLIB) -lc

DYNFLAGS +=	$(VERSREF) '-R$$ORIGIN'

# too hairy
pics/sections32.o := SMATCH=off
pics/sections64.o := SMATCH=off

BLTDEFS =	msg.h
BLTDATA =	msg.c
BLTMESG =	$(SGSMSGDIR)/libld

BLTFILES =	$(BLTDEFS) $(BLTDATA) $(BLTMESG)

# Due to cross linking support, every copy of libld contains every message.
# However, we keep target specific messages in their own separate files for
# organizational reasons.
#
SGSMSGCOM =	$(SRCDIR)/common/libld.msg
SGSMSGSPARC =	$(SRCDIR)/common/libld.sparc.msg
SGSMSGINTEL =	$(SRCDIR)/common/libld.intel.msg
SGSMSGTARG =	$(SGSMSGCOM) $(SGSMSGSPARC) $(SGSMSGINTEL)
SGSMSGALL =	$(SGSMSGCOM) $(SGSMSGSPARC) $(SGSMSGINTEL)

SGSMSGFLAGS1 =	$(SGSMSGFLAGS) -m $(BLTMESG)
SGSMSGFLAGS2 =	$(SGSMSGFLAGS) -h $(BLTDEFS) -d $(BLTDATA) -n libld_msg

CHKSRCS =	$(SRC)/uts/common/krtld/reloc.h \
		$(COMOBJS32:%32.o=$(SRCDIR)/common/%.c) \
		$(L_MACHOBJS32:%32.o=$(SRCDIR)/common/%.c) \
		$(L_MACHOBJS64:%64.o=$(SRCDIR)/common/%.c) \
		$(KRTLD_I386)/doreloc.c \
		$(KRTLD_AMD64)/doreloc.c \
		$(KRTLD_SPARC)/doreloc.c

LIBSRCS =	$(SGSCOMMONOBJ:%.o=$(SGSCOMMON)/%.c) \
		$(SGSCOMMONOBJ:%.o=$(SGSCOMMON)/%.c) \
		$(COMOBJS:%.o=$(SRCDIR)/common/%.c) \
		$(AVLOBJS:%.o=$(VAR_AVLDIR)/%.c) \
		$(BLTDATA)

CLEANFILES +=	$(BLTFILES)
CLOBBERFILES +=	$(DYNLIB) $(LIBLINKS)

ROOTFS_DYNLIB =	$(DYNLIB:%=$(ROOTFS_LIBDIR)/%)
