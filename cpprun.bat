:: for testing c++ code

@echo off


:: compile and link it
echo Compiling...
gcc "cpp testing/e.cpp" -lstdc++ -o output/cppmain.exe


:: run it
echo Running...
gdb -ex run output/cppmain.exe