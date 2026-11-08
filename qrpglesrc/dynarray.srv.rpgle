**free
// DYNARRAY: a dynamic array of texts.
//
// The caller's pointer points to a header that holds the number of
// elements, the number of elements that fit in the memory allocated
// (capacity), and a pointer to the slots. There is one slot per element,
// one after the other, so element n is found by position, without walking
// the array. When the slots are full, their memory is doubled with
// %realloc.
//
// A slot doesn't hold the text: it holds a pointer to it and its length.
// Each text has its own allocation of exactly its length, so a short text
// doesn't use the memory of the longest one.
//
// Teraspace allows allocations larger than 16 MB.
ctl-opt nomain alloc(*teraspace);

/include qrpglesrc/dynarray_h.rpgle

// Returned by DYN_retrieveNode when the element doesn't exist
dcl-c NOT_FOUND 'ERROR';
// Capacity of the first allocation
dcl-c INITIAL_CAPACITY 16;

dcl-ds header_t qualified template;
    count int(10);
    capacity int(10);
    ptr_slots pointer;
end-ds;

// The slots are stored one after the other, and pointers must be on a
// 16-byte boundary, so a slot is padded to 32 bytes.
dcl-ds slot_t qualified template;
    ptr_text pointer;           // *NULL when the text is empty
    length int(10);
    reserved char(12);
end-ds;

// Copies length bytes from source to target
dcl-pr memcpy pointer extproc('__memcpy');
    target pointer value;
    source pointer value;
    length uns(10) value;
end-pr;

//
// Procedure addNode: adds an element at the end of the array
//
dcl-proc DYN_addNode export;
    dcl-pi *n;
        text varchar(DYN_MAX_LENGTH) const;
        array like(dynamicarray_t);
    end-pi;
    dcl-s ptr_header pointer;
    dcl-s ptr_slot pointer;
    dcl-ds header likeds(header_t) based(ptr_header);
    dcl-ds slot likeds(slot_t) based(ptr_slot);

    // The first element allocates the header
    if (array = *NULL);
        array = %alloc(%size(header_t));
        ptr_header = array;
        clear header;
    else;
        ptr_header = array;
    endif;

    if (header.count = header.capacity);
        grow(header);
    endif;

    header.count += 1;
    ptr_slot = slotAt(header : header.count);
    clear slot;
    setText(slot : text);

    return;
end-proc;

//
// Procedure retrieveNode: returns the text of element number
//
dcl-proc DYN_retrieveNode export;
    dcl-pi *n varchar(DYN_MAX_LENGTH) rtnparm;
        number int(10) const;
        array like(dynamicarray_t) const;
    end-pi;
    dcl-s text varchar(DYN_MAX_LENGTH);
    dcl-s ptr_header pointer;
    dcl-s ptr_slot pointer;
    dcl-ds header likeds(header_t) based(ptr_header);
    dcl-ds slot likeds(slot_t) based(ptr_slot);

    if (not exists(array : number));
        return NOT_FOUND;
    endif;

    ptr_header = array;
    ptr_slot = slotAt(header : number);
    %len(text) = slot.length;
    if (slot.length > 0);
        memcpy(%addr(text : *data) : slot.ptr_text : slot.length);
    endif;

    return text;
end-proc;

//
// Procedure update: replaces the text of element number
//
dcl-proc DYN_update export;
    dcl-pi *n ind;
        number int(10) const;
        text varchar(DYN_MAX_LENGTH) const;
        array like(dynamicarray_t) const;
    end-pi;
    dcl-s ptr_header pointer;
    dcl-s ptr_slot pointer;
    dcl-ds header likeds(header_t) based(ptr_header);
    dcl-ds slot likeds(slot_t) based(ptr_slot);

    if (not exists(array : number));
        return *off;
    endif;

    ptr_header = array;
    ptr_slot = slotAt(header : number);
    setText(slot : text);

    return *on;
end-proc;

//
// Procedure delete: removes element number and moves the next ones up
//
dcl-proc DYN_delete export;
    dcl-pi *n ind;
        number int(10) const;
        array like(dynamicarray_t) const;
    end-pi;
    dcl-s i int(10);
    dcl-s ptr_header pointer;
    dcl-s ptr_to pointer;
    dcl-s ptr_from pointer;
    dcl-ds header likeds(header_t) based(ptr_header);
    dcl-ds slot_to likeds(slot_t) based(ptr_to);
    dcl-ds slot_from likeds(slot_t) based(ptr_from);

    if (not exists(array : number));
        return *off;
    endif;

    ptr_header = array;

    // Free the text of the element
    ptr_to = slotAt(header : number);
    freeText(slot_to);

    // Move the next slots up. Only the pointer to the text and its length
    // are copied, the texts themselves don't move.
    for i = number to header.count - 1;
        ptr_to = slotAt(header : i);
        ptr_from = slotAt(header : i + 1);
        slot_to.ptr_text = slot_from.ptr_text;
        slot_to.length = slot_from.length;
    endfor;

    header.count -= 1;

    return *on;
