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
# Copyright 2015 Gary Mills
# Copyright (c) 1990, 2010, Oracle and/or its affiliates. All rights reserved.
# Copyright (c) 2018, Joyent, Inc.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#

LIBRARY=	libelf.a
VERS=		.1

MACHOBJS=
COMOBJS=	ar.o		begin.o		cntl.o		cook.o \
		data.o		end.o		fill.o		flag.o \
		getarhdr.o	getarsym.o	getbase.o	getdata.o \
		getehdr.o	getident.o	getphdr.o	getscn.o \
		getshdr.o \
		getphnum.o	getshnum.o	getshstrndx.o \
		hash.o		input.o		kind.o \
		ndxscn.o	newdata.o	newehdr.o	newphdr.o \
		newscn.o	next.o		nextscn.o	output.o \
		rand.o		rawdata.o	rawfile.o	rawput.o \
		strptr.o	update.o	error.o		gelf.o \
		clscook.o	checksum.o
CLASSOBJS=	clscook64.o	newehdr64.o	newphdr64.o	update64.o \
		checksum64.o
BLTOBJS=	msg.o		xlate.o		xlate64.o
MISCOBJS=	String.o	args.o		demangle.o	nlist.o \
		nplist.o
MISCOBJS64=	nlist.o

OBJECTS=	$(BLTOBJS)  $(MACHOBJS)  $(COMOBJS)  $(CLASSOBJS) $(MISCOBJS)

include $(SRC)/lib/Makefile.lib

SRCDIR=	$(SRC)/cmd/sgs/libelf

# Use the value of M4 set in Makefile.master via Makefile.lib

DEMOFILES=	Makefile	00README	acom.c		dcom.c \
		pcom.c		tpcom.c		dispsyms.c
DEMOFILESRCDIR=	$(SRCDIR)/demo
ROOTDEMODIRBASE=$(ROOT)/usr/demo/ELF
ROOTDEMODIRS=   $(ROOTDEMODIRBASE)

include $(SRC)/cmd/sgs/Makefile.com

MAPFILES =	$(SRCDIR)/common/mapfile-vers

DYNFLAGS +=	$(VERSREF)
LDLIBS +=	$(CONVLIBDIR) -lconv -lc

CERRWARN +=	-_gcc=-Wno-parentheses
CERRWARN +=	$(CNOWARN_UNINIT)

SMOFF += indenting

BLTDEFS=	msg.h
BLTDATA=	msg.c
BLTMESG=	$(SGSMSGDIR)/libelf

BLTFILES=	$(BLTDEFS) $(BLTDATA) $(BLTMESG)

SGSMSGCOM=	$(SRCDIR)/common/libelf.msg
SGSMSG32=	$(SRCDIR)/common/libelf.32.msg
SGSMSGTARG=	$(SGSMSGCOM)
SGSMSGALL=	$(SGSMSGCOM) $(SGSMSG32)

SGSMSGFLAGS1=	$(SGSMSGFLAGS) -m $(BLTMESG)
SGSMSGFLAGS2=	$(SGSMSGFLAGS) -h $(BLTDEFS) -d $(BLTDATA) -n libelf_msg

BLTSRCS=	$(BLTOBJS:%.o=%.c)
LIBSRCS=	$(COMOBJS:%.o=$(SRCDIR)/common/%.c)  $(MISCOBJS:%.o=$(SRCDIR)/misc/%.c) \
		$(MACHOBJS:%.o=%.c)  $(BLTSRCS)

ROOTFS_DYNLIB=		$(DYNLIB:%=$(ROOTFS_LIBDIR)/%)

ROOTFS_DYNLIB64=	$(DYNLIB:%=$(ROOTFS_LIBDIR64)/%)

$(ROOTFS_DYNLIB) :=	FILEMODE= 755
$(ROOTFS_DYNLIB64) :=	FILEMODE= 755

LIBS =		$(DYNLIB)

CLEANFILES +=	$(BLTSRCS) $(BLTFILES)

.PARALLEL:	$(LIBS)
