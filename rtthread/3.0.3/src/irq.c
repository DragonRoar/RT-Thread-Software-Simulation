#include <rtthread.h>
#include <rthw.h>

/* 中断计数器 */
volatile rt_uint8_t rt_interrupt_nest;

void rt_interrupt_enter(void)
{
	rt_base_t level;
	
	/* 关中断 */
	level = rt_hw_interrupt_disable();
	
	/* 中断计数器++ */
	rt_interrupt_nest++;
	
	/* 开中断 */
	rt_hw_interrupt_enable(level);
}

void rt_interrupt_leave(void)
{
	rt_base_t level;
	
	/* 关中断 */
	level = rt_hw_interrupt_disable();
	
	/* 中断计数器++ */
	rt_interrupt_nest--;
	
	/* 开中断 */
	rt_hw_interrupt_enable(level);
	
}
