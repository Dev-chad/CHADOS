[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x7c0:START

TOTAL_SECTOR_COUNT:		dw 0x01

START:
	mov ax, 0x07C0
	mov ds, ax
	mov ax, 0xb800
	mov es, ax

	mov ax, 0x0000
	mov ss, ax
	mov sp, 0xFFFE
	mov bp, 0xFFFE

	mov si, 0

.SCREEN_CLEAR_LOOP:
	mov byte [es:si], 0
	mov byte [es:si+1], 0x07

	add si, 2

	cmp si, 80 * 25 * 2
	jl .SCREEN_CLEAR_LOOP

	push BOOTLOADER_START_MESSAGE
	push 0
	push 0
	push 0x07
	call PRINT_MESSAGE
	add sp, 8

	push START_LOADING_IMAGE_MESSAGE
	push 1
	push 0
	push 0x07
	call PRINT_MESSAGE
	add sp, 8

RESET_DISK:
	mov ax, 0
	mov dl, 0
	int 0x13
	jc DISK_ERROR_HANDLER

	mov si, 0x1000
	mov es, si
	mov bx, 0x0000

	mov di, word [TOTAL_SECTOR_COUNT]

READ_DATA:
	cmp di, 0
	je READ_END
	sub di, 0x1
	
	mov ah, 0x02
	mov al, 0x1
	mov ch, byte [TRACK_NUMBER]
	mov cl, byte [SECTOR_NUMBER]
	mov dh, byte [HEAD_NUMBER]
	mov dl, 0x00
	int 0x13
	jc DISK_ERROR_HANDLER

	add si, 0x0020
	mov es, si

	mov al, byte [SECTOR_NUMBER]
	add al, 0x01
	mov byte [SECTOR_NUMBER], al
	cmp al, 19
	jl READ_DATA

	xor byte [HEAD_NUMBER], 0x01
	mov byte [SECTOR_NUMBER], 0x01

	cmp byte [HEAD_NUMBER], 0x00
	jne READ_DATA

	add byte [TRACK_NUMBER], 0x01
	jmp READ_DATA

READ_END:
	push PASS_MESSAGE
	push 1
	push 45
	push 0x0A
	call PRINT_MESSAGE
	add sp, 8

	push SWITCH_MODE_MESSAGE
	push 2
	push 0
	push 0x07
	call PRINT_MESSAGE
	add sp, 8

	jmp 0x1000:0x0000

DISK_ERROR_HANDLER:
	push ERROR_MESSAGE
	push 1
	push 45
	push 0x04
	call PRINT_MESSAGE
	
	jmp $

PRINT_MESSAGE:
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

.MESSAGE_LOOP:
	mov cl, byte [si]

	cmp cl, 0
	je .MESSAGE_END
	
	mov byte [es:di], cl
	mov byte [es:di+1], al

	add si, 1
	add di, 2

	jmp .MESSAGE_LOOP

.MESSAGE_END:
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret

BOOTLOADER_START_MESSAGE:		db 'Boot Loader Start', 0

PASS_MESSAGE:					db 'PASS', 0
ERROR_MESSAGE:  				db 'FAIL', 0
START_LOADING_IMAGE_MESSAGE:	db 'Operating System Loading....................[    ]', 0
SWITCH_MODE_MESSAGE:			db 'Switch Real Mode To Protected Mode..........[    ]', 0

SECTOR_NUMBER:					db 0x02
HEAD_NUMBER:					db 0x00
TRACK_NUMBER:					db 0x00

times 510 - ($ - $$) db 0x00

dw 0xAA55
