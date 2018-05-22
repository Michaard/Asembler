$ NOMOD51
$ INCLUDE (8051_mgraniczka.MCU)

T0_VAL EQU (65535-46080)
TL0_VAL EQU (T0_VAL mod 256)
TH0_VAL EQU (T0_VAL/256)
CSDB16 EQU 0FF38h
CSDS16 EQU 0FF30h

ORG 0000h
_RESET:
	LJMP _INIT

ORG 0Bh
_INT_T0:
	ORL TL0,#TL0_VAL
	MOV TH0,#TH0_VAL
	INC _COUNTER
	RETI

ORG 0100h
_INIT:
	MOV TL0,#TL0_VAL
	MOV TH0,#TH0_VAL
	ANL TCON,#11001111b
	ANL TMOD,#11110001b
	ORL TMOD,#00000001b
	ORL IE,#10000010b

	MOV _COUNTER,#0d
	MOV _SEC,#0d

	MOV _ID_WSK,#00000001b
	MOV _W1_VAL,#00111111b
	MOV _W2_VAL,#00111111b
	MOV _W3_VAL,#00111111b

	ORL TCON,#00010000b
_LOOP:
	MOV A,_COUNTER
	CJNE A,#20d,_CD
	MOV _COUNTER,#0d
	INC _SEC
	LCALL _SPLIT
	CPL _LED
_CD:
	LCALL _REFRESH
	LJMP _LOOP

_SPLIT:
	MOV A,_SEC
	MOV B,#10d
	DIV AB
	MOV _W1_VAL,B
	MOV B,#10d
	DIV AB
	MOV _W2_VAL,B
	MOV _W3_VAL,A
	RET
	
_REFRESH:
	MOV A,_ID_WSK
	RL A
	MOV _ID_WSK,A
	CJNE A,#00001000b,_W1
	MOV _ID_WSK,#00000001b
	MOV A,_ID_WSK
_W1:
	CJNE A,#00000001b,_W2
	MOV R0,_W1_VAL
	LJMP _W_END
_W2:
	CJNE A,#00000010b,_W3
	MOV R0,_W2_VAL
	LJMP _W_END
_W3:
	CJNE A,#00000100b,_W_END
	MOV R0,_W3_VAL
_W_END:
    SETB _WYSW
	MOV A,_ID_WSK
    MOV DPTR,#CSDS16
	MOVX @DPTR,A

    MOV DPTR,#_WZORCE
    MOV A,R0
    MOVC A,@A+DPTR
	MOV DPTR,#CSDB16
	MOVX @DPTR,A
	CLR _WYSW
	RET
	
_WZORCE:
	DB 00111111b
	DB 00000110b
	DB 01011011b
	DB 01001111b
	DB 01100110b
	DB 01101101b
	DB 01111101b
	DB 00000111b
	DB 01111111b
	DB 01101111b
END