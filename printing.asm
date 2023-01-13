;this file contains things related to printing and the console

global handle
global strprintf
global intprintf
global charprintf
global floatprintf

global print
global printLineBreak
global printDigit
global printInt
global printf
global isNumber
global stof
global floorFloat
global printFloatFrac
global fracFloat


extern  _GetStdHandle
extern  _WriteConsoleA
extern  _ReadConsoleA

section .data
    ;printing numbers
	temp: dd 0                          ;(int) temporary number for printInt
	numberPrintIterations: db 0         ;(char) iterations of printing a number
	numberPrintArr: times 10 db 0       ;(char[10]) array of bytes containing a string of numbers (0x0-BASE)

	;stof stuff
	stofIntPart: times 16 db 0
	stofFracPart: times 16 db 0
	stofDebugMessage: db "%c%s.%s", 0xa, 0

	;definitions for printf
	strprintf: db "%s", 0
	intprintf: db "%i", 0
	charprintf: db "%c", 0
	floatprintf: db "%f", 0

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

	;floors the float stored in st0
	floorFloat:
		;register preservation
		push 	eax

		;int floored = 0;
		push	0

		;float half (st0) = 0.499999999;  //0.5 exactly would cause errors (int)(0.5) = 1 because it rounds up for 0.5
		push	0x3effffff
		fld		dword [esp+0] 	
		pop		eax

		;by here, st0 = 0.5; st1 = input;

		fsubp	st1				;st0 = st1 - st0; delete st1;
		fistp	dword [esp+0]	;floored = (int)input; delete st0
		fild	dword [esp+0]	;st0 = (float)floored;
		pop		eax				;delete floored;

		;register preservation
		pop		eax

		ret

	;strips the integer part from the float in st0
	fracFloat:
		;register preservation
		push	eax

		
		;clones st0 into st0 and st1
		push	0
		fst		dword [esp+0]
		fld		dword [esp+0]
		pop		eax

		;st0 = Math.floor(st0);
		call	floorFloat

		fsubp	st1

		;register preservation
		pop		eax

		ret

	;prints the 0-1 single precision floating point number stored in ecx
	printFloatFrac:
		;register preservation
		push 	eax
		push	ebx

		;int intTemp = 0;
		push	0

		; float temp = ecx;
		push	ecx
		fld		dword [esp+0]
		pop		eax

		;i=0;
		mov		ebx, 0

		loop7:
			;temp *= 10;
			push	10				;int ten = 10;
			fild	dword [esp+0]	;float floatTen = 10; (st0 = 10; st1 = temp)
			pop 	eax				;delete ten;
			fmulp	st1				;temp *= floatTen; delete floatTen;


			;int originalTemp = temp; //its a float but float definitions use fpu stuff so imma store this as an int
			push	0
			fst		dword [esp+0]


			;temp = Math.floor(temp);
			call	floorFloat

			;intTemp = (int)temp; delete temp;
			fistp	dword [esp+4]

			;float temp = (float)originalTemp; delete originalTemp;
			fld		dword [esp+0]
			pop		eax


			;printDigit(intTemp);
			mov		ecx, [esp+0]	;intTemp
			call	printDigit


			;temp -= intTemp;
			fild	dword [esp+0]	;float floatIntTemp = intTemp; (st0 = intTemp; st1 = temp)
			fsubp	st1				;temp -= floatIntTemp; delete floatIntTemp
			

			continue7:
				;i++;
				inc 	ebx

				;if(i < 16) loop();
				cmp		ebx, 16
				jl		loop7

		fstp	dword [esp+0]

		;delete intTemp
		pop		eax

		;register preservation
		pop		ebx
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

				if11:	;if(currentChar == 'f')
					cmp		byte [esp+0], "f"	;currentChar
					jne		else11

					mov		ecx, esp
					add		ecx, 16			;preserving registers
					add		ecx, 16			;local variables
					add		ecx, [esp+12]	;currentInputArgLocation
					mov		ecx, [ecx]

					;int num = ecx; //its actually a float but floats do fpu stuff
					push	ecx

					;integer part
						;int intPart = 0;
						push	0

						fld		dword [esp+4]	;st0 = num;
						call	floorFloat		;st0 = Math.floor(st0);
						fistp	dword [esp+0]	;intPart = (int)st0; delete st0;

						pop		ecx				;ecx = intPart; delete intPart;
						mov		edx, 10			;base
						call	printInt		;print


					;the dot part
						push	"."
						mov		ecx, esp
						mov		edx, 1
						call	print
						pop		edx


					;fractional part
						fld		dword [esp+0]	;st0 = num;

						call	fracFloat		;st0 = st0 - Math.floor(st0);

						;ecx = st0; delete st0;
						push	0
						fstp	dword [esp+0]
						pop		ecx

						call	printFloatFrac
					
					;delete num;
					pop		edx
				else11:

				;percent
				if12:
					cmp		byte [esp+0], "%"	;currentChar
					jne		else12

					push 	"%"
					
					mov		ecx, esp
					mov		edx, 1
					call 	print

					pop 	ecx

					;this one doesnt depend on an arg, so just undo it
					sub		dword [esp+12], 4 	;currentInputArgLocation

				else12:


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

        ret 

	;bool isNumber(char input)
	isNumber:
		mov 	eax, 0

		if14:	;if(input >= 48)
			cmp		byte [esp+4], 48	;input
			jl		else14

			if15:	;if(input <= 57)
				cmp		byte [esp+4], 57	;input
				jg		else15

				mov 	eax, 1

			else15:

		else14:

		ret 	4
	
	;int charToNum(char input)
	charToNum:
		xor		eax, eax
		mov 	al, [esp+4]
		sub 	eax, "0"

		ret 	4

	;implimentation of the libc stof function (string to float)
	;float stof(char* str)
	stof:
		;preserving registers
		push 	eax
		push 	ebx
		push 	ecx
		push 	edx
		
		;bool isNegative = false;
			push 	0
		
		;int pointLocation = 127
			push 127
		
		;int numbersStart = 0;
			push 0
		
		;int placeValue = 1;
			push 1

		;char currentChar = str[0]
			mov		eax, [esp+16+16+4]	;16 for register preservation, 16 for local variables, 4 for arg location
			push 	dword [eax]


		if16:	;if(currentChar == '+')
			cmp		byte [esp+0], "+"	;currentChar
			jne		else16

			mov 	dword [esp+8], 1	;numbersStart

		else16:

		if17:	;if(currentChar == '-')
			cmp		byte [esp+0], "-"	;currentChar
			jne		else17

			mov 	dword [esp+8], 1	;numbersStart

			mov		dword [esp+16], 1	;isNegative

		else17:

		;this loop splits the string into stofIntPart and stofFracPart
		
		;i = numbersStart
		mov 	ebx, [esp+8]	;numberStart

		loop4:
            ;currentChar = str[ebx];
            mov     ecx, [esp+16+20+4]	;16 for register preservation, 20 for local variables, 4 for arg location
            add     ecx, ebx
			mov		ecx, [ecx]
            mov     [esp+0], ecx		;currentChar

			if18:	;if(currentChar == '.')
				cmp		byte [esp+0], "."	;currentChar
				jne		else18

				if19:	;if(pointLocation == 127)
					cmp		dword [esp+12], 127	;pointLocation
					jne		else19

					mov		[esp+12], ebx

					jmp 	continue4

				else19:

			else18:

			;eax = isNumber(currentChar);
			push	dword [esp+0]		;currentChar
			call	isNumber

			if20:	;if(eax == 0)
				cmp		eax, 0
				jne		else20

				;break;
				jmp 	break4

			else20:

			if21:	;if(pointLocation > i)
				cmp 	ebx, [esp+12]		;pointLocation
				jle 	else21

				;fracPart[i-pointLocation-1] = currentChar;
				mov 	ecx, stofFracPart
				add 	ecx, ebx
				sub 	ecx, [esp+12]		;pointLocation
				sub 	ecx, 1
				mov		edx, dword [esp+0]	;currentChar
				mov		[ecx], dl

			else21:

			if22:	;if(pointLocation <= i)
				cmp 	ebx, [esp+12]		;pointLocation
				jg 		else22

				;intPart[i-numbersStart] = currentChar;
				mov 	ecx, stofIntPart
				add 	ecx, ebx
				sub 	ecx, [esp+8]		;numbersStart
				mov		edx, dword [esp+0]	;currentChar
				mov		[ecx], dl

			else22:

            continue4:
                ; i++;
				inc 	ebx
				
				; if(i < 32) loop();
				cmp 	ebx, 32
				jl		loop4

			break4:


		;float evaluated = 0;
		push 	0
		fild 	dword [esp+0]
		pop 	eax

		;integer part evaluation

		;i = 15
		mov 	ebx, 15
		
		loop5:
			;currentChar = stofIntPart[ebx];
            mov     ecx, stofIntPart		;stofIntPart
            add     ecx, ebx
			mov		ecx, [ecx]
            mov     [esp+0], ecx		;currentChar

			if23:	;if(currentChar == 0)
				cmp		byte [esp+0], 0	;currentChar
				jne		else23

				;continue;
				jmp		continue5

			else23:

			;eax = charToNum(currentChar)
			push	dword [esp+0] 	;currentChar
			call	charToNum

			;eax = eax*placeValue
			mul		dword [esp+4]

			;evaluated += eax;
				push 	eax
				fild	dword [esp+0]
				pop 	eax

				;by here st1 = evaluated
				;        st0 = eax

				;evaluated += eax
				faddp	st1, st0

			;placeValue *= 10
        	mov		eax, [esp+4]	;placeValue
			mov		ecx, 10
			mul		ecx
			mov		[esp+4], eax	;placeValue


            continue5:
                ; i--;
				dec 	ebx

				; if(i > 0) loop();
				cmp 	ebx, 0
				jge		loop5



		;fractional part evaluation

		;placeValue = 10
		mov		dword [esp+4], 10

		;i = 0;
		mov 	ebx, 0

		loop6:
			;currentChar = stofIntPart[ebx];
            mov     ecx, stofFracPart
            add     ecx, ebx
			mov		ecx, [ecx]
            mov     [esp+0], ecx		;currentChar

			if24:	;if(currentChar == 0)
				cmp		byte [esp+0], 0	;currentChar
				jne		else24

				;continue;
				jmp		continue6

			else24:

			;eax = charToNum(currentChar)
			push	dword [esp+0] 	;currentChar
			call	charToNum

			;evaluated += charToNum(currentChar)/placeValue;

			;load placeValue
			fild 	dword [esp+4]	;placeValue

			;load charToNum(currentChar)
			push	eax
			fild	dword [esp+0]   ;charToNum(currentChar)
			pop 	eax

			; by here, 
			; st2 = evaluated
			; st1 = placeValue
			; st0 = charToNum(currentChar)

			;do the stuff

			; st2 += st0 / st1
			fdiv	st0, st1
			faddp 	st2, st0
			
			;fdivp didnt work so i have to do this
			push 	0
			fstp	dword [esp+0]
			pop 	eax

			;placeValue *= 10
        	mov		eax, [esp+4]	;placeValue
			mov		ecx, 10
			mul		ecx
			mov		[esp+4], eax	;placeValue
			
            continue6:
                ; i++;
				inc 	ebx

				; if(i < 16) loop();
				cmp 	ebx, 16
				jl		loop6


		;sign
		if25:	;if(isNegative == true)
			cmp 	byte [esp+16], 1
			jne		else25

			;flip sign of st0
			fchs
		else25:


		;delete currentChar
		pop 	eax

		;delete placeValue
		pop 	eax

		;delete numbersStart
		pop 	eax

		;delete pointLocation
		pop 	eax

		;delete isNegative
		pop 	eax

		;register preservation
		pop 	edx
		pop 	ecx
		pop 	ebx
		pop 	eax

		;store evaluated into eax
		push 	0
		fstp	dword [esp+0]
		pop		eax

		ret 	4