global _start


extern _ExitProcess
extern _GetStdHandle
extern _ReadConsoleA


extern handle
extern strprintf
extern intprintf
extern floatprintf

extern printFloatFrac
extern floorFloat
extern fracFloat
extern stof
extern print
extern printLineBreak
extern printDigit
extern printInt
extern printf

section .data
	;msg1
	msg1: db "Hello, World", 0
	msg1Len: equ $-msg1

	;msg2
	msg2: db "hehehe", 0
	msg2Len: equ $-msg2

	;printf testing
	printfmessage: db "My name is %s, I was born on %s %i, %i, and I like %s. Type 15%% of 100 is 15. The best letter is %c, and pi is about %f.", 0xa, 0xa, 0
	myname: db "Iain", 0
	mybirthmonth: db "January", 0
	mybirthday: dd 1
	mybirthyear: dd 1970
	myinterests: db "to code and play video games :)", 0
	mychar: db "h"
	mypi: dd 0x40490fdb		;floating point value

	inputPrompt: db "Please input a number.", 0xa, 0
	inputResult: db "You input %i byte(s) (CRLF at the end.)", 0xa, "The string you input was %s", 0xa, "Your input converted to a float is %f.", 0xa, 0

	charsRead: dd 0
	inputBuffer: times 32 db 0

section .text
	;exits from the program
	exit: 
        ;ExitProcess(0)
        push    dword 0
        call    _ExitProcess

	printStuff:
		mov 	ecx, [esp+4]
		call 	printInt
		call 	printLineBreak

		mov 	ecx, [esp+8]
		call 	printInt
		call 	printLineBreak

		mov 	ecx, [esp+12]
		call 	printInt
		call 	printLineBreak

		ret 	12

	;entry
	_start:
		;print msg1
		mov 	edx, msg1Len
		mov		ecx, msg1
		call	print
		call	printLineBreak


		;print msg2
		mov 	edx, msg2Len
		mov		ecx, msg2
		call	print
		call 	printLineBreak


		;print a num
		mov		ecx, 874651
		mov		edx, 10
		call	printInt
		call 	printLineBreak


		;printf(&printfmessage, &myname, &mybirthmonth, mybirthday, mybirthyear, mychar)
		push	dword [mypi]
		push	dword [mychar]
		push	myinterests
		push 	dword [mybirthyear]
		push 	dword [mybirthday]
		push 	mybirthmonth
		push 	myname
		push 	printfmessage
		call 	printf

		;prompt user for input
		push	inputPrompt
		call	printf

		;read input
			;handle = GetStdHandle(-10)
			push    -10
			call    _GetStdHandle
			mov     [handle], eax


			;ReadConsole(handle, &inputBuffer, 32, charsRead, NULL)
			push 	0
			push 	charsRead
			push 	32
			push 	inputBuffer
			push 	dword [handle]
			call 	_ReadConsoleA

		;print results
		push	inputBuffer			;eax = stof(inputBuffer)
		call 	stof				;^
		push	eax					;^
		push	inputBuffer			;text inputted
		push	dword [charsRead]	;length of input (plus CRLF)
		push	inputResult
		call	printf

		;exit
		call 	exit