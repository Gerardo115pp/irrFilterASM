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
    %define X_values rbp-32
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
    .irr_filter_loop:\
        pxor xmm0, xmm0
        pinsrd xmm0, dword [rdi+rcx*4], 0
        pinsrd xmm0, dword [rdi+(rcx+1)*4], 1
        pinsrd xmm0, dword [rdi+(rcx+2)*4], 2
        pinsrd xmm0, dword [rdi+(rcx+3)*4], 3
        mulps xmm0, xmm1 ; xmm0 = xmm0/2
        movups [rbp-0x20], xmm0
        
        ; we cant use sse on y[n] because its not only in terms of X, but also in terms of y[n-1]
        ; which means we have to calculate those manually
        xor rbx, rbx; rbx will be the offset for the vectors, rbx = n-1
        push rcx
        push rsi
        dec rcx
        lea rsi, [rsi+rcx*4] ; set rsi to the address of y[n-1]
        mov rcx, 4
        .y_calculation_loop:
            fld dword [rsi+rbx*4] ; y[n-1]
            fld dword [A]
            fmul st0, st1
            fld dword [(rbp-32)+rbx*4] ; X[rbx]
            inc rbx; rbx = n
            fadd st0, st1
            fstp dword [rsi+rbx*4] ; y[n] =X[n]*0.5 + y[n-1]*0.5
            fstp st0
            fstp st0

            loop .y_calculation_loop
        pop rsi
        pop rcx

        add rcx, 4 ; increment the loop counter
        cmp rcx, rdx
        jl .irr_filter_loop

    ; initialize the 

    callee_restore_registers
    mov rsp, rbp
    pop rbp
    ret