main:
	call set_vga_mode
	call randomize

.start:
	call new_highscore
	call center_bird

.intro:
	call animate_bird

	call draw_background
	call draw_ground
	call draw_flats
	call draw_bushes
	call draw_clouds
	call draw_bird
	call draw_highscore

	call vsync
	call flpscr

	mov dx, 2
	call sleep
	
	call kbhit

	test al, al
	jz .intro

	cmp al, 27					; escape
	je .reboot					; reboot :P

	cmp al, 8					; backspace
	je .rndbg					; randomize background

	cmp al, 9					; tab
	je .rndbrd					; randomize bird

	call reset_pipes
	call randomize_pipes

	call reset_bird

	mov ax, 4242
	mov dx, 1
	call beep

.loop:
	call draw

	call update_bird
	jc .end

	call update_pipes
	call collide_pipe
	jc .end

	call vsync
	call flpscr

	mov dx, 1
	call sleep

	jmp .loop
	ret

.end:
	call draw

	call vsync
	call flpscr

	mov ax, 6969
	mov dx, 1
	call beep

	mov dx, 15
	call sleep

	jmp .start
	ret

.rndbg:
	call randomize_backgroundcolor
	jmp .intro
	ret

.rndbrd:
	call randomize_birdcolor
	jmp .intro
	ret

.reboot:
%ifdef COM
	call set_text_mode
	int 20h						; exit this bad-boy :P
%else
	call reboot					; reboot this bad-boy :P
	ret
%endif

draw:
	call draw_background
	call draw_flats
	call draw_bushes
	call draw_clouds
	call draw_pipes
	call draw_bird
	call draw_score
	ret

%include 'game/background.asm'
%include 'game/score.asm'
%include 'game/ground.asm'
%include 'game/flats.asm'
%include 'game/bushes.asm'
%include 'game/clouds.asm'
%include 'game/pipes.asm'
%include 'game/bird.asm'
%include 'game/data.asm'
