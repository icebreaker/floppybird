%define VIDMEW 320		  ; video memory width
%define VIDMEH 200		  ; video memory height
%define VIDMES 64000	  ; video memory size
%define VIDMEM IMAGE_SIZE ; back buffer video memory
%define VIDMED 0xA000	  ; system video memory

; ==========================================
; PROTOTYPE	: void set_vga_mode(void)
; INPUT		: n/a
; RETURN	: n/a
; ==========================================
set_vga_mode:
	pusha

	mov ax, 0x13	; 320x200 @ 256 color mode
	int 10h			; call BIOS interrupt

	popa
	ret

; ==========================================
; PROTOTYPE	: void vsync(void)
; INPUT		: n/a
; RETURN	: n/a
; ==========================================
vsync:
	pusha
	mov dx, 0x3DA	; port 0x3DA

.l1:
	in al, dx		; port
	test al, 8		; test bit 4
	jnz .l1			; retrace in progress?

.l2:
	in al, dx		; port
	test al, 8		; test bit 4
	jz .l2			; new retrace?
	
	popa
	ret

; =====================================================
; PROTOTYPE	: void blit( unsigned char *pixels,
;						 short  w, short  h,
;						 short sx, short sy,
;						 short sw, short sh, 
;						 short dx, short dy, 
;						 unsigned char color,
;						 unsigned char tint )
; INPUT		: n/a
; RETURN	: n/a
; =====================================================
blit:
	push bp
	mov bp, sp			; top of the stack
	
	pusha

	cmp word [bp+14], 0 ; sw is 0?
	je .end

	cmp word [bp+12], 0 ; sh is 0?
	je .end

	cmp word [bp+10], VIDMEW ; dx out of bounds on right
	jge .end				 ; full clip

	cmp word [bp+8], VIDMEH ; dy out of bounds on bottom
	jge .end				; full clip

	mov ax, [bp+14]		 ;  sw (width)
	neg ax				 ; -sw

	cmp word [bp+10], ax ; dx out of bounds on left
	jle .end			 ; full clip

	mov bx, [bp+12]		 ; sh (height)
	neg bx				 ; -sh

	cmp word [bp+8], bx  ; dy out of bounds on top
	jle .end			 ; full clip

	neg ax				 ; revert sw (width)
	add ax, [bp+10]		 ; add dx

	neg bx				 ; revert sh (height)
	add bx, [bp+8]		 ; add dy

	cmp ax, VIDMEW		 ; dx partially out of bounds on right
	jge .clipr			 ; try partial right clip

	cmp bx, VIDMEH		 ; dy partially ouf of bounds on bottom
	jge .clipb			 ; try partial bottom clip

	cmp word [bp+10], 0	; dx partially out of bounds on left
	jge .clipt			; quick exit if it's not the case

.clipl: ; clip left
	mov ax, [bp+10]		; use the dx as an offset

	sub [bp+18], ax	; offset sx to the right
	add [bp+14], ax	; offset sw to the left
	mov word [bp+10], 0	; reset dx

	jmp .clipt				; go and blit the visible part

.clipr: ; clip right
	sub ax, VIDMEW			; figure out how much is left to display?
	sub word [bp+14], ax	; and adjust sw (width)

	cmp bx, VIDMEH			; dy partially ouf of bounds on bottom?
	jl .noclip				; quick exit if it's not the case

.clipb: ; clip bottom
	sub bx, VIDMEH			; figure out how much is left to display?
	sub word [bp+12], bx	; and adjust sh (height)

	jmp .noclip				; go and blit the visible part

.clipt: ; clip top
	cmp word [bp+8], 0	; dy partially out of bounds on the top
	jge .noclip			; quick exit if it's not the case

	mov bx, [bp+8]		; use the dy as an offset

	sub [bp+16], bx	; offset sy to the top
	add [bp+12], bx	; offset sh to the bottom

	mov word [bp+8], 0	; reset dy

