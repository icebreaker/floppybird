draw_ground:
	push dx
	mov dx, 0

	push 0			; x
	push 156		; y
	push 320		; w
	push 2			; h
	push 230		; grass color
	call blit_rect

	push 0			; x
	push 158		; y
	push 320		; w
	push 2			; h
	push 70			; grass color
	call blit_rect

.grass:
	push grass
	push 8			; w
	push 4			; h
	push 0			; sx
	push 0			; sy
	push 8			; sw
	push 4			; sh
	push dx			; dx
	push 160		; dy
	push 0			; trasnsparent color
	push 0
	call blit_fast

	add dx, 8
	cmp dx, 320
	jl .grass

	push 0			; x
	push 164		; y
	push 320		; w
	push 2			; h
	push 70			; grass color
	call blit_rect

	push 0			; x
	push 166		; y
	push 320		; w
	push 2			; h
	push 67			; ground color
	call blit_rect

	push 0			; x
	push 168		; y
	push 320		; w
	push 32			; h
	push 66			; ground color
	call blit_rect

	pop dx
	ret
