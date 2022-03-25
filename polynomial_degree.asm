section .text

extern malloc

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
; r12 - n / 8 + 4, lub rozmiar podtablic po prostu 
; r8, r9 - pomocnicze

push rbx
push r12
mov rcx, rdi ; przeniesienie adresu wynikowej tablicy
mov r10, rcx ; przeniesienie adresu tablicy do iteratora po niej
mov r11, rsi ; przeniesienie n
mov r12, rdx ; rozmiar podtabilc będzie podany jako argument
;mov r12, r11
;shr r12, 3 ; dzielenie przez 8
;add r12, 2 ; teraz w r12 mamy n/8+2
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
    
    
    

global check_if_zero:
check_if_zero:
; rdi to tablica tablic, które mamy sprawdzić
; rsi to ich liczba
; rdx to liczba elementów każdej
; do rax zwracamy 1 jeśli jest niezero, w przeciwnym razie 0 jeśli same zera

push rbx
mov rbx, 0 ; counter zewnętrznej pętli
mov rax, 0
;add rax, [rdi+8] ; tylko do testu ta linijka 
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
    je exit
exit_positive:
    mov rax, 1 ; to powinno tu być, wykreślone tylko do testu
exit:
    pop rbx
    ret

global to_bigint
to_bigint:
; rbx - counter pętel zewnętrznych
; rcx - adres wynikowej tablicy (na koniec przekażę go do rax)
; rdx - początkowa tablica, z której bierzemy dane, i iteracja po niej
; r8, r9 - pomocnicze
; rsi - n
; r10 - n/8+4
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
add r10, 4 ; teraz r10 = n/8+4


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





global polynomial_degree:
polynomial_degree:
; rcx - wynikowa tablica
; r8, r9 - pomocnicze
; rbx - licznik iteracji
; r10 - n zmniejszające się
; r11 - n/8+2

    push rbx
    
    ; zaczniemy od odifowania n = 1, bo dla niego nie działa pętla
    cmp rsi, 1
    jne n_greater_than_1
    mov rbx, -1
    mov r8d, [rdi]
    cmp r8, 0
    je main_exit
    mov rbx, 0
    jmp main_exit

    n_greater_than_1:
    mov r10, rsi ; przenosimy n do r10
    push r10
    sub rsp, 8
    call to_bigint
    add rsp, 8
    pop r10

    ; teraz w rax jest wynikowa tablica, którą będziemy zmieniać
    mov rcx, rax ; przeniesienie wynikowej tablicy do rcx
    mov r11, r10
    shr r11, 3
    add r11, 4 ; teraz w r11 jest n/8+2
    mov rbx, 0 ; zerowanie licznika iteracji

    ; teraz sprawdzimy, czy w tablicy są od razu same zera, jeśli tak to zwrócimy -1
    push rdi
    push rsi
    push rdx
    mov rdi, rcx
    mov rsi, r10
    mov rdx, r11
    push rcx
    push r10
    push r11
    call check_if_zero
    pop r11
    pop r10
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    mov rbx, -1
    cmp rax, 0
    je main_exit
    mov rbx, 0
    
    
    
    
    main_loop:
        mov rdi, rcx
        mov rsi, r10 ; przeniesienie argumentów dla iteracji
        mov rdx, r11
        push rcx
        push r10
        push r11
        sub rsp, 8
        call iteracja
        add rsp, 8 ; wyrównanie stosu
        pop r11
        pop r10
        pop rcx
        mov rdi, rcx
        mov rsi, r10
        dec rsi ; bo sprawdzamy k-1 liczb 
        mov rdx, r11 ; przenoszenie argumentów dla check_if_zero
        push rcx
        push r10
        push r11
        sub rsp, 8
        call check_if_zero
        add rsp, 8
        pop r11
        pop r10
        pop rcx
        cmp rax, 0
        je main_exit
        ; tutaj jesteśmy jeśli nie ma samych zer
        dec r10 ; zmniejszamy n bo mniej liczb rozważamy już
        inc rbx ; zwiększamy counter pętli
        cmp r10, 1 ; jeśli zero to kończymy
        jne main_loop
    

    main_exit:
        mov rax, rbx
        pop rbx
        ret
