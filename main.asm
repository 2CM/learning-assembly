;needed for linker
global _start

;export variables
global heapHandle
global handle
global written

;kernel32.dll
extern _ExitProcess
extern _GetStdHandle
extern _ReadConsoleA


;printing.asm
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

;LinkedList.asm
extern LinkedListConstruct
extern LinkedListPush
extern LinkedListPrint
extern LinkedListGetNode
extern LinkedListGetData
extern LinkedListSetData
extern LinkedListDeconstruct

section .data
	;handle for the heap
	heapHandle: dd 0

	;printing stuff
	handle: dd 0
	written: dd 0

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

	;inputting
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
		
		;linked list testing vvv

		;create it
			;LinkedList* list = LinkedListConstruct();
			call	LinkedListConstruct
			push	eax
		
		;print it
			;LinkedListPrint(list)
			push	dword [esp+0] 		;list
			call	LinkedListPrint

		;add elements
			;LinkedListPush(list, 6)
			push	6
			push	dword [esp+4]		;list (4 because arg before it)
			call 	LinkedListPush

			;LinkedListPush(list, 1)
			push	1
			push	dword [esp+4]		;list (4 because arg before it)
			call 	LinkedListPush

			;LinkedListPush(list, 1000)
			push	1000
			push	dword [esp+4]		;list (4 because arg before it)
			call 	LinkedListPush


		;print it again
			;LinkedListPrint(list)
			push	dword [esp+0] 		;list
			call	LinkedListPrint


		;get data at location and print
			;eax = LinkedListGetData(list, 3)
			push	2						;location
			push	dword [esp+4]			;list (4 because arg before it)
			call	LinkedListGetData

			;printf("%i\n", eax)
			push 	eax
			push	intprintf
			call	printf
			pop		ebx
			pop		ebx
			call	printLineBreak


		;set data at location
			;eax = LinkedListGetData(list, 3)
			push	500						;new data
			push	2						;location
			push	dword [esp+8]			;list (8 because arg before it)
			call	LinkedListSetData


		;get data at location and print (again)
			;eax = LinkedListGetData(list, 3)
			push	2						;location
			push	dword [esp+4]			;list (4 because arg before it)
			call	LinkedListGetData

			;printf("%i\n", eax)
			push 	eax
			push	intprintf
			call	printf
			pop		ebx
			pop		ebx
			call	printLineBreak

		;deconstruct it
			push	dword [esp+0]
			call	LinkedListDeconstruct


		;print it again again
			;LinkedListPrint(list)
			push	dword [esp+0] 		;list
			call	LinkedListPrint


		call	exit



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