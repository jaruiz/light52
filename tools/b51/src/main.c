/**
    @file main.c
    @brief Entry point to b51 simulator.

    So farm this program is inly useful for the cosimulation of the light52 test
    bench. It does not simulate any peripheral hardware. Besides, this main
    program is just a stub: no argument parsing, for starters.

*/

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "b51_mcu.h"
#include "b51_cpu.h"
#include "b51_log.h"

/*-- Local file data ---------------------------------------------------------*/

/** Value of command line parameters */
static struct {
    char *hex_file_name;
} cmd_line_params;



/*-- Local function prototypes -----------------------------------------------*/

static bool parse_command_line(int argc, char **argv);
static void usage(void);


/*-- Entry point -------------------------------------------------------------*/

int main(int argc, char **argv){
    cpu51_t cpu;

    cpu_init(&cpu);

    if(!parse_command_line(argc, argv)){
        exit(2);
    }

    //if(!cpu_load_code(&cpu, "../../test/hello/Debug/Exe/hello.hex")){
    //if(!cpu_load_code(&cpu, "../../../../test/cpu_test/bin/tb51_cpu.hex")){
    if(!cpu_load_code(&cpu, cmd_line_params.hex_file_name)){
    //if(!cpu_load_code(&cpu, "../../../../test/brd2.hex")){
        exit(1);
    }

    //log_init("sw_log.txt", "console_log.txt");
    log_init("sw_log.txt", NULL);

    //cpu_add_breakpoint(&cpu, 0x0003);
    cpu_reset(&cpu);
    cpu_exec(&cpu, 55000);

    log_close();

    return 0;
}

/*-- local functions ---------------------------------------------------------*/

static bool parse_command_line(int argc, char **argv){

    if(argc!=2){
        usage();
        return false;
    }

    cmd_line_params.hex_file_name = argv[1];
    return true;
}


static void usage(void){
    printf("Usage:\n");
    printf("b51 <hex file name>       -"
           " Load HEX file on code memory, reset CPU and run.\n");
    printf("\n\n");
}
