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

struct LinkedListNode {
    int32_t data;
    LinkedListNode* next;
};

struct LinkedList {
    LinkedListNode* first;
    LinkedListNode* last;
    int32_t length;
};

LinkedListNode* LinkedListGetNode(LinkedList* list, int32_t index) {
    LinkedListNode* ptr = list->first;

    for(int32_t i = 0; i < index; i++) {
        // std::cout << ptr->data << std::endl;

        if(ptr == nullptr) return nullptr;

        ptr = ptr->next;
    }

    return ptr;
}

int32_t LinkedListGetValue(LinkedList* list, int32_t index) {
    LinkedListNode* ptr = LinkedListGetNode(list, index);

    if(ptr == nullptr) {
        std::cout << "out of bounds" << std::endl;

        return 0;
    }

    return ptr->data;
}

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

void LinkedListPush(LinkedList* list, int32_t data) {
    //create the new node
    LinkedListNode* newNode = new LinkedListNode();
    newNode->next = nullptr;
    newNode->data = data;

    //always gotta do this
    list->length++;


    if(list->first == nullptr) {
        list->first = newNode;

        list->last = newNode;

        return;
    }

    //current last node
    LinkedListNode* lastNode = list->last;
    if(lastNode == nullptr) lastNode = list->first;

    //set current last node to point to the new node
    lastNode->next = newNode;

    //assign the lists pointer to the last node
    list->last = newNode;

    return;
}

void LinkedListSetValue(LinkedList* list, int32_t index, int32_t data) {
    LinkedListNode* node = LinkedListGetNode(list, index);

    if(node == nullptr) {
        return;
    }

    node->data = data;

    return;
}

LinkedList* LinkedListConstruct() {
    LinkedList* list = new LinkedList();
    list->first = nullptr;
    list->last = nullptr;
    list->length = 0;

    return list;
}

void LinkedListDestruct(LinkedList* list) {
    LinkedListNode* currentNode = list->first;
    LinkedListNode* nextNode = nullptr;

    while(true) {
        nextNode = currentNode->next;

        delete currentNode;

        currentNode = nextNode;

        if(currentNode == nullptr) break;
    }

    delete list;
}

int main() {
    LinkedList* list = LinkedListConstruct();
    LinkedListPrint(list);

    LinkedListPush(list, 1);
    LinkedListPrint(list);

    LinkedListPush(list, 12);
    LinkedListPrint(list);

    LinkedListPush(list, 123);
    LinkedListPrint(list);

    LinkedListPush(list, 1234);
    LinkedListPrint(list);

    std::cout << LinkedListGetValue(list, 1) << ", " << list->length << std::endl;


    return 0;
}