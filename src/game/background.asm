draw_background:
	pusha

	mov cx, VIDMEM		; pointer to screen buffer
	mov es, cx			;
	xor di, di			; index 0
	
	mov al, byte [backgroundcolor]
	mov ah, al

	mov cx, VIDMES / 4	; 64000 / 4
	add cx, VIDMEW * 2	; 2 rows

	rep stosw			; store AX (2 bytes) in [ES:DI]

	popa
	ret

randomize_backgroundcolor:
	call random
	mov word [backgroundcolor], ax
	ret

backgroundcolor: dw 3
