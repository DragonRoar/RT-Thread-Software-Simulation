;******************************************************
;					  全局变量
;******************************************************
	IMPORT	rt_thread_switch_interrupt_flag
	IMPORT	rt_interrupt_from_thread
	IMPORT	rt_interrupt_to_thread

;******************************************************
;						常量
;******************************************************
SCB_VTOR			EQU		0xE000ED08
NVIC_INT_CTRL		EQU		0xE000ED04
NVIC_SYSPRI2		EQU		0xE000ED20
NVIC_PENDSV_PRI		EQU		0x00FF0000
NVIC_PENDSVSET		EQU		0x10000000

;******************************************************
;					 代码产生指令
;******************************************************
	AREA |.text|, CODE, READONLY, ALIGN=2
	THUMB
	REQUIRE8
	PRESERVE8

;*******************************************************
;					第一次线程切换（手动指定）
;*******************************************************
rt_hw_context_switch_to		PROC
		EXPORT rt_hw_context_switch_to
	
	;手动指定了第一个要运行的线程，因此 from_thread 被设置为0
	LDR		r1, = rt_interrupt_to_thread		
	STR		r0,	[r1]
	
	LDR		r1, = rt_interrupt_from_thread
	MOV		r0,	#0x0
	STR		r0,	[r1]
	
	LDR		r1, = rt_thread_switch_interrupt_flag
	MOV		r0, #1
	STR		r0,	[r1]
	
	;设置PendSV异常的优先级
	LDR		r0,	= NVIC_SYSPRI2
	LDR		r1, = NVIC_PENDSV_PRI
	LDR.W	r2, [r0,#0x00]
	ORR		r1,r1,r2
	STR		r1,	[r0]
	
	;触发PendSV异常
	LDR		r0,	= NVIC_INT_CTRL
	LDR		r1, = NVIC_PENDSVSET
	STR		r1,	[r0]
	
	CPSIE	F											;开异常
	CPSIE	I											;开中断（D:Disable / E:Enable）
	
	ENDP
		
;*******************************************************
;						线程调度
;*******************************************************
rt_hw_context_switch	PROC
		EXPORT	rt_hw_context_switch
			
	LDR		r2, = rt_thread_switch_interrupt_flag
	LDR		r3, [r2]
	CMP		r3,	#1
	BEQ		_reswitch
	MOV		r3,	#1			;中断标识不为1则置1
	STR		r3,	[r2]
	
	LDR		r2, = rt_interrupt_from_thread
	STR		r0,	[r2]
	
_reswitch
	LDR		r2,	= rt_interrupt_to_thread
	STR		r1, [r2]
	
	LDR		r0, = NVIC_INT_CTRL
	LDR		r1, = NVIC_PENDSVSET
	STR		r1,	[r0]
	
	BX		LR
	
	ENDP
		
;*******************************************************
;				PendSV异常处理（上下文切换）
;*******************************************************

PendSV_Handler		PROC
		EXPORT	PendSV_Handler
		
	MRS		r2, PRIMASK									;保存中断状态
	CPSID	I											
	
	LDR		r0, = rt_thread_switch_interrupt_flag
	LDR		r1,	[r0]
	CBZ		r1,	pendsv_exit								;如果中断标志为0，则不进行切换
	
	MOV		r1,	#0x00
	STR		r1,	[r0]
	
	LDR		r0,	= rt_interrupt_from_thread
	LDR		r1,	[r0]
	CBZ		r1,	switch_to_thread
	
	MRS		r1,	psp
	STMFD	r1!,{r4 - r11}
	LDR		r0,	[r0]
	STR		r1,	[r0]
	
switch_to_thread
	LDR		r1, = rt_interrupt_to_thread
	LDR		r1,	[r1]
	LDR		r1,	[r1]
	
	LDMFD	r1!,{r4 - r11}
	MSR		psp, r1
	
pendsv_exit
	MSR		PRIMASK, r2									;恢复中断状态
	ORR		lr, lr, #0x04
	BX		lr
	
	ENDP

;*******************************************************
;						 关中断
;*******************************************************
rt_hw_interrupt_disable		PROC
	EXPORT	rt_hw_interrupt_disable		
	MRS		r0, PRIMASK
	CPSID	I
	BX		LR
	ENDP

;*******************************************************
;						 开中断(恢复中断)
;*******************************************************
rt_hw_interrupt_enable		PROC
	EXPORT	rt_hw_interrupt_enable	
	MSR		PRIMASK, r0
	BX		LR
	ENDP

	ALIGN	4
		
	END