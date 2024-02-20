stseg segment para stack "stack"
    db 256 dup("stack")
stseg ends 

dseg segment para public "data"
    enter_mess db "Enter number: $"
    new_line db 0Dh, 0Ah, '$'
    num dw 0
    dump db 6, ?, 6 dup('?')
    enter_key equ 13
    err_not_digit db "Error: symbol not digit$"
    err_not_zero db "Error: dx not zero$"
    output db '+78=$'
    question db 'Would you like to continue?(y/n):$'
    header db '===Program to increase the input number by 78===$'
 dseg ends

cseg segment para public "code"
    main proc far
        assume cs:cseg, ds:dseg, ss:stseg
        push ds
        xor ax, ax
        push ax
        
        mov ax, dseg
        mov ds, ax
        
        ; header
        mov dx, offset header
        mov ah, 9
        int 21h
    
    repeat_entering:
        xor ax, ax
        
        mov [num], ax
        
        call new_line_output
        call new_line_output
        
        ; enter message
        call entering_mess 
        
        ; input
        call input_data
        
        ; get data from dump
        mov si, offset dump+2
        
        xor bx, bx
        
    convert_loop:
        mov bl, [si]
        
        cmp bl, '-'
        je push_minus
        
    cont_loop:
        
        ; check if end of line
        cmp bl, enter_key
        je end_print
        
        ; check if bl in range 0 and 9
        cmp bl, '0'
        jl not_digit
        cmp bl, '9'
        jg not_digit
        
        ; convert to int
        mov ax, 10
        mul [num]
        
        ; check if dx 0
        test dx, dx
        jo not_zero
        
        sub bl, '0'
        add ax, bx
        mov num, ax
        inc si
        jmp convert_loop
        ;jmp end_loop
        
    end_print:
        ; check if neg
        ;pop bx
        cmp cx, 1
        je convert_to_neg
        
    cont_print:    
       ; source number
        call digit
        
        ; sum
        mov ax, [num]
        add ax, 78
        mov [num], ax
        
        mov dx, offset output
        mov ah, 9
        int 21h
        
        call digit
        jmp end_loop
        
    not_zero:
        mov dx, offset err_not_zero
        mov ah, 9
        int 21h
        jmp end_loop
        
    not_digit:
        mov dx, offset err_not_digit
        mov ah, 9
        int 21h
        jmp end_loop
        
    end_loop:
        call new_line_output 
        
        ; asking for continue the program
        call continue_ques
        
        ; compare with y
        cmp al, 'y'
        jne end_prog
        jmp repeat_entering
        
    convert_to_neg:
        mov ax, [num]
        neg ax
        mov [num], ax
        jmp cont_print
        
    push_minus:
        mov cx, 1
        inc si
        mov bl, [si]
        jmp cont_loop
        ;push bx
        ;inc si
        ;mov bl, [si]
        ;jmp cont_loop
    
    end_prog:
        ret
    main endp
    
    
    new_line_output proc
        mov dx, offset new_line
        mov ah, 9
        int 21h
        ret
    new_line_output endp
    
    continue_ques proc
        mov dx, offset question
        mov ah, 9
        int 21h
        
        xor ax, ax
        
        ; fill question result
        mov ah, 01
        int 21h
        ret
    continue_ques endp
    
    entering_mess proc
        mov dx, offset enter_mess
        mov ah, 9
        int 21h 
        ret
    entering_mess endp
    
    input_data proc
        ; input
        lea dx, dump
        mov ah, 10
        int 21h
        
        ; new line
        call new_line_output
        
        ret
    input_data endp
    
    digit proc
        mov bx, num
        or bx, bx
        jns m1
        mov al, '-'
        int 29h
        neg bx
    m1:
        mov ax, bx
        xor cx, cx
        mov bx, 10
    m2:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        test ax, ax
        jnz m2
    m3:
        pop ax
        int 29h
        loop m3
        ret
    digit endp
    
cseg ends
end main