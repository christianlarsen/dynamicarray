**free
ctl-opt nomain;

// Returned by DYN_retrieveNode when the node doesn't exist
dcl-c NOT_FOUND 'ERROR';

/include qrpglesrc/dynarray_h.rpgle

//
// Procedure initializeArray: frees every node and leaves the list empty
//
dcl-proc DYN_initializeArray export;
    dcl-pi *n;
        array like(dynamicarray_t);
    end-pi;
    dcl-s ptr_node pointer;
    dcl-s ptr_next pointer;
    dcl-ds node likeds(node_t) based(ptr_node);

    ptr_node = array;
    dow (ptr_node <> *NULL);
        ptr_next = node.ptrnext;
        dealloc ptr_node;
        ptr_node = ptr_next;
    enddo;

    // Don't leave the caller with a pointer to freed memory
    array = *NULL;

    return;
end-proc;

//
// Procedure addNode: adds a node at the end of the list
//
dcl-proc DYN_addNode export;
    dcl-pi *n;
        text varchar(100) const;
        array like(dynamicarray_t);
    end-pi;
    dcl-s ptr_node pointer;
    dcl-s ptr_aux pointer;
    dcl-ds node_aux likeds(node_t) based(ptr_aux);
    dcl-ds node likeds(node_t) based(ptr_node);

    // Create the node in dynamic memory. %alloc doesn't initialize the
    // memory, so clear it: ptrnext must start as *NULL.
    ptr_node = %alloc(%size(node));
    clear node;
    node.text = text;

    if (array = *NULL);
        array = ptr_node;
        return;
    endif;

    // Find the last node and link the new one after it
    ptr_aux = array;
    dow (node_aux.ptrnext <> *NULL);
        ptr_aux = node_aux.ptrnext;
    enddo;
    node_aux.ptrnext = ptr_node;

    return;
end-proc;

//
// Procedure retrieveNode: returns the text of node number (1 = first)
//
dcl-proc DYN_retrieveNode export;
    dcl-pi *n varchar(100);
        number zoned(5) const;
        array like(dynamicarray_t);
    end-pi;
    dcl-s z zoned(5);
    dcl-s ptr_aux pointer;
    dcl-ds node_aux likeds(node_t) based(ptr_aux);

    if (number < 1);
        return NOT_FOUND;
    endif;

    ptr_aux = array;
    z = 1;
    dow (ptr_aux <> *NULL);
        if (z = number);
            return node_aux.text;
        endif;
        z += 1;
        ptr_aux = node_aux.ptrnext;
    enddo;

    // The list has fewer than number nodes
    return NOT_FOUND;
end-proc;
