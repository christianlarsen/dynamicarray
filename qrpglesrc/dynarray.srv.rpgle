**free
ctl-opt nomain;

/copy "/home/CLV/dynamicarray/qrpglesrc/dynarray_h.rpgle"

//
// Procedure initializeArray
//
dcl-proc DYN_initializeArray export;
    dcl-pi *n;
        array like(dynamicarray_t);
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
// Procedure addNode
//
dcl-proc DYN_addNode export;
    dcl-pi *n;
        text varchar(100) const;
        array like(dynamicarray_t);
    end-pi;
    dcl-s found ind;
    dcl-s ptr_node pointer;
    dcl-s ptr_aux pointer;
    dcl-ds node_aux likeds(node_t) based(ptr_aux);
    dcl-ds node likeds(node_t) based(ptr_node);

    // First, we create the node in dynamic memory
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
// Procedure retrieveNode
//
dcl-proc DYN_retrieveNode export;
    dcl-pi *n varchar(100);
        number zoned(5) const;
        array like(dynamicarray_t);
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



