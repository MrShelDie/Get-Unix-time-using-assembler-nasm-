GLOBAL _start

section .bss
	time_sec resq 1		;time in sec since 01.01.1970
	time_str resb 20	;string of numbers
	len resq 1

section .data
	msg db "Time in seconds since January 1, 1970:", 0xA

section .text
_start:
	;write msg
	push msg
	push 39
	call write


	;get system time
	mov eax, 13			;sys_time
	mov ebx, time_sec 	;output in [time_sec]
	int 80h

	
	;splits one number of time value ​into decimal digits to display them as a string
	;divides the time value by 10, the remainder writes to the time_str array (for now, as a number)
	;repeats until the dividend is 0
	mov rdi, time_str
	mov rax, [time_sec]	;set low part of dividend
	mov rcx, 10			;set divider
lp1:	
	xor rdx, rdx	;set high part of dividend
	div rcx			;divide the number of time by 10
	;eax - full part of division
	;edx - remainder of the division
	mov [rdi], dl
	inc rdi
	test rax, rax
	jnz lp1


	;translates digit into ASCII
	sub rdi, time_str 	;get len of string time_str
	mov [len], rdi		;save it
	mov rcx, rdi		;find how many times we need to run a cycle
	mov rdi, time_str 	
	mov al, '0'			;mask (for example, if you need to get '2', then in ACSII this character will be: '0' or 2)
lp2:
	mov ah, [rdi]		
	or ah, al
	mov [rdi], ah
	inc edi
	loop lp2


	;reverse string
	;swap the element from the ends to the middle of the line
	mov rsi, time_str
	mov rdi, rsi
	add rdi, [len]
	dec rdi
lp3:
	mov al, [rsi]
	mov ah, [rdi]
	mov [rsi], ah
	mov [rdi], al
	;condition for exiting the loop if the line has an even number of elements
	mov rdx, rdi
	sub rdx, rsi
	cmp rdx, 1
	jz 	add_end_char
	;and if our line has an odd number of elements
	cmp rsi, rdi
	jz 	add_end_char

	inc rsi
	dec rdi
	jmp lp3


add_end_char:
	;add '\n' char
	mov rax, time_str
	mov rbx, [len]
	mov [rax+rbx], byte 0x0A	;'\n'
	inc qword [len]


	;write string
	push time_str
	mov rax, [len]
	push rax
	call write


	;end
	mov rax, 1
	xor rbx, rbx
	int 80h


write:
	;print(*first_element, qword len)
	push rbp
	mov rbp, rsp
	
	mov rax, 4				;sys_write
	mov rbx, 1				;std_output
	mov rcx, [rbp + 24]  	;pointer on first element
	mov rdx, [rbp + 16]		;len
	int 80h

	mov rsp, rbp
	pop rbp
	ret