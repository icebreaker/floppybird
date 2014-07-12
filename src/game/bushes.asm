draw_bushes:
	push ax
	push cx

	xor ax, ax

.bush:
	push clouds
	push 40			; w
	push 16			; h
	push 0			; sx
	push 0			; sy
	push 40			; sw
	push 16			; sh
	push ax			; dx
	push 140		; dy
	push 3			; trasnsparent color
	push 58			; tint color
	call blit_fast

	add ax, 40
	cmp ax, 320
	jl .bush

	pop cx
	pop ax
	ret
