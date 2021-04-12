global start ;global to access while linking in ENTRY(start)
extern long_mode_start
section .text
bits 32 ;instruction are in 32 bits
;label for start
start:

	mov esp, stack_top ; esp stack register having top of stack

;for 64 bit conversion
	call check_multiboot ; confirms boot from multiboot2 loader
	call check_cpuid ; idk cpu instructions
	call check_long_mode ; check cpu id for mode of operation

;for virtual memory of 64bit
	call setup_page_tables
	call enable_paging

	;globat descriptor stuff for 64bit
	lgdt [gdt64.pointer]
	jmp gdt64.code_segment:long_mode_start
	
	;printing text to notify tis working
	; vga memory address is 0xb8000
	;mov dword [0xb8000], 0x2f4b2f4f
	hlt


;subroutine
check_multiboot:
	cmp eax, 0x36d76289 ;magik number which bootloader holds in eax
	jne .no_multiboot ; jump to no multiboot if false from uppper comparison
	ret

;label if multiboot not loaded
.no_multiboot:
	mov al, "M" ; M for no multi boot
	jmp error

check_cpuid: ;by flipping bit idk what happen or why
	pushfd
	pop eax
	mov ecx, eax
	xor eax, 1 << 21 ;flipping 21st bit
	push eax
	popfd
	pushfd
	pop eax
	push ecx
	popfd
	cmp eax, ecx ;check if bit flipped
	je .no_cpuid
	ret

.no_cpuid: ;cpu id not avaiable
	mov al, "C"
	jmp error

check_long_mode:
	mov eax, 0x80000000 ;to check if cpu id supports extended mode
	cpuid ;takes eax as argument
	cmp eax, 0x80000001 ;if condition passed, eax value changed and comparing for greater value
	jb .no_long_mode ;if false, long mode not supported

	mov eax, 0x80000001 ;if long mode supported, ln bit enables
	cpuid 
	test edx, 1 << 29 ;ln is 29th bit
	jz .no_long_mode

	ret
	
.no_long_mode: ;L for no long mode error
	mov al, "L"
	jmp error

setup_page_tables: ;mapping physicali memory to virtual page
	mov eax, page_table_l3
	or eax, 0b11 
	mov [page_table_l4], eax
	
	mov eax, page_table_l2
	or eax, 0b11 
	mov [page_table_l3], eax

	mov ecx, 0 

.loop:
	mov eax, 0x200000 ; 2MB page for mapping entire table
	mul ecx ;to get next correct address
	or eax, 0b10000011 ;page flag 
	mov [page_table_l2 + ecx * 8], eax

	inc ecx ;increment ecx
	cmp ecx, 512 ; for checking whole table mapped or nah
	jne .loop ;if not mapped

	ret

enable_paging:
	; pass page tble address to cpu
	mov eax, page_table_l4
	mov cr3, eax ;copying page4 address to cr3

	;enable Physical address extension (for 64 bit)
	mov eax, cr4
	or eax, 1 << 5 ;enabling 5th bit for PAE flag
	mov cr4, eax ;saving back to cr4

	;enable long mode
	mov ecx, 0xC0000080 ;magik value
	rdmsr ;read model specific register
	or eax, 1 << 8 ;long mode flag
	wrmsr ; write model specific reg (efer)

	;enable paging
	mov eax, cr0
	or eax, 1 << 31 ;enable paging bit 31st
	mov cr0, eax

	ret

error:
	; to display error code ERR:X
	mov dword [0xb8000], 0x4f524f45
	mov dword [0xb8004], 0x4f3a4f52
	mov dword [0xb8008], 0x4f204f20
	mov byte  [0xb800a], al ;error code for error which we stored in al
	hlt


; statically allocated variables section (reserved when kernel loaded)
section .bss
align 4096 ;as each page table 4KB
page_table_l4:
	resb 4096
page_table_l3:
	resb 4096
page_table_l2:
	resb 4096

;labels for stack
stack_bottom:
	resb 4096 * 4 ; 16KB  memory allocation, resb 1 = allocates 1 byte
stack_top:


section .rodata ;read only data section
gdt64: ; global descriptor label
	dq 0 ;zero entry idk why
.code_segment: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment, flags
.pointer:
	dw $ - gdt64 - 1 ;length
	dq gdt64 ;offset address