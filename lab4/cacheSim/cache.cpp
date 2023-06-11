#include <random>
#include <iomanip>

#include "cache.h"

cache::cache() {}

cache::~cache() {}

cache::cache(unsigned b, unsigned a, unsigned long d, replace r, unsigned m, write w) 
{
    block_size = b;
    data_size = d << 10;
    replace_strategy = r;
    cost = m;
    if (a >= 2) 
    {
        if (a % 2 == 0)
        {
            associate_strategy = SETASSOCIATE;
            set_size = 1 << a;
        }
        else
        {
            throw "wrong associate strategy";
        }
    }
    else
    {
        associate_strategy = (associate) a;
    }
    write_strategy = w;
    init();
}

cache::cache(std::ifstream &configfile)
{
    int line = 0;
    std::string data;
    while (std::getline(configfile, data))
    {
        switch (line)
        {
            // read block size
            case 0:
            {
                unsigned size = std::stoi(data);
                if (size == 1 || size % 2 == 0)
                {
                    block_size = size;
                }            
                else
                {
                    throw "wrong block size";
                }
                break;
            }
            // read associate strategy
            case 1:
            {
                int a = std::stoi(data);
                if (a == 0)
                {
                    associate_strategy = FULLASSOCIATE;
                }
                else if (a == 1)
                {
                    associate_strategy = DIRECT;
                }
                else if (a > 1 && a % 2 == 0)
                {
                    associate_strategy = SETASSOCIATE;
                    set_size = 1 << a;
                }
                else
                {
                    throw "wrong associate strategy";
                }
                break;
            }
            // read data size
            case 2:
            {
                unsigned size = std::stoul(data);
                if (size == 1 || size % 2 == 0)
                {
                    data_size = size << 10;
                }            
                else
                {
                    throw "wrong data size";
                }
                break;
            }
            // read replace strategy
            case 3:
            {
                int r = std::stoi(data);
                if (r == 0)
                {
                    replace_strategy = RANDOM;
                }
                else if (r == 1)
                {
                    replace_strategy = LRU;
                }
                else
                {
                    throw "wrong replace strategy";
                }
                break;
            }
            // read miss cost
            case 4:
            {
                cost = std::stoi(data);
                break;
            }
            // read write strategy
            case 5:
            {
                unsigned w = std::stoi(data);
                if (w == 0)
                {
                    write_strategy = WRITEBACK;
                }
                else if (w == 1)
                {
                    write_strategy = WRITEALLOCATE;
                }
                else
                {
                    throw "wrong write strategy";
                }
            }
            default:
                break;
        }
        ++line;
    }
    init();
}

void cache::init() 
{
    // init output data
	total = 0;
	total_load = 0;
	total_store = 0;
	run_time = 0;
	load_hit = 0;
	store_hit = 0;

    // set lines
    line_num = data_size / block_size;
    if (associate_strategy == SETASSOCIATE)
    {
        group_num = line_num / set_size; 
    }
}

// parse the access of cache, tag and line number of cache from trace data
bool cache::parseTraceData(const std::string &data, std::string &access, unsigned long long &addr)
{
    size_t colonPos = data.find(':');
    std::string a;
    if (colonPos != std::string::npos)
    {
        try
        {
            access = data.substr(colonPos + 2, 1);
			std::string d = data.substr(colonPos + 6);
			addr = std::stoull(d, nullptr, 16);
        }
        catch(const std::exception& e)
        {
            std::cerr << e.what() << '\n';
            return false;
        }
        return true;
    }
    return false;
}

