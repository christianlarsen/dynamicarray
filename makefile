# Build the DYNARRAY service program and its example.
#
#   gmake                    -> builds everything into library DYNARRAY
#   gmake BIN_LIB=MYLIB      -> builds everything into library MYLIB
#
# The library is created if it does not exist. Source paths are taken
# from the directory where gmake runs, so the project can live anywhere
# in the IFS.

BIN_LIB ?= DYNARRAY
SHELL   = /QOpenSys/usr/bin/qsh
SRCDIR  = $(CURDIR)
# The sources are plain ASCII. They are tagged 1252 because the RPG compiler
# does not accept a Unicode (1208) source with its default TGTCCSID(*SRC).
CCSID   = 1252
SOURCES = qrpglesrc/dynarray_h.rpgle qrpglesrc/dynarray.srv.rpgle \
          qrpglesrc/example01.pgm.rpgle qsrvsrc/dynarray.bnd

.PHONY: all lib ccsid srvpgm bnddir example

all: srvpgm bnddir example

lib:
	-system -q "CRTLIB LIB($(BIN_LIB)) TEXT('Dynamic array service program')"

ccsid:
	for f in $(SOURCES); do system -s "CHGATR OBJ('$(SRCDIR)/$$f') ATR(*CCSID) VALUE($(CCSID))" || exit 1; done

# Service program DYNARRAY, with the exports listed in qsrvsrc/dynarray.bnd.
srvpgm: lib ccsid
	system "CRTRPGMOD MODULE($(BIN_LIB)/DYNARRAY) SRCSTMF('$(SRCDIR)/qrpglesrc/dynarray.srv.rpgle') INCDIR('$(SRCDIR)') DBGVIEW(*SOURCE) OPTION(*EVENTF)"
	system "CRTSRVPGM SRVPGM($(BIN_LIB)/DYNARRAY) MODULE($(BIN_LIB)/DYNARRAY) EXPORT(*SRCFILE) SRCSTMF('$(SRCDIR)/qsrvsrc/dynarray.bnd') TEXT('Dynamic array service program')"
	system "DLTOBJ OBJ($(BIN_LIB)/DYNARRAY) OBJTYPE(*MODULE)"

# Binding directory DYNARRAY, so your own programs can bind with
# ctl-opt bnddir('DYNARRAY'). The entry uses *LIBL, so the objects can be
# moved to another library.
bnddir: srvpgm
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/DYNARRAY) TEXT('Dynamic array service program')"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/DYNARRAY) OBJ((*LIBL/DYNARRAY *SRVPGM))"

# Example program EXAMPLE01. It binds to the service program directly, so
# BIN_LIB doesn't need to be in the library list while building.
example: srvpgm
	system "CRTRPGMOD MODULE($(BIN_LIB)/EXAMPLE01) SRCSTMF('$(SRCDIR)/qrpglesrc/example01.pgm.rpgle') INCDIR('$(SRCDIR)') DBGVIEW(*SOURCE) OPTION(*EVENTF)"
	system "CRTPGM PGM($(BIN_LIB)/EXAMPLE01) MODULE($(BIN_LIB)/EXAMPLE01) BNDSRVPGM(($(BIN_LIB)/DYNARRAY)) ACTGRP(*NEW)"
	system "DLTOBJ OBJ($(BIN_LIB)/EXAMPLE01) OBJTYPE(*MODULE)"
