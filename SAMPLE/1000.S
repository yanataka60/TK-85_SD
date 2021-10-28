; LEDを右回りに点滅
        ORG     8000H   

LED1		EQU		83F8H
LED2		EQU		83F9H
LED3		EQU		83FAH
LED4		EQU		83FBH
LED5		EQU		83FCH
LED6		EQU		83FDH
LED7		EQU		83FEH
LED8		EQU		83FFH
KEYSCAN		EQU		0223H

WAIT1   EQU     30H
WAIT2   EQU     20H

START:	CALL	TIMER
	LD      HL,LED1
        LD      (HL),01H
	CALL	TIMER   
	LD      HL,LED2
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED3
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED4
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED5
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED6
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED7
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED8
        LD      (HL),01H
        CALL    TIMER   
	LD      HL,LED8
        LD      (HL),02H
        CALL    TIMER   
	LD      HL,LED8
        LD      (HL),04H
        CALL    TIMER   
	LD      HL,LED8
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED7
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED6
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED5
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED4
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED3
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED2
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED1
        LD      (HL),08H
        CALL    TIMER   
	LD      HL,LED1
        LD      (HL),10H
        CALL    TIMER   
	LD      HL,LED1
        LD      (HL),20H
        CALL    TIMER   
	JP	START

TIMER:	LD      A,0AH
LOP1:   LD      D,WAIT1
LOP2:   LD      E,WAIT2
LOP3:   DEC     E       
        JP      NZ,LOP3    
        DEC     D       
        JP      NZ,LOP2    
        DEC     A       
        JP      NZ,LOP1    
        LD      HL,LED1
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        INC     HL      
        LD      (HL),00H
        RET
END