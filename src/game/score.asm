add_score:
	add word [score], 50
	ret

new_highscore:
	push ax

	mov ax, word [score]
	cmp ax, word [highscore]
	jle .reset

	mov word [highscore], ax

.reset:
	mov word [score], 0
	pop ax
	ret

draw_score:
	push word [score]
	call draw_number
	ret

draw_highscore:
	push word [highscore]
	call draw_number
	ret

draw_number:
	push bp
	mov bp, sp

	pusha

	mov ax, [bp+4]
	mov bx, 10
	xor cx, cx

.loop:
	xor dx, dx
	div bx
	inc cx

	push dx
	test ax, ax
	jnz .loop

	mov ax, 8
	mul cx

	mov bx, VIDMEW
	sub bx, ax

	mov ax, bx
	xor dx, dx
	mov bx, 2
	div bx

	mov bx, ax

.blit:
	pop dx		; pop out the next digit (in reverse order)
	mov ax, 8
	mul dx

	push font
	push 80		; pw
	push 8		; ph
	push ax		; sx
	push 0		; sy
	push 8		; sw
	push 8		; sh
	push bx		; dx
	push 10		; dy
	push 0			; transparent color
	push 0			; tint color
	call blit_fast

	add bx, 8	; next digit (8 pixels)
	dec cx
	jnz .blit

	popa
	pop bp
	ret 2		; 1 params * 2 bytes

score:		dw 0	; current score
highscore:	dw 0	; high score
