; liczbę ujemną przedstawiamy z samymi minusami
; dodatnią z samymi plusami
; nie trzymamy liczby znakowej na początku
; po prostu odejmujemy, jak będzie overflow w którąś stronę to go naprawiamy


section .bss

section .text
global substract
substract:
    push rbx
    mov rbx, 0 ; counter pętli
    loop:
        mov r8, [rdi]
        mov r9, [rsi]
        ;sub r8, r9
        sbb r8, r9 ; jebać overflowy
        cmp r8, 0
        jge .no_overflow
        ; tutaj jesteśmy jak jest overflow
        ;cmp r9, 0
        ;jl .minus_overflow
        ; tutaj kod plus overflowu ; to wszystko zakomentowane tylko do testu
        ;jmp .no_overflow
        ;.minus_overflow:
            ; tutaj kod minus overflowu
        .no_overflow:
        mov [rdi], r8
        inc rbx
        add rdi, 8
        add rsi, 8
        cmp rbx, rdx ; czy osiągnęliśmy n
        jl loop
    exit:
        pop rbx
        ret


section .data
