[ORG 0x00]
[BITS 16]

SECTION .text


START:
	mov ax, 0x1000

	mov ds, ax
	mov es, ax

	mov ax, 0x2401
	int 0x15

	jc .A20GATE_ERROR
	jmp .A20GATE_SUCCESS

.A20GATE_ERROR:
	in al, 0x92
	or al, 0x02
	and al, 0xFE
	out 0x92, al

.A20GATE_SUCCESS:
	push (SWITCH_MODE_MESSAGE - $$ + 0x10000)
	push 2
	push 0
	push 0x07
	call PRINT_RM
	add sp, 8

	cli
	lgdt [GDTR]

	mov eax, 0x4000003B
	mov cr0, eax

	jmp dword 0x08:(PROTECTED_MODE - $$ + 0x10000)

[BITS 32]
PROTECTED_MODE:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ss, ax
	mov esp, 0xFFFE
	mov ebp, 0xFFFE

	push (PASS_MESSAGE - $$ + 0x10000)
	push 2
	push 45
	push 0x0A
	call PRINT_MESSAGE
	add esp, 16

	push (JMP_TO_C_KERNEL_MESSAGE - $$ + 0x10000)
	push 3
	push 0
	push 0x07
	call PRINT_MESSAGE
	add esp, 16

	jmp dword 0x08:0x10200

PRINT_MESSAGE:
	push ebp
	mov ebp, esp
	push esi
	push edi
	push eax
	push ecx
	push edx

	mov eax, dword [ebp + 16]
	mov esi, 160
	mul esi
	mov edi, eax

	mov eax, dword [ebp + 12]
	mov esi, 2
	mul esi
	add edi, eax

	mov esi, dword [ebp + 20]
	mov eax, dword [ebp + 8]

.MESSAGE_LOOP:
	mov cl, byte [esi]
	
	cmp cl, 0
	je .MESSAGE_END

	mov byte [edi + 0xB8000], cl
	mov byte [edi + 0xB8000 + 1], al

	add esi, 1
	add edi, 2

	jmp .MESSAGE_LOOP

.MESSAGE_END:
	pop edx
	pop ecx
	pop eax
	pop edi
	pop esi
	pop ebp
	ret

align 8, db 0

dw 0x0000

GDTR:
	dw GDT_END - GDT - 1
	dd (GDT - $$ + 0x10000)

GDT:
	NULL_DESCRIPTOR:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
		db 0x00

	CODE_DESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x9A
		db 0xCF
		db 0x00

	DATA_DESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x92
		db 0xCF
		db 0x00

GDT_END:

%include "Source/Print_RM.asm"

PASS_MESSAGE:					db 'PASS', 0
FAIL_MESSAGE:					db 'FAIL', 0
SWITCH_MODE_MESSAGE:			db 'Switch Real Mode To Protected Mode..........[    ]', 0
JMP_TO_C_KERNEL_MESSAGE:		db 'Jump to C Kernel............................[    ]', 0

times 512 - ($ - $$) db 0x00
