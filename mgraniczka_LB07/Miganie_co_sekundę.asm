; Licznik T0 ma pojemność 65535, co zapełnia się w około 71ms.
; By zapełnił się w 1s musiałby mieć pojemność 921600.
; Można jednak w nim zapisać wartość taką, by przepełniał się co 50ms.
; 50ms zajmuje mu wykonanie 46080 cykli.
; Aby więc przepełniał się co 50ms należy ustawić mu wartość równą 65535-46080=19455.
; Wtedy zaczynając z wartością 19455, przepełnienie zajmie mu dokłądnie 46080 cykli, czyli 50ms.
; 1s=1000ms=50ms*20
; Musimy więc zmieniać sygnał diody co 20 przepełnień licznika przepełniajacego się co 50ms.
; 19455=75 255(h)=01001011 11111111b
; Do TH0 musimy więc zapisać wartość 75 == 01001011b == 19455 mod 256
; Do TL0 -> 255 == 11111111b == 19455/256

; Stąd w kodzie z zajęć:
;T0_VAL EQU (65535-46080)
;TL0_VAL EQU (T0_VAL mod 256)
;TH0_VAL EQU (T0_VAL/256)

;Poniżej kod z zajęć na ocenę 3 (dioda TEST miga co sekundę)

$ NOMOD51
$ INCLUDE (8051_mgraniczka.MCU)

T0_VAL EQU (65535-46080)
TL0_VAL EQU (T0_VAL mod 256)
TH0_VAL EQU (T0_VAL/256)

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
	MOV _COUNTER,#0d
	MOV _SEC,#0d
	MOV TL0,#TL0_VAL
	MOV TH0,#TH0_VAL
	ANL TCON,#11001111b
	ANL TMOD,#11110001b
	ORL TMOD,#00000001b
	ORL IE,#10000010b
	ORL TCON,#00010000b
_LOOP:
	MOV A,_COUNTER
	CJNE A,#20d,_CD
	MOV _COUNTER,#0d
	INC _SEC
	CPL _LED
_CD:
	LJMP _LOOP
END