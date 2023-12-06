use16

org 07C00h

;; Set up video mode
mov ah, 00h		; set BIOS video mode 
mov al, 03h		; set text mode, 80x25, 16 color VGA
int 10h			

;; Set up video memory
mov ax, 0B800h
mov es, ax	; ES:DI <- B800:0000

;; Game loop
game_loop:
	;; Clear screen to black every cycle
	xor ax, ax
	xor di, di
	mov cx, 80*25
	rep stosw
	;; stosw is equivalent to:
	;;						mov [es:di], ax
	;;						inc di

;; Draw stuff to the screen

;; Player input

;; CPU input

jmp game_loop

;; Bootsector padding
times 510-($-$$) db 0
dw 0AA55h ; Write the MAGIC Bootsector # in last 2 bytes
