#include <fstream>
#include <iostream>
#include <string>

#include "cache.h"

using namespace std;

int main(int argc, char* argv[])
{
    string configFile;
    string traceFile;
    string outFile;

    for (int i = 1; i < argc; ++i)
    {
        string arg = argv[i];
        if (arg == "-c" && i + 1 < argc)
        {
            configFile = argv[i + 1];
            i++;
        }
        else if (arg == "-t" && i + 1 < argc)
        {
            traceFile = argv[i + 1];
            i++;
        }
        else
        {
            std::cout << "Invalid arguments." << std::endl;
            return 0;
        }
    }

    outFile = traceFile + ".out";
    ifstream cfg(configFile);
    ifstream trace(traceFile);
    ofstream out(outFile);

    if (cfg.is_open() && trace.is_open())
    {
        cache cacheSim(cfg);
        cfg.close();
        try
        {
            string data;
            while (getline(trace, data))
            {
                cacheSim.run(data);
            }
            trace.close();
            out << cacheSim;
        }
        catch(const exception& e)
        {
            cerr << e.what() << '\n';
        }
    }
    else
    {
        cout << "fail to open file" << endl;
    }
    return 0;
}