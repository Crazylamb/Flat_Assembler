format PE console
entry start
include 'win32a.inc'

section '.idata' import data readable writeable
    library kernel32, 'kernel32.dll', \
        msvcrt, 'MSVCRT.DLL'

    import kernel32, \
        ExitProcess, 'ExitProcess'

    import msvcrt, \
        printf, 'printf', \
        scanf, 'scanf', \
        getch, '_getch'

section '.data' data readable
    szEnterNum db 'Please enter a valid number: ',0
    szNumFormat db '%d',0
    szPrime db 'Confirmed! %d is prime!',0
    szNotPrime db 'Well, %d is not prime!',0

section '.bss' data readable writeable
    ddNum rd 1
    ddSqrt rd 1

section '.text' code readable executable
    start:
        push szEnterNum
        call [printf]
        add esp, 4

        push ddNum
        push szNumFormat
        call [scanf]
        add esp, 8


        cmp [ddNum], 1
        je notPrime
        cmp [ddNum], 2
        je isPrime
        cmp [ddNum], 3
        je isPrime


        clc
        mov ebx, [ddNum]
        shr ebx, 1
        jb checkIfPrime
        jmp notPrime

    checkIfPrime:
        fild [ddNum]
        fsqrt
        fist [ddSqrt]
        
        mov ebx, 3
        loopPrime:
            mov eax, [ddNum]
            cdq
            idiv ebx
            cmp edx, 0
            je notPrime
            cmp ebx, [ddSqrt]   
            jg isPrime
            inc ebx
            jmp loopPrime

    notPrime:
        push [ddNum]
        push szNotPrime
        call [printf]
        add esp, 8
        jmp exit

    isPrime: 
        push [ddNum]
        push szPrime
        call [printf]
        add esp, 8

    exit:
        call [getch]
        push 0
        call [ExitProcess]