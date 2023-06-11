# 实验4：构建cache模拟器

实验时间：6.5 2023

实验人员：黄昊，21300240011



## 1 实验目的

实验目的：

- 完成cache模拟器
- 理解cache块大小对cache性能的影响
- 理解cache关联性对cache性能的影响

- 理解cache总大小对cache性能的影响

- 理解cache替换策略对cache性能的影响
- 理解cache写回策略对cache性能的影响



## 2 实验过程

### 2.1 完成cache模拟器

- cache行

  ~~~c++
  struct line
  {
      bool valid;
      bool dirty;
      unsigned tag;
      unsigned counter;
  
      line() : valid(false), dirty(false), tag(0), counter(0) {}
  };
  ~~~

  因为模拟器中不需要实际保存数据，因此cache行中只有有效位、修改位、使用位和tag标识

- cache类

  cache模拟器成员变量：

  - block_size：块大小
  - data_size：数据大小
  - cost：非命中开销
  - line_num：cache行数
  - lines：保存cache行的数组
  - associate_strategy：cache关联性（直接映射、全相联映射或组相联映射）
  - set_size和group_num：组相联映射时的组行数和组数
  - replace_strategy：替换策略（LRU、随机替换）
  - write_strategy：写回策略（写分配法、回写法）
  - total：访存指令总数
  - total_load和total_store：读内存和写内存的总指令数
  - load_hit和store_hit：读命中和写命中次数
  - run_time：模拟运行周期数

  cache模拟器成员函数：

  - `init`：根据配置信息计算cache行数和组数
  - `parseTraceData`：从一条trace数据中解析出访存方式和访存地址
  - `getTag`和`getLineNum`：根据解析出的访存地址，取出tag和对应的cache行号
  - `LRUNum`和`randomLineNum`：根据替换策略在需要替换时返回被替换的行号
  - `updateCounter`：用于在LRU策略下更新使用位
  - `setConfig`：根据配置文件设置cache模拟器
  - `run`：模拟器运行函数，根据提供的trace数据来运行cache
  - 输出重载用于模拟器模拟结果输出

~~~c++
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
    void setConfig(std::ifstream &cfg);
    void run(const std::string &data);
    friend std::ostream& operator<<(std::ostream &os, const cache &item);
    friend std::ofstream& operator<<(std::ofstream &os, const cache &item);
    ~cache();
};
~~~

- cache运行函数`run`

  首先根据访存地址取出tag标识和cache行号，然后根据不同的关联性分析cache行为

  在不同的关联性下，根据cache是读访问还是写访问再做进一步分析：

  | 关联性     | 读命中                            | 读缺失                                                       | 写命中                                                       | 写缺失                                                       |
  | ---------- | --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
  | 直接映射   | load_hit++                        | 直接进行替换，周期加上读内存开销                             | store_hit++，写分配法要增加写内存开销，写回法要更新修改位    | 周期加上写内存开销，并将内容直接进行替换                     |
  | 全相联映射 | load_hit++，LRU策略下要更新使用位 | 有空余行直接进行替换，没有则根据替换策略进行替换；LRU策略下要更新使用位 | store_hit++，写分配法要增加写内存开销，写回法要更新修改位，同时在LRU策略下要更新使用位 | 周期加上写内存开销，有空余行直接进行替换，没有则根据替换策略进行替换 |
  | 组相联映射 | load_hit++，LRU策略下要更新使用位 | 对应组中如果有空余行直接进行替换，没有则根据替换策略进行替换；LRU策略下要更新使用位 | store_hit++，写分配法要增加写内存开销，写回法要更新修改位，同时在LRU策略下要更新使用位 | 周期加上写内存开销，对应组中如果有空余行直接进行替换，没有则根据替换策略进行替换 |

  

## 3 实验结果

> 实验数据来自ls.trace

- cache块大小对cache性能影响

- cache总大小对cache性能的影响

  cache配置：

  - 关联性：直接映射
  - 替换策略：LRU
  - 非命中开销：100
  - 写回策略：写分配法

  实验结果：

  根据cache命中率结果可以发现，在cache数据大小相同时，块大小太大或太小都会使命中率降低，块大小居中时命中率较高，并且cache总大小越小时越明显

  当cache块大小固定时，cache的总大小越大，命中率越高

  ![block_cache](D:\大二\计算机组成与体系结构\实验\lab4\block_cache.png)

- cache关联性对cache性能的影响

  cache配置：

  - 块大小：64B
  - 替换策略：LRU

  - 非命中开销：100
  - 写回策略：写分配法![associate_block64B](D:\大二\计算机组成与体系结构\实验\lab4\associate_block64B.png)

  通过图像可以看出，全相联映射的命中率最高；组相联映射其次，并且4路组相联的命中率大于2路组相联，与cache运行原理相符；直接映射的命中率最低；

  cache数据大小越大，不同关联性之间的命中率差距越小

- cache替换策略对cache性能的影响

  cache配置：

  - 块大小：256B
  - 替换策略：LRU

  - 非命中开销：100
  - 关联性：直接映射

  ![write](D:\大二\计算机组成与体系结构\实验\lab4\write.png)

  通过图像可以看出回写法的时钟周期数要远小于写分配法的时钟周期数，因此使用回写法的cache的性能更好；并且cache数据大小越大，运行的时间越短，说明运行时命中率提高，这和cache数据大小对性能影响的结果一致

- cache写回策略对cache性能的影响

  cache配置：

  - 块大小：64B

  - 非命中开销：100
  - 关联性：全相联映射
  - 写回策略：写分配法

  

![replace](D:\大二\计算机组成与体系结构\实验\lab4\replace.png)

通过图像可以看出使用更加符合局部性的LRU替换策略的cache命中率更高，但随着数据大小的增大，两种算法的命中率差距也逐渐减小，因为数据大小增大后需要替换的次数减少，不同替换策略间的差距也就不明显了