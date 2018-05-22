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
	CLR _WYSW
	MOV _COUNTER,#0d
	MOV _SEC,#0d
	MOV TL0,#TL0_VAL
	MOV TH0,#TH0_VAL
	ANL TCON,#11001111b
	ANL TMOD,#11110001b
	ORL TMOD,#00000001b
	ORL IE,#10000010b
	ORL TCON,#00010000b
	
	MOV _ID_WSK,#1d

        MOV DPTR,#CSDS16
	MOV A,_ID_WSK
	MOVX @DPTR,A
_LOOP:
	MOV A,_COUNTER
	CJNE A,#20d,_CD
	MOV _COUNTER,#0d
	INC _SEC
	MOV _W1_VAL,(_SEC mod 10)
	MOV _W2_VAL,(_SEC/10 mod 10)
	MOV _W3_VAL,(_SEC/100 mod 10)
	CPL _LED
_W1:
	MOV A,_ID_WSK
	CJNE A,#1d,_W2
	MOV DPTR,#CSDB16
	MOV A,_W1_VAL
	MOVX @DPTR,A
	LJMP _W4
_W2:
	MOV A,_ID_WSK
	CJNE A,#2d,_W3
	MOV DPTR,#CSDB16
	MOV A,_W2_VAL
	MOVX @DPTR,A
	LJMP _W4
_W3:
	MOV A,_ID_WSK
	CJNE A,#4d,_W4
        MOV DPTR,#CSDB16
	MOV A,_W3_VAL
	MOVX @DPTR,A
	LJMP _W4
_W4:
    	MOV A,_ID_WSK
	RL A
	MOV _ID_WSK,A
    	MOV A,_ID_WSK
	CJNE A,#8d,_CD
    	MOV _ID_WSK,#1d
_CD:
	LJMP _LOOP
END