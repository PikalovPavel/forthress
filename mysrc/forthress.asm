global _start
global last_word

%include "util.inc"
%include "macro.inc"

%define w r15
%define pc r14
%define rstack r13

section .data
program_stub: dq 0
xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop
current_word: times 256 db 0, 0
stack_head: dq 0

section .rodata
undefined:          db 'No such word',10, 0

section .text
%include "words.inc"

section .text
next:
  mov w, pc
  add pc, 8
  mov w, [w]
  jmp [w]

interpreter_loop:
  mov rsi, 256
  mov rdi, current_word
  call read_word

  test rdx, rdx
  jz .exit

  mov rdi, rax
  call find_word

  test rax, rax
  jz .not_word

  mov rdi, rax
  call cfa

  mov [program_stub], rax
  mov pc, program_stub

  jmp next

  .not_word:
  mov rdi, current_word
  call parse_int

  test rdx, rdx
  jz .not_found

  push rax

  jmp interpreter_loop

  .not_found:
  mov rdi, undefined
  call print_string

  jmp interpreter_loop

  .exit:
  xor rdi, rdi
  call exit

_start:
  mov [stack_head], rsp
  mov pc, xt_interpreter
  jmp next

section .data
last_word: dq _lw

