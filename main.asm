
;������9600
;---------------------------------------
        ORG 0000H
        LJMP MAIN
;--------------------------------------
;λ����		
        LCMRS  bit  P2.6
        LCMRW  bit  P2.5
        LCMEN  bit  P2.7
		LCMDATA EQU P0

;---------------------------------------
;�ж���ڵ�ַ����

        ORG  000BH
        LJMP TIMO      ;��ʱ��T0�ж���ڵ�ַ������ʱ�ö�ʱ���жϣ�
        ORG  0003H
		LJMP CLEAR
		ORG  0013H
        LJMP JISHU     ;�ⲿ�ж�1(��������),P3.3
		ORG  0023H
		LJMP RECEIVE   ;�����ж�

;------------------------------------
CLEAR:	   ;���ⲿ�ж�0
        //PUSH ACC				
        MOV  R0,#00H ;��ռ���ֵ
		MOV  30H,#0   ;���ҡһҡ���������λ�õ����ݳ�ʼ��
		MOV  31H,#0 
		MOV  32H,#0 
		MOV  33H,#0
		MOV  34H,#0
		LCALL SHOWTIME1

		//POP  ACC     	
		RETI

;---------------------------------------
RECEIVE:	           ;�����ж��ӳ���
    CLR RI
    MOV A,SBUF          
    MOV 5FH,A		   ;��������5FH
	MOV 61H,5FH		   ;��������61H
	LCALL SHOWTIME
    MOV SBUF,A           
    JNB TI,$
    CLR TI
	CLR ES
    RETI

;---------------------------------------
TIMO:
PUSH ACC
MOV TH0,#0D8H
MOV TL0,#0F0H
DJNZ 60H,TT1
MOV 60H,#100
DEC 61H
LCALL SHOWTIME
MOV A,61H
JNZ TT1
MOV 61H,5FH
SETB 4FH
TT1:
POP ACC
RETI
;---------------------------------------
;�ⲿ�ж�1 ҡһҡ�������
JISHU:  			       ;���жϽ����ۼӼ��� 
     CLR EX1
	 LCALL  DELAY 	      
	 INC    @R0	
	 LCALL  SEND	   ;����ʵʱ������
	 SETB EX1			  
	 RETI
;---------------------------------------
;������
        ORG  0100H
MAIN:   ;��ʼ��
        //LCALL UP
        MOV  30H,#0   ;���ҡһҡ���������λ�õ����ݳ�ʼ��
		MOV  31H,#0 
		MOV  32H,#0 
		MOV  33H,#0
		MOV  34H,#0
		MOV  R4 ,#5		;�������������Ϊ5
		MOV  R0 ,#30H 
		MOV  SP ,#60H     

        MOV  SCON ,#50H  ;�趨���з�ʽ�� 8 λ�첽�� �������
        MOV  TMOD ,#21H  ;�趨������ 1 Ϊģʽ2 
        //MOV  PCON ,#80H  ;�����ʼӱ�
        MOV  TH1,  #0FDH ;9600
        MOV  TL1,  #0FDH ;
		MOV  TH0,  #0D8H
        MOV  TL0,  #0F0H
        
		SETB EX0
		SETB ET0 ;�򿪶�ʱ��T0�ж�
		SETB PX0
		SETB PX1 ;�����ⲿ�ж�1Ϊ�����ȼ�
        //CLR  PT0 ;���ö�ʱ��T0�ж�Ϊ�����ȼ�
        CLR  IT1 ;�����ⲿ�ж�1 ������ʽΪ�͵�ƽ����
	    CLR  IT0
// SETB TR0 ;�򿪴������벨���ʶ�ʱ��
//SETB EX1 ;���ⲿ�ж�1		 
        SETB EA	 ;���ж������ܿ���λ

MOV 5FH,#00H
MOV 64H,#00H
MOV SP,#70H
LCALL LCMSET
LCALL LCMCLR
MOV A,#80H
LCALL LCMWR0
MOV DPTR,#TAB0
LCALL SHOW1
MOV A,#0C0H
LCALL LCMWR0
MOV DPTR,#TAB1
LCALL SHOW1

MOV 60H,#100
MOV 61H,5FH
CLR 4FH  
      
SETB EA               
SETB ES               
SETB TR1              
MOV A,5FH



;------------------------------------------------------
; ���ö�����������

wait:		 ;p3.2   ��������ʱ  �������￨ס��β���
JNZ key1
MOV A,5FH  
LJMP wait

key1:
jnb p3.1,s1ok 
JMP key1

SJMP $

s1ok:
MOV A,#80H
LCALL LCMWR0
MOV DPTR,#TAB3
LCALL SHOW1
SETB EX1 		  ;���ⲿ�ж��������λ
LCALL SHOWTIME 
SETB TR0
SETB EX1

TT: 
JNB 4FH,TT
CLR TR0
CLR 4FH
INC R0	;ָ����һ����ַ
CLR EX1
DJNZ R4,key1  
	    
;-----------------------------------------------------
key2:	  ;p3.2   �ð������ڵ�����λ��ַ�����ӳ���  
          ;�����������ڴ��ڰ�������ʾ�����ַ�ģ����ţ�����12345�ɣ�
jnb p3.0,SORTSHOW	   ;p3.2   
LJMP key2
	   
LJMP  wait	 
			
;-----------------------------
;��������������ӳ���	(������Ҫ�޸�)
SORTSHOW:
MOV A,#80H
LCALL LCMWR0
MOV DPTR,#TAB4
LCALL SHOW1	  
MOV  IE,#0
MOV  A,#0 
MOV  SP,#60H	
MOV SCON,#0D0H
MOV PCON,#80H
MOV TMOD,#21H
MOV PCON,#80H  
MOV TL1,#0FAH
MOV TH1,#0FAH  	  
SETB TR1
mov R4,#5
mov R0,#30H
SORT:    
        MOV R6,#5  ;���ѭ������
        MOV R7,#5  ;�ڲ�ѭ������
        MOV R0,#30H

