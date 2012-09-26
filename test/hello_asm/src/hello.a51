; hello.a51 -- 'Hello World' on serial console.
;
; This small program is meant to be run on a light52 MCU on actual hardware,
; as a first sanity check.
;
; This version of the program does not use interrupts.
;
; If this program runs and displays its message on a terminal, you may then be
; sure that your development environment is working.
    
    
        ;-- Parameters common to all tests -------------------------------------
        

saved_psw set   070h                ; (IDATA) temp store for PSW value
stack0  set     09fh                ; (IDATA) stack addr used for push/pop tests
    
    
        ;-- Macros -------------------------------------------------------------

        ; putc: send character in A to console (UART), by polling.
putc    macro   character
        local   putc_loop
        mov     SBUF,a
putc_loop:
        mov     a,SCON
        anl     a,#10h
        jz      putc_loop
        endm
        
        ; put_crlf: send CR+LF to console
put_crlf macro
        putc    #13
        putc    #10
        endm
    
    
        ;-- Reset & interrupt vectors ------------------------------------------

        org     00h
        ljmp    start               ;
        org     03h
        ljmp    irq_unused
        org     0bh
        ljmp    irq_timer
        org     13h
        ljmp    irq_unused
        org     1bh
        ljmp    irq_unused
        org     23h
        ljmp    irq_uart

        ;-- Main test program --------------------------------------------------
        org     30h
start:
        ; Write some stuff to P0 and P1
        mov     P0,#0abh
        mov     P1,#87h

        ; Initialize serial port...
        mov     DPTR,#text0

        ; ...and dump the hello string to the serial port.
        mov     r0,#00h
puts_loop:
        mov     a,r0
        inc     r0
        movc    a,@a+DPTR
        jz      puts_done
        
        putc
        sjmp    puts_loop
puts_done:

        ;-- End of test program, enter single-instruction endless loop
quit:   ajmp    $

irq_unused:
        reti
irq_uart:
        reti
irq_timer:
        reti

text0:  db      'Hello World!',13,10,00h,00h
    
        end
