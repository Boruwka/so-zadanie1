section .bss


section .data


; https://stackoverflow.com/questions/59697603/how-to-use-malloc-in-asm
; size_t ma 8 bajtów

section .text

extern malloc

global to_bigint
to_bigint:
; rbx - counter pętel zewnętrznych
; rcx - adres wynikowej tablicy (na koniec przekażę go do rax)
; rdx - początkowa tablica, z której bierzemy dane, i iteracja po niej
; r8, r9 - pomocnicze
; rsi - n
; r10 - n/8+2
; r11 - iteracja po wynikowej tablicy 
; r12 - iteracja po wnętrzach podtablic
; r13 - counter wewnętrznej pętli
push rbx
push r12
push r13
mov rdx, rdi ; przekazanie żeby początkowa tablica była w rdx
mov rdi, rsi ; przekazanie do rdi n
imul rdi, 8
push rdx
push rsi
call [rel malloc wrt ..got]
pop rsi
pop rdx ; dla pewności, żeby malloc ich nie zmienił
mov rcx, rax ; teraz wynikowa tablica jest w rcx

mov r10, rsi
shr r10, 3 ; dzielenie przez 8
add r10, 2 ; teraz r10 = n/8+2


mov rbx, 0 ; counter pętli
mov r11, rcx

loop_alloc:
    mov rdi, r10
    imul rdi, 8
    push rcx
    push rdx
    push rsi
    push r10
    push r11
    call [rel malloc wrt ..got]
    pop r11
    pop r10
    pop rsi
    pop rdx
    pop rcx
    mov [r11], rax
    
    inc rbx
    add r11, 8
    cmp rbx, rsi
    jne loop_alloc


mov rbx, 0; zerujemy counter
mov r11, rcx; zerujemy iterację po wynikowej tablicy    


; rcx - adres wynikowej tablicy (na koniec przekażę go do rax)
; r11 - iteracja po wynikowej tablicy 
; r12 - iteracja po wnętrzach podtablic
; r13 - counter wewnętrznej pętli


    
loop_move:
    mov r12, [r11]
    mov r8, 0
    mov [r12], r8 ; czyścimy to co jest w [r12] zerem zanim tam coś zapiszemy
    mov r8d, [rdx]
    cmp r8d, 0 ; nowa linijka
    jge .positive ; nowa linijka
    ; tutaj jesteśmy jeśli przenoszona wartość jest ujemna
    mov r9, 0 ; nowa linijka
    sub r9d, r8d ; nowa linijka, mamy |[rdx]| w r9d
    mov r8, 0
    sub r8, r9
    .positive: ; nowa linijka
    mov [r12], r8
    mov r13, 1 ; zerowanie countera

    loop_intern:
        add r12, 8
        inc r13
        mov r8, 0
        mov [r12], r8
        cmp r13, r10
        jne loop_intern

    inc rbx
    add r11, 8 ; przejście do następnego elementu wynikowej tablicy
    add rdx, 4 ; dodajemy 4, bo w tej pierwotnej tablicy są inty
    cmp rbx, rsi
    jne loop_move


check_exit:
mov rax, rcx ; to powinno byc
pop r13
pop r12
pop rbx
ret


