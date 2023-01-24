// #include <string>
#include <cstring>
#include <iostream>
#include <math.h>
using namespace std;

// void printff(char* str, int a) {
//     bool primedForType = false;

//     for(int i = 0; i < strlen(str); i++) {
//         char currentChar = *(str+i);

//         if(primedForType == true) {
//             cout << "(type " << currentChar << ")";

//             primedForType = false;

//             continue;
//         }

//         if(currentChar == '%') {
//             primedForType = true;

//             continue;
//         }

//         cout << currentChar;
//     }
// }

// bool isNumber(char input) {
//     return input >= 48 && input <= 57;
// }

// int charToNum(char input) {
//     return input-48;
// }

// //things for stof implimentation
// const int maxInputLength = 32;

// const int sizeOfParts = maxInputLength/2+1;

// char intPart[sizeOfParts] = {};
// char fracPart[sizeOfParts] = {};

// //stof implimentation
// float mstof(char* str) {
//     //temp variables
//     float evaluated = 0;       //evaluated number
//     bool isNegative = false;   //will result be negative
//     int pointLocation = 255;   //arbitrary starting value (strlen(str) will never be greater than 255)
//     int numbersStart = 0;      //location of first (number or '.') in str
//     int placeValue = 1;        //value of place in evaluation
//     char currentChar = str[0]; //current character

//     //determine sign and starting location
//     if(currentChar == '+') {
//         numbersStart = 1;
//     }

//     if(currentChar == '-') {
//         isNegative = true;

//         numbersStart = 1;
//     }

//     //setting parts
//     for(int i = numbersStart; i < maxInputLength; i++) {
//         currentChar = str[i];

//         if(currentChar == '.' && pointLocation == 255) {
//             pointLocation = i;

//             continue;
//         }

//         //stdc stof stops at a non (num | [.+-]) char
//         if(!isNumber(currentChar)) {
//             break;
//         }

//         if(i > pointLocation) {
//             fracPart[i-pointLocation-1] = currentChar;
//         } else {
//             intPart[i-numbersStart] = currentChar;
//         }
//     }

//     printf("%c%s.%s\n", isNegative == true ? '-' : '\0', intPart, fracPart);

//     //evaluations

//     //integer part
//     for(int i = sizeOfParts; i >= 0; i--) {
//         char intChar = intPart[i];

//         if(intChar == '\0') continue;

//         int intNum = charToNum(intChar);

//         evaluated += placeValue*intNum;

//         placeValue *= 10;
//     }

//     //fraction part
//     placeValue = 10;

//     for(int i = 0; i < sizeOfParts; i++) {
//         char fracChar = fracPart[i];

//         if(fracChar == '\0') continue;

//         int fracNum = charToNum(fracChar);

//         evaluated += fracNum/(float)placeValue;

//         placeValue *= 10;
//     }

//     //sign
//     if(isNegative) {
//         evaluated = -evaluated;
//     }

//     return evaluated;
// }

#pragma region Structures

struct LinkedListNode {
    int32_t data;
    LinkedListNode* next;
};

struct LinkedList {
    LinkedListNode* first;
    LinkedListNode* last;
    int32_t length;
};

#pragma endregion Structures

#pragma region Construction

LinkedList* LinkedListConstruct() {
    LinkedList* list = new LinkedList();
    list->first = nullptr;
    list->last = nullptr;
    list->length = 0;

    return list;
}

#pragma endregion Construction

#pragma region Getting

LinkedListNode* LinkedListGetNode(LinkedList* list, int32_t index) {
    LinkedListNode* ptr = list->first;

    if(index < 0) {
        return nullptr;
    }

    for(int32_t i = 0; i < index; i++) {
        ptr = ptr->next;

        if(ptr == nullptr) {
            break;
        }
    }


    return ptr;
}

int32_t LinkedListGetValue(LinkedList* list, int32_t index) {
    LinkedListNode* ptr = LinkedListGetNode(list, index);

    if(ptr == nullptr) {
        return 0;
    }

    return ptr->data;
}

#pragma endregion Getting
#pragma region Setting

void LinkedListSetValue(LinkedList* list, int32_t index, int32_t data) {
    LinkedListNode* node = LinkedListGetNode(list, index);

    if(node == nullptr) {
        return;
    }

    node->data = data;
}

#pragma endregion Setting

#pragma region Printing

void LinkedListPrint(LinkedList* list) {
    LinkedListNode* currentNode = list->first;

    if(currentNode == nullptr) {
        std::cout << "[]" << std::endl;

        return;
    }

    std::cout << "(" << list->length << ") ";
    
    std::cout << "[";

    while(true) {
        std::cout << currentNode->data;

        currentNode = currentNode->next;

        if(currentNode == nullptr) {
            std::cout << "]" << std::endl;

            break;
        }

        std::cout << ", ";
    }
}


