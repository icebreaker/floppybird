%define SECTORS 16							; keep it under 18
%define IMAGE_SIZE ((SECTORS + 1) * 512)	; SECTORS + 1 (~= 18) * 512 bytes
%define STACK_SIZE 256						; 4096 bytes in paragraphs

bits 16										; 16 bit mode
;org 0x7C00									; BIOS boot sector entry point

start:
	cli ; disable interrupts
	
	;
	; Notes:
	;  1 paragraph	= 16 bytes
	; 32 paragraphs = 512 bytes
	;
	; Skip past our SECTORS
	; Skip past our reserved video memory buffer (for double buffering)
	; Skip past allocated STACK_SIZE
	;
	mov ax, (((SECTORS + 1) * 32) + 4000 + STACK_SIZE)
	mov ss, ax
	mov sp, STACK_SIZE * 16 ; 4096 in bytes

	sti ; enable interrupts

	mov ax, 07C0h			; point all segments to _start
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; dl contains the drive number

	mov ax, 0				; reset disk function
	int 13h					; call BIOS interrupt
	jc disk_reset_error

	; FIXME: if SECTORS + 1 > 18 (~= max sectors per track) 
	; then we should try to do _multiple_ reads
	; 
	; Notes:
	;
	; 1 sector			= 512 bytes
	; 1 cylinder/track	= 18 sectors
	; 1 side			= 80 cylinders/tracks
	; 1 disk (1'44 MB)	= 2 sides
	; 
	; 2 * 80 * 18 * 512 = 1474560 bytes = 1440 kilo bytes = 1.4 mega bytes
	;
	; We start _reading_ at SECTOR 2 because SECTOR 1 is where our stage 1
	; _bootloader_ (this piece of code up until the dw 0xAA55 marker, if you
	; take the time and scroll down below) is *loaded* automatically by BIOS 
	; and therefore there is no need to read it again ...

	push es				; save es

	mov ax, 07E0h		; destination location (address of _start)
	mov es, ax			; destination location
	mov bx, 0			; index 0

	mov ah, 2			; read sectors function
	mov al, SECTORS		; number of sectors
	mov ch, 0			; cylinder number
	mov dh, 0			; head number
	mov cl, 2			; starting sector number
	int 13h				; call BIOS interrupt

	jc disk_read_error

	pop es				; restore es

	mov si, boot_msg	; boot message
	call _puts			; print

	jmp 07E0h:0000h		; jump to _start (a.k.a stage 2)

disk_reset_error:
	mov si, disk_reset_error_msg
	jmp fatal

disk_read_error:
	mov si, disk_read_error_msg

fatal:
	call _puts	; print message in [DS:SI]

	mov ax, 0	; wait for a keypress
	int 16h

	mov ax, 0	; reboot
	int 19h

; ===========================================
; PROTOTYPE	: void _puts(char *s)
; INPUT		: offset/pointer to string in SI
; RETURN	: n/a
; ===========================================
_puts:
	lodsb		; move byte [DS:SI] into AL

	cmp al, 0	; 0 == end of string ?
	je .end

	mov ah, 0Eh ; display character function
	int 10h		; call BIOS interrupt

	jmp _puts	; next character

.end:
	ret

disk_reset_error_msg: db 'Could not reset disk', 0
disk_read_error_msg: db 'Could not read disk', 0
boot_msg: db 'Booting Floppy Bird ... ', 0

times 510 - ($ - $$) db 0	; pad to 510 bytes
dw 0xAA55					; pad 2 more bytes = 512 bytes = THE BOOT SECTOR

; entry point
_start:
	call main				; call main
	jmp $					; loop forever

; mixin sys and main
%include 'sys/txt.asm'
%include 'sys/tmr.asm'
%include 'sys/rnd.asm'
%include 'sys/snd.asm'
%include 'sys/vga.asm'
%include 'main.asm'

times IMAGE_SIZE - ($ - $$) db 0	; pad to IMAGE_SIZE
