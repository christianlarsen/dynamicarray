**free
ctl-opt main(main) actgrp(*caller);

dcl-s dinamicarray_t pointer template;
dcl-ds node_t qualified template;
    text varchar(100) inz;
    ptrnext like(dinamicarray_t) inz;
end-ds;

dcl-proc main;
    dcl-s z zoned(5);
    dcl-s array like(dinamicarray_t);

    // Initialize of array
    initializeArray(array);

    // Add 10 new nodes to array
    for z = 1 to 10;
        addNode('Test ' + %char(z):array);
    endfor;

    // Retrieve some nodes, and write the content to the job log
    snd-msg retrieveNode(8:array);
    snd-msg retrieveNode(2:array);
    snd-msg retrieveNode(9:array);

    // Remove array from memory before ending the program
    initializeArray(array);

end-proc;

//
// Subprocedure initializeArray
//
dcl-proc initializeArray;
    dcl-pi *n;
        array like(dinamicarray_t);
    end-pi;
    dcl-s found ind;
    dcl-s ptr_aux pointer;
    dcl-s ptr_aux2 pointer;
    dcl-ds node_aux likeds(node_t) based(ptr_aux);
    dcl-ds node_aux2 likeds(node_t) based(ptr_aux2);

    if array = *NULL;
        return;
    else;
        found = *off;
        ptr_aux = array;
        dou found;
            if node_aux.ptrnext = *NULL;
                dealloc(n) ptr_aux;
                found = *on;
                snd-msg 'Memory deallocated';
                return;
            endif;
            ptr_aux2 = ptr_aux;
            ptr_aux = node_aux.ptrnext;
            dealloc(n) ptr_aux2;
            snd-msg 'Memory deallocated';
        enddo;
    endif;

    return;
end-proc;

//
// Subprocedure addNode
//
dcl-proc addNode;
    dcl-pi *n;
        text varchar(100) const;
        array like(dinamicarray_t);
    end-pi;
    dcl-s found ind;
    dcl-s ptr_node pointer;
    dcl-s ptr_aux pointer;
    dcl-ds node_aux likeds(node_t) based(ptr_aux);
    dcl-ds node likeds(node_t) based(ptr_node);

    // First, we create the node in dinamic memory
    ptr_node = %alloc(%size(node));
    node.text = text;
    snd-msg 'Memory allocated';

    if array = *NULL;
        array = ptr_node;
    else;
        found = *off;
        ptr_aux = array;
        dou found;
            if node_aux.ptrnext = *NULL;
                node_aux.ptrnext = ptr_node;
                found = *on;
                return;
            endif;
            ptr_aux = node_aux.ptrnext;
        enddo;
    endif;

    return;

end-proc;

//
// Subprocedure retrieveNode
//
dcl-proc retrieveNode;
    dcl-pi *n varchar(100);
        number zoned(5) const;
        array like(dinamicarray_t);
    end-pi;
    dcl-s z zoned(5);
    dcl-s ptr_node pointer;
    dcl-s ptr_aux pointer;
    dcl-ds node_aux likeds(node_t) based(ptr_aux);
    dcl-ds node likeds(node_t) based(ptr_node);

    ptr_aux = array;
    z = 1;
    dow z <= number;
        if z = number;
            return node_aux.text;
        endif;
        z += 1;
        ptr_aux = node_aux.ptrnext;
    enddo;

    return 'ERROR';

end-proc;