void LinkedListPrintNode(LinkedListNode* node) {
    if(node == nullptr) {
        std::cout << "{ nullptr }" << std::endl;

        return;
    }

    std::cout << "{ data: " << node->data << ", next: " << node->next << " }" << std::endl;
}

#pragma endregion Printing

#pragma region Insertion

void LinkedListInsert(LinkedList* list, int32_t index, int32_t data) {
    LinkedListNode* newNode = new LinkedListNode();
    newNode->next = nullptr;
    newNode->data = data;


    LinkedListNode* prevNode = LinkedListGetNode(list, index-1);
    LinkedListNode* nextNode = nullptr;

    if(prevNode == nullptr) {
        nextNode = LinkedListGetNode(list, index);
    } else {
        nextNode = prevNode->next;
    }

    //set the previous node to point to the new node
        LinkedListNode** prevNodeNext = &prevNode->next;
        
        //is first
        if(index == 0) {
            prevNodeNext = &list->first;
        }

        *prevNodeNext = newNode;


    //set the new node to point to the next node
        LinkedListNode** newNodeNext = &newNode->next;

        *newNodeNext = nextNode;


    //is last
    if(nextNode == nullptr) {
        LinkedListNode** listLast = &list->last;

        *listLast = newNode;
    }

    list->length++;
}

void LinkedListPush(LinkedList* list, int32_t data) {
    LinkedListInsert(list, list->length, data);
}

void LinkedListUnshift(LinkedList* list, int32_t data) {
    LinkedListInsert(list, 0, data);
}

#pragma endregion Insertion
#pragma region Deletion

int32_t LinkedListDelete(LinkedList* list, int32_t index) {
    list->length--;

    LinkedListNode* prevNode = LinkedListGetNode(list, index-1);
    LinkedListNode* node = nullptr;

    if(prevNode == nullptr) {
        node = LinkedListGetNode(list, index);
    } else {
        node = prevNode->next;
    }

    int32_t nodeData = node->data;

    //set the previous node to point to the one after the current one
        LinkedListNode** prevNodeNext = &prevNode->next;

        //is first
        if(index == 0) prevNodeNext = &list->first;

        *prevNodeNext = node->next;


    //is last
    if(node == nullptr) list->last = prevNode;

    delete node;

    return nodeData;
}

int32_t LinkedListPop(LinkedList* list) {
    int32_t data = LinkedListDelete(list, list->length-1);

    return data;
}

int32_t LinkedListShift(LinkedList* list) {
    int32_t data = LinkedListDelete(list, 0);

    return data;
}

#pragma endregion Deletion

#pragma region Deconstruction

void LinkedListDeconstruct(LinkedList* list) {
    LinkedListNode* currentNode = list->first;
    LinkedListNode* nextNode = nullptr;

    while(true) {
        if(currentNode == nullptr) break;

        nextNode = currentNode->next;

        delete currentNode;

        currentNode = nextNode;
    }

    delete list;
}

#pragma endregion Deconstruction

int main() {
    //construct it
    LinkedList* list = LinkedListConstruct();

    //initalize it
        //push 1, 12, 123, 1234
        LinkedListPush(list, 1);
        LinkedListPush(list, 12);
        LinkedListPush(list, 123);
        LinkedListPush(list, 1234);
        LinkedListPrint(list); //(4) [1, 12, 123, 1234]
    

    //pushing and unshifting
        //add 12345 to the end
        LinkedListPush(list, 12345);
        LinkedListPrint(list); //(5) [1, 12, 123, 1234, 12345]

        //add 0 to the start
        LinkedListUnshift(list, 0);
        LinkedListPrint(list); //(6) [0, 1, 12, 123, 1234, 12345]


    //popping and shifting
        //remove 12345 from the end
        LinkedListPop(list);
        LinkedListPrint(list); //(5) [0, 1, 12, 123, 1234]

        //remove 0 from the start
        LinkedListShift(list);
        LinkedListPrint(list); //(4) [1, 12, 123, 1234]


    //removing and insertion
        //remove 12 from index 1
        LinkedListDelete(list, 1);
        LinkedListPrint(list); //(3) [1, 123, 1234]

        //insert 0 into index 1
        LinkedListInsert(list, 1, 0);
        LinkedListPrint(list); //(4) [1, 0, 123, 1234]


    //deconstruct it
    LinkedListDeconstruct(list);

    return 0;
}