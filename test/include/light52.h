/**
    @file light52.h
    @brief SFR definitions for the light52 core.
    
    This file uses the SCDD compiler MCS51 C extensions and will not be
    directly compatible with other compilers.
*/

#ifndef LIGHT52_H_INCLUDED
#define LIGHT52_H_INCLUDED

/* FIXME this file is mostly a stub; to be fleshed up later */

__sfr __at 0x98 SCON;       /**< UART control register */
__sbit __at 0x9c TXRDY;     /**< UART TxRdy flag */
__sfr __at 0x99 SBUF;       /**< UART tx/rx data buffer */

#endif
