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

extern LinkedListElementPrintString

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

	seperator: db "--------------", 0xa, 0

	;inputting
	inputPrompt: db "Please input a number.", 0xa, 0
	inputResult: db "You input %i byte(s) (CRLF at the end.)", 0xa, "The string you input was %s", 0xa, "Your input converted to a float is %f.", 0xa, 0
	charsRead: dd 0
	inputBuffer: times 32 db 0

	linkedListInputPrompt: db "Input a number to be put in the linked list. (q = quit)", 0xa, 0

section .text
	;exits from the program
	exit: 
        ;ExitProcess(0)
        push    dword 0
        call    _ExitProcess

	userInputPrompt:
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
		pop		eax					;delete args
		pop		eax					;^
		pop		eax					;^

		ret

	testLinkedList:
		;LinkedList* numbersList = new LinkedList();
		call	LinkedListConstruct
		push	eax
		
		;float numberInput = 0;
		push	0

		mov		byte [LinkedListElementPrintString+1], "f"

		;while(true)
		promptAddToArr:
			;prompt user for input
			push	linkedListInputPrompt
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

			;stop asking for input if q is the input
			cmp		byte [inputBuffer], "q"
			je		stopAsking

			;numberInput = stof(inputBuffer);
			push	inputBuffer
			call 	stof
			mov		dword [esp+0], eax

			;LinkedListPush(numbersList, numberInput)
			push	dword [esp+0]		;numberInput
			push	dword [esp+4+4]		;numbersList (4 because arg offset)
			call	LinkedListPush

			;LinkedListPrint(numbersList)
			push	dword [esp+4]		;numbersList
			call	LinkedListPrint

			jmp		promptAddToArr

			stopAsking:

		;delete numberInput; (from the stack)
		pop		eax

		push	dword [esp+0]
		call	LinkedListDeconstruct
		
		pop		eax

		ret

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
		

		;testing stuff
		; call	userInputPrompt


		;seperate sections ------------
		push	seperator
		call	printf


		;testing more stuff
		call	testLinkedList


		;exit
		call 	exit