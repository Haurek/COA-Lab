# pragma once 

const long MAX_LINE = 65536;

enum associate {
    FULLASSOCIATE, DIRECT, SETASSOCIATE
};

enum replace {
    RANDOM, LRU
};

enum write {
    WRITEBACK, WRITEALLOCATE
};

