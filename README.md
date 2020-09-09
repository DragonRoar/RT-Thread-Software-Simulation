# RT-Thread-Software-Simulation
板级移植前的手撸RT-Thread内核仿真版本管理库

2020/9/9 线程的定义与线程切换的实现：发现按照教程敲出来的代码只有在将ARM Complier配置为V5版本的时候才能仿真出正确的结果，V6版本则不行。简单地在 rtdef.h 文件中的 #if defined __CC_ARM 之后追加过 #elif defined(__ARMCC_VERSION) && (__ARMCC_VERSION >= 6010050) 尝试解决兼容问题，但似乎并没有这么简单。
