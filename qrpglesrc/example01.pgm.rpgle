**free
// EXAMPLE01: uses every procedure of DYNARRAY and writes the results to
// the job log (DSPJOBLOG).
ctl-opt main(main);

/include qrpglesrc/dynarray_h.rpgle

dcl-proc main;
    dcl-s i int(10);
    dcl-s long varchar(25000);
    dcl-s array like(dynamicarray_t);

    // Add 1000 elements. The array starts empty (*NULL) and grows by itself.
    for i = 1 to 1000;
        DYN_addNode('Test ' + %char(i) : array);
    endfor;
    snd-msg 'Elements: ' + %char(DYN_count(array));            // 1000

    // Retrieve some elements
    snd-msg DYN_retrieveNode(8 : array);                         // Test 8
    snd-msg DYN_retrieveNode(999 : array);                       // Test 999
    snd-msg DYN_retrieveNode(5000 : array);                      // ERROR

    // Change element 2x
    DYN_update(2 : 'Changed' : array);
    snd-msg DYN_retrieveNode(2 : array);                         // Changed

    // Remove element 1: the rest move up one position
    DYN_delete(1 : array);
    snd-msg DYN_retrieveNode(1 : array);                         // Changed
    snd-msg 'Elements: ' + %char(DYN_count(array));            // 999

    // Find elements
    snd-msg 'Test 10 is at ' + %char(DYN_find('Test 10' : array));  // 9
    snd-msg 'Missing is at ' + %char(DYN_find('Missing' : array));  // 0

    // Long texts: each element only uses the memory its text needs
    %len(long) = 25000;
    long = *all'x';
    DYN_addNode(long : array);
    i = DYN_count(array);                                        // 1000
    snd-msg 'Length of element ' + %char(i) + ': '
            + %char(%len(DYN_retrieveNode(i : array)));          // 25000
    DYN_update(i : 'Short again' : array);
    snd-msg DYN_retrieveNode(i : array);                         // Short again

    // Free the memory before ending the program
    DYN_free(array);
    snd-msg 'Elements: ' + %char(DYN_count(array));            // 0

end-proc;
