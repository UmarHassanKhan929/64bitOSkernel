#include "print.h"

void kernel_main(){
    //clear screen
    print_clear();
    //text color FG,BG
    print_set_color(PRINT_COLOR_MAGENTA, PRINT_COLOR_WHITE);

    
    //print text
    print_str("                                                                           \n");
    print_str("   *********************************************************************** \n");
    print_str("   ``````````````````````````````````````````````````````````````````````` \n");
    print_str("         ***    **   00     00     $$$$$$       ##########                 \n");
    print_str("         ****   **   00     00    8                 ##                     \n");
    print_str("         ** **  **   00     00     $$$$$$           ##                     \n");
    print_str("         **  ** **   00     00          88          ##                     \n");
    print_str("         **   ****   00     00          88          ##                     \n");
    print_str("         **    ***    \\00000/      $$$$$$           ##                     \n");
    print_str("   _______________________________________________________________________ \n");
    print_str("                 Umar Hassan Khan   288929   BSCS-9-B                      \n");
    print_str("   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ");

    
}