end-proc;

//
// Procedure count: returns the number of elements
//
dcl-proc DYN_count export;
    dcl-pi *n int(10);
        array like(dynamicarray_t) const;
    end-pi;
    dcl-s ptr_header pointer;
    dcl-ds header likeds(header_t) based(ptr_header);

    if (array = *NULL);
        return 0;
    endif;

    ptr_header = array;
    return header.count;
end-proc;

//
// Procedure find: returns the number of the first element equal to text
//
dcl-proc DYN_find export;
    dcl-pi *n int(10);
        text varchar(DYN_MAX_LENGTH) const;
        array like(dynamicarray_t) const;
    end-pi;
    dcl-s i int(10);

    for i = 1 to DYN_count(array);
        if (DYN_retrieveNode(i : array) = text);
            return i;
        endif;
    endfor;

    return 0;
end-proc;

//
// Procedure free: frees the array and leaves it empty (*NULL)
//
dcl-proc DYN_free export;
    dcl-pi *n;
        array like(dynamicarray_t);
    end-pi;
    dcl-s i int(10);
    dcl-s ptr_header pointer;
    dcl-s ptr_slot pointer;
    dcl-s ptr_slots pointer;
    dcl-ds header likeds(header_t) based(ptr_header);
    dcl-ds slot likeds(slot_t) based(ptr_slot);

    if (array = *NULL);
        return;
    endif;

    ptr_header = array;

    // Free every text, then the slots, then the header
    for i = 1 to header.count;
        ptr_slot = slotAt(header : i);
        freeText(slot);
    endfor;

    ptr_slots = header.ptr_slots;
    if (ptr_slots <> *NULL);
        dealloc ptr_slots;
    endif;
    dealloc ptr_header;

    // Don't leave the caller with a pointer to freed memory
    array = *NULL;

    return;
end-proc;

//
// Procedure initializeArray: same as DYN_free (earlier name)
//
dcl-proc DYN_initializeArray export;
    dcl-pi *n;
        array like(dynamicarray_t);
    end-pi;

    DYN_free(array);

    return;
end-proc;

//
// Internal: *on if the array has an element number
//
dcl-proc exists;
    dcl-pi *n ind;
        array like(dynamicarray_t) const;
        number int(10) const;
    end-pi;
    dcl-s ptr_header pointer;
    dcl-ds header likeds(header_t) based(ptr_header);

    if (array = *NULL);
        return *off;
    endif;

    ptr_header = array;
    return (number >= 1 and number <= header.count);
end-proc;

//
// Internal: address of the slot of element number
//
dcl-proc slotAt;
    dcl-pi *n pointer;
        header likeds(header_t) const;
        number int(10) const;
    end-pi;

    return header.ptr_slots + (number - 1) * %size(slot_t);
end-proc;

//
// Internal: stores text in a slot, in an allocation of exactly its length
//
dcl-proc setText;
    dcl-pi *n;
        slot likeds(slot_t);
        text varchar(DYN_MAX_LENGTH) const;
    end-pi;
    dcl-s ptr_text pointer;
    // %addr can't be used on a const parameter, so copy the text first.
    // Only its current length is copied, not DYN_MAX_LENGTH bytes.
    dcl-s value varchar(DYN_MAX_LENGTH);

    value = text;
    ptr_text = slot.ptr_text;

    if (%len(value) = 0);
        freeText(slot);
        return;
    endif;

    if (ptr_text = *NULL);
        ptr_text = %alloc(%len(value));
    elseif (%len(value) <> slot.length);
        ptr_text = %realloc(ptr_text : %len(value));
    endif;

    memcpy(ptr_text : %addr(value : *data) : %len(value));

    slot.ptr_text = ptr_text;
    slot.length = %len(value);

    return;
end-proc;

//
// Internal: frees the text of a slot and leaves it empty
//
dcl-proc freeText;
    dcl-pi *n;
        slot likeds(slot_t);
    end-pi;
    dcl-s ptr_text pointer;

    ptr_text = slot.ptr_text;
    if (ptr_text <> *NULL);
        dealloc ptr_text;
    endif;

    slot.ptr_text = *NULL;
    slot.length = 0;

    return;
end-proc;

//
// Internal: makes room for more elements (doubles the capacity)
//
dcl-proc grow;
    dcl-pi *n;
        header likeds(header_t);
    end-pi;

    if (header.capacity = 0);
        header.capacity = INITIAL_CAPACITY;
        header.ptr_slots = %alloc(header.capacity * %size(slot_t));
    else;
        header.capacity *= 2;
        header.ptr_slots = %realloc(header.ptr_slots
                                    : header.capacity * %size(slot_t));
    endif;

    return;
end-proc;
