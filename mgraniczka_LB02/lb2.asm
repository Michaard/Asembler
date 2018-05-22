$ NOMOD51      ;1
$ INCLUDE (8051_mgraniczka.MCU)

ORG 0000h
_RESET:
	LJMP _INIT

ORG 0100h
_INIT:
	NOP
_LOOP:
        CLR Port1.5
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
	SETB Port1.5
	NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
	LJMP _LOOP
END