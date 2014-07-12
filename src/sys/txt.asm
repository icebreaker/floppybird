; =====================================
; PROTOTYPE	: void set_text_mode(void)
; INPUT		: n/a
; RETURN	: n/a
; =====================================
set_text_mode:
	pusha

	mov ax, 0x3		; 80x25 @ 16 color mode
	int 10h			; call BIOS interrupt

	popa
	ret	

; ==============================
; PROTOTYPE	: void reboot(void)
; INPUT		: n/a
; RETURN	: n/a
; ==============================
reboot:
	mov ax, 0
	int 19h
	ret

; ==================================
; PROTOTYPE	: short getch(void)
; INPUT		: n/a
; RETURN	: returns key hit in AX
; ==================================
getch:
	pusha

	mov ax, 0		; get key hit function (will block)
	int 16h			; call BIOS interrupt

	mov [.key], ax

	popa
	
	mov ax, [.key]
	ret	

	.key: dw 0

; ==================================
; PROTOTYPE	: short kbhit(void)
; INPUT		: n/a
; RETURN	: returns key hit in AX
; ==================================
kbhit:
	pusha

	mov al, 0			; check for any keys hit
	mov ah, 1			; but do not block (async)
	int 16h				; call BIOS interrupt
	jz .end				; if no keys hit jump to end

	mov ax, 0			; get key hit function
	int 16h				; call BIOS interrupt

	mov [.key], ax

	popa
	
	mov ax, [.key]
	ret		

.end:
	popa

	mov ax, 0			; set AX to 0 if no keys hit
	ret

	.key: dw 0

; ===========================================
; PROTOTYPE	: void puts(char *s)
; INPUT		: offset/pointer to string in SI
; RETURN	: n/a
; ===========================================
puts:
	pusha

.loop:
	lodsb		; move byte [DS:SI] into AL

	cmp al, 0	; 0 == end of string ?
	je .end

	mov ah, 0Eh ; display character function
	int 10h		; call BIOS interrupt

	jmp .loop	; next character

.end:
	popa
	ret

; =======================================
; PROTOTYPE	: void putc(char ch)
; INPUT		: character to display in AL
; RETURN	: n/a
; =======================================
putc:
	pusha

	mov ah, 0Eh ; display character function
	int 10h		; call BIOS interrupt

	popa
	ret
