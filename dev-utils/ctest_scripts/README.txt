Some info in optimizations:

if you are using gcc-4.2.2 or newer you can also use

-march=native or -mtune=native.

This shows you enabled options on native march setting.

gcc -c -Q -march=native --help=target

and also,

gcc -### -march=native -E /usr/include/stdlib.h 2>&1 | grep "/usr/lib.*cc1" 
