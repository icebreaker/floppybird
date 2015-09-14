%define SECTORS 16
%define IMAGE_SIZE ((SECTORS + 1) * 512)	; SECTORS + 1 (~= 18) * 512 bytes

bits 16
org 100h

call main
jmp $

%include 'sys/txt.asm'
%include 'sys/tmr.asm'
%include 'sys/rnd.asm'
%include 'sys/snd.asm'
%include 'sys/vga.asm'
%include 'main.asm'

times IMAGE_SIZE - ($ - $$) db 0	; pad to IMAGE_SIZE
