;	---------------------------------------------------------------------------------------
;	program ini.asm - jest programem wzorcowym przeznaczonym dla studentów informatyki UMCS
;	i rozpoczynaj¹cych pracê z zestawem dydaktycznym DSM51.
;	autor: Jerzy Kotlinski, Lublin, 2005r
;	---------------------------------------------------------------------------------------

$nomod51							; usuñ symbolikê SFR (8051)
$include	(8051.MCU)					; do³¹cz symbolikê SFR kontrolera 8051
$nolist							; wy³¹cz listowanie

;			przyporzadkowanie bitow portow p1 i p3 urzadzeniom i/o w dsm_51
;			---------------------------------------------------------------

;			p1.0	-	(out)	txd (2)
;			p1.1	-	(out)	tryb sterownika int	
;			p1.2	-	(out)	transoptor o1
;			p1.3	-	(out)	transoptor o2
;			p1.4	-	(out)	watchdog
;			p1.5	-	(out)	buzzer	
;			p1.6	-	(out)	uaktywnienie wyswietlacza
;			p1.7	-	(out)	dioda led_test
;			p3.0	-	(in)	rxd
;			p3.1	-	(out)	txd
;			p3.2	-	(in)	int0
;			p3.3	-	(in)	int1
;			p3.4	-	(in)	transoptor o3
;			p3.5	-	(in)	klawiatura multipleksowana (normalnie stan '0')
;			p3.6	-	(out)	wr
;			p3.7	-	(out)	rd


;			stale programowe i adresy w polu wewnetrznym ram
;			------------------------------------------------
t0_dat		equ	65535-921			; dana dla licznika T0 (przerwanie co 1ms)
cskb1			equ	22h				; adres klawiatury statycznej (grupa 8..enter)

timer_buf		equ	17				; bufor licznika programowego
rec_bufor		equ	18				; bufor chwilowy na odebrany bajt
send_bufor		equ	19				; bufor chwilowy dla bajtu do nadawania

stos			equ	100				; adres poczatku stosu


;			mapa bitowa pamieci ram (adr. bajtu: 32)
;			----------------------------------------
rec_flag		bit	00h				; flaga - w buforze odbiornika portu rs232
								; jest bajt gotowy do pobrania
send_flag		bit	01h				; flaga - w buforze pomocniczym jest bajt 
								; gotowy do wyslania przez port rs232
t0_flag		bit	02h				; flaga - licznik T0 wygenerowal przerwanie
timer_flag		bit	03h				; flaga - licznik programowy zostal zregenerowany
								; (w przykladzie: uplynal czas 100ms) 

$list								; w³¹cz listowanie

;	###########################################################################################
;	##################    s  t  a  r  t     p  r  o  g  r  a  m  u    #########################
;	###########################################################################################

			org	0
inicjacja:
			ljmp	start				; skocz do poczatku programu !!!

;		------------------------------------------------------
;		  p r o c e d u r y   o b s l u g i   p r z e r w a n
;		------------------------------------------------------
			org	0bh				; INT od licznika T0 ukladu czasowo-licznikowego
t0_int:
			orl	tl0,#t0_dat mod 256	; ustaw licznik T0
			mov	th0,#t0_dat	/ 256
			setb	t0_flag			; ustaw flage zdarzenia (co 100ms)
			reti

			org	23h				; INT od portu szeregowego
sio_int:
			jbc	ti,sint_20			; skocz, gdy pusty bufor nadajnika
			clr ri		     		; zeruj flage odbioru bajtu
			setb	rec_flag			; ustaw flage odebrania bajtu
			reti
sint_20:							; dzialania zwiazane z faktem wyslania bajtu
								; (w niniejszym przykladzie opcja bez obslugi) 
			reti


;	###########################################################################################
;	########    p  r  z  y  g  o  t  o  w  a  n  i  e      w  s  t  e  p  n  e    #############
;	###########################################################################################

			org	0100h
start:
			mov	a,#255
			mov	p1,a				; ustaw port P1
			mov	p3,a				; ustaw port P3
			mov	sp,#stos			; ustal adres poczatku stosu


;		ustawienie rejestrow kontrolnych
;		--------------------------------
			mov	pcon,#80h			; zegar dla sio: taktowanie T1 (19200 bitow/s)
			mov	scon,#01010000b		; ustawienie parametrow transmisji:
								; tryb 1: 8 znakow, szybkosc: T1
			mov	tmod,#00100001b		; ustalenie trybu pracy licznika: T1 w tryb 2 
			mov	tcon,#00000000b		; T0 w tryb 1; bez przerwan INT_0 i INT_1
			mov	tl0,#t0_dat mod 256	; ustawienie mlodszego i starszego bajtu
			mov	th0,#t0_dat / 256		; licznika T0
			mov	tl1,#0fdh			; ustawienie mlodszego i starszego bajtu
			mov	th1,#0fdh			; licznika T1 (dla 19200 bitow/s)

;		ustawienie flag nadawania/odbioru przez rs232
;		---------------------------------------------
			clr	send_flag			; kasuj flage gotowosci nadawania
			clr	rec_flag			; kasuj flage gotowosci odbioru

;		inne ustawienia
;		---------------
			clr	t0_flag			; kasuj flage przerwania t0_int
			clr	timer_flag			; kasuj flage timera
			mov	timer_buf,#100		; laduj licznik timeout (100ms)

;		ustawienie bitow systemu przerwan
;		---------------------------------
			setb	ps				; ustaw prior. int od serial najwyzej
			setb	et0				; wlacz int dla licznika T0
			setb	es				; wlacz int dla portu szeregowego
			setb	ea				; uaktywnij przerwania

