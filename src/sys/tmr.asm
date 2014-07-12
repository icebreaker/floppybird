; ==================================================
; PROTOTYPE	: void ticks(void)
; INPUT		: n/a
; RETURN	: tick count in DX (resolution =~ 55ms)
; ==================================================
ticks:
	push ax

	mov ax, 0			; get tick count function 
	int 1Ah				; call BIOS interrupt

	mov [.ticks], dx

	pop ax

	mov dx, [.ticks]
	ret

	.ticks dw 0

; ============================================================
; PROTOTYPE	: void sleep(short ms)
; INPUT		: amount of ms to sleep in DX (resolution =~ 55ms)
; RETURN	: n/a
; ============================================================
sleep:
	pusha

	mov ax, 0	; get tick count function
	mov bx, dx	; save ms

	int 1Ah		; call BIOS interrupt
	add bx, dx	; ms + ticks

.wait:
	int 1Ah		; call BIOS interrupt

	cmp dx, bx
	jne .wait	; loop until we waited for ms amount

	popa
	ret
