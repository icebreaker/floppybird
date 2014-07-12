draw_clouds:
	push ax
	push cx

	mov ax, 0

.clouds:
	push clouds
	push 40			; w
	push 16			; h
	push 0			; sx
	push 0			; sy
	push 40			; sw
	push 16			; sh
	push ax			; dx
	push 90			; dy
	push 3			; trasnsparent color
	push 0
	call blit_fast

	add ax, 40
	cmp ax, 320
	jl .clouds

	pop cx
	pop ax
	ret
