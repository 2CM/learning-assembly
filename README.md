# Intro
Hello, I'm trying to learn x86 assembly stuff, so this is the repo for it.

# System
Its made for Windows using the Win32 library, so (this is a shocker) it wont work on Mac and Linux.

# Compiling / Running
I havent figured out how to run it inside of vscode yet, so I have a 4 line command I use to compile and debug it.
```
nasm -F dwarf -g -f elf32 -o main.obj main.asm; nasm -F dwarf -g -f elf32 -o printing.obj printing.asm; ld main.obj printing.obj C:\Windows\SysWOW64\kernel32.dll -mi386pe --entry=_start -o main.exe; gdb -ex run .\main.exe
```

## It can be seperated into 3 steps:

1. ### Assembling the files:
        nasm -F dwarf -g -f elf32 -o main.obj main.asm;
        nasm -F dwarf -g -f elf32 -o printing.obj printing.asm;
2. ### Linking them:
        ld main.obj printing.obj C:\Windows\SysWOW64\kernel32.dll -mi386pe --entry=_start -o main.exe;
3. ### Debugging them
        gdb -ex run .\main.exe

# Requirements
It requires [nasm](https://www.nasm.us/), [msys2 (mingw)](https://www.msys2.org/), and [gdb](https://www.sourceware.org/gdb/) (comes in mingw)