section .bss
section .data

; zaczynamy od tablicy bigintów, która jest w rax
; i zmieniamy ją na różnicę


section .text

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



global iteracja:
iteracja:
; rcx - wynikowa tablica
; r10 - iterator po niej 
; rbx - counter pętli po tablicy
; r11 - n-1
; r12 - n / 8 + 2
; r8, r9 - pomocnicze

push rbx
push r12
mov rcx, rdi ; przeniesienie adresu wynikowej tablicy
mov r10, rcx ; przeniesienie adresu tablicy do iteratora po niej
mov r11, rsi ; przeniesienie n
mov r12, r11
shr r12, 3 ; dzielenie przez 8
add r12, 2 ; teraz w r12 mamy n/8+2
dec r11 
mov rbx, 0

iteracja_loop:
    mov rdi, [r10]
    mov rsi, [r10+8] ; ten i następny bigint
    mov rdx, r12
    push rcx
    push r10
    push rbx
    push r11
    push r12
    call substract
    pop r12
    pop r11
    pop rbx
    pop r10
    pop rcx
    inc rbx ; zwiększenie countera
    add r10, 8 ; przejście do następnego elementu tablicy
    cmp rbx, r11 ; czy już doszliśmy do n-1
    jne iteracja_loop    

iteracja_exit:
    pop r12
    pop rbx
    ret
    
    

