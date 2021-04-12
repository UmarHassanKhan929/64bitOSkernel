section .multiboot_header
header_start: ;start label
	
	dd 0xe85250d6 ; multiboot2 magik number
	
	dd 0 ; architecture of OS (protected mode)
	
	dd header_end - header_start ; length of header
	
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ;checksum for correct boot info

	;ending tags to notify header is finished
	dw 0
	dw 0
	dd 8
header_end: ;end label