/**
    @file b51_debug.h
    @brief 
*/

#ifndef S51_DEBUG_H_INCLUDED
#define S51_DEBUG_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>

#include "b51_cpu.h"

/*-- Public functions --------------------------------------------------------*/

extern int debug_target(cpu51_t *cpu, const char *ttyfname);



#endif // S51_DEBUG_H_INCLUDED
