;linked list stuff

;export functions
global LinkedListConstruct
global LinkedListPush
global LinkedListPrint

;main.asm
extern heapHandle

;kernel32.dll
extern _GetProcessHeap
extern _HeapAlloc


;printing.asm
extern printf
extern intprintf


;struct LinkedList {
;   LinkedListNode* first;
;   LinkedListNode* last;
;   int32_t length;
;};

;struct LinkedListNode {
;    int32_t data;
;    LinkedListNode* next;
;};

section .data
    outOfBoundsMessage: db "out of bounds", 0xa, 0

    ;for printing it
    emptyMessage: db "[]", 0xa, 0
    listPrefix: db "(%i) [", 0
    elementSeperator: db ", ", 0
    listSuffix: db "]", 0xa, 0

section .text
    ;constructs a linked list and returns it (heap allocation)
    ;LinkedList* LinkedListConstruct()
    LinkedListConstruct:
        ;heapHandle = GetProcessHeap()
        call    _GetProcessHeap
        mov     [heapHandle], eax


        ;LinkedList* newList (eax) = HeapAlloc(heapHandle, 8, sizeof(LinkedList))
        push    dword 12            ;sizeof(LinkedList)
        push    dword 8             ;initialize to 0
        push    dword [heapHandle]  ;handle
        call    _HeapAlloc

        ;newList.first = nullptr;
        mov     dword [eax+0], 0    ;first

        ;newList.last = nullptr;
        mov     dword [eax+4], 0    ;last

        ;newList.length = 0;
        mov     dword [eax+8], 0    ;length

        ret

    ;pushes an element to a linked list
    ;void LinkedListPush(LinkedList* list, int32_t data)
    LinkedListPush:
        ;register preservation
        push    eax
        push    ebx
        push    ecx

        ;LinkedListNode* newNode;
        push    0

        ;LinkedListNode* currentLastNode;
        push    0

        ;heapHandle = GetProcessHeap()
        call    _GetProcessHeap
        mov     [heapHandle], eax

        ;newNode = HeapAlloc(heapHandle, 8, sizeof(LinkedListNode))
        push    dword 8                 ;sizeof(LinkedListNode)
        push    dword 8                 ;initialize to 0
        push    dword [heapHandle]      ;handle
        call    _HeapAlloc
        mov     dword [eax+0], 7
        mov     dword [eax+4], 0
        mov     dword [esp+4], eax

        ;newNode.data = data
        mov     eax, dword [esp+4]      ;&newNode
        add     eax, 0                  ;&newNode.data
        mov     ecx, dword [esp+8+12+8] ;data (8 for local variables, 12 for register preservation, 8 for arg location)
        mov     [eax], ecx

        ;newNode.next = nullptr
        mov     eax, dword [esp+4]      ;&newNode
        add     eax, 4                  ;&newNode.next
        mov     dword [eax], 0          ;nullptr

        ;list.length = list.length + 1;
        mov     eax, dword [esp+8+12+4] ;&list (8 for local variables, 12 for register preservation, 8 for arg location)
        add     eax, 8                  ;&list.length
        mov     ecx, [eax]              ;ecx = list.length
        inc     ecx                     ;ecx++;
        mov     [eax], ecx              ;*eax = ecx

        llif0:  ;if(list.first == nullptr)
            mov     eax, dword [esp+8+12+4]  ;list (8 for local variables, 12 for register preservation, 8 for arg location)
            add     eax, 0                   ;list.first
            mov     ecx, [eax]
            cmp     ecx, 0
            jne     llelse0

            mov     eax, eax

            ;list.first = newNode;
            mov     eax, dword [esp+8+12+4] ;&list (8 for local variables, 12 for register preservation, 4 for arg location)
            add     eax, 0                  ;&list.first
            mov     ecx, dword [esp+4]      ;newNode
            mov     [eax], ecx

            ;list.last = newNode;
            mov     eax, dword [esp+8+12+4] ;&list (8 for local variables, 12 for register preservation, 4 for arg location)
            add     eax, 4                  ;&list.last
            mov     ecx, dword [esp+4]      ;newNode
            mov     [eax], ecx

            ;return
                ;delete currentLastNode; (from the stack)
                pop     ecx

                ;delete newNode; (from the stack)
                pop     ecx

                ;register preservation
                pop     ecx
                pop     ebx
                pop     eax

                ret     8

        llelse0:


        ;currentLastNode = list->last
        mov     eax, dword [esp+8+12+4] ;&list (8 for local variables, 12 for register preservation, 4 for arg location)
        add     eax, 4                  ;&list.last
        mov     eax, [eax]              ;list.last
        mov     dword [esp+0], eax      ;currentLastNode

        llif1:  ;if(currentLastNode == nullptr)
            cmp     dword [esp+4], 0
            jne     llelse1

            ;currentLastNode = list->first
            mov     eax, dword [esp+8+12+4] ;&list (8 for local variables, 12 for register preservation, 4 for arg location)
            add     eax, 0                  ;&list.first
            mov     eax, [eax]              ;list.first
            mov     dword [esp+0], eax      ;currentLastNode

        llelse1:

        ;currentLastNode->next = newNode;
        mov     eax, dword [esp+0]      ;&currentLastNode
        add     eax, 4                  ;&currentLastNode.next
        mov     ecx, dword [esp+4]      ;newNode
        mov     [eax], ecx

        ;list.last = newNode;
        mov     eax, dword [esp+8+12+4] ;&list (8 for local variables, 12 for register preservation, 4 for arg location)
        add     eax, 4                  ;&list.last
        mov     ecx, dword [esp+4]      ;newNode
        mov     [eax], ecx

        ;return
            ;delete currentLastNode; (from the stack)
            pop     eax

            ;delete newNode; (from the stack)
            pop     eax

            ;register preservation
            pop     ecx
            pop     ebx
            pop     eax

            ret     8
    
    ;prints a linked list in javascript array form. "(5) [1, 2, 3, 4, 5]" | "[]"
    ;void LinkedListPrint(LinkedList* list)
    LinkedListPrint:
        ;register preservation
        push    eax
        push    ebx
        push    ecx

        ;LinkedList* currentNode;
        push    0

        ;currentNode = list.first
        mov     eax, dword [esp+4+12+4]     ;&list (4 for local variables, 12 for register preservation, 4 for arg location)
        add     eax, 0                      ;&list.first
        mov     eax, [eax]                  ;list.first
        mov     dword [esp+0], eax          ;currentNode

        llif2:  ;if(currentNode == nullptr)
            cmp     dword [esp+0], 0
            jne     llelse2
            
            ;printf("[]\n");
            push    emptyMessage
            call    printf
            pop     eax

            ;return
                ;delete currentNode; (from the stack)
                pop     eax

                ;register preservation
                pop     ecx
                pop     ebx
                pop     eax

                ret     4
        llelse2:

        ;printf("(%i) [", list.length);
        mov     eax, dword [esp+4+12+4]     ;&list (4 for local variables, 12 for register preservation, 4 for arg location)
        add     eax, 8                      ;&list.length
        mov     eax, [eax]                  ;list.length
        push    eax
        push    listPrefix
        call    printf
        pop     eax
        pop     eax

        ;while(true)
        llloop1:
            ;printf("%i", currentNode.data)
            mov     eax, dword [esp+0]  ;&currentNode
            add     eax, 0              ;&currentNode.data
            mov     eax, [eax]          ;currentNode.data
            push    eax
            push    intprintf
            call    printf
            pop     eax
            pop     eax

            ;currentNode = currentNode.next
            mov     eax, dword [esp+0]  ;&currentNode
            add     eax, 4              ;&currentNode.next
            mov     eax, [eax]          ;currentNode.next
            mov     dword [esp+0], eax

            llif3:  ;if(currentNode == nullptr)
                cmp     dword [esp+0], 0
                jne     llelse3

                ;printf("]")
                push    listSuffix
                call    printf
                pop     eax

                ;break;
                jmp     llbreak1

            llelse3:

            push    elementSeperator
            call    printf
            pop     eax


            llcontinue1:
                ;its a while loop, so just jump
                jmp     llloop1

            llbreak1:

        ;delete currentNode; (from the stack)
        pop     eax

        ;register preservation
        pop     ecx
        pop     ebx
        pop     eax

        ret     4