;ORG 0000h   ;zaczynamy od adresu 0-rowego
;_RESET:     ;etykieta
;	NOP ;no operation
;END ;kod minimalny
ORG 0000h
_RESET:
	LJMP _INIT

ORG 0100h
_INIT:
	;CLR 097h ;dioda TEST
	CLR 095h ;brzêczyk
_LOOP:
	NOP
	LJMP _LOOP    ;nieskoñczona pêtla
END