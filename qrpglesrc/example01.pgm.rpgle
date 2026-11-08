**free
ctl-opt main(main);

/include qrpglesrc/dynarray_h.rpgle

dcl-proc main;
    dcl-s z zoned(5);
    dcl-s array like(dynamicarray_t);

    // The array starts empty (*NULL), but initializing it doesn't hurt
    DYN_initializeArray(array);

    // Add 10 new nodes to array
    for z = 1 to 10;
        DYN_addNode('Test ' + %char(z):array);
    endfor;

    // Retrieve some nodes, and write the content to the job log
    snd-msg DYN_retrieveNode(8:array);
    snd-msg DYN_retrieveNode(2:array);
    snd-msg DYN_retrieveNode(9:array);
    snd-msg DYN_retrieveNode(99:array);   // doesn't exist: 'ERROR'

    // Remove array from memory before ending the program
    DYN_initializeArray(array);

end-proc;
