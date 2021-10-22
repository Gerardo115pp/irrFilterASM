DEFAULT rel

%include "./asm_utils.s"

section .text
global pysum
global irrFilterSSE

pysum:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rax, rdi
    add rax, rsi
    inc rax
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

irrFilterSSE:
    ; gets a pointer to a simple precision float array X on rdi,
    ; a pointer to an empty float array Y on rsi, and the length of the rdi array
    ; on rdx. applies the irr filter to the array X and stores the result in Y.
    ; the formula is:
    ; Y[n] = (X[n] + Y[n-1])/2
    ; RegistersUsage
    ; rdi: X
    ; rsi: Y
    ; rdx: length of X
    ; rcx: loop counter
    ; xmm0: For multiplication operations on X[n, n-1, n-2, n-3]
    ; xmm1: 0.5 multiplier matrix
    push rbp
    mov rbp, rsp
    sub rsp, 0x20 ; reserve 4 double words 
    %define A rbp-4
    %define B rbp-8
    %define C rbp-12
    %define D rbp-16
    %define X_value rbp-20
    callee_save_registers

    ; initialize the multiplier matrix
    mov dword [D], __?float32?__(0.5)
    mov dword [C], __?float32?__(0.5)
    mov dword [B], __?float32?__(0.5)
    mov dword [A], __?float32?__(0.5)
    pxor xmm1, xmm1
    movaps xmm1, [D]

    pxor xmm0, xmm0
    ; treat y[0] as a special case, because y[n] in in terms of y[n-1] which means we only consider x[n]*0.5
    fld dword [rdi]
    fld dword [A]
    fmul st0, st1
    fstp dword [rsi]

    ; now we can start the main loop
    xor rcx, rcx
    inc rcx ; skip n=0, because we already handled it

    ; loop over the array
    finit
    .irr_filter_loop:
        pinsrd xmm0, dword [rdi+rcx*4], 0
        pinsrd xmm0, dword [rdi+(rcx+1)*4], 1
        pinsrd xmm0, dword [rdi+(rcx+2)*4], 2
        pinsrd xmm0, dword [rdi+(rcx+3)*4], 3
        mulps xmm0, xmm1 ; xmm0 = xmm0/2
        
        ; we cant use sse on y[n] because its not only in terms of X, but also in terms of y[n-1]
        ; which means we have to calculate those manually
        
        fld dword [rsi+(rcx-1)*4]
        fld dword [A]
        fmul st0, st1
        pextrd [X_value], xmm0, 0
        fld dword [X_value]
        fadd st0, st1
        fstp dword [rsi+rcx*4] ; y[n] = y[n-1]*0.5
        fstp st0
        fstp st0

        fld dword [rsi+rcx*4]
        fld dword [A]
        fmul st0, st1
        pextrd [X_value], xmm0, 1
        fld dword [X_value]
        fadd st0, st1
        fstp dword [rsi+(rcx+1)*4] ; y[n+1] = y[n]*0.5
        fstp st0
        fstp st0

        fld dword [rsi+(rcx+1)*4]
        fld dword [A]
        fmul st0, st1
        pextrd [X_value], xmm0, 2
        fld dword [X_value]
        fadd st0, st1
        fstp dword [rsi+(rcx+2)*4] ; y[n+2] = y[n+1]*0.5
        fstp st0
        fstp st0

        fld dword [rsi+(rcx+2)*4]
        fld dword [A]
        fmul st0, st1
        pextrd [X_value], xmm0, 3
        fld dword [X_value]
        fadd st0, st1
        fstp dword [rsi+(rcx+3)*4] ; y[n+3] = y[n+2]*0.5
        fstp st0
        fstp st0


        add rcx, 4 ; increment the loop counter
        cmp rcx, rdx
        jl .irr_filter_loop

    ; initialize the 

    callee_restore_registers
    mov rsp, rbp
    pop rbp
    ret