[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x7c0:START

TOTAL_SECTOR_COUNT:	dw 0x02	; 디스크에서 읽을 섹터의 개수

START:
	mov ax, 0x07C0	; BootLoader의 Starting address를 Data Segment Register에 넣음
	mov ds, ax
	mov ax, 0xB800	; Video memory의 String address를 Extra Segment Register에 넣음
	mov es, ax

	; Stack 영역을 64KB 만큼 지정
	mov ax, 0x0000	; Stack Segment를 0 번지로
	mov ss, ax
	mov sp, 0xFFFE	; Stack Pointer & Base Pointer를 0xFFFE로
	mov bp, 0xFFFE	; 0xFFFF가 아닌 이유는 16bit Stack은 하나에 2Byte를 차지하기 때문

	mov si, 0		; Screen Clear에서 증가 값으로 사용 할 레지스터를 0으로 초기화

	call SCREEN_CLEAR_RM

	push BOOTLOADER_START_MESSAGE		; Message가 적혀있는 주소의 시작 번지를 Stack에 push
	push 0								; Y좌표 값
	push 0								; X좌표 값
	push 0x07							; 색상 값
	call PRINT_RM					; PRINT_RM 호출
	add sp, 8							; Stack Pointer를 위에서 push한 만큼 증가시켜서
										; push한 파라미터들을 제거

	push START_LOADING_IMAGE_MESSAGE	; 위와 동일
	push 1
	push 0
	push 0x07
	call PRINT_RM
	add sp, 8

RESET_DISK:								; BIOS 함수를 호출하여 디스크를 초기화
	mov ax, 0							; Service no 0
	mov dl, 0							; Drive no 0
	int 0x13							; 디스크 함수 인터럽트를 호출
	jc DISK_ERROR_HANDLER				; Carrie Flag가 발생하면 디스크 초기화 과정에서
										; 오류가 발생했다는 의미
										; 오류 발생 시 DISK_ERROR_HANDLER로 Jump

	mov si, 0x1000						; 0x10000에 OS이미지를 올리기 위해	
	mov es, si							; (ES:BX)를 0x10000으로 설정
	mov bx, 0x0000

	mov di, word [TOTAL_SECTOR_COUNT]	; 읽을 섹터의 개수

READ_DATA:
	cmp di, 0							; di가 0이면 디스크 읽기 완료
	je READ_END

	sub di, 0x1							; 아니면 개수를 하나 줄임
	
	mov ah, 0x02						; Service no 2 (Read sector)
	mov al, 0x1							; 읽을 섹터의 개수
	mov ch, byte [TRACK_NUMBER]			; 아래 3줄은 트랙 섹터 헤드에 관한 설정 값
	mov cl, byte [SECTOR_NUMBER]
	mov dh, byte [HEAD_NUMBER]
	mov dl, 0x00						; Drive no 0
	int 0x13
	jc DISK_ERROR_HANDLER				

	add si, 0x0020						; 섹터당 512Byte (0x0200 = 512), 주소값을 증가시킴
	mov es, si							; ex) 0x10000 -> 0x10200
										; 한 섹터를 읽을 시 512Byte 만큼 증가시킴

	mov al, byte [SECTOR_NUMBER]		; 
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
	call PRINT_RM
	add sp, 8

	jmp 0x1000:0x0000
DISK_ERROR_HANDLER:
	push ERROR_MESSAGE
	push 1
	push 45
	push 0x04
	call PRINT_RM
	
	jmp $

%include "Source/Print_RM.asm"

BOOTLOADER_START_MESSAGE:		db 'Boot Loader Start', 0
PASS_MESSAGE:					db 'PASS', 0
ERROR_MESSAGE:					db 'FAIL', 0
START_LOADING_IMAGE_MESSAGE:	db 'Operating System Loading....................[    ]', 0

SECTOR_NUMBER:					db 0x02
HEAD_NUMBER:					db 0x00
TRACK_NUMBER:					db 0x00

times 510 - ($ - $$) db 0x00

dw 0xAA55
