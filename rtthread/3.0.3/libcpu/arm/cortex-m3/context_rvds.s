;******************************************************
;					  ȫ�ֱ���
;******************************************************
	IMPORT	rt_thread_switch_interrupt_flag
	IMPORT	rt_interrupt_from_thread
	IMPORT	rt_interrupt_to_thread

;******************************************************
;						����
;******************************************************
SCB_VTOR			EQU		0xE000ED08
NVIC_INT_CTRL		EQU		0xE000ED04
NVIC_SYSPRI2		EQU		0xE000ED20
NVIC_PENDSV_PRI		EQU		0x00FF0000
NVIC_PENDSVSET		EQU		0x10000000

;******************************************************
;					 �������ָ��
;******************************************************
	AREA |.text|, CODE, READONLY, ALIGN=2
	THUMB
	REQUIRE8
	PRESERVE8

;*******************************************************
;					��һ���߳��л����ֶ�ָ����
;*******************************************************
rt_hw_context_switch_to		PROC
		EXPORT rt_hw_context_switch_to
	
	;�ֶ�ָ���˵�һ��Ҫ���е��̣߳���� from_thread ������Ϊ0
	LDR		r1, = rt_interrupt_to_thread		
	STR		r0,	[r1]
	
	LDR		r1, = rt_interrupt_from_thread
	MOV		r0,	#0x0
	STR		r0,	[r1]
	
	LDR		r1, = rt_thread_switch_interrupt_flag
	MOV		r0, #1
	STR		r0,	[r1]
	
	;����PendSV�쳣�����ȼ�
	LDR		r0,	= NVIC_SYSPRI2
	LDR		r1, = NVIC_PENDSV_PRI
	LDR.W	r2, [r0,#0x00]
	ORR		r1,r1,r2
	STR		r1,	[r0]
	
	;����PendSV�쳣
	LDR		r0,	= NVIC_INT_CTRL
	LDR		r1, = NVIC_PENDSVSET
	STR		r1,	[r0]
	
	CPSIE	F											;���쳣
	CPSIE	I											;���жϣ�D:Disable / E:Enable��
	
	ENDP
		
;*******************************************************
;						�̵߳���
;*******************************************************
rt_hw_context_switch	PROC
		EXPORT	rt_hw_context_switch
			
	LDR		r2, = rt_thread_switch_interrupt_flag
	LDR		r3, [r2]
	CMP		r3,	#1
	BEQ		_reswitch
	MOV		r3,	#1			;�жϱ�ʶ��Ϊ1����1
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
;				PendSV�쳣�����������л���
;*******************************************************

PendSV_Handler		PROC
		EXPORT	PendSV_Handler
		
	MRS		r2, PRIMASK									;�����ж�״̬
	CPSID	I											
	
	LDR		r0, = rt_thread_switch_interrupt_flag
	LDR		r1,	[r0]
	CBZ		r1,	pendsv_exit								;����жϱ�־Ϊ0���򲻽����л�
	
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
	MSR		PRIMASK, r2									;�ָ��ж�״̬
	ORR		lr, lr, #0x04
	BX		lr
	
	ENDP

;*******************************************************
;						 ���ж�
;*******************************************************
rt_hw_interrupt_disable		PROC
	EXPORT	rt_hw_interrupt_disable		
	MRS		r0, PRIMASK
	CPSID	I
	BX		LR
	ENDP

;*******************************************************
;						 ���ж�(�ָ��ж�)
;*******************************************************
rt_hw_interrupt_enable		PROC
	EXPORT	rt_hw_interrupt_enable	
	MSR		PRIMASK, r0
	BX		LR
	ENDP

	ALIGN	4
		
	END