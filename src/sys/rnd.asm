%define MAX_SHORT 65535
; =================================
; PROTOTYPE	: void randomize(void)
; INPUT		: n/a
; RETURN	: n/a
; =================================
randomize:
	pusha

	call ticks
	mov [seed], dx ; tickcount as seed

	popa
	ret

; ================================
; PROTOTYPE	: void random(void)
; INPUT		: n/a
; RETURN	: random number in AX
; ================================
random:
	pusha
	
	mov ax, [seed]
	mov dx, 33333
	mul dx				; multiply SEED with AX

	inc ax				; increment seed
	mov [seed], ax		; use AX as new seed
	mov [.rnd], dx		; save random value

	popa

	mov ax, [.rnd]		; return random value in AX
	ret

	.rnd dw 0

seed: dw 13666 ; default seed