.noclip:
	mov ax, VIDMEM		; pointer to screen buffer
	mov es, ax			; 

	mov ax, VIDMEW		; screen width
	mov dx, [bp+8]		; dy
	mul dx

	mov di, ax			; dy * screen width
	add di, [bp+10]		; dx

	mov dx, VIDMEW		; screen width
	sub dx, [bp+14]		; sw

	mov [.dxoffset], dx ; destination offset

	mov dx, [bp+22]		; w
	sub dx, [bp+14]		; sw

	mov [.sxoffset], dx ; source offset

	mov ax, [bp+22]		; w
	mov dx, [bp+16]		; sy
	mul dx
	add ax, [bp+18]		; sx + sy * w

	mov si, [bp+24]		; pointer to pixel buffer
	add si, ax			; sx + sy * w

	xor ax, ax			; clear AX
	xor bx, bx			; clear BX
	xor cx, cx			; clear CX
	xor dx, dx			; clear DX

.loop:
	lodsb					; load [DS:SI] into AL

	cmp al, byte [bp+6]		; compare AL to transparent color
	je .transparent			; skip this pixel if transparent

	add al, byte [bp+4]		; add tint color

	stosb					; store AL into [ES:DI]
	jmp .next				; next pixel

.transparent:
	inc di					; increment destination offset

.next:
	inc bx					; increment width
	cmp bx, [bp+14]			; sw
	jl .loop				; end of row?

	xor bx, bx				; reset width
	add di, [.dxoffset]		; increment destination offset
	add si, [.sxoffset]		; increment source offset

	inc cx					; increment height
	cmp cx, [bp+12]			; sh 
	jl .loop				; next row

.end:
	popa
	pop bp
	ret 22					; 11 params * 2 bytes

	.sxoffset: dw 0			; source X offset
	.dxoffset: dw 0			; destination X offset

; =====================================================
; PROTOTYPE	: void blit( unsigned char *pixels,
;						 short  w, short  h,
;						 short sx, short sy,
;						 short sw, short sh, 
;						 short dx, short dy, 
;						 unsigned char color,
;						 unsigned char tint )
; INPUT		: n/a
; RETURN	: n/a
; =====================================================
blit_fast:
	push bp
	mov bp, sp			; top of the stack
	
	pusha

	mov ax, VIDMEM		; pointer to screen buffer
	mov es, ax			; 

	mov ax, VIDMEW		; screen width
	mov dx, [bp+8]		; dy
	mul dx

	mov di, ax			; dy * screen width
	add di, [bp+10]		; dx

	mov dx, VIDMEW		; screen width
	sub dx, [bp+14]		; sw

	mov [.dxoffset], dx ; destination offset

	mov dx, [bp+22]		; w
	sub dx, [bp+14]		; sw

	mov [.sxoffset], dx ; source offset

	mov ax, [bp+22]		; w
	mov dx, [bp+16]		; sy
	mul dx
	add ax, [bp+18]		; sx + sy * w

	mov si, [bp+24]		; pointer to pixel buffer
	add si, ax			; sx + sy * w

	xor ax, ax			; clear AX
	xor bx, bx			; clear BX
	xor cx, cx			; clear CX
	xor dx, dx			; clear DX

.loop:
	lodsb					; load [DS:SI] into AL

	cmp al, byte [bp+6]		; compare AL to transparent color
	je .transparent			; skip this pixel if transparent

	add al, byte [bp+4]		; add tint color

	stosb					; store AL into [ES:DI]
	jmp .next				; next pixel

.transparent:
	inc di					; increment destination offset

.next:
	inc bx					; increment width
	cmp bx, [bp+14]			; sw
	jl .loop				; end of row?

	xor bx, bx				; reset width
	add di, [.dxoffset]		; increment destination offset
	add si, [.sxoffset]		; increment source offset

	inc cx					; increment height
	cmp cx, [bp+12]			; sh 
	jl .loop				; next row

.end:
	popa
	pop bp
	ret 22					; 11 params * 2 bytes

	.sxoffset: dw 0			; source X offset
	.dxoffset: dw 0			; destination X offset

