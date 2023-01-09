global handle

global print
global printLineBreak
global printDigit
global printInt
global printf


extern  _GetStdHandle
extern  _WriteConsoleA
extern  _ReadConsoleA

section .data
    ;printing numbers
	temp: dd 0                          ;(int) temporary number for printInt
	numberPrintIterations: db 0         ;(char) iterations of printing a number
	numberPrintArr: times 10 db 0       ;(char[10]) array of bytes containing a string of numbers (0x0-BASE)

	;printing stuff
	handle: db 0
	written: db 0

section .text
	;prints *ecx with length edx
	print:
		;preserving registers
		push	eax
		push 	ebx

		;handle = GetStdHandle(-11)
		push    -11
        call    _GetStdHandle
        mov     [handle], eax

		;WriteConsole(handle, &msg[0], length, &written, 0)
        push    0
        push    written				;chars written
		push 	edx 				;length
        push    ecx					;message location
        push    dword [handle]
        call    _WriteConsoleA

		;preserving registers
		pop 	ebx
		pop 	eax

		ret

	;prints a line break
	printLineBreak:
		;preserving registers
		push 	ecx
		push 	edx

		;char lineBreak = '\n'
		push 	0xa				;\n
		
		mov		ecx, esp+0		;ecx = &lineBreak
		mov 	edx, 1			;length of 1
		call	print

		;delete lineBreak
		pop 	edx

		;preserving registers
		pop 	edx
		pop		ecx

		ret

	;prints the digit stored in ecx
	printDigit:
		;preserving registers
		push 	edx

		;char digit = '0';
		push 	"0"

		add		dword [esp+0], ecx	;digit += ecx

		if0:
			cmp 	cl, 10
			jl 		else0

			add		dword [esp+0], 39
		else0:

		mov		ecx, esp			;ecx = &digit
		mov 	edx, 1				;length of 1
		call 	print

		;delete digit
		pop		edx

		;preserving registers
		pop 	edx

		ret
        
	;prints the integer stored in ecx in base edx
	printInt:
		;perserving registers
		push 	eax
		push	ebx
		push 	ecx
		push 	edx

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
		; 	numberPrintArr[9 - numberPrintIterations] = remainder;
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
		; 	ecx = numberPrintArr[i];
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



		if1:
			cmp		ecx, 0
			jne		else1

			call	printDigit

			;preserving registers
			pop		edx
			pop 	ecx
			pop 	ebx
			pop 	eax

			ret
		else1:

		; temp = ecx
		mov 	[temp], ecx

		;int base = edx
		push 	edx

		recur:
			; divided = Math.floor(temp / 10)
			; remainder = temp % 10
			mov		edx, 0		;clear edx so division isnt weird
			mov 	eax, [temp]	;num to divide
			mov 	ebx, [esp+0]		;what to divide it by
			div 	ebx			;divide it


			; temp = divided
			mov 	[temp], eax


			; numberPrintArr[9 - numberPrintIterations] = remainder;
			; *( &numberPrintArr + 9 - numberPrintIterations ) = remainder; 
				;0000000000
				;0000000007
				;0000000037
				;0000000137
			mov		ecx, numberPrintArr+9
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

		loop1:
			; ecx = numberPrintArr[i];
			; ecx = *( &numberPrintArr + i );
			mov 	ecx, numberPrintArr
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

					jmp 	continue1
			else2: ;else

			
			; print(ecx);
			call	printDigit



			continue1:
				; i++;
				inc 	ebx
				
				; if(i < 10) loop();
				cmp 	ebx, 10
				jl		loop1
		;

		;cleaning up
		mov		dword [numberPrintIterations], 0

		;im so sorry
		mov		dword [numberPrintArr+0], 0
		mov		dword [numberPrintArr+1], 0
		mov		dword [numberPrintArr+2], 0
		mov		dword [numberPrintArr+3], 0
		mov		dword [numberPrintArr+4], 0
		mov		dword [numberPrintArr+5], 0
		mov		dword [numberPrintArr+6], 0
		mov		dword [numberPrintArr+7], 0
		mov		dword [numberPrintArr+8], 0
		mov		dword [numberPrintArr+9], 0

		;delete base
		pop 	edx

		;perserving registers
		pop		edx
		pop 	ecx
		pop 	ebx
		pop 	eax

		ret

	;strlen(char* str)
    strlen:
		;register preservation
		push	 ebx
		push	 ecx

		;char currentChar = 'x';
		push	"x"

		mov 	ebx, 0

		loop2:
			;currentChar = [str+ebx];
            mov     ecx, [esp+8+4+4]	;8 for register preservation, 4 for local variables, 4 for arg location
            add     ecx, ebx
			mov		ecx, [ecx]
            mov     [esp+0], ecx

			if4:	;if(currentChar == 0x0)
				cmp		byte [esp+0], 0x0
				jne		else4

				jmp 	break2
			
			else4:

			continue2:
                ; i++;
				inc 	ebx

				; if(i < 1000) loop();
				cmp 	ebx, 1000
				jl		loop2
			
			break2:


		mov		eax, ebx

		;delete currentChar
		pop		ebx

		;preserving registers
		pop		ecx
		pop 	ebx

		ret	4

    ;recreation of printf but its worse and its in asm
	printf:
		;printf(char* str)

		;perserving registers
		push	eax
		push 	ebx
		push 	ecx
		push 	edx


		;int currentInputArgLocation = 4;
			push	4


		;bool primedForType = 0;
        	push    0


		;int stringLength = strlen(&str);
			;eax = strlen(&str);
			push    dword [esp+16+8+4]		;16 for register preservation, 8 for local variables, 4 for arg location
			call    strlen
			push 	eax


		;char currentChar = 'x';
        	push    "x"


        mov     ebx, 0		;i

        loop3:
            ;currentChar = [str+ebx];
            mov     ecx, [esp+16+16+4]	;16 for register preservation, 16 for local variables, 4 for arg location
            add     ecx, ebx
			mov		ecx, [ecx]
            mov     [esp+0], ecx	;currentChar

			if5:	;if(primedForType == true)
				cmp		dword [esp+8], 1	;primedForType
				jne		else5

				add		dword [esp+12], 4 	;currentInputArgLocation


				;integer
				if7:	;if(currentChar == 'i')
					cmp		byte [esp+0], "i"	;currentChar
					jne		else7

					;ecx = [esp+[preserving registers size]+[local variables size]+currentInputArgLocation]
					mov		ecx, esp
					add		ecx, 16			;preserving registers
					add		ecx, 16			;local variables
					add		ecx, [esp+12]	;currentInputArgLocation
					mov		ecx, [ecx]

					mov 	edx, 10

					call	printInt

				else7:

				;hex
				if8:	;if(currentChar == 'x')
					cmp		byte [esp+0], "x"	;currentChar
					jne		else8

					;ecx = [esp+[preserving registers size]+[local variables size]+currentInputArgLocation]
					mov		ecx, esp
					add		ecx, 16			;preserving registers
					add		ecx, 16			;local variables
					add		ecx, [esp+12]	;currentInputArgLocation
					mov		ecx, [ecx]

					mov 	edx, 16

					call	printInt

				else8:

				;string
				if9:	;if(currentChar == 's')
					cmp		byte [esp+0], "s"	;currentChar
					jne		else9

					;ecx = [esp+[preserving registers size]+[local variables size]+currentInputArgLocation]
					mov		ecx, esp
					add		ecx, 16			;preserving registers
					add		ecx, 16			;local variables
					add		ecx, [esp+12]	;currentInputArgLocation
					mov		ecx, [ecx]
					
					;preserve ebx and ecx
					push 	ebx
					push 	ecx
					
					;eax = strlen(&ecx)
					push	dword ecx
					call 	strlen

					mov 	edx, eax
					pop 	ecx
					call	print

					pop 	ebx

				else9:

				;char
				if10:	;if(currentChar == 'c')
					cmp		byte [esp+0], "c"	;currentChar
					jne		else10

					;ecx = [esp+[preserving registers size]+[local variables size]+currentInputArgLocation]
					mov		ecx, esp
					add		ecx, 16			;preserving registers
					add		ecx, 16			;local variables
					add		ecx, [esp+12]	;currentInputArgLocation

					mov 	edx, 1

					call 	print

				else10:

				;percent
				if11:
					cmp		byte [esp+0], "%"	;currentChar
					jne		else11

					push 	"%"
					
					mov		ecx, esp
					mov		edx, 1
					call 	print

					pop 	ecx

					;this one doesnt depend on an arg, so just undo it
					sub		dword [esp+12], 4 	;currentInputArgLocation

				else11:


				;primedForType = false;
				mov		dword [esp+8], 0	;primedForType

				;continue;
				jmp		continue3
			
			else5:

			if6:	;if(currentChar == '%')
				cmp		byte [esp+0], "%"	;currentChar
				jne		else6

				;primedForType = true;
				mov		dword [esp+8], 1	;primedForType

				;continue;
				jmp		continue3

			else6:
	

            mov     edx, 1
            mov     ecx, esp+0
        	call    print


            continue3:
                ; i++;
				inc 	ebx
				
				; if(i < 10) loop();
				cmp 	ebx, [esp+4]
				jl		loop3

		;delete currentChar
		pop 	edx

		;delete stringLength
		pop 	edx

		;delete primedForType
		pop		edx

		;delete nextInputArgLocation
		pop		edx

		;perserving registers
		pop		edx
		pop 	ecx
		pop 	ebx
		pop 	eax

		;TODO: delete args

        ret 	4
