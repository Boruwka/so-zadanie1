section .bss
section .data

; zaczynamy od tablicy bigintów, która jest w rax
; i zmieniamy ją na różnicę


section .text
substract:
    push rbx
    mov rbx, 0 ; counter pętli
    substract_loop:
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
        jl substract_loop
    substract_exit:
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
    
    

