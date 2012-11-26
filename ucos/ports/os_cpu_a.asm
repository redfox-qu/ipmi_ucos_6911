;****************************************Copyright (c)****************************************************
;**                               Guangzou ZLG-MCU Development Co.,LTD.
;**                                      graduate school
;**                                 http://www.zlgmcu.com
;**
;**--------------File Info--------------------------------------------------------------------------------
;** File name: 	            os_cpu_a.asm
;** Last modified Date:     2007.12.12
;** Last Version:           1.0
;** Descriptions: 	    The assembly functions that a uC/OS-II port requires
;**                         uC/OS-II移植所需要的汇编函数  
;**-------------------------------------------------------------------------------------------------------
;** Created By:       	    Steven Zhou 周绍刚
;** Created date:   	    2007.12.12
;** Version:	            1.0
;** Descriptions:           The original version
;**
;**-------------------------------------------------------------------------------------------------------
;** Modified by:            
;** Modified date:          
;** Version:                
;** Description:            
;**
;*********************************************************************************************************

;*********************************************************************************************************
;  Declarations for the interrupt handlers that are used by the application.              
;  本应用所用到的声明                                       
;*********************************************************************************************************
    EXTERN  OSRunning                
    EXTERN  OSPrioCur
    EXTERN  OSPrioHighRdy
    EXTERN  OSTCBCur
    EXTERN  OSTCBHighRdy
    EXTERN  OSIntNesting
    EXTERN  OSIntExit
    EXTERN  OSTaskSwHook
    EXTERN  OsEnterSum


;*********************************************************************************************************
;  Declarations for the exported functions             
;  输出外部声明                          
;*********************************************************************************************************
    EXPORT  OSStartHighRdy
    EXPORT  OSCtxSw
    EXPORT  OSIntCtxSw
    EXPORT  OSPendSV
    EXPORT  OS_ENTER_CRITICAL
    EXPORT  OS_EXIT_CRITICAL                  
    EXPORT  intDisAll
           
           
;*********************************************************************************************************
;  Registers or macros used by this file                                
;  本文件用到的寄存器和宏                             
;*********************************************************************************************************							    
NVIC_INT_CTRL           EQU     0xE000ED04                              ;  Interrupt control state  
                                                                        ;  register.
                                                                        ;  中断控制寄存器

NVIC_SYSPRI2            EQU     0xE000ED20                              ;  System priority register (2)
                                                                        ;  系统优先级寄存器（2）

NVIC_PENDSV_PRI         EQU     0xFFFF0000                              ;  PendSV and system tick priority
                                                                        ;  (Both are lowest,0xff)  
                                                                        ;  软件中断和系统节拍中断
                                                                        ;  （都为最低，0xff）.
NVIC_PENDSVSET          EQU     0x10000000                              ;  Value to trigger PendSV  
                                                                        ;  exception.触发软件中断的值.

OS_CRITICAL_INT_PRIO    EQU     (1 << 5)		                ;  Critical setions manage priority 
                                                                        ;  (equal or bigger number managed) 
                                                                        ;  临界代码管理的优先级（数值等于
                                                                        ;  或大于被管理）
	         
		
    RSEG CODE:CODE:NOROOT(2)
    
;*********************************************************************************************************
;** Function name:      OS_ENTER_CRITICAL
;** Descriptions:       Enter the critical section  进入临界区                         
;** Input parameters:	None 无
;** Output parameters:	None 无
;** Returned value:	None 无
;** Created by:		Steven Zhou 周绍刚
;** Created Date:	2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:
;** Modified date:
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
OS_ENTER_CRITICAL
    IF OS_CRITICAL_INT_PRIO > 0
     	PUSH 	{R1,R2} 	                
     	LDR 	R1, =OS_CRITICAL_INT_PRIO                               ;  Disable priorities between 
                                                                        ;  OS_CRITICAL_INT_PRIO & 0xFF 
                                                                             			 				
        MSR 	BASEPRI,  R1                                            ;  禁能优先级在OS_CRITICAL_INT 
                                                                        ;  _PRIO到0xFF的中断      			 				 
    ELSE
	CPSID   I                                                       ;  Disable all the interrupts
                                                                        ;  禁能所有中断
        PUSH 	{R1,R2}      
    ENDIF
    
    LDR     R1, __OS_EnterSum	                                        ;  OsEnterSum++
    LDRB    R2, [R1]
    ADD     R2, R2, #1
    STRB    R2, [R1]
    POP     {R1,R2}
    BX      LR