;		uruchomienie ukladow czasowo-licznikowych T0 i T1
;		-------------------------------------------------
			setb	tr0				; uruchom licznik T0
			setb	tr1				; uruchom licznik T1


;	###########################################################################################
;	####################    p  e  t  l  a      g  l  o  w  n  a     ###########################
;	###########################################################################################

petla:
;	testowanie:	czy w buforze odbiornika portu rs232 jest odebrany bajt
;	-------------------------------------------------------------------
			jnb	rec_flag,ptl_20		; dalej gdy brak odbioru rs232
			clr	rec_flag			; zeruj flage odebrania bajtu
			lcall	rec_service			; wykonaj obsluge odbioru bajtu

ptl_20:
;	testowanie:	czy w buforze posrednim jest bajt do wyslania przez port rs232
;	-------------------------------------------------------------------------- 
			jnb	send_flag,ptl_30		; dalej, gdy brak danej do wyslania
			clr	send_flag			; zeruj flage nadawania bajtu
			lcall	send_service		; wykonaj obsluge nadawania

ptl_30:
;	testowanie:	czy licznik T0 zakonczyl odliczanie ustalonego odcinka czasu (1ms)
;	------------------------------------------------------------------------------ 
			jnb	t0_flag,ptl_40		; dalej gdy brak przerwania od licznika T0
			clr	t0_flag			; zeruj flage
			lcall	t0_service			; obsluz przerwanie od t0

ptl_40:
;	testowanie:	czy nacisnieto jakis klawisz klawiatury (test co 100ms)
;	-------------------------------------------------------------------
			jnb	timer_flag,ptl_50		; dalej gdy nie uplynelo jeszcze 100ms
			clr	timer_flag			; zeruj flage
			lcall	key_service			; obsluz klawiature

ptl_50:
			ljmp	petla


;	###########################################################################################
;	######################    p  o  d  p  r  o  g  r  a  m  y     #############################
;	###########################################################################################



;		-------------------------------------------------------------------------------------
;		obsluga przerwania od T0 (co 1 ms)
;		-------------------------------------------------------------------------------------
;		opis:	z odstepem czasu wskazywanym przez stala t0_dat (1 ms), licznik T0 generuje 
;			przerwanie - w czasie obslugi tego przerwania odswiezany jest stan rejestrow 
;			licznika (patrz: t0_int). Podany nizej program ustawia flage 'timer_flag' co 
;			100 ms -> pozwala to na obsluge zdarzenia w petli, ktore powinno pojawic sie 
;			co 100ms
;		-------------------------------------------------------------------------------------
t0_service:
			dec	timer_buf			; zmniejsz stan timera programowego
			mov	a,timer_buf 		; laduj stan timera programowego
			jz	tose_10
			ret
tose_10:
			setb	timer_flag			; ustaw flage gdy uplynelo 100ms
			mov	timer_buf,#100		; regeneruj stan licznika (100ms)
			ret



;		-------------------------------------------------------------------------------------
;		obsluga przerwania od odbiornika portu rs232
;		-------------------------------------------------------------------------------------
;		opis:	po odebraniu i skompletowaniu bajtu w buforze odbiornika portu rs232 jest
;			generowane przerwnie, w wyniku ktorego jest ustawiana flaga 'rec_flag'
;			(patrz: sio_int). Podany nizej program pobiera bajt, znienia jego kod 
;			i przekazuje do bufora nadawania
;		-------------------------------------------------------------------------------------
rec_service:
			mov	a,sbuf			; pobierz bajt z portu rs232
			add	a,#256 - 32			; zamien kod bajtu (np. litera 'a' na litere 'A')
			mov	send_bufor,a		; i zapamietaj
			setb	send_flag			; ustaw flage gotowosci do nadawania przez rs232
			ret



;		-------------------------------------------------------------------------------------
;		obsluga zdarzenia zwiazanego z istnieniem bajtu gotowego do wyslania przez port rs232
;		-------------------------------------------------------------------------------------
;		opis:	po umieszczeniu bajtu w buforze 'send_bufor', fakt ten jest sygnalizowany
;			przez ustawienie flagi 'send_flag'. Podany nizej program pobiera bajt z bufora 
;			'send_bufor' i przemieszcza go do bufora nadajnika portu rs232 co powoduje 
;			automatyczne rozpoczecie jego nadawania
;		-------------------------------------------------------------------------------------
send_service:
			mov	send_bufor,a		; pobierz bajt do wyslania
			mov	sbuf,a			; i rozpocznij jego nadawanie
			ret



;		-------------------------------------------------------------------------------------
;		obsluga klawiatury
;		-------------------------------------------------------------------------------------
;		opis:	co 100ms powinien byc sprawdzony stan klawiatury. Podany nizej program testuje
;			stan klawisza ENTER - po jego nacisnieciu jest wl¹czany 'buzzer' a po 
;			zwolnieniu nacisku 'buzzer' jest wylaczany
;		-------------------------------------------------------------------------------------
key_service:
			mov	dpl,#cskb1			; ustal adres klawiatury
			mov	dph,#0ffh
			movx	a,@dptr			; odczytaj stan klawiatury
			anl	a,#10000000b		; pozostaw bit 7 (stan k25)
			jz	kese_10			; dalej gdy klawisz nacisniety
;			setb	p1.5				; ustaw bit p1.5 (wylacz buzzer)
			orl	p1,#00100000b		; ustaw bit p1.5 (wylacz buzzer)
			ret
kese_10:
;			clr	p1.5				; zeruj bit p1.5 (wlacz buzzer)
			anl	p1,#11011111b		; zeruj bit p1.5 (wlacz buzzer)
			ret

end