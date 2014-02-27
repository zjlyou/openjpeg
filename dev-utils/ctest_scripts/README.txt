Some info in optimizations:

if you are using gcc-4.2.2 or newer you can also use

-march=native or -mtune=native.

This shows you enabled options on native march setting.

gcc -c -Q -march=native --help=target

and also,

gcc -### -march=native -E /usr/include/stdlib.h 2>&1 | grep "/usr/lib.*cc1" 

See:
http://gcc.gnu.org/onlinedocs/gcc-4.7.2/gcc/i386-and-x86_002d64-Options.html#i386-and-x86_002d64-Options
http://gcc.gnu.org/onlinedocs/gcc-4.7.2/gcc/RS_002f6000-and-PowerPC-Options.html#RS_002f6000-and-PowerPC-Options
