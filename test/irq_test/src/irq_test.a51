; irq_test.a51 -- First interrupt srvice test.
;
; This program is meant to run on a light53 MCU with the 8-bit timer. It can be
; run on simulation or in actual hardware.
; Its purpose is to demonstrate the working of the interrupt service logic. No
; actual tests are performed (other than the co-simulation tests), only checks.
;
    
        ;-----------------------------------------------------------------------
        
timer_irq_ctr   set     060h        ; Incremented by timer irq routine

    
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
        ljmp    irq_wrong
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
        ; Initialize timer.
        mov     TL0,#10
        mov     TCON,#20h
        
        ; Trigger timer IRQ with IRQs disabled, it should be ignored.
        mov     timer_irq_ctr,#00
        mov     r7,#10h
        mov     TL0,#10
        mov     TCON,#20h
loop0:
        djnz    r7,loop0
        mov     a,timer_irq_ctr
        cjne    a,#00,fail_unexpected
        setb    TCON.0              ; Clear timer IRQ flag

        ; Trigger timer IRQ with timer IRQ enabled but global IE disabled
        mov     IE,#02h
        mov     timer_irq_ctr,#00
        mov     r7,#10h
        mov     TL0,#10
        mov     TCON,#20h
loop1:
        djnz    r7,loop1
        mov     a,timer_irq_ctr
        cjne    a,#00,fail_unexpected
        setb    TCON.0              ; Clear timer IRQ flag

        ; Trigger timer IRQ with timer and global IRQ enabled
        mov     IE,#82h
        mov     timer_irq_ctr,#00
        mov     r7,#10h
        mov     TL0,#10
        mov     TCON,#20h
loop2:
        djnz    r7,loop2
        mov     a,timer_irq_ctr
        cjne    a,#01,fail_expected


        ;-- End of test program, enter single-instruction endless loop
        mov     DPTR,#text2
        call    puts
quit:   ajmp    $


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
irq_timer:
        setb    TCON.0              ; Clear timer IRQ flag
        inc     timer_irq_ctr       ; Increment irq counter
        mov     DPTR,#text0         ; Print IRQ message...
        call    puts
        reti                        ; ...and quit
        
irq_wrong:
        ajmp    irq_wrong




text0:  db      '<Timer irq>',13,10,00h,00h
text1:  db      'Unexpected IRQ',13,10,00h,00h
text2:  db      'IRQ test finished, no errors',13,10,0
text3:  db      'Missing IRQ',13,10,0
    
        end
