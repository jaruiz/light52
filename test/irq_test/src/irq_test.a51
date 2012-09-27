; irq_test.a51 -- First interrupt srvice test.
;
; This program is meant to run on a light53 MCU with the 16-bit timer. It can be
; run on simulation or in actual hardware.
; Its purpose is to demonstrate the working of the interrupt service logic. No
; actual tests are performed (other than the co-simulation tests), only checks.
;
;-------------------------------------------------------------------------------

        ; Include the definitions for the light52 derivative
        $nomod51
        $include (light52.mcu)
        
ext_irq_ctr     set     060h        ; Incremented by external irq routine

    
        ;-- Macros -------------------------------------------------------------

        ; putc: send character in A to console (UART)
putc    macro   character
        local   putc_loop
        mov     SBUF,character
putc_loop:
        ;mov     a,SCON
        ;anl     a,#10h
        ;jz      putc_loop
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
        ljmp    irq_ext
        org     0bh
        ljmp    irq_timer
        org     13h
        ljmp    irq_wrong
        org     1bh
        ljmp    irq_wrong
        org     23h
        ljmp    irq_wrong


        ;-- Main test program --------------------------------------------------
        org     30h
start:

        ; Disable all interrupts.
        mov     IE,#00

        
        ;---- External interrupt test --------------------------------------
        
        ; Trigger external IRQ with IRQs disabled, it should be ignored.
        mov     P1,#01h
        nop
        nop
        nop
        mov     a,ext_irq_ctr
        cjne    a,#00,fail_unexpected
        setb    EXTINT0.0           ; Clear external IRQ flag

        ; Trigger timer IRQ with external IRQ enabled but global IE disabled
        mov     IE,#01h
        mov     P1,#01h
        nop
        nop
        nop
        mov     a,ext_irq_ctr
        cjne    a,#00,fail_unexpected
        setb    EXTINT0.0          ; Clear timer IRQ flag

        ; Trigger external IRQ with external and global IRQ enabled
        mov     P1,#00h
        mov     IE,#81h
        mov     ext_irq_ctr,#00
        mov     P1,#01h
        nop
        nop
        nop
        mov     a,ext_irq_ctr
        cjne    a,#01,fail_expected
        setb    EXTINT0.0          ; Clear timer IRQ flag


        ; End of irq test, print message and continue
        mov     DPTR,#text2
        call    puts

        ;---- Timer test ---------------------------------------------------
        ; Assume the prescaler is set for a 20ms count period
        
        mov     IE,#000h
        
        mov     TSTAT,#00
        mov     TH,#00
        mov     TL,#00
        mov     TCH,#0c3h           ; Compare register = 50000 = 1 second
        mov     TCL,#050h
        mov     TSTAT,#030h         ; Start counting

        ; Ok, now wait for a little less than 20us and make sure TH:TL has not
        ; changed yet.
        mov     r0,#95              ; We need to wait for 950 clock cycles...
loop0:                              ; ...and this is a 10-clock loop
        nop
        djnz    r0,loop0
        mov     a,TH
        cjne    a,#000h,fail_timer_error
        mov     a,TL
        cjne    a,#000h,fail_timer_error
        
        ; Now wait for another 100 clock cycles and make sure TH:TL has already
        ; changed.
        mov     r0,#10              ; We need to wait for 100 clock cycles...
loop1:                              ; ...and this is a 10-clock loop
        nop
        djnz    r0,loop1
        mov     a,TH
        cjne    a,#000h,fail_timer_error
        mov     a,TL
        cjne    a,#001h,fail_timer_error

        ; End of timer test, print message and continue
        mov     DPTR,#text5
        call    puts

        ;-- End of test program, enter single-instruction endless loop
quit:   ajmp    $


fail_timer_error:
        mov     DPTR,#text4
        call    puts
        mov     IE,#00h
        ajmp    $


        ; Did not get expected IRQ: print failure message and block.
fail_expected:
        mov     DPTR,#text3
        call    puts
        mov     IE,#00h
        ajmp    $

        ; Got unexpected IRQ: print failure message and block.
fail_unexpected:
        mov     DPTR,#text1
        call    puts
        mov     IE,#00h
        ajmp    $

;-- puts: output to UART a zero-terminated string at DPTR ----------------------
puts:
        mov     r0,#00h
puts_loop:
        mov     a,r0
        inc     r0
        movc    a,@a+DPTR
        jz      puts_done

        putc    a
        sjmp    puts_loop
puts_done:
        ret

;-- irq_timer: interrupt routine for timer -------------------------------------
; Note we don't bother to preserve any registers
irq_ext:
        mov     P1,#00h             ; Remove the external interrupt request
        mov     EXTINT0,#0ffh       ; Clear all external IRQ flags
        inc     ext_irq_ctr         ; Increment irq counter
        mov     DPTR,#text0         ; Print IRQ message...
        call    puts
        reti                        ; ...and quit
        
irq_timer:
irq_wrong:
        ajmp    irq_wrong




text0:  db      '<External irq>',13,10,00h,00h
text1:  db      'Unexpected IRQ',13,10,00h,00h
text2:  db      'IRQ test finished, no errors',13,10,0
text3:  db      'Missing IRQ',13,10,0
text4:  db      'Timer error',13,10,0
text5:  db      'Timer test finished, no errors',13,10,0
    
        end
