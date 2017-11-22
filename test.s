factorial(double):
  push rbp
  mov rbp, rsp
  movsd QWORD PTR [rbp-24], xmm0
  movsd xmm0, QWORD PTR [rbp-24]
  movsd QWORD PTR [rbp-8], xmm0
  mov DWORD PTR [rbp-12], 0
.L4:
  cvtsi2sd xmm0, DWORD PTR [rbp-12]
  movsd xmm1, QWORD PTR [rbp-24]
  ucomisd xmm1, xmm0
  jbe .L7
  movsd xmm0, QWORD PTR [rbp-24]
  movsd xmm1, QWORD PTR .LC0[rip]
  subsd xmm0, xmm1
  movsd xmm1, QWORD PTR [rbp-8]
  mulsd xmm0, xmm1
  movsd QWORD PTR [rbp-8], xmm0
  movsd xmm0, QWORD PTR [rbp-24]
  movsd xmm1, QWORD PTR .LC0[rip]
  subsd xmm0, xmm1
  movsd QWORD PTR [rbp-24], xmm0
  add DWORD PTR [rbp-12], 1
  jmp .L4
.L7:
  movsd xmm0, QWORD PTR [rbp-8]
  pop rbp
  ret
power(double, int):
  push rbp
  mov rbp, rsp
  movsd QWORD PTR [rbp-24], xmm0
  mov DWORD PTR [rbp-28], edi
  movsd xmm0, QWORD PTR [rbp-24]
  movsd QWORD PTR [rbp-8], xmm0
  mov DWORD PTR [rbp-12], 0
.L10:
  mov eax, DWORD PTR [rbp-28]
  sub eax, 1
  cmp DWORD PTR [rbp-12], eax
  jge .L9
  movsd xmm0, QWORD PTR [rbp-8]
  mulsd xmm0, QWORD PTR [rbp-24]
  movsd QWORD PTR [rbp-8], xmm0
  add DWORD PTR [rbp-12], 1
  jmp .L10
.L9:
  movsd xmm0, QWORD PTR [rbp-8]
  pop rbp
  ret
taylor(double):
  push rbp
  mov rbp, rsp
  sub rsp, 40
  movsd QWORD PTR [rbp-24], xmm0
  movsd xmm0, QWORD PTR [rbp-24]
  movsd QWORD PTR [rbp-8], xmm0
  mov DWORD PTR [rbp-12], -1
  mov DWORD PTR [rbp-16], 3
.L14:
  cmp DWORD PTR [rbp-16], 9
  jg .L13
  cvtsi2sd xmm3, DWORD PTR [rbp-12]
  movsd QWORD PTR [rbp-32], xmm3
  mov edx, DWORD PTR [rbp-16]
  mov rax, QWORD PTR [rbp-24]
  mov edi, edx
  mov QWORD PTR [rbp-40], rax
  movsd xmm0, QWORD PTR [rbp-40]
  call power(double, int)
  movsd QWORD PTR [rbp-40], xmm0
  cvtsi2sd xmm0, DWORD PTR [rbp-16]
  call factorial(double)
  movsd xmm2, QWORD PTR [rbp-40]
  divsd xmm2, xmm0
  movapd xmm0, xmm2
  mulsd xmm0, QWORD PTR [rbp-32]
  movsd xmm1, QWORD PTR [rbp-8]
  addsd xmm0, xmm1
  movsd QWORD PTR [rbp-8], xmm0
  neg DWORD PTR [rbp-12]
  add DWORD PTR [rbp-16], 2
  jmp .L14
.L13:
  movsd xmm0, QWORD PTR [rbp-8]
  leave
  ret
__static_initialization_and_destruction_0(int, int):
  push rbp
  mov rbp, rsp
  sub rsp, 16
  mov DWORD PTR [rbp-4], edi
  mov DWORD PTR [rbp-8], esi
  cmp DWORD PTR [rbp-4], 1
  jne .L18
  cmp DWORD PTR [rbp-8], 65535
  jne .L18
  mov edi, OFFSET FLAT:std::__ioinit
  call std::ios_base::Init::Init()
  mov edx, OFFSET FLAT:__dso_handle
  mov esi, OFFSET FLAT:std::__ioinit
  mov edi, OFFSET FLAT:std::ios_base::Init::~Init()
  call __cxa_atexit
.L18:
  nop
  leave
  ret
_GLOBAL__sub_I__Z9factoriald:
  push rbp
  mov rbp, rsp
  mov esi, 65535
  mov edi, 1
  call __static_initialization_and_destruction_0(int, int)
  pop rbp
  ret
.LC0:
  .long 0
  .long 1072693248
