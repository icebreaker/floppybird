draw_flats:
	push ax
	push cx

	mov ax, 0

.flats:
	push flats
	push 40			; w
	push 50			; h
	push 0			; sx
	push 0			; sy
	push 40			; sw
	push 50			; sh
	push ax			; dx
	push 106		; dy
	push 0			; trasnsparent color
	push 0
	call blit_fast

	add ax, 40
	cmp ax, 320
	jl .flats

	pop cx
	pop ax
	ret
