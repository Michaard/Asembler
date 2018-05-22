; Licznik T0 ma pojemność 65535, co zapełnia się w około 71ms.
; By zapełnił się w 1s musiałby mieć pojemność 921600.
; Można jednak w nim zapisać wartość taką, by przepełniał się co 50ms.
; 50ms zajmuje mu wykonanie 46080 cykli.
; Aby więc przepełniał się co 50ms należy ustawić mu wartość równą 65535-46080=19455.
; Wtedy zaczynając z wartością 19455, przepełnienie zajmie mu dokłądnie 46080 cykli, czyli 50ms.
; 1s=50ms*20
; Musimy więc zmieniać sygnał diody co 20 przepełnień licznika przepełniajacego się co 50ms.
; 19455=75 255(h)=01001011 11111111b
; Do TH0 musimy więc zapisać wartość 75=01001011b
; Do TL0 -> 255=11111111b

ORG 0000h
_RESET:
	LJMP _INIT

ORG 0Bh
_INT_T0:
	INC A	;zwiększamy A o 1
_IF:
	CJNE A,#20,_ELSE	;Jeżeli A!=20, skacz do _ELSE; Jeżeli A=20, wykonaj instrukcje poniżej
	CPL 097h	;zmieniamy dotychczasowy sygnał docierający do diody
	MOV A,#0	;zerujemy A, bo móc znowu zliczać do 20
	MOV TL0,#11111111b	;ponownie ustawiamy TL0 na odpowiednią wartość
	MOV TH0,#01001011b	;ponownie ustawiamy TH0 na odpowiednią wartość
	RETI	;powrót z procedury przerwaniowej
_ELSE:
	RETI	;powrót z proceduty przerwaniowej

ORG 0100h
_INIT:
	MOV A,#0	;inicjujemy A na wartość 0
	MOV TL0,#11111111b	;ustawiamy odpowiednią wartość dla TL0
	MOV TH0,#01001011b	;ustawiamy odpowiednią wartość dla TH0
	ANL TCON,#11001111b ;ustawiamy TF0 i TR0 na 0, bo licznik na pewno jeszcze niczego nie zliczał
	ANL TMOD,#11110001b ;ustawiamy GATE0,C/T0 i T0M1 na 0, by licznik działał z odpowiednich sygnałów i w odpowiednim trybie, reszta zostaje nie zmieniona
	ORL TMOD,#00000001b ;ustawiamy T0M0 na 1, dzięki czemu teraz T0M1 i T0M0 mają odpowiednio wartość 01, i w związku z czym licznik działą w trybie 01 - czyli 16 bitowym
	ORL IE,#10000010b ;ustawiamy EA i EX1 na 1, by włączyć możliwość przerwać (rejestr IE - Interrupt Enable)
	ORL TCON,#00010000b ;ustawiamy TR0 na 1, by licznik zaczął działać
_LOOP:
	LJMP _LOOP	;nieskończona pętla
END