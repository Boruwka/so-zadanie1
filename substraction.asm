


section .bss

section .text
global substract
substract:
    ; liczbę ujemną przedstawiamy z samymi minusami
    ; dodatnią z samymi plusami
    ; nie trzymamy liczby znakowej na początku
    ; po prostu odejmujemy, jak będzie overflow w którąś stronę to go naprawiamy

    ; w rdi przyjmuje adres tablicy do odjęcia i nim iterujemy
    ; w rsi drugiej tablicy i też nim iterujemy
    ; w rdx ich rozmiar
    ; rbx - counter pętli
    ; r8, r9 - pomocnicze
    ; r10 - overflow, który mamy dodać do następnego


    push rbx
    mov rbx, 0 ; counter pętli
    mov r10, 0 ; overflow

    substraction_loop:
        mov r8, [rdi]
        mov r9, [rsi]
        sub r8, r9 ; jebać overflowy
        pushf
        add r8, r10; dodajemy flagę overflow
        mov r10, 0
        popf
        jno .no_overflow
        pushf
        mov r10, -1
        popf
        jns .no_overflow
        mov r10, 1
        .no_overflow:
        mov [rdi], r8
        inc rbx
        add rdi, 8
        add rsi, 8
        cmp rbx, rdx ; czy osiągnęliśmy n
        jl substraction_loop

    substraction_exit:
        pop rbx
        ret


section .data