// run cache and updata cache status
void cache::run(const std::string &data)
{
    std::string access;
    unsigned long long address;

    if (parseTraceData(data, access, address))
    {
        unsigned tag = getTag(address);
        unsigned num = getLineNum(address);
        total++;
        run_time++;

        if (associate_strategy == DIRECT)
        {
            if (access == "R")
            {
                total_load++;
                // read hit
                if (lines[num].valid == true && lines[num].tag == tag)
                {
                    load_hit++;
                }
                // read miss
                else 
                {
                    run_time += cost;
					if (lines[num].valid)
					{
						// replace
						if (write_strategy == WRITEBACK)
						{
							lines[num].dirty = false;
						}
					}
                    lines[num].valid = true;
                    lines[num].tag = tag;
                }
            }
            else if (access == "W")
            {
				total_store++;
                // write hit
                if (lines[num].valid == true && lines[num].tag == tag)
                {
                    store_hit++;
					if (write_strategy == WRITEALLOCATE)
                    {
                        run_time += cost;
                    }
					else if (write_strategy == WRITEBACK)
					{
						lines[num].dirty = true;
					}
                }
                // write miss
                else
                {   
                    run_time += cost;
                    if (write_strategy == WRITEBACK)
                    {
                        lines[num].dirty = false;
                    }
                    lines[num].valid = true;
                    lines[num].tag = tag;
                }
            }
        }

        else if (associate_strategy == FULLASSOCIATE)
        {
            if (access == "R")
            {
				total_load++;
                int i;
                for (i = 0; i < line_num; ++i)
                {
                    if (lines[i].valid == true && lines[i].tag == tag)
                    {
                        // read hit
                        load_hit++;                        
						if (replace_strategy == LRU)
						{
							updateCounter();
							lines[i].counter = 0;
						}
                        break;
                    }
                }
                // read miss
                if (i == line_num)
                {
                    run_time += cost;
                    int j;
                    for (j = 0; j < line_num; ++j)
                    {
                        // still hava empty line
                        if (lines[j].valid == false)
                        {
                            if (replace_strategy == LRU)
                            {
                                updateCounter();
                                lines[j].counter = 0;
                            }
                            if (write_strategy == WRITEBACK)
                            {
                                lines[j].dirty = false;
                            }
                            lines[j].valid = true;
                            lines[j].tag = tag;
                            break;
                        }
                    }
                    // no empty line
                    // replace
                    if (j == line_num)
                    {
                        if (replace_strategy == RANDOM)
                        {
                            unsigned n = randomLineNum(0, line_num);
							if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                        else if (replace_strategy == LRU)
                        {
                            unsigned n = LRUNum(0, line_num);
                            if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            updateCounter();
                            lines[n].counter = 0;
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                    }
                }
            }
            else if (access == "W")
            {
				total_store++;
                int i;
                for (i = 0; i < line_num; ++i)
                {
                    if (lines[i].valid == true && lines[i].tag == tag)
                    {
                        // write hit
                        store_hit++;
						if (write_strategy == WRITEBACK)
                        {
							lines[i].dirty = true;
                        }
                        else if (write_strategy == WRITEALLOCATE)
                        {
                            run_time += cost;
                        }
						if (replace_strategy == LRU)
						{
							updateCounter();
							lines[i].counter = 0;
						}
                        break;
                    }
                }
                // write miss
                if (i == line_num)
                {
                    run_time += cost;
                    int j;
                    for (j = 0; j < line_num; ++j)
                    {
                        // still hava empty line
                        if (lines[j].valid == false)
                        {
							if (write_strategy == WRITEBACK)
							{
								lines[j].dirty = false;
							}
                            if (replace_strategy == LRU)
                            {
                                updateCounter();
                                lines[j].counter = 0;
                            }
                            lines[j].valid = true;
                            lines[j].tag = tag;
                            break;
						} 
                    }
                    // no empty line
                    // replace
                    if (j == line_num)
                    {
                        if (replace_strategy == RANDOM)
                        {
                            unsigned n = randomLineNum(0, line_num);
							if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                        else if (replace_strategy == LRU)
                        {
                            unsigned n = LRUNum(0, line_num);
                            if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            updateCounter();
                            lines[n].counter = 0;
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                    }
                }
            }
        }
        else if (associate_strategy == SETASSOCIATE)
        {
            // num is index of group
            if (access == "R")
            {
				total_load++;
                int i;
                for (i = 0; i < set_size; ++i)
                {
                    if (lines[num * set_size + i].valid == true && lines[num * set_size + i].tag == tag)
                    {
                        // read hit
                        load_hit++;
                        if (replace_strategy == LRU)
						{
							updateCounter();
							lines[num * set_size + i].counter = 0;
						}
                        break;
                    }
                }
                // read miss
                if (i == set_size)
                {
                    run_time += cost;
                    int j;
                    for (j = 0; j < set_size; ++j)
                    {
                        // still hava empty line
                        if (lines[num * set_size + j].valid == false)
                        {
                            if (replace_strategy == LRU)
                            {
                                updateCounter();
                                lines[num * set_size + j].counter = 0;
                            }
                            if (write_strategy == WRITEBACK)
                            {
                                lines[num * set_size + j].dirty = false;
                            }
                            lines[num * set_size + j].valid = true;
                            lines[num * set_size + j].tag = tag;
                            break;
                        }
                    }
                    // no empty line
                    // replace
                    if (j == set_size)
                    {
                        if (replace_strategy == RANDOM)
                        {
                            unsigned n = randomLineNum(num * set_size, num * set_size + set_size);
                            if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                        else if (replace_strategy == LRU)
                        {
                            unsigned n = LRUNum(num * set_size, num * set_size + set_size);
                            if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            updateCounter();
                            lines[n].counter = 0;
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                    }
                }
            }
            else if (access == "W")
            {
				total_store++;
                int i;
                for (i = 0; i < set_size; ++i)
                {
                    if (lines[num * set_size + i].valid == true && lines[num * set_size + i].tag == tag)
                    {
                        // write hit
                        store_hit++;
                        if (write_strategy == WRITEBACK)
                        {
                            lines[num * set_size + i].dirty = true;
                        }
                        else if (write_strategy == WRITEALLOCATE)
                        {
                            run_time += cost;
                        }
                        
						if (replace_strategy == LRU)
						{
							updateCounter();
							lines[num * set_size + i].counter = 0;
						}
                        break;
                    }
                }
                // write miss
                if (i == set_size)
                {
                    run_time += cost;
                    int j;
                    for (j = 0; j < set_size; ++j)
                    {
                        // still hava empty line
                        if (lines[num * set_size + j].valid == false)
                        {
                            if (write_strategy == WRITEBACK)
							{
								lines[num * set_size + j].dirty = false;
							}
                            if (replace_strategy == LRU)
                            {
                                updateCounter();
                                lines[num * set_size + j].counter = 0;
                            }
                            lines[num * set_size + j].valid = true;
                            lines[num * set_size + j].tag = tag;
                            break;
                        }
                    }
                    // no empty line
                    // replace
                    if (j == set_size)
                    {
                        if (replace_strategy == RANDOM)
                        {
                            unsigned n = randomLineNum(num * set_size, num * set_size + set_size);
                            if (write_strategy == WRITEBACK)
							{
								lines[n].dirty = false;
							}
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                        else if (replace_strategy == LRU)
                        {
                            unsigned n = LRUNum(num * set_size, num * set_size + set_size);
                            {
								lines[n].dirty = false;
							}
                            updateCounter();
                            lines[n].counter = 0;
                            lines[n].valid = true;
                            lines[n].tag = tag;
                        }
                    }
                }
            }
        }
    }
}

unsigned cache::getTag(const unsigned long long &addr)
{
    int block = 0;
    int line = 0;
    unsigned long long tag;
    int temp = block_size;
    unsigned long long mask = 0xffffffffffffffff;
    // get block address len
    while (temp != 1)
    {
        temp /= 2;
        block++;
    }
    mask <<= block;
    if (associate_strategy == DIRECT)
    {
        temp = line_num;
        while (temp != 1)
        {
            temp /= 2;
            line++;
        }
        mask <<= line;
        tag = addr & mask;
    }
    else if (associate_strategy == FULLASSOCIATE)
    {
        tag = addr & mask;
    }
    else
    {
        temp = group_num;
        while (temp != 1)
        {
            temp /= 2;
            line++;
        }
        mask <<= line;
        tag = addr & mask;
    }
    return tag >> (block + line);
}

unsigned cache::getLineNum(const unsigned long long &addr)
{
    int block = 0;
    int temp = block_size;
    while (temp != 1)
    {
        temp /= 2;
        block++;
    }
    int line = 0;
    unsigned long long mask = 1;
    if (associate_strategy == DIRECT)
    {
        temp = line_num;
        while (temp != 1)
        {
            temp /= 2;
            line++;
        }
        mask = (1 << line) - 1;
        return (addr >> block) & mask;
    }
    else if (associate_strategy == SETASSOCIATE)
    {
        temp = group_num;
        while (temp != 1)
        {
            temp /= 2;
            line++;
        }
        mask = (1 << line) - 1;
        return (addr >> block) & mask;
    }
    else
    {
        return -1;
    }
}

const unsigned cache::randomLineNum(const unsigned from, const unsigned to)
{
    std::random_device rd;
    std::mt19937 generator(rd());
    std::uniform_int_distribution<int> distribution(from, to);
    return distribution(generator);
}

const unsigned cache::LRUNum(const unsigned from, const unsigned to)
{
    unsigned num = lines[from].counter;
    for (int i = from + 1; i < to; ++i)
    {
        num = std::max(num, lines[i].counter);
    }
    return num;
}

void cache::updateCounter() 
{
	for (int i = 0; i < line_num; ++i)
	{
		if (lines[i].valid)
			lines[i].counter++;
	}
}

std::ostream& operator<<(std::ostream &os, const cache &item)
{
	double total_hit_rate = (double)(item.load_hit + item.store_hit) / (double)item.total;
    os << "Total Hit Rate: " << std::fixed << std::setprecision(2) << ((double)(item.load_hit + item.store_hit) / (double)item.total * 100.0) << "%" << "\n";
	os << "Load Hit Rate: "  << std::fixed << std::setprecision(2) << ((double)item.load_hit / (double)item.total_load * 100.0)				  << "%" << "\n";
	os << "Store Hit Rate: " << std::fixed << std::setprecision(2) << ((double)item.store_hit / (double)item.total_store * 100.0)		      << "%" << "\n";
    os << "Total Run Time: " << (item.run_time)	<< "\n";
	os << "AVG MA Latency: " << std::fixed << std::setprecision(2) << 1 + (1 - total_hit_rate) * item.cost << "\n";
	return os;
}

std::ofstream& operator<<(std::ofstream &os, const cache &item)
{
	double total_hit_rate = (double)(item.load_hit + item.store_hit) / (double)item.total;
    os << "Total Hit Rate: " << std::fixed << std::setprecision(2) << ((double)(item.load_hit + item.store_hit) / (double)item.total * 100.0) << "%" << "\n";
	os << "Load Hit Rate: "  << std::fixed << std::setprecision(2) << ((double)item.load_hit / (double)item.total_load * 100.0)				  << "%" << "\n";
	os << "Store Hit Rate: " << std::fixed << std::setprecision(2) << ((double)item.store_hit / (double)item.total_store * 100.0)		      << "%" << "\n";
    os << "Total Run Time: " << (item.run_time)	<< "\n";
	os << "AVG MA Latency: " << std::fixed << std::setprecision(2) << 1 + (1 - total_hit_rate) * item.cost << "\n";
	return os;
}