**free
// Prototypes for the DYNARRAY service program.
//
// Include it in your program with:
//   /include qrpglesrc/dynarray_h.rpgle
// and compile with INCDIR pointing to the directory of this project.

/if defined(DYNARRAY_H)
/eof
/endif
/define DYNARRAY_H

// A list. Declare it with like(dynamicarray_t). It starts empty (*NULL).
dcl-s dynamicarray_t pointer template;

// One element of the list, stored in dynamic memory.
dcl-ds node_t qualified template;
    text varchar(100) inz;
    ptrnext like(dynamicarray_t) inz;
end-ds;

// Frees every element of the list and leaves it empty (*NULL).
// Call it when you are done with the list, or to reuse it.
dcl-pr DYN_initializeArray extproc;
    array like(dynamicarray_t);
end-pr;

// Adds text at the end of the list.
dcl-pr DYN_addNode extproc;
    text varchar(100) const;
    array like(dynamicarray_t);
end-pr;

// Returns the text of element number (the first one is 1).
// Returns 'ERROR' if that element doesn't exist.
dcl-pr DYN_retrieveNode varchar(100) extproc;
    number zoned(5) const;
    array like(dynamicarray_t);
end-pr;
