# pragma once

#include <iostream>
#include <fstream>
#include <string>

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

struct line {
    bool valid;
    bool dirty;
    unsigned tag;
    unsigned counter;

    line() : valid(false), dirty(false), tag(0), counter(0) {}
};

class cache
{
private:
    unsigned block_size;
    unsigned long data_size;
    unsigned cost;
    unsigned line_num;
    line lines[MAX_LINE];

    associate associate_strategy;
    unsigned set_size;
    unsigned group_num;
    replace replace_strategy;
    write write_strategy;

    unsigned long total;
    unsigned long total_load;
	unsigned long total_store;
    unsigned long load_hit;
    unsigned long store_hit;
    unsigned long run_time;

    void init();
    bool parseTraceData(const std::string &data, std::string &access, unsigned long long &addr);
    unsigned getTag(const unsigned long long &addr);
    unsigned getLineNum(const unsigned long long &addr);
    const unsigned randomLineNum(const unsigned from, const unsigned to);
    const unsigned LRUNum(const unsigned from, const unsigned to);
	void updateCounter();

public:
    cache();
    cache(unsigned b, unsigned a, unsigned long d, replace r, unsigned m, write w);
    cache(std::ifstream &configfile);
    void setConfig(std::ifstream &cfg);
    void run(const std::string &data);
    friend std::ostream& operator<<(std::ostream &os, const cache &item);
    friend std::ofstream& operator<<(std::ofstream &os, const cache &item);
    ~cache();
};