;*********************************************************************************************************
;** Function name:      OS_EXIT_CRITICAL
;** Descriptions:       Exit the critical section  退出临界区
;** Output parameters:	None 无
;** Input parameters:	None 无
;** Returned value:	None 无
;** Created by:		Steven Zhou 周绍刚
;** Created Date:       2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:    
;** Modified date:  
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
OS_EXIT_CRITICAL
	PUSH    {R1, R2}
	LDR     R1, __OS_EnterSum                                     	;  OsEnterSum--
        LDRB    R2, [R1]
        SUB     R2, R2, #1
        STRB    R2, [R1]
	MOV     R1,  #0    
	CMP     R2,  #0			                                ;  if OsEnterSum=0,enable 
                                                                        ;  interrupts.  
     	                                                                ;  如果OsEnterSum=0，开中断。
        
        IF OS_CRITICAL_INT_PRIO > 0 
 	    IT EQ 
  	    MSREQ  BASEPRI, R1 
	ELSE
            IT EQ 
            MSREQ  PRIMASK, R1     
	ENDIF
        
        POP     {R1, R2}
        BX      LR
        

;*********************************************************************************************************
;** Function name:      OSStartHighRdy
;** Descriptions:	Uses the context switcher  to cause the first task to start.
;**                     使用调度器运行第一个任务   
;** Input parameters:	None 无
;** Output parameters:	None 无
;** Returned value:	None 无
;** Created by:		Steven Zhou 周绍刚
;** Created Date:	2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:            
;** Modified date:          
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
OSStartHighRdy

    LDR     R4, =NVIC_SYSPRI2                                           ;  set the PendSV exception 
                                                                        ;  priority设置PendSV优先级
    LDR     R5, =NVIC_PENDSV_PRI	
    STR     R5, [R4]
	    
    MOV     R4, #0                                                      ;  set the PSP to 0 for initial  
                                                                        ;  context switch call 使PSP等于0
    MSR     PSP, R4

    LDR     R4, __OS_Running                                            ;  OSRunning = TRUE
    MOV     R5, #1
    STRB    R5, [R4]

    LDR     R4, =NVIC_INT_CTRL                                          ;  trigger the PendSV exception
                                                                        ;  触发软件中断
    LDR     R5, =NVIC_PENDSVSET
    STR     R5, [R4]

    CPSIE   I                                                           ;  enable interrupts at processor 
                                                                        ;  level使能所有优先级的中断
OSStartHang
    B       OSStartHang             


;*********************************************************************************************************
;** Function name:      OSCtxSw
;** Descriptions:	Perform a contex switch from task level  任务级上下文切换                          
;** Input parameters:	None 无
;** Output parameters:  None 无
;** Returned value:	None 无        
;** Created by:		Steven Zhou 周绍刚
;** Created Date:       2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:           
;** Modified date:         
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
OSCtxSw
    PUSH    {R4, R5}
    LDR     R4, =NVIC_INT_CTRL                                          ;  trigger the PendSV exception
                                                                        ;  触发软件中断
    LDR     R5, =NVIC_PENDSVSET
    STR     R5, [R4]
    POP     {R4, R5}
    BX      LR


;*********************************************************************************************************
;** Function name:      OSIntCtxSw
;** Descriptions:	Called by OSIntExit() when it determines a context switch is needed as the
;**                     result of an interrupt.
;**                     中断级任务切换                 
;** Input parameters:   None 无
;** Output parameters:	None 无
;** Returned value:	None 无
;** Created by:		Steven Zhou 周绍刚
;** Created Date:       2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:   
;** Modified date: 
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
OSIntCtxSw
    PUSH    {R4, R5}
    LDR     R4, =NVIC_INT_CTRL                                          ;  trigger the PendSV exception
                                                                        ;  触发软件中断
    LDR     R5, =NVIC_PENDSVSET
    STR     R5, [R4]
    POP     {R4, R5}
    BX      LR
    NOP


