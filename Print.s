; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

	
    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
; R0=0,    then output "0"
; R0=3,    then output "3"
; R0=89,   then output "89"
; R0=123,  then output "123"
; R0=9999, then output "9999"
; R0=4294967295, then output "4294967295"
LCD_OutDec
	PUSH{R4-R8,R11, LR}
	SUB SP, #8;
	MOV R11, SP;
	STR R0, [R11, #4];
	MOV R4, #0;
	STR R4, [R11, #0];
Branchdec
	MOV R5, #10;
	LDR R4, [R11, #4];
	CMP R4, #0;
	BEQ nextstep;
	UDIV R6, R4, R5;
	MUL R7, R6, R5;
	SUB R8, R4, R7;
	PUSH{R8};
	STR R6, [R11, #4];
	LDR R6, [R11, #0];
	ADD R6, #1;
	STR R6, [R11, #0];
	B Branchdec
	
nextstep
	LDR R4, [R11, #0];
	CMP R4, #0;
	BNE next
	MOV R0, #0x30;
	BL ST7735_OutChar
	B finish
next

	LDR R4, [R11, #0];
	CMP R4, #0;
	BEQ finish
	POP{R0}
	ADD R0, #0x30;
	BL ST7735_OutChar
	SUB R4, #1;
	STR R4, [R11, #0];
	B next
	

finish
	ADD SP, #8
	POP{R4-R8,R11, LR}
      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000"
;       R0=3,    then output "0.003"
;       R0=89,   then output "0.089"
;       R0=123,  then output "0.123"
;       R0=9999, then output "9.999"
;       R0>9999, then output "*.***"
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
	PUSH{R4-R8,R11, LR}
	SUB SP, #8;	
	LDR R4, =9999;
	CMP R0, R4;
	BHI asterix;
	

	MOV R11, SP;
	STR R0, [R11, #4];
	MOV R4, #0;
	STR R4, [R11, #0];
	
	
Branchdec2
	MOV R5, #10;
	LDR R4, [R11, #0];
	CMP R4, #4;
	BEQ next2;
	LDR R4, [R11, #4];
	UDIV R6, R4, R5;
	MUL R7, R6, R5;
	SUB R8, R4, R7;
	PUSH{R8};
	STR R6, [R11, #4];
	LDR R6, [R11, #0];
	ADD R6, #1;
	STR R6, [R11, #0];
	B Branchdec2
	
next2	
	LDR R4, [R11, #0];
	CMP R4, #0;
	BEQ finish2
	CMP R4, #3;
	BEQ adddot;
dotdone	
	POP{R0}
	ADD R0, #0x30;
	BL ST7735_OutChar
	SUB R4, #1;
	STR R4, [R11, #0];
	B next2
adddot
	MOV R0, #46;
	BL ST7735_OutChar;
	B dotdone
	
asterix
	MOV R0, #42;
	BL ST7735_OutChar;
	MOV R0, #46;
	BL ST7735_OutChar;
	MOV R0, #42;
	BL ST7735_OutChar;	
	MOV R0, #42;
	BL ST7735_OutChar;
	MOV R0, #42;
	BL ST7735_OutChar;
	
finish2
	ADD SP,#8;
	POP{R4-R8,R11, LR}

     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
