**free
// Prototypes for the DYNARRAY service program.
//
// Include it in your program with:
//   /include qrpglesrc/dynarray_h.rpgle
// and compile with INCDIR pointing to the directory of this project.
//
// Elements are numbered from 1. Procedures that receive an element number
// that doesn't exist do nothing and report it in their return value.

/if defined(DYNARRAY_H)
/eof
/endif
/define DYNARRAY_H

// Maximum length of an element. Each element only uses the memory its
// text needs, whatever this maximum is.
dcl-c DYN_MAX_LENGTH 65535;

// An array. Declare it with like(dynamicarray_t). It starts empty (*NULL),
// and the first DYN_addNode allocates it. Don't change it or look at what
// it points to: use the procedures below.
dcl-s dynamicarray_t pointer template;

// Adds text at the end of the array.
dcl-pr DYN_addNode extproc;
    text varchar(DYN_MAX_LENGTH) const;
    array like(dynamicarray_t);
end-pr;

// Returns the text of element number.
// Returns 'ERROR' if that element doesn't exist.
dcl-pr DYN_retrieveNode varchar(DYN_MAX_LENGTH) rtnparm extproc;
    number int(10) const;
    array like(dynamicarray_t) const;
end-pr;

// Replaces the text of element number.
// Returns *off if that element doesn't exist.
dcl-pr DYN_update ind extproc;
    number int(10) const;
    text varchar(DYN_MAX_LENGTH) const;
    array like(dynamicarray_t) const;
end-pr;

// Removes element number. The elements after it move up one position.
// Returns *off if that element doesn't exist.
dcl-pr DYN_delete ind extproc;
    number int(10) const;
    array like(dynamicarray_t) const;
end-pr;

// Returns the number of elements in the array (0 if it is empty).
dcl-pr DYN_count int(10) extproc;
    array like(dynamicarray_t) const;
end-pr;

// Returns the number of the first element equal to text, or 0 if there is
// none. Trailing blanks are ignored, as in any RPG comparison.
dcl-pr DYN_find int(10) extproc;
    text varchar(DYN_MAX_LENGTH) const;
    array like(dynamicarray_t) const;
end-pr;

// Frees the array and leaves it empty (*NULL). Call it when you are done
// with the array: the memory is not released until you do, or until the
// activation group of your program ends.
dcl-pr DYN_free extproc;
    array like(dynamicarray_t);
end-pr;

// Same as DYN_free. Kept for programs written for earlier versions.
dcl-pr DYN_initializeArray extproc;
    array like(dynamicarray_t);
end-pr;