;*********************************************************************************************************
;** Function name:      OSPendSV
;** Descriptions:	Used to cause a context switch 用于上下文切换
;** Input parameters:	None 无
;** Output parameters:	None 无
;** Returned value:	None 无
;** Created by:		Steven Zhou 周绍刚
;** Created Date:	2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:         
;** Modified date:       
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
OSPendSV
    IF OS_CRITICAL_INT_PRIO > 0	                                        ;  disable interupt 禁能中断
        MRS R3, BASEPRI
        LDR R1, =OS_CRITICAL_INT_PRIO
	MSR BASEPRI, R1
    ELSE
       	MRS     R3, PRIMASK                
       	CPSID   I
    ENDIF

    MRS     R0, PSP                                                     ;  PSP is process stack pointer  
                                                                        ;  PSP是任务的堆栈指针
    CBZ     R0, OSPendSV_nosave                                         ;  skip register save the first 
                                                                        ;  time第一次跳过保存

    SUB     R0, R0, #0x20                                               ;  save remaining regs r4-11 on 
                                                                        ;  process stack 保存r4-r11
    STM     R0, {R4-R11}

    LDR     R4, __OS_TCBCur                                             ;  OSTCBCur->OSTCBStkPtr = SP;
    LDR     R4, [R4]
    STR     R0, [R4]                                                    ;  R0 is SP of process being 
                                                                        ;  switched outR0是被切换开的任务
                                                                        ;  的堆栈指针
OSPendSV_nosave
    PUSH    {R14}                                                       ;  need to save LR exc_return 
                                                                        ;  value保存LR返回值

    LDR.W   R0, __OS_TaskSwHook                                         ;  OSTaskSwHook();
    BLX     R0
    POP     {R14}
 	  
    LDR     R4, __OS_PrioCur                                            ;  OSPrioCur = OSPrioHighRdy
    LDR     R5, __OS_PrioHighRdy     
    LDRB    R6, [R5]
    STRB    R6, [R4]

    LDR     R4, __OS_TCBCur                                             ;  OSTCBCur  = OSTCBHighRdy;
    LDR     R6, __OS_TCBHighRdy      
    LDR     R6, [R6]
    STR     R6, [R4]

    LDR     R0, [R6]                                                    ;  SP = OSTCBHighRdy->OSTCBStkPtr;
    LDM     R0, {R4-R11}                                                ;  restore r4-11 from new process
                                                                        ;  stack 从新任务的堆栈恢复r4-r11
    ADD     R0, R0, #0x20
    MSR     PSP, R0                                                     ;  load PSP with new process SP
                                                                        ;  从新任务的堆栈恢复PSP
 	   	
    ORR     LR, LR, #0x04                                               ;  ensure exception return uses 
                                                                        ;  PSP确保返回后使用PSP
        
    IF OS_CRITICAL_INT_PRIO > 0                                         ;  restore interrupts 恢复中断  
        MSR 	BASEPRI,  R3
    ELSE
	MSR     PRIMASK, R3
    ENDIF
		   
    BX      LR                                                          ; exception return will restore 
                                                                        ;  remaining context 
                                                                        ;  返回时会恢复剩下的上下文
    NOP


;*********************************************************************************************************
;** Function name:      IntDisAll
;** Descriptions:	Disable all interrupts from the interrupt controller  关闭中断控制器的所有中断
;** Input parameters:	None 无
;** Output parameters:	None 无
;** Returned value:	None 无
;** Created by:		Steven Zhou 周绍刚
;** Created Date:	2007.12.12
;**-------------------------------------------------------------------------------------------------------
;** Modified by:         
;** Modified date:       
;**-------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
intDisAll
    CPSID   I
    BX      LR
    
    
;*********************************************************************************************************
;  POINTERS TO VARIABLES
;  变量指针  
;*********************************************************************************************************
    DATA

__OS_TaskSwHook:
    DC32    OSTaskSwHook

__OS_IntExit:
    DC32    OSIntExit

__OS_IntNesting:
    DC32    OSIntNesting

__OS_PrioCur:
    DC32    OSPrioCur

__OS_PrioHighRdy:
    DC32    OSPrioHighRdy

__OS_Running:
    DC32    OSRunning

__OS_TCBCur:
    DC32    OSTCBCur

__OS_TCBHighRdy:
    DC32    OSTCBHighRdy

__OS_EnterSum:
    DC32    OsEnterSum


    END

;*********************************************************************************************************
;  __END FILE 
;*********************************************************************************************************
