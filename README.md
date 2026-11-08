# Dynamic array in RPG (IBM i)

A small RPG service program, `DYNARRAY`, that keeps a list of texts in
dynamic memory. The list grows as you add elements, so you don't have to
choose a size for it at compile time.

Internally the list is a singly linked list of nodes allocated with
`%alloc`. The example shows how to work with pointers, based data
structures and dynamic memory in RPG, and how to package procedures in a
service program with a binding directory.

## The procedures

| Procedure | What it does |
| --- | --- |
| `DYN_addNode(text : array)` | Adds `text` (up to 100 characters) at the end of the list |
| `DYN_retrieveNode(number : array)` | Returns the text of element `number`. The first one is 1. Returns `'ERROR'` if the element doesn't exist |
| `DYN_initializeArray(array)` | Frees every element and leaves the list empty |

The prototypes are in [`qrpglesrc/dynarray_h.rpgle`](qrpglesrc/dynarray_h.rpgle).

Things to know before you use it:

- **Free the list when you are done** with `DYN_initializeArray`. The memory
  belongs to the activation group of the caller and is only released when
  that activation group ends.
- Adding an element and retrieving element *n* walk the list from the
  beginning, so they get slower as the list grows. That's fine for hundreds
  or a few thousand elements, but not for very large lists.
- Elements are `varchar(100)`. Longer texts are truncated.

## What's in the repo

```
qrpglesrc/dynarray_h.rpgle        Prototypes (include this in your programs)
qrpglesrc/dynarray.srv.rpgle      DYNARRAY service program
qsrvsrc/dynarray.bnd              Binder source (exported procedures)
qrpglesrc/example01.pgm.rpgle     EXAMPLE01: example program
makefile                          Builds everything with GNU make
```

## Building

Requirements: IBM i 7.4 TR6 or 7.5 or later (the example uses `SND-MSG`),
plus `git` and GNU `make` from the IBM i open source packages
(`yum install git make-gnu`).

From a PASE shell (SSH) on your IBM i:

```sh
git clone https://github.com/christianlarsen/dynamicarray.git
cd dynamicarray
gmake BIN_LIB=MYLIB
```

`BIN_LIB` is the library that will hold the objects. It is created if it
doesn't exist, and defaults to `DYNARRAY`. The build creates:

| Object | Type | |
| --- | --- | --- |
| `DYNARRAY` | `*SRVPGM` | The service program |
| `DYNARRAY` | `*BNDDIR` | Binding directory with the service program |
| `EXAMPLE01` | `*PGM` | Example program |

### From VS Code (Code for IBM i)

Open the folder and run the **Deploy and build 🔨** action. It deploys the
sources to your IFS deploy directory and runs `gmake` with your current
library (`&CURLIB`) as `BIN_LIB`.

## Trying it

```
CALL PGM(MYLIB/EXAMPLE01)
```

The example adds 10 elements, writes elements 8, 2, 9 and 99 to the job
log, and frees the list. Element 99 doesn't exist, so it writes `ERROR`.
Look at the result with `DSPJOBLOG`.

## Using it in your own programs

```rpgle
**free
ctl-opt main(main) dftactgrp(*no) bnddir('DYNARRAY');

/include qrpglesrc/dynarray_h.rpgle

dcl-proc main;
    dcl-s list like(dynamicarray_t);

    DYN_addNode('First' : list);
    DYN_addNode('Second' : list);

    snd-msg DYN_retrieveNode(2 : list);   // Second

    DYN_initializeArray(list);            // free the memory
end-proc;
```

Compile it with the library that holds `DYNARRAY` in your library list,
and with `INCDIR` pointing to the directory where you cloned this project,
for example:

```
CRTBNDRPG PGM(MYLIB/MYPGM) SRCSTMF('/home/me/mypgm.rpgle')
          INCDIR('/home/me/dynamicarray')
```

## License

[MIT](LICENSE)
