; ==================================================
; PROTOTYPE	: void beep(short note, short delay)
; INPUT		: note in AX, delay in DX
; RETURN	: n/a
; ==================================================
beep:
	push bx
	mov bx, ax

	mov al, 182
	out 43h, al

	mov ax, bx
	out 42h, al
	mov al, ah
	out 42h, al

	in al, 61h
	or al, 03h
	out 61h, al

	call sleep

	in al, 61h
	and al, 0FCh
	out 61h, al

	pop bx
	ret
