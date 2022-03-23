section .bss

section .text
global check_if_zero:
check_if_zero:
; rdi to tablica tablic, które mamy sprawdzić
; rsi to ich liczba
; rdx to liczba elementów każdej
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


section .data