LOP0:   MOV R7,#5 ;
        MOV R0,#30H

LOP1:   MOV A,@R0
        INC R0
        MOV B,@R0  ;��ʱABΪǰ��������
        CJNE A,B,COM  ;�Ƚϲ����ת��

COM:              ;�ж��Ƿ񽻻�
	    JNC NEXT  ;���ǰ�������A�еģ�����CY=0������CY=1������ڳ���ת�ƺ��ٴ�����CY�Ϳ��жϳ�A�е�����data����С�ˡ�
  	    XCH A,B   ;��ʼ����
	    DEC R0
	    MOV @R0,A
	    INC R0
	    MOV @R0,B
	    JMP NEXT

NEXT: 
        DJNZ R7,LOP1 ;�ж����ѭ������
        DJNZ R6,LOP0 ;�ж����ѭ�����������ѭ����һ�ˣ�R0���¶�λ����ǰ������ݣ���R6��7
       // LCALL ;�������������
		MOV R0,#30H
	LCALL trs
trs:	 ;��������ӳ���
MOV   A ,@R0
MOV   SBUF ,A
WAI: JBC TI,CONT
     SJMP WAI
CONT:INC R0
     DJNZ R4,trs
     SJMP $
	 RET
	         
;----------------------------------------
;���ڷ��������ӳ���
SEND:	  
		  SETB TR1
          LCALL  DELAY1      
          MOV   A,@R0
          MOV   SBUF, A
     	  CLR TI
		  CLR TR1
		  RET

MOV  SCON ,#50H  ;�趨���з�ʽ�� 8 λ�첽�� �������
MOV  TMOD ,#21H  ;�趨������ 1 Ϊģʽ2 
        //MOV  PCON ,#80H  ;�����ʼӱ�
MOV  TH1,  #0FDH ;9600
MOV  TL1,  #0FDH ;  
;--------------------------------
SHOWTIME:
PUSH ACC
MOV A,#0C9H
LCALL LCMWR0
MOV R1,#61H		 
LCALL HASC
LCALL SHOW2
POP ACC
RET 
SHOWTIME1:
PUSH ACC
MOV A,#0C9H
LCALL LCMWR0

MOV A,#' '                            
LCALL LCMLAY
CLR LCMEN
SETB LCMRS
CLR LCMRW
SETB LCMEN
MOV LCMDATA,A
CLR LCMEN
RET		 
LCALL HASC
LCALL SHOW2
POP ACC
RET 
;---------------------------------------
;10ms��ʱ �����ڰ�������
/*DLY:        MOV  R6, #20            
     D11:    MOV  R7, #248
            DJNZ R7, $
            DJNZ R6, D11
            RET*/
;---------------------------------------

;--------------------------------------------------------------------------------
DELAY1:			       	  ;��ʱ��������ҡһҡ����
            MOV R6,#100
   D11:     MOV R5,#255   
   D22:     DJNZ R5,D22   
            DJNZ R6,D11   
            RET	

;-----------------------------------					
TAB0: DB "Set Time Please",00H
TAB1: DB "Time Is:   s",00H
TAB3: DB "Shake It Quick!",00H
TAB4: DB "Show The Sort!",00H
HASC: 
PUSH ACC
MOV A,@R1       
MOV B,#10
DIV AB
SWAP A
ADDC A,B
MOV B,A 
ANL A,#0FH 
ADD A,#90H
DA A
ADDC A,#40H
DA A
XCH A,B 
SWAP A 
ANL A,#0FH 
ADD A,#90H
DA A
ADDC A,#40H
DA A
MOV 62H,A
MOV 63H,B
INC R1     
POP ACC
RET

LCMLAY:                                   
PUSH ACC
LOOP:
CLR LCMEN
CLR LCMRS
SETB LCMRW
SETB LCMEN
MOV A,LCMDATA
CLR LCMEN
JB ACC.7,LOOP
POP ACC
LCALL DELAY
RET

LCMWR0:                                  
LCALL LCMLAY
CLR LCMEN
CLR LCMRS
CLR LCMRW
SETB LCMEN
MOV LCMDATA,A
CLR LCMEN
RET

LCMWR1:                              
LCALL LCMLAY
CLR LCMEN
SETB LCMRS
CLR LCMRW
SETB LCMEN
MOV LCMDATA,A
CLR LCMEN
RET


SHOW1:             ;���д�뷽ʽ               
PUSH ACC
LOOP3:
CLR A
MOVC A,@A+DPTR
JZ LOOP4
LCALL LCMWR1
INC DPTR
LJMP LOOP3
LOOP4:
POP ACC
RET

SHOW2:               ;����д�뷽ʽ            
PUSH ACC
LOOP1:
CLR A
MOV A,@R1
JZ LOOP2
LCALL LCMWR1
INC R1
LJMP LOOP1
LOOP2:
POP ACC
RET

LCMSET:                            
MOV A,#38H
LCALL LCMWR0
MOV A,#08H
LCALL LCMWR0
MOV A,#01H
LCALL LCMWR0
MOV A,#06H
LCALL LCMWR0
MOV A,#0CH

LCALL LCMWR0
RET

LCMCLR:                             
MOV A,#01H
LCALL LCMWR0
RET

DELAY:
MOV R6,#5           
D1:  MOV R7,#248
DJNZ R7,$
DJNZ R6,D1
RET

END
