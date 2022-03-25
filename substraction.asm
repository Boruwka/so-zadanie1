


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
    ; r10 - kopia flagi overflow (xd)
    ; r11 - kopia flagi sign (też xd, ale te flagi się ciężko obsługuje)


    push rbx
    mov rbx, 0 ; counter pętli
    mov r10, 0
    mov r11, 0 ; zerujemy kopie flag
    substraction_loop:
        mov r8, [rdi]
        mov r9, [rsi]
        sub r8, r9 ; jebać overflowy
        cmp r10, 0
        je .no_overflow_prev ; chodzi o overflow w poprzednim odejmowaniu
        dec r8
        jmp .no_overflow_prev
        cmp r11, 0
        je .positive_overflow_prev
        .positive_overflow_prev:
        inc r8
        .no_overflow_prev: ; nie musimy dodawać poprzedniego overflowu
        mov r10, 0
        jno .no_overflow
        mov r10, 1
        mov r11, 0
        jns .no_overflow
        mov r11, 1
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
