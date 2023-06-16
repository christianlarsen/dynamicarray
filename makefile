
BIN_LIB=CMPSYS
LIBLIST=$(BIN_LIB) CLV1
SHELL=/QOpenSys/usr/bin/qsh

all: dynarray.bnd dynarray.srv.rpgle example01.pgm.rpgle

dynarray.rpgle: dynarray.bnd

%._h.rpgle:
	system -s "CHGATR OBJ('/home/CLV/dynamicarray/qrpglesrc/$*._h.rpgle') ATR(*CCSID) VALUE(1252)"

%.pgm.rpgle:
	system -s "CHGATR OBJ('/home/CLV/dynamicarray/qrpglesrc/$*.pgm.rpgle') ATR(*CCSID) VALUE(1252)"
	system "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('/home/CLV/dynamicarray/qrpglesrc/$*.pgm.rpgle') DBGVIEW(*SOURCE) OPTION(*EVENTF)"
	system "CRTPGM PGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*) ACTGRP(*NEW)"

%.srv.rpgle:
	system -s "CHGATR OBJ('/home/CLV/dynamicarray/qrpglesrc/$*.srv.rpgle') ATR(*CCSID) VALUE(1252)"
	system "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('/home/CLV/dynamicarray/qrpglesrc/$*.srv.rpgle') DBGVIEW(*SOURCE) OPTION(*EVENTF)"
	system "CRTSRVPGM SRVPGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*) EXPORT(*SRCFILE) SRCSTMF('/home/CLV/dynamicarray/qsrvsrc/$*.bnd')"
	system "DLTOBJ OBJ($(BIN_LIB)/$*) OBJTYPE(*MODULE)"

%.bnd:
	system -s "CHGATR OBJ('/home/CLV/dynamicarray/qsrvsrc/$*.bnd') ATR(*CCSID) VALUE(1252)"
