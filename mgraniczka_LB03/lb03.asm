$ NOMOD51
$ INCLUDE (8051_mgraniczka.MCU)

ORG 0000h
_RESET:
	LJMP _INIT

ORG 0100h
_INIT:
;	MOV A,#255
	MOV A,#254
	CLR flaga_buzz
;1
;_IF1:
;	JB P,_FI
;	CLR LED
;_FI:

;2
;_IF2:
;	JB P,_ELSE
;	CLR LED
;	LJMP _FI
;_ELSE:
;	CLR BUZZ
;_FI:

;3
;_IF3:
;	JB P,_ELIF
;	CLR LED
;	LJMP _FI
;_ELIF:
;	JNB flaga_buzz,_FI
;	CLR BUZZ
;_FI:

;4
_IF4:
	JB P,_ELIF
	CLR LED
	LJMP _FI
_ELIF:
	JNB flaga_buzz,_DEFAULT
	CLR BUZZ
	LJMP _FI
_DEFAULT:
_FI:

_LOOP:
	NOP
	LJMP _LOOP
END