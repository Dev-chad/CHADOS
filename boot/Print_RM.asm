[BITS 16]

PRINT_RM:
	push bp
	mov bp, sp

	push es
	push si
	push di
	push ax
	push cx
	push dx

	mov ax, 0xB800
	mov es, ax

	mov ax, word [bp + 8]
	mov si, 160
	mul si
	mov di, ax

	mov ax, word [bp + 6]
	mov si, 2
	mul si
	add di, ax

	mov si, word [bp + 10]
	mov al, byte [bp + 4]

.PRINT_RM_LOOP:
	mov cl, byte [si]

	cmp cl, 0
	je .PRINT_RM_END

	mov byte [es:di], cl
	mov byte [es:di+1], al

	add si, 1
	add di, 2

	jmp .PRINT_RM_LOOP


.PRINT_RM_END:
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret

	
SCREEN_CLEAR_RM:
	mov ax, 0xB800
	mov es, ax

	mov byte [es:si], 0
	mov byte [es:si+1], 0x07

	add si, 2

	cmp si, 80 * 25 * 2
	jl SCREEN_CLEAR_RM
	ret
