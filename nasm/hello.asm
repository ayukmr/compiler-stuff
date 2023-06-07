; entry point
global _main

; data section
section .data
   msg db 'hello world', 0x0a ; declare msg label
   loop_msg db 'loop', 0x0a   ; declare loop_msg label

; text section
section .text
_main:
   ;; message

   mov rdx, 12        ; number of bytes to write
   lea rsi, [rel msg] ; move message to rsi
   mov rdi, 1         ; write to stdout
   mov rax, 0x2000004 ; syscall to write
   syscall            ; invoke syscall

   ;; loop

   mov ebx, 5 ; set ebx register

   .loop:
      mov rdx, 5              ; number of bytes to write
      lea rsi, [rel loop_msg] ; move message to rsi
      mov rdi, 1              ; write to stdout
      mov rax, 0x2000004      ; syscall to write
      syscall                 ; invoke syscall

      dec ebx   ; decrement ebx
      jnz .loop ; loop if ebx is non-zero

   ;; exit

   mov rax, 0x2000001 ; syscall to exit
   mov rdi, 0         ; exit status
   syscall            ; invoke syscall
