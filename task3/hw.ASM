format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
; Data section
section '.data' data readable writable
; User messages
msg_l      db     'Latin letters: %d', 10, 0
msg_k      db     'Cyrillic letters: %d', 10, 0
info     db     'Enter the message: ', 0
; String container
tmp db 128 dup (?)
strr      db     '%s', 0
latin    dd     0
kirill    dd     0

;--------------------------------------------------------------------------
; Main program
section '.code' code readable executable
start:
    ;Telling to enter the message
    invoke printf, info
    add esp, 4
    ;Getting the string
    invoke scanf, strr, tmp
    add esp, 8
    ;Separating latin letters from Cyrillic
    call strfindstart
    ; Output latin
    invoke printf, msg_l, [latin]
    add esp, 8
    ; Output cyrillic
    invoke printf, msg_k, [kirill]
    add esp, 8

    invoke getch
    invoke ExitProcess, 0

;--------------------------------------------------------------------------
proc strfindstart
            ;Move the string
             mov edi, tmp
             xor al,al
             xor bl, bl
        strfind:
             ;if there was last symbol the programm will finish
             cmp bl, [edi]
             je endloop
             ;push a letter to compare
             mov al, [edi]
             cmp al, 41h ;'A'
             jb testlatin2
             cmp al, 05ah ;'Z'
             ja testlatin2
             ;increase the number of latin letters
             inc [latin]
             jmp next_sym
        testlatin2:
             cmp al, 61h; 'a'
             jb testkirill1
             cmp al, 07ah; 'z'
             ja testkirill1
             ;increase the number of latin letters
             inc [latin]
             jmp next_sym
        testkirill1:
             cmp al, 80h ; 'À'
             jb testkirill2
             cmp al, 0afh ; 'ï'
             ja testkirill2
             ;increase the number of cyrillic letters
             inc [kirill]
             jmp next_sym
        testkirill2:
             cmp al, 0e0h ;'ð'
             jb next_sym
             cmp al, 0f1h ;'¸'
             ja next_sym
             inc [kirill]
             jmp next_sym

        next_sym:
             ; moving to the next symbol
             inc edi
             jmp strfind
        endloop:
                ret
endp

;--------------------------------------------------------------------------
; Including External Api
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

include 'api\kernel32.inc'

    import kernel,\
           ExitProcess, 'ExitProcess'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'