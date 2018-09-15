/**
    @file main.c
    @brief Entry point to b51 simulator.

    This simulator is only meant for the cosimulation of the light52 test
    bench. It does not simulate any peripheral hardware. 

*/

#include <argp.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "b51_mcu.h"
#include "b51_cpu.h"
#include "b51_log.h"
#include "b51_debug.h"



/*-- Local function prototypes -----------------------------------------------*/

static error_t parse_command_line(int argc, char **argv);
static error_t parse_opt (int key, char *arg, struct argp_state *state);
static void usage(void);
static int sim_batch_mode(cpu51_t *cpu, uint32_t ninst);


/*-- Local file data ---------------------------------------------------------*/

/** Value of command line parameters */
struct arguments {
    char *hex_file_name;
    char *trace_logfile_name;
    char *console_logfile_name;
    uint32_t num_instructions;
    bool implement_bcd;
    char *debug_tty;
} args = {NULL, "sw_log.txt", NULL, INT_MAX, false, NULL};

/* Info displayed before and after options. */
static char doc[] =
    "B51: Batch-mode simulator for MCS51 architecture.\v"
    "B51 will load the executable hex file on CODE space, reset the CPU and execute\n"
    "the specified number of instructions, then quit.\n"
    "Simulation will only stop after <nint> instructions, when the CPU "
    "enters a\nsingle-instruction endless loop or on an error "
    "condition.\n\n";

/* Positional argument display names. */
static char args_doc[] = "HEX";

/* Command line info used by argp. */
static struct argp_option options[] = {
    {"log",     904, "FILE",0,  "Execution log file (CPU state delta log)\n"
                                "If omitted no execution log is output", 2 },
    {"log-con", 905, "FILE",0,  "UART0 echo file\n"
                                "If omitted no echo is output" },
    {"nologs",  900, 0,     0,  "Disable console and execution logging", 3 },
    {"ninst",   901, "NUM", 0,  "No. of instructions to run\n"
                                "Defaults to a gazillion" },
    {"tty",     902, "TTY", 0,  "Tty file to use as debugger interface\n"
                                "Defaults to none (batch mode)" },
    {"bcd",     903, 0,     0,  "Disable implementation of BCD instructions\n"
                                "If omitted, BCD instructions are implemented" },
    {"HEX",     999, 0,     OPTION_DOC, "MCS51 executable in Intel Hex format", 1 },
    { 0 }
};

static struct argp argp = { options, parse_opt, args_doc, doc };


/*-- Entry point -------------------------------------------------------------*/

int main(int argc, char **argv){
    cpu51_t cpu;
    int retval;

    cpu_init(&cpu);

    /* Parse command line... */
    if(parse_command_line(argc, argv)){
        exit(2);
    }
    /* ...and pass options to CPU model */
    cpu.options.bcd = args.implement_bcd;
    if (cpu.options.bcd){
        printf("Simulating BCD instructions.\n");
    }

    if(!cpu_load_code(&cpu, args.hex_file_name)){
        exit(1);
    }

    log_init(args.trace_logfile_name, args.console_logfile_name);

    if (args.debug_tty == NULL) {
        /* Run in batch mode. */
        retval = sim_batch_mode(&cpu, args.num_instructions);
    }
    else {
        /* Run under control of remote debugger -- pretend to be HW target. */
        retval = debug_target(&cpu, args.debug_tty); 
    }

    log_close();

    return retval;
}

/*-- local functions ---------------------------------------------------------*/

/* Run simulation to completion in batch mode. */
static int sim_batch_mode(cpu51_t *cpu, uint32_t ninst){
    int retval;

    printf("\n\n");

    cpu_reset(cpu);
    retval = cpu_exec(cpu, ninst);

    printf("\n\nExecution finished after %u instructions and %u cycles.\n",
           cpu->log.executed_instructions, cpu->cycles);

    switch(retval){
    case EXIT_UNKNOWN :
        printf("Execution interrupted, cause unknown.\n");
        break;
    case EXIT_BREAKPOINT :
        printf("Execution hit a breakpoint.\n");
        break;
    case EXIT_COSIMULATION :
        printf("SW wrote EOT (0x04) to SBUF.\n");
        break;
    default :
        printf("Execution loop returned invalid code %d\n", retval);
        break;
    }

    return 0;
}


/* Callback to parse a single command line option. */
static error_t parse_opt (int key, char *arg, struct argp_state *state){
    /* Get the input argument from argp_parse, which we
     know is a pointer to our arguments structure. */
    struct arguments *arguments = state->input;

    switch (key){
    case 900: /* --nologs */
        arguments->console_logfile_name = NULL;
        arguments->trace_logfile_name = NULL;
        break;
    case 901: /* --ninst = N */
        if(sscanf(arg, "%u", &(arguments->num_instructions))==0){
            argp_error(state, "Error: expected decimal integer as argument of --ninst");
        }
        break;
    case 902: /* --tty = FILE */
        arguments->debug_tty = arg;
        break;
    case 903: /* --bcd */
        arguments->implement_bcd = true;
        break;
    case 904: /* --log = FILE */
        arguments->trace_logfile_name = arg;
        break;
    case 905: /* --log-con = FILE */
        arguments->console_logfile_name = arg;
        break;
    case ARGP_KEY_ARG:
        if (state->arg_num == 0) {
            arguments->hex_file_name = arg;
        }
        else {
            /* Too many arguments. */
            argp_usage (state);
        }
        break;
    case ARGP_KEY_END:
        if (state->arg_num < 1) {
            /* Not enough arguments. */
            argp_usage (state);
        }
        break;
    default:
        return ARGP_ERR_UNKNOWN;
    }
    return 0;
}

static error_t parse_command_line(int argc, char **argv){
    return argp_parse (&argp, argc, argv, 0, 0, &args);
}
