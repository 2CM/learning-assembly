;linked list stuff

;export functions
global LinkedListConstruct
global LinkedListPush
global LinkedListPrint
global LinkedListGetNode
global LinkedListGetData
global LinkedListSetData
global LinkedListDeconstruct

global LinkedListElementPrintString

;main.asm
extern heapHandle

;kernel32.dll
extern _GetProcessHeap
extern _HeapAlloc
extern _HeapFree


;printing.asm
extern printf
extern intprintf


%define nullptr 0

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
    outOfBoundsMessage: db "ERROR: %i is out of bounds.", 0xa, 0

    ;for printing it
    emptyMessage: db "[]", 0xa, 0
    listPrefix: db "(%i) [", 0
    elementSeperator: db ", ", 0
    listSuffix: db "]", 0xa, 0

    LinkedListElementPrintString: db "%i", 0

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
        mov     dword [eax+0], nullptr    ;first

        ;newList.last = nullptr;
        mov     dword [eax+4], nullptr    ;last

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
        push    nullptr

        ;LinkedListNode* currentLastNode;
        push    nullptr

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
        mov     dword [eax], nullptr    ;nullptr

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
            cmp     ecx, nullptr
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
            cmp     dword [esp+4], nullptr
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
    
    
    ;pushes an element to a linked list
    ;void LinkedListPushBack(LinkedList* list, int32_t data)
    LinkedListPushBack:

    ;prints a linked list in javascript array form. "(5) [1, 2, 3, 4, 5]" | "[]"
    ;void LinkedListPrint(LinkedList* list)
    LinkedListPrint:
        ;register preservation
        push    eax
        push    ebx
        push    ecx

        ;LinkedList* currentNode;
        push    nullptr

        ;currentNode = list.first
        mov     eax, dword [esp+4+12+4]     ;&list (4 for local variables, 12 for register preservation, 4 for arg location)
        add     eax, 0                      ;&list.first
        mov     eax, [eax]                  ;list.first
        mov     dword [esp+0], eax          ;currentNode

        llif2:  ;if(currentNode == nullptr)
            cmp     dword [esp+0], nullptr
            jne     llelse2
            
            ;printf("[]\n");
            push    emptyMessage
            call    printf

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

        ;while(true)
        llloop1:
            ;printf(LinkedListElementPrintString, currentNode.data)
            mov     eax, dword [esp+0]  ;&currentNode
            add     eax, 0              ;&currentNode.data
            mov     eax, [eax]          ;currentNode.data
            push    eax
            push    LinkedListElementPrintString
            call    printf
            pop     eax

            ;currentNode = currentNode.next
            mov     eax, dword [esp+0]  ;&currentNode
            add     eax, 4              ;&currentNode.next
            mov     eax, [eax]          ;currentNode.next
            mov     dword [esp+0], eax

            llif3:  ;if(currentNode == nullptr)
                cmp     dword [esp+0], nullptr
                jne     llelse3

                ;printf("]")
                push    listSuffix
                call    printf

                ;break;
                jmp     llbreak1

            llelse3:

            push    elementSeperator
            call    printf


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

    ;gets the node at an index and returns nullptr if its out of bounds
    ;LinkedListNode* LinkedListGetNode(LinkedList* list, int32_t index)
    LinkedListGetNode:
        ;register preservation
        push    ebx
        push    ecx

        ;LinkedListNode* currentNode;
        push    nullptr

        ;currentNode = list.first;
        mov     eax, dword [esp+4+8+4]      ;&list (4 for local variables, 8 for register preservation, 4 for arg location)
        add     eax, 0                      ;&list.first
        mov     eax, [eax]                  ;list.first
        mov     dword [esp+0], eax


        ;i = 0;
        mov     ebx, 0

        llloop2:
            cmp		ebx, dword [esp+4+8+8]  ;index (4 for local variables, 8 for register preservation, 8 for arg location)
            jge		llbreak2

            ;currentNode = currentNode.next
            mov     eax, dword [esp+0]  ;&currentNode
            add     eax, 4              ;&currentNode.next
            mov     eax, [eax]          ;currentNode.next
            mov     dword [esp+0], eax

            llif4:  ;if(currentNode == nullptr)
                cmp     dword [esp+0], nullptr 
                jne     llelse4

                ;printf("ERROR: %i is out of bounds", index)
                push    dword [esp+4+8+8]    ;index (4 for local variables, 8 for register preservation, 8 for arg location)
                push    outOfBoundsMessage
                call    printf
                pop     eax

                ;break;
                jmp     llbreak2

            llelse4:

            llcontinue2:
                ;i++
                inc     ebx

                jmp     llloop2

            llbreak2:


        ;return currentNode
            ;eax = currentNode; delete currentNode; (from the stack)
            pop     eax

            ;register preservation
            pop    ecx
            pop    ebx
            
            ret     8

    ;gets the data at an index
    ;int32_t LinkedListGetData(LinkedList* list, int32_t index)
    LinkedListGetData:
        ;LinkedListNode* node (eax) = LinkedListGetNode(list, index);
        push    dword [esp+8]       ;index
        push    dword [esp+4+4]     ;list (4 because arg before it)
        call    LinkedListGetNode

        llif5:  ;if(node == nullptr)
            cmp     eax, nullptr
            jne     llelse5

            ;return 0
                mov     eax, 0
                ret     8
            
        llelse5:

        ;return node.data
        mov     eax, [eax]  ;node.data

        ret     8

    ;sets the data at an index
    ;void LinkedListSetData(LinkedList* list, int32_t index, int32_t data)
    LinkedListSetData:
        ;register preservation
        push    eax
        push    ecx

        ;LinkedListNode* node (eax) = LinkedListGetNode(list, index);
        push    dword [esp+8+8]       ;index (8 for register preservation)
        push    dword [esp+8+4+4]     ;list (8 for register preservation, 4 because arg before it)
        call    LinkedListGetNode

        llif6:  ;if(value == nullptr)
            cmp     eax, nullptr
            jne     llelse6

            ;return 0
                ;register preservation
                pop     ecx
                pop     eax

                ret     12
            
        llelse6:

        ;value.data = data
        mov     ecx, dword [esp+8+12]   ;data (8 for register preservation, 12 for arg location)
        mov     [eax], ecx

        ;return 0
            ;register preservation
            pop     ecx
            pop     eax

            ret     12

    ;deconstructs a linked list
    ;void LinkedListDeconstruct(LinkedList* list)
    LinkedListDeconstruct:
        ;register preservation
        push    eax

        ;LinkedListNode* currentNode = list.first;
        mov     eax, dword [esp+4+4]        ;&list          (4 for register preservation, 4 for arg location)
        add     eax, 0                      ;&list.first
        mov     eax, [eax]                  ;list.first
        push    eax

        ;LinkedListNode* nextNode = nullptr;
        push    nullptr

        ;while(true)
        llloop3:
            ;nextNode = currentNode.next;
            mov     eax, dword [esp+4]      ;&currentNode
            add     eax, 4                  ;&currentNode.next
            mov     eax, [eax]              ;currentNode.next
            mov     dword [esp+0], eax

            ;delete currentNode;
            push    dword [esp+4]      ;currentNode
            push    dword 1            ;0
            call    _GetProcessHeap
            mov     [heapHandle], eax
            push    dword [heapHandle]
            call    _HeapFree


            ;currentNode = nextNode;
            mov     eax, dword [esp+0]      ;nextNode
            mov     dword [esp+4], eax      ;currentNode

            llif7: ;if(currentNode == nullptr)
                cmp     dword [esp+4], nullptr
                jne     llelse7

                ;break;
                jmp     llbreak3

            llelse7:

            llcontinue3:
                jmp     llloop3
                
            llbreak3:

        ;delete list;
        push    dword [esp+8+4+4]  ;list (8 for local variables, 4 for register preservation, 4 for arg location)
        push    dword 1            ;0
        call    _GetProcessHeap
        mov     [heapHandle], eax
        push    dword [heapHandle]
        call    _HeapFree

        ;return
            ;delete nextNode; (from the stack)
            pop     eax

            ;delete currentNode; (from the stack)
            pop     eax

            ;register preservation
            pop     eax

            ret     4