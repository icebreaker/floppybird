%define PIPE_1 pipes + 0
%define PIPE_2 pipes + 8
%define PIPE_3 pipes + 16

update_pipes:
	sub word [PIPE_1], 2
	sub word [PIPE_2], 2
	sub word [PIPE_3], 2

.n1:
	cmp word [PIPE_1], -36
	jg .n2

	call random_pipe_position
	add ax, word [PIPE_3]
	mov word [PIPE_1], ax

	call randomize_pipe_1
	ret

.n2:
	cmp word [PIPE_2], -36
	jg .n3

	call random_pipe_position
	add ax, word [PIPE_1]
	mov word [PIPE_2], ax

	call randomize_pipe_2
	ret

.n3:
	cmp word [PIPE_3], -36
	jg .end

	call random_pipe_position
	add ax, word [PIPE_2]
	mov word [PIPE_3], ax

	call randomize_pipe_3
	ret

.end:
	ret

collide_pipe:
	push si

	mov si, pipes
	add si, [pipe_a]

	cmp word [si], 74	; front edge of the pipe
	jg .end

	cmp word [si], 48	; back edge of the pipe
	jl .score

	mov ax, word [bird_pos + 2]
	cmp ax, word [si + 2]
	jl .hit

	add ax, word [bird_pos + 6]
	cmp ax, word [si + 4]
	jg .hit

.end:
	pop si
	clc
	ret

.hit:
	pop si
	stc
	ret

.score:
	call add_score
	
	cmp word [pipe_a], 16
	je .wrap

	add word [pipe_a], 8
	pop si
	clc
	ret

.wrap:
	mov word [pipe_a], 0
	pop si
	clc
	ret

draw_pipes:
	push word [PIPE_1 + 0]
	push 0
	push word [PIPE_1 + 2]
	call draw_pipe

	push word [PIPE_1 + 0]
	push word [PIPE_1 + 4]
	push word [PIPE_1 + 6]
	call draw_pipe

	push word [PIPE_2 + 0]
	push 0
	push word [PIPE_2 + 2]
	call draw_pipe

	push word [PIPE_2 + 0]
	push word [PIPE_2 + 4]
	push word [PIPE_2 + 6]
	call draw_pipe

	push word [PIPE_3 + 0]
	push 0
	push word [PIPE_3 + 2]
	call draw_pipe

	push word [PIPE_3 + 0]
	push word [PIPE_3 + 4]
	push word [PIPE_3 + 6]
	call draw_pipe

	ret

draw_pipe:
	push bp
	mov bp, sp
	
	pusha

	mov ax, word [bp+4]
	mov bx, 2
	xor dx, dx
	div bx

	mov cx, ax
	mov ax, word [bp+6]
	xor dx, dx

.body:
	push pipe
	push 16			; w
	push 2			; h
	push 0			; sx
	push 0			; sy
	push 16			; sw
	push 2			; sh
	push word [bp+8]; dx
	push ax			; dy
	push 0			; trasnsparent color
	push 0
	call blit

	add ax, 2
	dec cx
	jnz .body

	mov ax, [bp+6]
	cmp ax, 0
	jne .top

	mov ax, [bp+4]
	sub ax, 4

.top:
	mov dx, [bp+8]
	sub dx, 2

	push pipe_top
	push 18			; w
	push 4			; h
	
	push 0			; sx
	push 0			; sy
	
	push 18			; sw
	push 4			; sh

	push dx			; dx
	push ax			; dy
	
	push 0			; trasnsparent color
	push 0
	call blit

	popa
	pop bp
	ret 6			; 3 param * 2 bytes

randomize_pipes:
	push si
	mov si, pipes

.loop:
	push si
	call randomize_pipe

	add si, 8
	cmp si, pipes + 24
	jl .loop

	pop si
	ret

randomize_pipe_1:
	push PIPE_1
	call randomize_pipe
	ret

randomize_pipe_2:
	push PIPE_2
	call randomize_pipe
	ret

randomize_pipe_3:
	push PIPE_3
	call randomize_pipe
	ret

randomize_pipe_height:
	call random

	cmp ax, 116			; 120 - 6 = 114 will be a max value
	jge randomize_pipe_height

	cmp ax, 40			; 6 (pipe) + 36 (window) = 42 will be a min value
	jle randomize_pipe_height

	mov cx, ax			; test if a random number is even (divides by 2)
	mov bx, 2
	xor dx, dx
	div bx

	cmp dx, 0
	jne randomize_pipe_height

	mov ax, cx
	ret

randomize_pipe:
	push bp
	mov bp, sp

	push si
	pusha

	call randomize_pipe_height	; UPPER PIPE

	mov bx, ax			; range of values: 6 (small) ... 114 (big)

	mov si, [bp + 4]

	mov word [si + 2], bx

					; BOTTOM PIPE (depends on the upper pipe)
	mov bx, 120
	sub bx, ax			; range of values: 6 (small) ... 114 (big)

	mov word [si + 6], bx

	mov ax, 156			; 156 is a ground
	sub ax, bx			; root of a bottom pipe
	mov word [si + 4], ax

	popa
	pop si
	pop bp
	ret 2				; 1 params * 2 bytes

random_pipe_position:
	call random
	
	cmp ax, 100
	jle random_pipe_position

	cmp ax, 220
	jge random_pipe_position
	
	ret

reset_pipes:
	mov word [PIPE_1], 160
	mov word [PIPE_2], 280
	mov word [PIPE_3], 400
	mov word [pipe_a], 0
	ret

pipes : dw 120, 32, 64, 32, 260, 78, 78, 78, 400, 78, 78, 78 ; offset = 4
pipe_a: dw 0 ; active pipe offset [0, 8, 16]
