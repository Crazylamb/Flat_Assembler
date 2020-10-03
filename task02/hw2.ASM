;ввести массив, получить массив В элементов A, значение которых не совпадает с введённым числом x
;5 вариант
Format PE Console

entry start

include 'win32ax.inc'

section '.data' data readable writable
        strArrayLength db 'Enter the length of array: ', 0
        strIncorrectArraySize db 'The size is incorrect', 0
        strXValue db 'Enter X value: ' , 0
        space db ' %d', 0
        space_norm db ' ', 0
        strInput db 'A[%d] = ', 0
        strOutputElem    db 'B[%d] = %d ', 10, 0
        strOutputElemA    db 'A[%d] = %d ', 10, 0
        newLine          db '', 10, 0
        strOutputArrayB   db 'Array B: ', 10, 0
        strOutputArrayA   db 'Array A: ', 10, 0

        x dd 0
        array_length dd 0
        Array_A rd 1000
        Array_B rd 1000
        temp dd ?
        tmpStack dd ?
        i dd ?
        j dd 0
        k dd 0

        NULL = 0

section '.code' readable executable

        start:
                call Make_Array
                call Make_B
                call PrintArrayA
                call PrintArrayB

        finish:
                call [getch]

                push NULL
                call [ExitProcess]


;---------------------
proc        Make_Array
                push strArrayLength
                call[printf]
                add esp, 4
                push array_length
                push space
                call [scanf]
                add esp, 8
                mov eax, [array_length]
                cmp eax, 0
                jg fillArray
;if incorrect
                push strIncorrectArraySize
                call [printf]
                jmp finish


        fillArray:
                xor ecx, ecx
                mov ebx, Array_A

        Fill_Array_Loop:
                mov [temp], ebx
                cmp ecx,[array_length]
                jge endInput
                mov [i], ecx
                push ecx
                push strInput
                call[printf]
                add esp, 8
                push ebx
                push space
                call [scanf]
                add esp,8
                mov ecx, [i]
                inc ecx
                mov ebx, [temp]
                add ebx, 4
                jmp Fill_Array_Loop

        endInput:
                ret
endp

;---------------------
proc        Make_B
                push strXValue
                call[printf]
                add esp, 4
                push x
                push space
                call[scanf]
                add esp, 8
                mov edx, Array_A
                mov ecx, Array_B
                xor esi, esi

        getArrayBLoop:
                        cmp esi, [array_length]
                        je endGetArrayB
                        inc esi
                        mov ebx, edx ;******************
                mov eax ,dword [ebx]
                        cmp [x], eax
                        je incNum
                        inc [j]
                        mov [ecx], eax
                        add edx, 4
                        add ecx, 4
                        jmp getArrayBLoop

        incNum:
        add edx, 4
        jmp getArrayBLoop

        endGetArrayB:
                ret
endp
;-------------------------------------------------

proc       PrintArrayB
                push newLine
                call [printf]
                add esp, 4

                push strOutputArrayB
                call [printf]
                add esp, 4

                mov [tmpStack], esp
                xor ecx, ecx
                mov edx, Array_B

        printArrayBLoop:
                mov [temp], edx
                cmp ecx, [j]
                je endPrint

                mov [i], ecx

                push dword [edx]
                push ecx
                push strOutputElem
                call [printf]

                mov ecx, [i]
                inc ecx
                mov edx, [temp]
                add edx, 4
                jmp printArrayBLoop

        endPrint:
                mov esp, [tmpStack]
                ret
 endp
;-------------------------------------------------
proc       PrintArrayA
                push newLine
                call [printf]
                add esp, 4

                push strOutputArrayA
                call [printf]
                add esp, 4

                mov [tmpStack], esp
                xor ecx, ecx
                mov edx, Array_A

        printArrayALoop:
                mov [temp], edx
                cmp ecx, [array_length]
                je endPrintA

                mov [i], ecx

                push dword [edx]
                push ecx
                push strOutputElemA
                call [printf]

                mov ecx, [i]
                inc ecx
                mov edx, [temp]
                add edx, 4
                jmp printArrayALoop

        endPrintA:
                mov esp, [tmpStack]
                ret
 endp
;-------------------------------------------------


section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
        ExitProcess, 'ExitProcess'

        import msvcrt,\
        printf, 'printf',\
        scanf, 'scanf',\
        getch, '_getch'
