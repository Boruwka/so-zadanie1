section .bss

section .text

extern malloc

; zaczynamy od tablicy bigintów, która jest w rax
; i zmieniamy ją na różnicę
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
    

check_if_zero:
; rdi to tablica tablic, które mamy sprawdzić
; rsi to ich liczba
; rdx to liczba elementów każdej
; do rax zwracamy 1 jeśli jest niezero, w przeciwnym razie 0 jeśli same zera

push rbx
mov rbx, 0 ; counter zewnętrznej pętli
mov rax, 0
extern_loop:
    mov rcx, 0 ; counter wewnętrznej pętli
    mov r10, [rdi] ; wskaźnik do aktualnie przeglądanej tablicy
    ;add rax, r10 ; tylko do testu ta linijka
    ;add rax, [rdi]
    intern_loop:
        mov r8, [r10] ; w r8 będzie inspektowana liczba
        ; okay, czyli tu jesteśmy, tylko uważamy, że r8 to 0
        cmp r8, 0
        jne exit_positive
        inc rcx
        add r10, 8
        cmp rcx, rdx
        jne intern_loop
    inc rbx
    add rdi, 8
    cmp rbx, rsi
    jne extern_loop
    je check_exit
exit_positive:
    mov rax, 1 ; to powinno tu być, wykreślone tylko do testu
check_exit:
    pop rbx
    ret


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
    mov r8d, [rdx] ; to powinno być
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

tobigint_exit:
mov rax, rcx ; to powinno byc
pop r13
pop r12
pop rbx
ret






; rcx - wynikowa tablica
; r8, r9 - pomocnicze
; rbx - licznik iteracji
; r10 - n zmniejszające się
; r11 - n/8+2
global polynomial_degree:
polynomial_degree:
    mov r10, rsi ; przenosimy n do r10
    push r10
    call to_bigint
    pop r10
    ; teraz w rax jest wynikowa tablica, którą będziemy zmieniać
    mov rcx, rax ; przeniesienie wynikowej tablicy do rcx
    mov r11, r10
    shr r11, 3
    add r11, 2 ; teraz w r11 jest n/8+2
    mov rbx, 0 ; zerowanie licznika iteracji
    main_loop:
        mov rdi, rcx
        mov rsi, r10 ; przeniesienie argumentów dla iteracji
        push rcx
        push r10
        push r11
        call iteracja
        pop r11
        pop r10
        pop rcx
        mov rdi, rcx
        mov rsi, r10
        mov rdx, r11 ; przenoszenie argumentów dla check_if_zero
        push rcx
        push r10
        push r11
        call check_if_zero
        pop r11
        pop r10
        pop rcx
        cmp rax, 0
        je main_exit
        ; tutaj jesteśmy jeśli nie ma samych zer
        dec r10 ; zmniejszamy n bo mniej liczb rozważamy już
        inc rbx ; zwiększamy counter pętli
        cmp r10, 0 ; jeśli zero to kończymy
        jne main_loop
    

    main_exit:
        mov rax, rbx
    

section .data