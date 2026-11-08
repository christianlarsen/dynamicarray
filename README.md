# Dynamic array in RPG (IBM i)

A small RPG service program, `DYNARRAY`, that keeps an array of texts in
dynamic memory. The array grows as you add elements, so you don't have to
choose a size for it at compile time.

The example shows how to work with pointers, based variables and dynamic
memory (`%alloc`, `%realloc`, `dealloc`) in RPG, and how to package
procedures in a service program with a binding directory.

## The procedures

| Procedure | What it does |
| --- | --- |
| `DYN_addNode(text : array)` | Adds `text` (up to 65535 characters) at the end of the array |
| `DYN_retrieveNode(number : array)` | Returns the text of element `number`. Returns `'ERROR'` if it doesn't exist |
| `DYN_update(number : text : array)` | Replaces the text of element `number`. Returns `*off` if it doesn't exist |
| `DYN_delete(number : array)` | Removes element `number`; the elements after it move up one position. Returns `*off` if it doesn't exist |
| `DYN_count(array)` | Returns the number of elements |
| `DYN_find(text : array)` | Returns the number of the first element equal to `text`, or 0 |
| `DYN_free(array)` | Frees the array and leaves it empty |
| `DYN_initializeArray(array)` | Same as `DYN_free`. Kept for programs written for earlier versions |

Elements are numbered from 1. The prototypes are in
[`qrpglesrc/dynarray_h.rpgle`](qrpglesrc/dynarray_h.rpgle).

## How it works

Your program holds a pointer (`like(dynamicarray_t)`) that starts as
`*NULL`. The first `DYN_addNode` allocates a small header with the number
of elements, the capacity, and a pointer to the *slots*. There is one slot
per element, stored one after the other in a single block of memory, so
element *n* is found by its position. When the block is full, its size is
doubled with `%realloc`.

A slot doesn't hold the text, only a pointer to it and its length. Each
text has its own allocation of exactly its length: a text of 10 characters
uses 10 bytes, plus 32 for its slot, even if other elements have 25000.

So:

- Retrieving, updating and adding elements take the same time whatever the
  size of the array.
- Deleting an element moves all the elements after it, and `DYN_find`
  compares the elements one by one. Both get slower as the array grows.
- The service program uses teraspace storage (`ALLOC(*TERASPACE)`), so the
  array isn't limited to the 16 MB of a single-level storage allocation.

Things to know before you use it:

- **Free the array when you are done** with `DYN_free`. The memory belongs
  to the activation group of the caller and is only released when that
  activation group ends.
- Elements can be up to 65535 characters long (`DYN_MAX_LENGTH`). Longer
  texts are truncated.
- Don't change the pointer yourself or read the memory it points to. Use
  the procedures: the layout of that memory may change between versions.

RPG also has native varying-dimension arrays (`DIM(*AUTO)` and
`DIM(*VAR)`) in recent releases. Use them if they fit your needs. This
project is useful when you want to pass an array between programs and
procedures as a single pointer, or to learn how dynamic memory works in RPG.

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

The example adds 1000 elements, then retrieves, updates, deletes and finds
some of them, adds a text of 25000 characters, and frees the array. It writes each result to the job log,
next to the expected value in the source. Look at it with `DSPJOBLOG`.

## Using it in your own programs

```rpgle
**free
ctl-opt main(main) dftactgrp(*no) bnddir('DYNARRAY');

/include qrpglesrc/dynarray_h.rpgle

dcl-proc main;
    dcl-s i int(10);
    dcl-s list like(dynamicarray_t);

    DYN_addNode('First' : list);
    DYN_addNode('Second' : list);

    for i = 1 to DYN_count(list);
        snd-msg DYN_retrieveNode(i : list);
    endfor;

    DYN_free(list);
end-proc;
```

Compile it with the library that holds `DYNARRAY` in your library list,
and with `INCDIR` pointing to the directory where you cloned this project,
for example:

```
CRTBNDRPG PGM(MYLIB/MYPGM) SRCSTMF('/home/me/mypgm.rpgle')
          INCDIR('/home/me/dynamicarray')
```

New versions only add procedures at the end of the binder source, so
programs that are already compiled keep working without being bound again.

## License

[MIT](LICENSE)
