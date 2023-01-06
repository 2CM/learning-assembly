global _start

;externs
extern  _ExitProcess@4
extern  _GetStdHandle@4
extern  _WriteConsoleA@20

section .data
	lineBreak: dd 0xa		;constant line break
	printTemp: dd "0"		;for printing digits

	;msg1
	msg1: dd "Hello, World"
	msg1Len: equ $-msg1

	;msg2
	msg2: dd "hehehe"
	msg2Len: equ $-msg2

	
	temp: dd 0
	numberPrintIterations: dd 0
	numberPrintString: times 10 dd 0


	;printing stuff
	handle: dd 0
	written: dd 0


section .text
	;exits from the program
	exit: 
        ; ExitProcess(0)
        push    dword 0
        call    _ExitProcess@4

	;prints *ecx with length edx
	print:
		; handle = GetStdHandle(-11)
		push    -11
        call    _GetStdHandle@4
        mov     [handle], eax

		; WriteConsole(handle, &msg[0], length, &written, 0)
        push    0
        push    written				;chars written
		push 	edx 			;length
        push    ecx					;message location
        push    dword [handle]
        call    _WriteConsoleA@20

		ret

	;prints a line break
	printLineBreak:
		mov 	edx, 1			;length of 1
		mov		ecx, lineBreak	;\n
		call	print

		ret

	;prints the digit stored in ecx
	printDigit:
		mov 	edx, [printTemp]
		add		edx, ecx
		mov		[printTemp], edx
		mov		ecx, printTemp
		mov 	edx, 1
		call 	print
		mov 	dword [printTemp], "0"	;clear it for next time

		ret
	;prints the integer stored in ecx
	printInt:
		; if(ecx == 0) {
		; 	print("0");
		; }
		; 
		; temp = ecx;
		;
		; void recur() {
		;	divided = Math.floor(temp / 10);
		; 	remainder = temp % 10;
		; 	
		; 	temp = divided;
		; 
		; 	numberPrintString[9 - numberPrintIterations] = remainder;
		; 	
		; 	numberPrintIterations++;
		; 
		; 	if(temp > 0) recur();
		; }
		; 
		; 
		; i = 0;
		; 
		; void loop() {
		; 	ecx = numberPrintString[i];
		;	
		; 	if(foundFirstDigit == false) {
		; 	    if(digit != 0) {
		; 	        foundFirstDigit = true;
		; 	    } else {
		; 	        continue; 
		; 	    }
		; 	}
		;	
		; 	print(ecx);
		;
		;	i++;
		;	if(i < 10) loop();
		; }

		; if(ecx == 0) {
		; 	printDigit(ecx);
		; }
		if1:
			cmp		ecx, 0
			jne		else1

			call	printDigit

			ret
		else1:

		; temp = ecx
		mov 	[temp], ecx

		recur:
			; divided = Math.floor(temp / 10)
			; remainder = temp % 10
			mov		edx, 0		;clear edx so division isnt weird
			mov 	eax, [temp]	;num to divide
			mov 	ebx, 10		;what to divide it by
			div 	ebx			;divide it


			; temp = divided
			mov 	[temp], eax


			; numberPrintString[9 - numberPrintIterations] = remainder;
			; *( &numberPrintString + 9 - numberPrintIterations ) = remainder; 
				;0000000000
				;0000000007
				;0000000037
				;0000000137
			mov		ecx, numberPrintString+9
			mov 	ebx, [numberPrintIterations]
			sub		ecx, ebx
			mov 	[ecx], dl


			; numberPrintIterations++;
			mov 	eax, [numberPrintIterations]
			inc		eax
			mov		[numberPrintIterations], eax


			; if(temp > 0) recur();
			mov 	eax, [temp]
			cmp		eax, 0
			jg		recur
		;

		; i = 0;
		mov 	ebx, 0
		mov 	eax, 0

		loop:
			; ecx = numberPrintString[i];
			; ecx = *( &numberPrintString + i );
			mov 	ecx, numberPrintString
			add		ecx, ebx
			mov		ecx, [ecx]

			; if(foundFirstDigit == false) {
			;     if(digit != 0) {
			;         foundFirstDigit = true;
			;     } else {
			;         continue; 
			;     }
			; }
			if2: ;if(foundFirstDigit == false)
				cmp		al, 0
				jne		else2

				if3: ;if(digit != 0)
					cmp 	cl, 0
					je 		else3

					mov 	eax, 1
				else3: ;else
					cmp 	cl, 0
					jne 	else2

					jmp 	continue
			else2: ;else

			
			; print(ecx);
			call	printDigit



			continue:
				; i++;
				inc 	ebx
				
				; if(i < 10) loop();
				cmp 	ebx, 10
				jl		loop
		;

		;cleaning up
		mov		dword [numberPrintIterations], 0

		mov		dword [numberPrintString+0], 0
		mov		dword [numberPrintString+1], 0
		mov		dword [numberPrintString+2], 0
		mov		dword [numberPrintString+3], 0
		mov		dword [numberPrintString+4], 0
		mov		dword [numberPrintString+5], 0
		mov		dword [numberPrintString+6], 0
		mov		dword [numberPrintString+7], 0
		mov		dword [numberPrintString+8], 0
		mov		dword [numberPrintString+9], 0

		ret

	
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

		ret

	;entry
	_start:
		push 	34
		push 	23
		push	12
		call	printStuff

		;print msg1
		mov 	edx, msg1Len
		mov		ecx, msg1
		call	print
		call	printLineBreak

		push 	67
		push 	56
		push	45
		call	printStuff

		;print msg2
		mov 	edx, msg2Len
		mov		ecx, msg2
		call	print
		call 	printLineBreak

		;print the num
		mov		ecx, 10000
		call	printInt
		call 	printLineBreak


		push 	90
		push 	89
		push	78
		call	printStuff

		;exit
		call 	exit