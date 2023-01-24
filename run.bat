:: does all the stuff to run the program
@echo off


:: assembling the files
echo Assembling...
nasm -F dwarf -g -f elf32 -o output/main.obj main.asm
nasm -F dwarf -g -f elf32 -o output/printing.obj printing.asm
nasm -F dwarf -g -f elf32 -o output/LinkedList.obj LinkedList.asm


:: linking them
echo Linking...
ld output/*.obj C:\Windows\SysWOW64\kernel32.dll -mi386pe --entry=_start -o output/main.exe


:: debug them
echo Debugging...
gdb -ex run output/main.exe