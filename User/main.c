/*
***********************************************************
*												包含的头文件
***********************************************************
*/

#include <rtthread.h>
#include <rthw.h>
#include "ARMCM3.h"

/*
***********************************************************
*													全局变量
***********************************************************
*/
rt_uint8_t	flag1;
rt_uint8_t	flag2;

extern rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];

/*
***********************************************************
*								线程控制块 & STACK & 线程声明
***********************************************************
*/

/* 定义线程控制块 */
struct	rt_thread	rt_flag1_thread;
struct	rt_thread	rt_flag2_thread;

ALIGN(RT_ALIGN_SIZE)
/* 定义线程栈 */
rt_uint8_t	rt_flag1_thread_stack[512];
rt_uint8_t	rt_flag2_thread_stack[512];

/* 线程声明 */
void flag1_thread_entry(void *p_arg);
void flag2_thread_entry(void *p_arg);

/*
***********************************************************
*												函数声明
***********************************************************
*/

void delay (uint32_t count);

/*
***********************************************************
*													main函数
***********************************************************
*/
int main(void)
{
	/* 硬件初始化 */
	
	/* 关中断 */
	rt_hw_interrupt_disable();
	
	/* SysTick中断频率设置 */
	SysTick_Config(SystemCoreClock / RT_TICK_PER_SECOND);
	
	/* 调度器初始化 */
	rt_system_scheduler_init();
	
	/* 初始化空闲线程 */
	rt_thread_idle_init();
	
	/* 初始化线程 */
	rt_thread_init(	&rt_flag1_thread,
									"rt_flag1_thread",
									flag1_thread_entry,
									RT_NULL,
									&rt_flag1_thread_stack[0],
									sizeof(rt_flag1_thread_stack),
									2);
	
	/* 将线程插入到就绪列表 */
	//rt_list_insert_before(&(rt_thread_priority_table[0]),&(rt_flag1_thread.tlist));
	rt_thread_startup(&rt_flag1_thread);
	
	/* 初始化线程 */
	rt_thread_init(	&rt_flag2_thread,
									"rt_flag2_thread",
									flag2_thread_entry,
									RT_NULL,
									&rt_flag2_thread_stack[0],
									sizeof(rt_flag2_thread_stack),
									3);
	
	/* 将线程插入到就绪列表 */
	//rt_list_insert_before(&(rt_thread_priority_table[1]),&(rt_flag2_thread.tlist));
	rt_thread_startup(&rt_flag2_thread);
	
	/* 启动系统调度器 */
	rt_system_scheduler_start();
}

/* software delay */
void delay (uint32_t count)
{
	for(; count != 0; count--);
}

/* thread1 */
void flag1_thread_entry(void *p_arg)
{
	for( ; ; )
	{
#if 0
		flag1 = 1;
		delay(100);
		flag1 = 0;
		delay(100);
		
		/* 线程切换，这里是手动切换 */
		rt_schedule();
#else
		flag1 = 1;
		rt_thread_delay(2);
		flag1 = 0;
		rt_thread_delay(2);
#endif
	}
}

/* thread2 */
void flag2_thread_entry(void *p_arg)
{
	for( ; ; )
	{
#if 0
		flag2 = 1;
		delay(100);
		flag2 = 0;
		delay(100);
		
		/* 线程切换，这里是手动切换 */
		rt_schedule();
#else
		flag2 = 1;
		rt_thread_delay(2);
		flag2 = 0;
		rt_thread_delay(2);
#endif
	}
}

void SysTick_Handler(void)
{
	/* 进入中断 */
	rt_interrupt_enter();
	
	/* 时基更新 */
	rt_tick_increase();
	
	/* 离开中断 */
	rt_interrupt_leave();
}
