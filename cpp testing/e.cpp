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

bool isNumber(char input) {
    return input >= 48 && input <= 57;
}

int charToNum(char input) {
    return input-48;
}

//things for stof implimentation
const int maxInputLength = 32;

const int sizeOfParts = maxInputLength/2+1;

char intPart[sizeOfParts] = {};
char fracPart[sizeOfParts] = {};

//stof implimentation
float mstof(char* str) {
    //temp variables
    float evaluated = 0;       //evaluated number
    bool isNegative = false;   //will result be negative
    int pointLocation = 255;   //arbitrary starting value (strlen(str) will never be greater than 255)
    int numbersStart = 0;      //location of first (number or '.') in str
    int placeValue = 1;        //value of place in evaluation
    char currentChar = str[0]; //current character

    //determine sign and starting location
    if(currentChar == '+') {
        numbersStart = 1;
    }

    if(currentChar == '-') {
        isNegative = true;

        numbersStart = 1;
    }

    //setting parts
    for(int i = numbersStart; i < maxInputLength; i++) {
        currentChar = str[i];

        if(currentChar == '.' && pointLocation == 255) {
            pointLocation = i;

            continue;
        }

        //stdc stof stops at a non (num | [.+-]) char
        if(!isNumber(currentChar)) {
            break;
        }

        if(i > pointLocation) {
            fracPart[i-pointLocation-1] = currentChar;
        } else {
            intPart[i-numbersStart] = currentChar;
        }
    }

    printf("%c%s.%s\n", isNegative == true ? '-' : '\0', intPart, fracPart);

    //evaluations

    //integer part
    for(int i = sizeOfParts; i >= 0; i--) {
        char intChar = intPart[i];

        if(intChar == '\0') continue;

        int intNum = charToNum(intChar);

        evaluated += placeValue*intNum;

        placeValue *= 10;
    }

    //fraction part
    placeValue = 10;

    for(int i = 0; i < sizeOfParts; i++) {
        char fracChar = fracPart[i];

        if(fracChar == '\0') continue;

        int fracNum = charToNum(fracChar);

        evaluated += fracNum/(float)placeValue;

        placeValue *= 10;
    }

    //sign
    if(isNegative) {
        evaluated = -evaluated;
    }

    return evaluated;
}

int main() {
    char* str = "6.16";
    float num = mstof(str);

    printf("%f", num);

    return 0;
}