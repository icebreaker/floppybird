reset_bird:
	mov word [bird_pos+0], 60
	mov word [bird_pos+2], 60
	ret

center_bird:
	mov word [bird_pos+0], 144
	mov word [bird_pos+2], 60
	ret

update_bird:
	mov ax, word [bird_pos + 2] ; sy
	cmp ax, 0				; top
	jle .collide				; reached sky?

	add ax, word [bird_pos + 6] ; sh
	cmp ax, 156				; bottom (ground)
	jg .collide				; reached ground?

	call kbhit
	add ax, word [bird_pos + 8]	; add stage_of_jump to return value

	test al, al			; if no key has been pressed and
	jz .fall			; stage_of_jump is 0, then just fall

	call animate_bird		; animate bird

.move:
	add word [bird_pos + 8], 1
	sub word [bird_pos + 2], 6	; move 6 pixels up on the Y axis

	mov ax, word [bird_pos + 8]
	cmp ax, 3
	jl .keep_jumping

	mov word [bird_pos + 8], 0

.keep_jumping:
	clc
	ret

.fall:
	add word [bird_pos + 2], 2	; move 2 pixels down on the Y axis
	clc
	ret

.collide:
	stc
	ret

animate_bird:
	add word [bird_frm], 16		; advance fly animation by one frame
	cmp word [bird_frm], 32		; did we reach the last frame yet?
	jle .end			; if not, then we can jump right away
	
	mov word [bird_frm], 0		; reset animation to the first frame
.end:
	ret

draw_bird:
	push bird
	push 48				; pw
	push 12				; ph
	push word [bird_frm]		; sx
	push 0				; sy
	push word [bird_pos + 4]	; sw
	push word [bird_pos + 6]	; sh
	push word [bird_pos + 0]	; dx
	push word [bird_pos + 2]	; dy
	push 0				; transparent color
	push word [bird_tint]		; tint
	call blit_fast
	ret

randomize_birdcolor:
	call random
	add ax, ax
	mov word [bird_tint], ax
	ret

bird_pos: dw 60, 60, 16, 12, 0 ; x, y, w, h, stage_of_jump
bird_frm: dw 0				; current animation frame (X in pixels)
bird_tint: dw 0				; crazy tint :P
