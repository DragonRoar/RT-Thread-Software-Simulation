# RT-Thread-Software-Simulation
板级移植前的手撸RT-Thread内核仿真版本管理库

2020/9/9 线程的定义与线程切换的实现：发现按照教程敲出来的代码只有在将ARM Complier配置为V5版本的时候才能仿真出正确的结果，V6版本则不行。简单地在 rtdef.h 文件中的 #if defined __CC_ARM 之后追加过 #elif defined(__ARMCC_VERSION) && (__ARMCC_VERSION >= 6010050) 尝试解决兼容问题，但似乎并没有这么简单。

2020/9/10 空闲线程与阻塞延时的实现：这次按教程敲出代码后刚开始仿真的时候发现无法全速运行（但是仿真正常的话跑出来的波形是正确的），会自动停在 PendSV_Handler 函数中时基更新函数 rt_tick_increase 中的 if(thread->remaining_tick > 0) thread->remaining_tick--; 这一句。将其注释掉即可全速运行。怀疑是什么地方敲错了导致出现了要求访问不存在的内存或是寄存器的情况。经初步校对源码后并未发现明显错误，然后仿真能够正常运行了（改了改格式加了点注释之类的，总之到底发生了什么就是觉得很懵QAQ）