; ==========================================
; PROTOTYPE	: void blit_rect(short x, short y
;							 short w, short h,
;							 unsigned char color)
; INPUT		: n/a
; RETURN	: n/a
; ==========================================
blit_rect:
	push bp
	mov bp, sp			; top of the stack

	pusha

	mov ax, VIDMEM		; pointer to screen buffer
	mov es, ax			; 

	mov ax, VIDMEW		; screen width
	mov dx, [bp+10]		; y
	mul dx

	mov di, ax			; y * screen width
	add di, [bp+12]		; x

	mov dx, VIDMEW		; screen width
	sub dx, [bp+8]		; width

	mov bx, [bp+6]		; height

	xor ah, ah
	mov al, byte [bp+4] ; color

.loop:
	mov cx, [bp+8]		; width
	rep stosb			; draw one row

	add di, dx			; next row

	dec bx				; increase row
	jnz .loop			; continue unless index 0

.end:
	popa
	pop bp
	ret	10				; 5 params * 2 bytes

%if 0
; ==========================================
; PROTOTYPE	: void clrscr(void)
; INPUT		: clear color in AL
; RETURN	: n/a
; ==========================================
clrscr:
	push ax
	push cx

	mov cx, VIDMEM		; pointer to screen buffer
	mov es, cx			;
	xor di, di			; index 0
	
	mov ah, al

	mov cx, VIDMES / 2	; 64000 / 2
	rep stosw			; store AX (2 bytes) in [ES:DI]

	pop cx
	pop ax
	ret
%endif

; ==========================================
; PROTOTYPE	: void flpscr(void)
; INPUT		: n/a
; RETURN	: n/a
; ==========================================
flpscr:
	push ds
	push cx

	mov cx, VIDMED
	mov es, cx
	xor di, di

	mov cx, VIDMEM
	mov ds, cx
	xor si, si

	mov cx, VIDMES / 4 ; 64000 / 4

	rep movsd  ; copy 4 bytes from [DS:SI] into [ES:DI]

	pop cx
	pop ds
	ret

%if 0
; ==========================================
; PROTOTYPE	: void blit_color_palette(void)
; INPUT		: n/a
; RETURN	: n/a
; ==========================================
blit_color_palette:
	pusha

	mov ax, VIDMEM	; pointer to screen buffer
	mov es, ax		; 
	xor di, di		; index 0

	xor ax, ax
	mov al, 40		; start with color 40 to avoid jmp
	xor bx, bx

.loopy1:
	sub al, 40		; substract 40 from the color (see above)

.loopy2:
	xor dx, dx		; initialize row to index 0

.loopx:
	mov cx, 8		; initialize counter with 8
	rep stosb		; draw 8 pixels with the current color and increment DI
	inc al			; increment color

	inc dx			; increment column index
	cmp dx, 40		; start again unless end of row (VIDMEW / 8 = 40)
	jl .loopx		;

	inc ah			; increment height
	cmp ah, 8		; if we didn't draw 8 pixels, loop again
	jl .loopy1		;

	inc bx			; increment row index
	cmp bx, 25		; if we reached rows 25 then we are done
	je .end			;

	xor ah, ah		; reset height
	jmp .loopy2		; start a new row

.end:
	popa
	ret

; ====================================================
; PROTOTYPE	: void intersect(short r1[4], short r2[4])
; INPUT		: two vectors (x, y, w, z)
; RETURN	: carry flag set if intersect
; ====================================================
intersect:
	push bp
	mov bp, sp

	pusha

	mov si, [bp+4] ; r1
	mov di, [bp+6] ; r2

	mov ax, [di+0] ; x
	add ax, [di+4] ; w

	cmp word [si+0], ax ; x1 > x2 + w2
	jg .fail

	mov ax, [di+2] ; y
	add ax, [di+6] ; h

	cmp word [si+2], ax ; y1 > y2 + h2
	jg .fail

	mov ax, [si+0] ; x
	add ax, [si+4] ; w

	cmp ax, word [di+0] ; x1 + w1 < x2
	jl .fail

	mov ax, [si+2] ; y
	add ax, [si+6] ; h

	cmp ax, word [di+2] ; y1 + h1 < y2
	jl .fail

	stc
	popa
	pop bp
	ret 4 ; 2 params * 2 bytes

.fail:
	clc
	popa
	pop bp
	ret 4 ; 2 params * 2 bytes
%endif
