**free

dcl-s dynamicarray_t pointer template;
dcl-ds node_t qualified template;
    text varchar(100) inz;
    ptrnext like(dynamicarray_t) inz;
end-ds;

dcl-pr DYN_initializeArray extproc;
    array like(dynamicarray_t);
end-pr;

dcl-pr DYN_addNode extproc;
    text varchar(100) const;
    array like(dynamicarray_t);
end-pr;

dcl-pr DYN_retrieveNode varchar(100) extproc;
    number zoned(5) const;
    array like(dynamicarray_t);
end-pr;
