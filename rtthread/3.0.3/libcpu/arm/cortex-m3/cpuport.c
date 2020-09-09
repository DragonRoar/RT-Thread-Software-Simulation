#include <rtthread.h>

/*
*************************************************************************
*                                 数据类型
*************************************************************************
*/
struct exception_stack_frame
{
	/* The contents of the CPU registers are automatically loaded when an exception occurs */
	rt_uint32_t r0;
	rt_uint32_t r1;
	rt_uint32_t r2;
	rt_uint32_t r3;
	rt_uint32_t r12;
	rt_uint32_t lr;
	rt_uint32_t pc;
	rt_uint32_t psr;
};

struct stack_frame
{
	/* The contents of the CPU registers need to load by user when an exception occurs */
	rt_uint32_t r4;
	rt_uint32_t r5;
	rt_uint32_t r6;
	rt_uint32_t r7;
	rt_uint32_t r8;
	rt_uint32_t r9;
	rt_uint32_t r10;
	rt_uint32_t r11;
	
	struct exception_stack_frame exception_stack_frame;
};

/*
*************************************************************************
*                                 全局变量
*************************************************************************
*/

/* 用于存储上一个线程栈的sp指针 */
rt_uint32_t	rt_interrupt_from_thread;
/* 用于存储下一个将要运行的线程栈的sp指针 */
rt_uint32_t	rt_interrupt_to_thread;

/* PendSV中断服务函数执行标志 */
rt_uint32_t	rt_thread_switch_interrupt_flag;

/*
*************************************************************************
*                                 函数实现
*************************************************************************
*/
/* 线程栈初始化 */
rt_uint8_t *rt_hw_stack_init(	void				*tentry,
															void				*parameter,
															rt_uint8_t	*stack_addr)
{
	
	
	struct	stack_frame *stack_frame;
	rt_uint8_t					*stk;
	unsigned long				i;
	
	
	/* get stack top pointer 
	 when call rt_hw_stack_init, (stack top pointer - 4) will be transmitted to stack_addr*/
	stk = stack_addr + sizeof(rt_uint32_t);
	
	/* align stk pointer down 8 bytes */
	stk = (rt_uint8_t *)RT_ALIGN_DOWN((rt_uint32_t)stk,8);
	
	/* stk pointer continues to move down (struct stack_frame) offsets */
	stk -= sizeof(struct stack_frame);
	
	/* change the stk pointer's type to stack_frame */
	stack_frame = (struct stack_frame *)stk;
	
	/* set stack_frame as start address, and set 0xdeadbeef as the initial vaule of sizeof(struct stack_frame) buffers in stack space */
	for(i = 0; i < sizeof(struct stack_frame) / sizeof(rt_uint32_t); i++)
	{
		((rt_uint32_t *)stack_frame)[i] = 0xdeadbeef;
	}
	
	/* the registers that will save automaticly when there are a unusual inition */
	stack_frame->exception_stack_frame.r0 = (unsigned long)parameter;
	stack_frame->exception_stack_frame.r1 = 0;
	stack_frame->exception_stack_frame.r2 = 0;
	stack_frame->exception_stack_frame.r3 = 0;
	stack_frame->exception_stack_frame.r12 = 0;
	stack_frame->exception_stack_frame.lr = 0;
	stack_frame->exception_stack_frame.pc = (unsigned long)tentry;
	stack_frame->exception_stack_frame.psr = 0x01000000L;
	
	
	/* return stk pointer */
	return stk;
}
