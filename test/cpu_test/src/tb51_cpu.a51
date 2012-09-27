;-------------------------------------------------------------------------------
; tb51_cpu.a51 -- MCS51 instruction set test bench.
;-------------------------------------------------------------------------------
; This program is meant to verify the basic operation of an MCS51 CPU
; instruction set implementation.
; It is far too weak to rely on it exclusively but it can help detect gross
; implementation errors (overclocked CPUs, timing errors in FPGA cores, that
; kind of thing).
;
; The program is not yet ready to run on actual hardware (UART interface).
;
; For a full verification of the instruction set, an instruction set exerciser
; such as 'zexall' for the Z80 would be more suitable. This one is too weak.
;
; The program is meant to run in actual hardware or on a simulated environment.
; In the latter case you can use the co-simulation features of the light52
; project to pinpoint bugs.
;
; FIXME add assembly option to run tests in an (possibly infinite) loop.
;-------------------------------------------------------------------------------
; Major limitations:
;   1.- PSW is not checked for undue changes.
;   2.- <#imm> instructions are tested with one imm value only.
;   3.- <rel> jumps tested with small values (not near corner values).
;   4.- <bit> tested on 1 byte only, on 2 bits only.
;   5.- BCD instructions (DA, XCHG) not tested at all.
;
; Note there are too many limitations to list. Use this test bench as a first
; approximation only. If your CPU fails this test, it must be dead!
;-------------------------------------------------------------------------------
    
        ; Include the definitions for the light52 derivative
        $nomod51
        $include (light52.mcu)
    
        ;-- Parameters common to all tests -------------------------------------
        
dir0    set     060h                ; Address used in direct addressing tests
dir1    set     061h                ; Address used in direct addressing tests
fail    set     06eh                ; (IDATA) set to 1 upon test failure
saved_psw set   070h                ; (IDATA) temp store for PSW value
stack0  set     09fh                ; (IDATA) stack addr used for push/pop tests
    
    
        ;-- Macros common to all tests -----------------------------------------

        ; putc: send character to console (UART)
        ; If you change this macro, make sure it DOES NOT MODIFY PSW!
putc    macro   character
        local   putc_loop
putc_loop:
        ;jnb     SCON.1,putc_loop
        ;clr     SCON.1
        mov     SBUF,character
        endm
        
        ; put_crlf: send CR+LF to console
put_crlf macro
        putc    #13
        putc    #10
        endm
    
        ;eot char, label: 'end of test' to be used at the end of all tests.
        ; If you run into this macro it will print character 'char' and
        ; continue.
        ; If you jump to label 'label', it will instead print char '?' and
        ; will set variable 'fail' to 1, then it will continue.
eot     macro   char,label
        local   skip
        putc    #char
        sjmp    skip
label:  putc    #'?'
        mov     fail,#001h
skip:
        endm
    
        ;-- Reset & interrupt vectors ------------------------------------------

        org     00h
        ljmp    start               ;
        org     03h
        org     0bh
        org     13h
        org     1bh
        org     23h


        ;-- Main test program --------------------------------------------------
        org     30h
start:
        ; Initialize serial port
        ;(leave it with the default configuration: 19200-8-N-1)
        ;mov     TMOD,#20h           ; C/T = 0, Mode = 2
        ;mov     TH1,#0fdh           ; 9600 bauds @11.xxx MHz
        ;mov     TCON,#40h           ; Enable T1
        ;mov     SCON,#52h           ; 8/N/1, TI enabled
        
        ; Clear failure flag
        mov     fail,#000h


        ;-- Test series A ------------------------------------------------------
        ; Test the basic opcodes needed in later tests:
        ; a.- Serial port initialization is OK
        ; a.- Bootstrap instructions work as used
        ; b.- <SJMP rel> (small positive rel only)
        ; c.- ACC can be loaded with direct mode addressing (as an SFR)
        ; c.- <CJNE a,#imm,rel>
        ; d.- <DJNZ dir, rel> (small positive rel only)
        ; e.- <MOV  a,dir>
        ; Note that one instance of LJMP has been tested too.

        putc    #'A'                ; start of test series

        ; If we arrive here at all, and you see the chars in the
        ; terminal, the A.a test has passed
        putc    #'a'

        sjmp    ta_b0               ; <SJMP rel> with very small positive rel
        putc    #'?'
        mov     fail,#001h
ta_b0:  putc    #'b'


ta_c0:  sjmp    ta_c1
ta_c3:  putc    #'c'
        sjmp    ta_c4
ta_c1:  mov     0e0h,#5ah           ; load A as SFR
        cjne    a,#5ah,ta_c3        ; test cjne with == args...
        cjne    a,#7ah,ta_c2        ; ...with != args, rel>0...
        putc    #'?'
        mov     fail,#001h
ta_c2:  cjne    a,#7ah,ta_c3        ; ...and with != args, rel<0
        putc    #'?'
        mov     fail,#001h
ta_c4:

        mov     dir0,#02h
        djnz    dir0,ta_d1
        putc    #'?'
        mov     fail,#001h
ta_d1:  djnz    dir0,ta_d2

        eot     'd',ta_d2

        mov     dir0,#0a5h          ; test mov a,dir
        mov     a,dir0
        cjne    a,#0a5h,ta_e1

        eot     'e',ta_e1

        put_crlf                    ; end of test series
        
        ;-- Test series B ------------------------------------------------------
        ; Test CJNE plus a few aux opcodes
        ; a.- <MOV Rn, #imm>
        ; a.- <MOV a, Rn>
        ; b.- <JC rel>, <JNC rel>
        ; c.- <CJNE Rn, #imm, rel>
        ; d.- <SETB C>, <CLR C>, <CPL C>
        ; e.- <MOV @Ri, #imm>
        ; f.- <CJNE @Ri, #imm, rel>
        ; g.- <CJNE A, dir, rel>

        putc    #'B'                ; start of test series

tb_ma   macro   reg,val
        mov     reg,val
        mov     a,reg
        cjne    a,val,tb_a1
        endm
        
        tb_ma   r0,#081h
        tb_ma   r1,#043h
        tb_ma   r2,#027h
        tb_ma   r3,#0c2h
        tb_ma   r4,#0f1h
        tb_ma   r5,#004h
        tb_ma   r6,#092h
        tb_ma   r7,#01fh

        eot     'a',tb_a1

        mov     PSW,#80h            ; <JC rel>, <JNC rel>
        jc      tb_b0
        putc    #'?'
        mov     fail,#001h
tb_b0:  jnc     tb_b1
        mov     PSW,#00h
        jc      tb_b1
        jnc     tb_b2
tb_b1:  putc    #'?'
        mov     fail,#001h
tb_b2:  putc    #'b'

tb_mc   macro   reg,val
        local   tb_mc0
        local   tb_mc1
        mov     reg,val+1
        cjne    reg,val,tb_mc0
        putc    #'?'
        mov     fail,#001h
tb_mc1: mov     reg,val
tb_mc0: cjne    reg,val,tb_mc1
        endm

        tb_mc   r0,#091h            ; first test the jumps for all Rn regs
        tb_mc   r1,#0a2h
        tb_mc   r2,#0b3h
        tb_mc   r3,#0c4h
        tb_mc   r4,#0d5h
        tb_mc   r5,#0e6h
        tb_mc   r6,#0f7h
        tb_mc   r7,#008h
        
tb_c0:  mov     PSW,#00h            ; now test the C flag with a single Rn reg
        mov     r0,#034h
        cjne    r0,#035h,tb_c1
tb_c1:  jnc     tb_c2
        cjne    r0,#034h,tb_c3
tb_c3:  jc      tb_c2
        cjne    r0,#033h,tb_c4
tb_c4:  jc      tb_c2

        eot     'c',tb_c2

        mov     PSW,#80h            ; test C set, reset and complement
        clr     c
        jc      tb_d0
        setb    c
        jnc     tb_d0
        cpl     c
        jc      tb_d0

        eot     'd',tb_d0

tb_me   macro   reg                 
        mov     reg,#dir0
        mov     dir0,#12h
        mov     a,dir0
        cjne    a,#012h,tb_e0
        mov     @reg,#0f5h
        mov     a,dir0
        cjne    a,#0f5h,tb_e0
        endm

        tb_me   r0                  ; test <mov @ri, #imm> with both regs
        tb_me   r1

        eot     'e',tb_e0

tb_mf   macro   reg,val
        local   tb_mf0
        local   tb_mf1
        mov     reg,#30h
        mov     @reg,val+1
        cjne    @reg,val,tb_mf0
        putc    #'?'
        mov     fail,#001h
tb_mf1: mov     @reg,val
tb_mf0: cjne    @reg,val,tb_mf1
        endm
        
        tb_mf   r0,#12h
        tb_mf   r1,#34h

tb_f0:  mov     r0,#30h             ; now test the C flag with a single Rn reg
        clr     c
        mov     @r0,#034h
        cjne    @r0,#035h,tb_f1
tb_f1:  jnc     tb_f2
        cjne    @r0,#034h,tb_f3
tb_f3:  jc      tb_f2
        cjne    @r0,#033h,tb_f4
tb_f4:  jc      tb_f2

        eot     'f',tb_f2

        mov     dir0,#0c0h
        mov     031h,#0c1h
        mov     032h,#0c2h
        clr     c
        mov     a,#0c1h
        cjne    a,031h,tb_g0
        jc      tb_g0
        cjne    a,032h,tb_g1
        putc    #'?'
        mov     fail,#001h
tb_g1:  jnc     tb_g0
        cjne    a,dir0,tb_g2
        putc    #'$'
        mov     fail,#001h
tb_g2:  jc      tb_g0
        
        eot     'g',tb_g0
        
        put_crlf                    ; end of test series


        ;-- Test series C ------------------------------------------------------
        ; Bit operations and the rest of the conditional rel jumps
        ; The following tests will use a bit address within the IRAM
        ; a.- <JB bit, rel>, <JNB bit, rel>
        ; b.- <MOV A, #imm>
        ; c.- <JZ rel>, <JNZ rel>
        ; d.- <CLR bit>, <CPL bit>
        ; e.- <ANL C, bit>, <ORL C, bit>
        ; e.- <ANL C, /bit>, <ORL C, /bit>
        ; f.- <MOV C,bit>, <MOV bit, C>
        ; g.- <SETB bit>
        ; h.- <JBC bit>
        ; The following tests are the same as above except a bit address within
        ; SFR B is used.
        ; i.- <JB bit, rel>, <JNB bit, rel>
        ; j.- <CLR bit>, <CPL bit>
        ; k.- <ANL C, bit>, <ORL C, bit>
        ; k.- <ANL C, /bit>, <ORL C, /bit>
        ; l.- <MOV C,bit>, <MOV bit, C>
        ; m.- <SETB bit>
        ; n.- <JBC bit>

        putc    #'C'                ; start of test series

        mov     02fh,#80h           ; We'll be testing bits 2F.7 and 2F.6
        sjmp    tc_a0
tc_a1:  jnb     07fh,tc_a3          ; JNB jumps not on bit set
        jnb     07eh,tc_a2          ; JNB jumps on bit clear
        putc    #'?'
        mov     fail,#001h
        sjmp    tc_a3
tc_a0:  jb      07fh,tc_a1          ; JB jumps on bit set
        putc    #'!'
        mov     fail,#001h
tc_a2:  jb      07eh,tc_a3          ; JB jumps not on bit clear

        eot     'a',tc_a3

        mov     0e0h,#079h          ; init acc (as sfr) with some data
        cjne    a,#079h,tc_b1
        mov     a,#05ah             ; now load a with imm data...
        cjne    a,#05ah,tc_b1       ; ...and make sure a got the data

        eot     'b',tc_b1

        mov     a,#80h
        sjmp    tc_c0
tc_c1:  jz      tc_c3               ; JZ jumps not on acc!=0
        mov     a,#00h
        jz      tc_c2               ; JZ jumps on acc==0
        putc    #'?'
        mov     fail,#001h
        sjmp    tc_c3
tc_c0:  jnz     tc_c1               ; JNZ jumps on acc!=0
        putc    #'!'
        mov     fail,#001h
tc_c2:  jnz     tc_c3               ; JNZ jumps not on acc==0

        eot     'c',tc_c3


        mov     02fh,#80h           ; We'll be testing bit 2F.7
        jb      07fh,tc_d1
        sjmp    tc_d0
tc_d1:  clr     07fh
        jb      07fh,tc_d0
        cpl     07fh
        jnb     07fh,tc_d0
        
        eot     'd',tc_d0

        mov     02eh,#08h           ; We'll be testing bits 2E.3 and 2E.2
        clr     c
        anl     c,073h              ; Test ANL in all 4 input combinations
        jc      tc_e0
        setb    c
        anl     c,073h
        jnc     tc_e0
        anl     c,/072h
        jnc     tc_e0
                                    ; CY == 1
        orl     c,073h              ; ORL-ing with 1 should give 1
        jnc     tc_e0
        orl     c,072h
        jnc     tc_e0
        clr     c                   ; CY == 0
        orl     c,073h              ; Now ORL c, 'bit' should give 'bit'
        jnc     tc_e0
        orl     c,/072h
        jnc     tc_e0

        eot     'e',tc_e0

        mov     02eh,#08h           ; We'll be testing bits 2E.3 and 2E.2
        clr     c
        mov     c,073h
        jnc     tc_f0
        mov     c,072h
        jc      tc_f0
        clr     c
        mov     071h,c
        jb      071h,tc_f0
        setb    c
        mov     071h,c
        jnb     071h,tc_f0

        eot     'f',tc_f0

        mov     02eh,#00h           ; We'll be testing bits 2E.3 and 2E.2
        setb    073h
        mov     c,073h
        jnc     tc_g0
        setb    072h
        mov     c,072h
        jnc     tc_g0
        
        eot     'g',tc_g0

        ; (better read the following code in execution order)
        mov     02eh,#08h           ; We'll be testing bits 2E.3 and 2E.2
        sjmp    tc_h1               ; jump forward so we can test jump backwards
tc_h2:  mov     c,073h              ; make sure the target bit is clear
        jc      tc_h0
        jbc     072h,tc_h0          ; JBC jumps not when target bit clear
        sjmp    tc_h3
tc_h1:  jbc     073h,tc_h2          ; JBC jumps when target bit set
        sjmp    tc_h0
tc_h3:

        eot     'h',tc_h0

        mov     02fh,#00h
        mov     B,#80h              ; We'll be testing bits B.7 and B.6
        sjmp    tc_i0
tc_i1:  jnb     B.7,tc_i3           ; JNB jumps not on bit set
        jnb     B.6,tc_i2           ; JNB jumps on bit clear
        putc    #'?'
        mov     fail,#001h
        sjmp    tc_i3
tc_i0:  jb      B.7,tc_i1           ; JB jumps on bit set
        putc    #'!'
        mov     fail,#001h
tc_i2:  jb      B.6,tc_i3           ; JB jumps not on bit clear

        eot     'i',tc_i3

        mov     B,#80h              ; We'll be testing bit B.7
        jb      B.7,tc_j1
        sjmp    tc_j0
tc_j1:  clr     B.7
        jb      B.7,tc_j0
        cpl     B.7
        jnb     B.7,tc_j0

        eot     'j',tc_j0

        mov     B,#08h              ; We'll be testing bits B.3 and B.2
        clr     c
        anl     c,B.3               ; Test ANL in all 4 input combinations
        jc      tc_k0
        setb    c
        anl     c,B.3
        jnc     tc_k0
        anl     c,/B.2
        jnc     tc_k0
                                    ; CY == 1
        orl     c,B.3               ; ORL-ing with 1 should give 1
        jnc     tc_k0
        orl     c,B.2
        jnc     tc_k0
        clr     c                   ; CY == 0
        orl     c,B.3               ; Now ORL c, 'bit' should give 'bit'
        jnc     tc_k0
        orl     c,/B.2
        jnc     tc_k0

        eot     'k',tc_k0

        mov     B,#08h              ; We'll be testing bits B.3, B.2 and B.1
        clr     c
        mov     c,B.3
        jnc     tc_L0
        mov     c,B.2
        jc      tc_L0
        clr     c
        mov     B.1,c
        jb      B.1,tc_L0
        setb    c
        mov     B.1,c
        jnb     B.1,tc_L0

        eot     'l',tc_L0

        mov     02eh,#00h           ; We'll be testing bits B.3 and B.2
        setb    B.3
        mov     c,B.3
        jnc     tc_m0
        setb    B.2
        mov     c,B.2
        jnc     tc_m0

        eot     'm',tc_m0

        ; (better read the following code in execution order)
        mov     B,#08h              ; We'll be testing bits B.3 and B.2
        sjmp    tc_n1               ; jump forward so we can test jump backwards
tc_n2:  mov     c,B.3               ; make sure the target bit is clear
        jc      tc_n0
        jbc     B.2,tc_n0           ; JBC jumps not when target bit clear
        sjmp    tc_n3
tc_n1:  jbc     B.3,tc_n2           ; JBC jumps when target bit set
        sjmp    tc_n0
tc_n3:

        eot     'n',tc_n0



        put_crlf                    ; end of test series

        ;-- Test series D ------------------------------------------------------
        ;
        ; a.- <XRL A, #imm>
        ; b.- <RLC A>
        ; c.- <RRC A>
        ; d.- <RL A>, <RR A>
        ;
        ; This test executes a few NOPs too but does NOT check for unintended
        ; side effects; we intersperse the nops between the other tests to at
        ; least have a chance to catch buggy behavior but that's all.


        putc    #'D'                ; start of test series

        mov     a,#085h             ; test XRL A,#imm before using it in
        xrl     a,#044h             ; subsequent tests
        jz      td_a0
        xrl     a,#0c1h
        jnz     td_a0

        eot     'a',td_a0

        mov     a,#085h             ; Test RLC effects on ACC, ignore CY for now
        nop
        clr     c
        rlc     a                   ; a = (a << 1) | 0
        mov     dir0,a
        xrl     a,#00ah             ; We can't use CJNE because it modifies CY
        jnz     td_b0               ; check shifted acc
        mov     a,dir0
        rlc     a                   ; rotate again...
        xrl     a,#015h             ; ...and check shifted acc with CY at bit 0
        jnz     td_b0
        
        mov     a,#085h             ; Now check RLC effects on CY
        nop
        clr     c
        rlc     a
        jnc     td_b0
        rlc     a
        jc      td_b0               ; CY==1 moved into ACC.0

        eot     'b',td_b0

        mov     a,#085h             ; Test RRC effects on ACC, ignore CY for now
        clr     c
        rrc     a                   ; will set CY
        mov     dir0,a
        nop
        xrl     a,#042h             ; We can't use CJNE because it modifies CY
        jnz     td_c0               ; check shifted acc
        mov     a,dir0
        rrc     a                   ; rotate again...
        xrl     a,#0a1h             ; ...and check shifted acc with CY at bit 7
        jnz     td_c0

        mov     a,#085h             ; Now check RRC effects on CY
        clr     c
        rrc     a
        jnc     td_c0
        rrc     a
        jc      td_c0               ; CY==1 moved into ACC.0

        eot     'c',td_c0

        mov     a,#085h             ; Test RL effects on ACC, ignore CY for now
        clr     c
        rl      a                   ; a = (a << 1) | 0
        mov     dir0,a
        xrl     a,#00bh             ; We can't use CJNE because it modifies CY
        jnz     td_d0               ; check shifted acc
        mov     a,dir0
        setb    c
        rl      a                   ; rotate again...
        xrl     a,#016h             ; ...and check shifted acc with CY at bit 0
        jnz     td_d0

        mov     a,#085h             ; Test RR effects on ACC, ignore CY for now
        clr     c
        rr      a                   ; will set CY
        mov     dir0,a
        xrl     a,#0c2h             ; We can't use CJNE because it modifies CY
        jnz     td_d0               ; check shifted acc
        mov     a,dir0
        rr      a                   ; rotate again...
        xrl     a,#061h             ; ...and check shifted acc with CY at bit 7
        jnz     td_d0

        mov     a,#0ffh             ; Now make sure RL and RR don't touch CY
        clr     c
        rl      a
        jc      td_d0
        rr      a
        rr      a
        jc      td_d0

        eot     'd',td_d0

        put_crlf                    ; end of test series

        ;-- Test series E ------------------------------------------------------
        ; Increment
        ; a.- <INC A>
        ; b.- <INC Rn>
        ; c.- <INC @Ri>
        ; d.- <MOV dir,#imm>
        ; e.- <INC dir>
        ; f.- <DEC A>
        ; g.- <DEC Rn>
        ; h.- <DEC @Ri>
        ; i.- <DEC dir>

        putc    #'E'                ; start of test series

te_ma   macro   target, error_loc
        mov     target,#080h
        inc     target
        cjne    target,#081h,error_loc
        mov     target,#0ffh
        clr     c
        inc     target
        jc      error_loc
        cjne    target,#000h,error_loc
        endm

        te_ma   a,te_a0             ; Test <INC A>
        
        eot     'a',te_a0
        
        mov     r0,#066h
        
        te_ma   r0,te_b0
        te_ma   r1,te_b0
        te_ma   r2,te_b0
        te_ma   r3,te_b0
        te_ma   r4,te_b0
        te_ma   r5,te_b0
        te_ma   r6,te_b0
        te_ma   r7,te_b0

        eot     'b',te_b0

        mov     r0,#dir0
        mov     r1,#031h
        
        te_ma   @r0,te_c0
        te_ma   @r1,te_c0

        eot     'c',te_c0

        mov     dir0,#034h          ; Test <MOV dir,#imm> before using it in
        mov     a,dir0              ; subsequent tests
        cjne    a,#034h,te_d0

        eot     'd',te_d0

        mov     039h,#080h
        inc     039h
        mov     a,039h
        cjne    a,#081h,te_e0
        mov     039h,#0ffh
        clr     c
        inc     039h
        jc      te_e0
        mov     a,039h
        cjne    a,#000h,te_e0

        eot     'e',te_e0

te_mf   macro   target, error_loc
        mov     target,#001h
        dec     target
        cjne    target,#000h,error_loc
        clr     c
        dec     target
        jc      error_loc
        cjne    target,#0ffh,error_loc
        endm

        te_ma   a,te_f0             ; Test <INC A>

        eot     'f',te_f0

        mov     r0,#066h

        te_ma   r0,te_g0
        te_ma   r1,te_g0
        te_ma   r2,te_g0
        te_ma   r3,te_g0
        te_ma   r4,te_g0
        te_ma   r5,te_g0
        te_ma   r6,te_g0
        te_ma   r7,te_g0

        eot     'g',te_g0

        mov     r0,#dir0
        mov     r1,#031h

        te_ma   @r0,te_h0
        te_ma   @r1,te_h0

        eot     'h',te_h0

        mov     dir0,#034h          ; Test <MOV dir,#imm> before using it in
        mov     a,dir0              ; subsequent tests
        cjne    a,#034h,te_i0

        eot     'i',te_i0

        put_crlf                    ; end of test series


        ;-- Test series F ------------------------------------------------------
        ;
        ; a.- <MOV dir,Rn>
        ; b.- <MOV dir,@Ri>
        ; c.- <MOV dir,dir>
        ; d.- <MOV Rn,dir>
        ; e.- <MOV @Ri,dir>
        ; f.- <MOV Rn,A>
        ; g.- <MOV @Ri,A>
        ; h.- <MOV dir,A>

        
        putc    #'F'                ; start of test series
        
tf_ma   macro   rn, n, error_loc
        mov     rn,#(091h+n)
        mov     039h,rn
        mov     a,039h
        cjne    a,#(091h+n),error_loc
        endm
        
        tf_ma   r0,0,tf_a0
        tf_ma   r1,1,tf_a0
        tf_ma   r2,2,tf_a0
        tf_ma   r3,3,tf_a0
        tf_ma   r4,4,tf_a0
        tf_ma   r5,5,tf_a0
        tf_ma   r6,6,tf_a0
        tf_ma   r7,7,tf_a0
        
        eot     'a',tf_a0

        tf_ma   @r0,0,tf_b0
        tf_ma   @r1,1,tf_b0

        eot     'b',tf_b0

        mov     031h,#091h
        mov     039h,031h
        mov     a,039h
        cjne    a,#091h,tf_c0

        eot     'c',tf_c0

tf_md   macro   rn, n, error_loc
        mov     039h,#(091h+n)
        mov     rn,039h
        cjne    rn,#(091h+n),error_loc
        endm

        tf_md   r0,0,tf_d0
        tf_md   r1,1,tf_d0
        tf_md   r2,2,tf_d0
        tf_md   r3,3,tf_d0
        tf_md   r4,4,tf_d0
        tf_md   r5,5,tf_d0
        tf_md   r6,6,tf_d0
        tf_md   r7,7,tf_d0
        
        eot     'd',tf_d0

        mov     r0,#dir0
        mov     r1,#031h
        tf_md   @r0,0,tf_e0
        tf_md   @r1,1,tf_e0

        eot     'e',tf_e0

tf_mf   macro   rn, n, error_loc
        mov     a,#(091h+n)
        mov     rn,a
        cjne    rn,#(091h+n),error_loc
        endm

        tf_mf   r0,0,tf_f0
        tf_mf   r1,1,tf_f0
        tf_mf   r2,2,tf_f0
        tf_mf   r3,3,tf_f0
        tf_mf   r5,4,tf_f0
        tf_mf   r5,5,tf_f0
        tf_mf   r6,6,tf_f0
        tf_mf   r7,7,tf_f0
        
        eot     'f',tf_f0

        mov     r0,#dir0
        mov     r1,#031h
        tf_mf   @r0,0,tf_g0
        tf_mf   @r1,1,tf_g0

        eot     'g',tf_g0

        mov     dir0,#079h
        mov     r0,#000h
        mov     a,#34h
        mov     dir0,a
        mov     r0,dir0
        cjne    r0,#034h,tf_h0

        eot     'h',tf_h0

        mov     a,#000h

        mov     r1,#031h
        mov     031h,#056h
        mov     r0,#dir0
        mov     dir0,#034h
        mov     a,@r0
        cjne    a,#034h,tf_i0
        mov     a,@r1
        cjne    a,#056h,tf_i0

        eot     'i',tf_i0

        put_crlf                    ; end of test series


        ;-- Test series G ------------------------------------------------------
        ; Note the XCG tests are specially lame even within this context.
        ; a.- <CLR A>, <CPL A>, <SWAP A>
        ; b.- <INC DPTR>
        ; c.- <XCH A,dir>
        ; d.- <XCH A,@Ri>
        ; e.- <XCH A,Rn>

        putc    #'G'                ; start of test series
        
        mov     a,#055h
        clr     a
        jnz     tg_a0

        mov     a,#055h
        cpl     a
        cjne    a,#0aah,tg_a0
        
        mov     a,#097h
        swap    a
        cjne    a,#079h,tg_a0

        eot     'a',tg_a0
        
        mov     DPH,#012h
        mov     DPL,#0fdh
        inc     dptr
        mov     a,DPH
        cjne    a,#012h,tg_b0
        mov     a,DPL
        cjne    a,#0feh,tg_b0
        inc     dptr
        mov     a,DPH
        cjne    a,#012h,tg_b0
        mov     a,DPL
        cjne    a,#0ffh,tg_b0
        inc     dptr
        mov     a,DPH
        cjne    a,#013h,tg_b0
        mov     a,DPL
        cjne    a,#000h,tg_b0

        eot     'b',tg_b0

        ; c.- <XCH A,dir>
        mov     a,#34h
        mov     13h,#57h
        xch     a,13h
        cjne    a,#57h,tg_c0
        mov     a,13h
        cjne    a,#34h,tg_c0

        eot     'c',tg_c0

        ; d.- <XCH A,@Ri>
        mov     a,#91h
        mov     29h,#78h
        mov     r1,#29h
        xch     a,@r1
        cjne    a,#78h,tg_d0
        mov     a,29h
        cjne    a,#91h,tg_d0

        eot     'd',tg_d0

        ; e.- <XCHG A,Rn>
        mov     a,#43h
        mov     r6,#0a2h
        xch     a,r6
        cjne    a,#0a2h,tg_e0
        mov     a,r6
        cjne    a,#43h,tg_e0

        eot     'e',tg_e0


        put_crlf                    ; end of test series


        ;-- ALU opcode block test ----------------------------------------------
        ; This set of macros is used to test families of opcodes, such as ORL,
        ; ANL, ADD, etc. with all their addressing modes.
        ;
        ; a.- <OP A,dir>, <OP A,@Ri>, <OP A, Rn> (n=0,1)
        ; b.- <OP A, Rn> (n=2,3)
        ; c.- <OP A, Rn> (n=4,5)
        ; d.- <OP A, Rn> (n=6,7)
        ; e.- <OP dir,#imm>, <OP A,#imm>
        ; f.- <OP dir,A>

        ;save_psw:
save_psw macro
        mov     saved_psw,PSW
        endm

tst_psw macro   flags,error_loc
        mov     a,saved_psw
        anl     a,#0c4h
        xrl     a,#flags
        anl     a,#0feh
        jnz     error_loc
        endm

set_cy  macro   flags
        local   cy_val
cy_val  set     (flags and 1)
        if      cy_val eq 1
        setb    c
        else
        clr     c
        endif
        endm

top_ma  macro   op,src,error_loc,flags
        mov     src,#arg0
        mov     a,#arg1
        ifnb    <flags>
        set_cy  flags
        endif
        op      a,src
        ifnb    <flags>
        save_psw
        endif
        cjne    a,#res,error_loc
        ifnb    <flags>
        tst_psw <flags>,error_loc
        endif
        endm

top_mb  macro   op,dst,error_loc,flags
        mov     dst,#arg0
        ifnb    <flags>
        set_cy  flags
        endif
        op      dst,#arg1
        ifnb    <flags>
        save_psw
        endif
        mov     ACC,dst
        cjne    a,#res,error_loc
        ifnb    <flags>
        tst_psw <flags>,error_loc
        endif
        endm

top_mc  macro   op,error_loc,flags
        mov     dir0,#arg0
        mov     a,#arg1
        ifnb    <flags>
        set_cy  flags
        endif
        op      dir0,a
        ifnb    <flags>
        save_psw
        endif
        mov     a,dir0
        cjne    a,#res,error_loc
        ifnb    <flags>
        tst_psw <flags>,error_loc
        endif
        endm


tst_alu macro   op,a0,a1,r,flags
        local   tall_0d
        local   tall_0a
        local   tall_0b
        local   tall_0c
        local   tall_1
        local   tall_2

        arg0    set a0
        arg1    set a1
        res     set r

        top_ma  op,dir0,tall_0a,<flags>
        mov     r0,#dir0
        top_ma  op,@r0,tall_0a,<flags>
        mov     r1,#031h
        top_ma  op,@r1,tall_0a,<flags>

        top_ma  op,r0,tall_0a,<flags>
        top_ma  op,r1,tall_0a,<flags>

        eot     'a',tall_0a

        top_ma  op,r2,tall_0b,<flags>
        top_ma  op,r3,tall_0b,<flags>

        eot     'b',tall_0b

        top_ma  op,r4,tall_0c,<flags>
        top_ma  op,r5,tall_0c,<flags>

        eot     'c',tall_0c

        top_ma  op,r6,tall_0d,<flags>
        top_ma  op,r7,tall_0d,<flags>

        eot     'd',tall_0d
        
        ifb     <flags>

        top_mb  op,a,tall_1,<flags>
        top_mb  op,dir0,tall_1,<flags>

        eot     'e',tall_1

        top_mc  op,tall_2,<flags>

        eot     'f',tall_2
        endif
        endm


        ;-- Test series H ------------------------------------------------------
        ; ANL
        ; (See comments for 'ALU opcode block test')

        putc    #'H'                ; start of test series
        
        tst_alu anl,03ch,099h,018h,

        put_crlf                    ; end of test series


        ;-- Test series I ------------------------------------------------------
        ; ORL
        ; (See comments for 'ALU opcode block test')

        putc    #'I'                ; start of test series

        tst_alu orl,051h,092h,0d3h,

        put_crlf                    ; end of test series

        ;-- Test series J ------------------------------------------------------
        ; XRL
        ; (See comments for 'ALU opcode block test')


        putc    #'J'                ; start of test series

        tst_alu xrl,051h,033h,062h,

        put_crlf                    ; end of test series

        ;-- Test series K ------------------------------------------------------
        ; DJNZ
        ; a.- <DJNZ dir,rel>, <DJNZ Rn,rel> tested only with small negative rels

        putc    #'K'                ; start of test series
        
        ;tk_ma: test DJNZ with parametrizable addressing mode
tk_ma   macro   dst,error_loc
        local   tk_ma0
nloops  set     3
        mov     dst,#nloops         ; We'll perform a fixed no. of iterations
        mov     a,#(nloops+1)       ; A will or our control counter
tk_ma0: dec     a
        jz      error_loc           ; Break loop after nloops iterations
        djnz    dst,tk_ma0          ; Test DJNZ instruction
        cjne    a,#001,error_loc    ; Verify number of iterations is ok
        endm
        
        tk_ma   dir0,tk_a0          ; <DJNZ dir,rel>

        eot     'a',tk_a0

        tk_ma   r0,tk_b0            ; <DJNZ Rn,rel>
        tk_ma   r1,tk_b0
        tk_ma   r2,tk_b0
        tk_ma   r3,tk_b0
        tk_ma   r4,tk_b0
        tk_ma   r5,tk_b0
        tk_ma   r6,tk_b0
        tk_ma   r7,tk_b0

        eot     'b',tk_b0

        put_crlf                    ; end of test series


        ;-- Test series L ------------------------------------------------------
        ; ADD
        ; (See comments for 'ALU opcode block test')


        putc    #'L'                ; start of test series

        putc    #'0'
        tst_alu add,051h,033h,084h,004h     ; /CY /AC  OV
        putc    #'1'
        tst_alu add,081h,093h,014h,084h     ;  CY /AC  OV
        putc    #'2'
        tst_alu add,088h,098h,020h,0c4h     ;  CY  AC  OV

        put_crlf                    ; end of test series


        ;-- Test series M ------------------------------------------------------
        ; ADDC
        ; (See comments for 'ALU opcode block test')
        ; Note the test runs 4 times for different values of operands

        putc    #'M'                ; start of test series

        putc    #'0'
        tst_alu addc,051h,033h,084h,004h     ; /CY /AC  OV
        putc    #'1'
        tst_alu addc,081h,093h,014h,084h     ;  CY /AC  OV
        putc    #'2'
        tst_alu addc,088h,098h,020h,0c4h     ;  CY  AC  OV
        putc    #'3'
        tst_alu addc,088h,098h,021h,0c5h     ;  CY  AC  OV (CY input)


        put_crlf                    ; end of test series


        ;-- Test series N ------------------------------------------------------
        ; SUBB
        ; (See comments for 'ALU opcode block test')
        ; Note the test runs 4 times for different values of operands

        putc    #'N'                ; start of test series

        ;tst_alu <arg2>,<A value>,<result>,<PSW | CY input>
        ;

        putc    #'0'
        tst_alu subb,070h,073h,003h,000h     ; /CY /AC /OV
        putc    #'1'
        tst_alu subb,070h,073h,002h,001h     ; /CY /AC /OV (CY input)
        putc    #'2'
        tst_alu subb,0c3h,0c5h,002h,004h     ; /CY  AC  OV
        putc    #'3'
        tst_alu subb,0c3h,0c5h,001h,005h     ; /CY  AC  OV (CY input)

        ; FIXME subb tests are specially weak

        put_crlf                    ; end of test series


        ;-- Test series O ------------------------------------------------------
        ; PUSH and POP
        ; a.- <PUSH dir (IRAM)>
        ; b.- <POP dir (IRAM)>
        ; c.- <PUSH dir (SFR)>
        ; d.- <POP dir (SFR)>

        putc    #'O'                ; start of test series
        
        ; <PUSH dir (IRAM)>
        mov     SP,#stack0          ; prepare SP...
        mov     dir0,#012h          ; ...and data to be pushed
        mov     r0,#(stack0+1)      ; r0->stack so we can verify data is pushed
        mov     @r0,#000h           ; clear target stack location
        push    dir0                ; <PUSH dir>
        mov     a,@r0               ; verify data has been pushed
        cjne    a,#012h,to_a0
        mov     a,SP                ; verify SP has been incremented
        cjne    a,#(stack0+1),to_a0
        
        eot     'a',to_a0

        ; <POP dir (IRAM)> We'll use the data that was pushed previously
        mov     dir1,#000h          ; clear POP target
        clr     a
        pop     dir1                ; <POP dir>
        mov     r1,#dir1            ; verify data has been popped
        mov     a,@r1
        cjne    a,#012h,to_b0
        mov     a,SP                ; verify SP has been decremented
        cjne    a,#stack0,to_b0

        eot     'b',to_b0
        
        ; <PUSH dir (SFR)>
        mov     SP,#stack0          ; prepare SP...
        mov     B,#042h             ; ...and data to be pushed
        mov     r0,#(stack0+1)      ; r0->stack so we can verify data is pushed
        mov     @r0,#000h           ; clear target stack location
        push    B                   ; <PUSH dir>
        mov     a,@r0               ; verify data has been pushed
        cjne    a,#042h,to_c0
        mov     a,SP                ; verify SP has been incremented
        cjne    a,#(stack0+1),to_c0

        eot     'c',to_c0

        ; <POP dir (SFR)> We'll use the data that was pushed previously
        mov     B,#000h             ; clear POP target
        clr     a
        pop     B                   ; <POP dir>
        mov     a,B                 ; verify data has been popped
        cjne    a,#042h,to_d0
        mov     a,SP                ; verify SP has been decremented
        cjne    a,#stack0,to_d0

        eot     'd',to_d0
        
        put_crlf                    ; end of test series

        ;-- Test series P ------------------------------------------------------
        ; Access to XRAM -- note that current tests are bare-bone minimal!
        ; a.- <MOV DPTR, #16>
        ; b.- <MOVX @DPTR, A>, <MOVX A, @DPTR>
        ; c.- <MOVX A, @Ri>
        ; d.- <MOVX @Ri, A>

        putc    #'P'                ; start of test series

        ; a.- <MOV DPTR, #16>
        mov     DPH,#065h           ; initialize DPTR with known value...
        mov     DPL,#043h

        mov     DPTR,#0123h         ; ...then load it through MOV...
        mov     a,DPH               ; ...and verify the load
        cjne    a,#01h,tp_a0
        mov     a,DPL
        cjne    a,#23h,tp_a0

        eot     'a',tp_a0
        
        
        ; b.- <MOVX @DPTR, A>, <MOVX A, @DPTR>
        ; We have no independent means to verify XRAM writes or reads, other
        ; than the very instructions we're testing. So we should store a data
        ; pattern on XRAM that is difficult to get back 'by chance'.
        ; Ideally we would try all areas of XRAM, back-to-back operations, etc.
        ; For the time being a simple word store will suffice.
        mov     DPTR,#0013h         ; Store 55h, aah at XRAM[0013h]...
        mov     A,#55h
        movx    @DPTR,a
        inc     DPTR
        cpl     a
        movx    @DPTR,a

        mov     DPTR,#0013h         ; ...then verify the store
        movx    a,@DPTR
        cjne    a,#55h,tp_b0
        inc     DPTR
        movx    a,@DPTR
        cjne    a,#0aah,tp_b0

        eot     'b',tp_b0

        ; c.- <MOVX A, @Ri>
        mov     a,#79h              ; change A and DPTR so we can catch fails
        mov     dptr,#0000h
        mov     r0,#13h             ; read back the same data again through
        mov     r1,#14h             ; indexed addressing...
        movx    a,@r0
        cjne    a,#55h,tp_c0
        movx    a,@r1
        cjne    a,#0aah,tp_c0

        eot     'c',tp_c0

        put_crlf                    ; end of test series

        ;-- Test series Q ------------------------------------------------------
        ; MOVC instructions
        ; a.- <MOVC A, @A + PC>
        ; b.- <MOVC A, @A + DPTR>

        putc    #'Q'                ; start of test series

        ; a.- <MOVC A, @A + PC>
        mov     a,#03h              ; we'll read the 4th byte in the table...
        add     a,#02h              ; ...and must account for intervening sjmp
        movc    a,@a+PC
        sjmp    tq0

tq1:    db      07h, 13h, 19h, 21h
tq0:    cjne    a,#21h,tq_a0

        eot     'a',tq_a0
        
        ; b.- <MOVC A, @A + DPTR>
        mov   DPTR,#tq1

        mov   a,#00h
        movc  a,@a+DPTR
        cjne  a,#07h,tq_b0
        
        mov   a,#01h
        movc  a,@a+DPTR
        cjne  a,#13h,tq_b0
        
        mov   a,#02h
        movc  a,@a+DPTR
        cjne  a,#19h,tq_b0

        mov   a,#03h
        movc  a,@a+DPTR
        cjne  a,#21h,tq_b0

        eot     'b',tq_b0

        put_crlf                    ; end of test series


        ;-- Test series R ------------------------------------------------------
        ; ACALL, LCALL instructions
        ; a.- <ACALL addr8>
        ; b.- <LCALL addr16>
        ; c.- <JMP @A+DPTR>
        ;
        ; Biggest limitations:
        ; .- Short jumps; jumps to other pages (!= H addr byte) not tested.
        ;
        ; Note RET is NOT tested here! we don't return from these calls, just
        ; use them as jumps.
        ;

        putc    #'R'                ; start of test series

        mov     SP,#4fh             ; Initialize SP...
        mov     50h,#00h            ; ...and clear stack area
        mov     51h,#00h
        mov     52h,#00h
        mov     53h,#00h

        ; a.- <ACALL addr8>
        ; We should test all code pages eventually...
        acall   tr_sub0             ; Do the call...
tr_rv0: sjmp    tr_a0
tr_sub0:
        mov     A,SP
        cjne    A,#51h,tr_a0       ; ...verify the SP value...
        mov     A,50h
        cjne    A,#LOW(tr_rv0),tr_a0 ; ...and verify the pushed ret address
        mov     A,51h
        cjne    A,#HIGH(tr_rv0),tr_a0

        eot     'a',tr_a0

        ; b.- <LCALL addr16>
        lcall   tr_sub1             ; Do the call...
tr_rv1: sjmp    tr_b0
tr_rv2: nop
        eot     'b',tr_b0
        
        
        ; c.- <JMP @A+DPTR>
        mov     DPTR,#(tr_sub2-33h)
        mov     a,#33h
        jmp     @a+DPTR
        jmp     tr_c0
tr_sub2: jmp     tr_0
        jmp     tr_c0
tr_0:   mov     a,#00h
        mov     a,#00h
        mov     a,#00h
        mov     a,#00h
        
        eot     'c',tr_c0

        put_crlf                    ; end of test series


        ;-- Test series S ------------------------------------------------------
        ; RET, RETI instructions
        ; a.- <RET>
        ; b.- <RETI>
        ;
        ; RETs to different code pages (!= H addr byte) not tested!
        ; Interrupt flag stuff not tested, only RET functionality
        
        putc    #'S'                ; start of test series


        ; a.- <RET>
        mov     SP,#4fh             ; Initialize SP...
        mov     4fh,#HIGH(s_sub0)   ; ...and load stack area with return
        mov     4eh,#LOW(s_sub0)    ; addresses to be tested
        mov     4dh,#HIGH(s_sub1)
        mov     4ch,#LOW(s_sub1)

        ret                         ; Do the ret...
        sjmp    ts_a0
        mov     A,#00h
s_sub0: mov     A,SP
        cjne    A,#4dh,ts_a0       ; ... and verify the SP value

        ret                         ; Do another ret...
        sjmp    ts_a0
        mov     A,#00h
s_sub1: mov     A,SP
        cjne    A,#4bh,ts_a0       ; ... and verify the SP value

        eot     'a',ts_a0


        ; a.- <RETI>
        mov     SP,#4fh             ; Initialize SP...
        mov     4fh,#HIGH(s_sub2)   ; ...and load stack area with return
        mov     4eh,#LOW(s_sub2)    ; addresses to be tested
        mov     4dh,#HIGH(s_sub3)
        mov     4ch,#LOW(s_sub3)

        ret                         ; Do the ret...
        sjmp    ts_a0
        mov     A,#00h
s_sub2: mov     A,SP
        cjne    A,#4dh,ts_b0       ; ... and verify the SP value

        ret                         ; Do another ret...
        sjmp    ts_a0
        mov     A,#00h
s_sub3: mov     A,SP
        cjne    A,#4bh,ts_b0       ; ... and verify the SP value

        eot     'b',ts_b0

        ; Lots of things can go badly and we wouldn't know with this test...
        put_crlf                    ; end of test series

        ;-- Test series T ------------------------------------------------------
        ; MUL, DIV instructions
        ; a.- <DIV>
        ; b.- <MUL>
        ;

        putc    #'T'                ; start of test series

        ; a.- <DIV>
        mov     B,#07h              ; First of all, make sure B can be read back
        mov     A,#13h
        mov     A,B
        cjne    A,#07h,tt_a0
        
        ; Now do a few representative DIVs using a table. The table has the
        ; following format:
        ; denominator, numerator, overflow, quotient, remainder
        ; Where 'overflow' is 00h or 04h.

        ; DPTR will point to the start of the table, r0 will be the current data
        ; byte offset and r1 the number of test cases remaiining.
        mov     DPTR,#tt_a_tab
        mov     r0,#00h
        mov     r1,#((tt_a_tab_end-tt_a_tab)/5)

tt_a_loop:
        mov     a,r0
        inc     r0
        movc    a,@a+DPTR
        mov     B,a
        mov     a,r0
        inc     r0
        movc    a,@a+DPTR
        div     ab
        mov     dir0,a
                      
        mov     a,r0                ; Get expected OV flag
        inc     r0
        movc    a,@a+DPTR
        jnz     tt_a_divzero        ; If OV expected, skip verification of
        mov     a,PSW               ; quotient and remainder
        anl     a,#04h
        jnz     tt_a0
                      
        mov     a,r0                ; Verify quotient...
        inc     r0
        movc    a,@a+DPTR
        cjne    a,dir0,tt_a0
        mov     a,r0                ; ...and verify remainder
        inc     r0
        movc    a,@a+DPTR
        cjne    a,B,tt_a0
        jmp     tt_a_next
        
tt_a_divzero:
        inc     r0
        inc     r0
tt_a_next:
        dec     r1                  ; go for next test vector, if any
        mov     a,r1
        jnz     tt_a_loop
        
        eot     'a',tt_a0
        sjmp    tt_a_tab_end

tt_a_tab:
        db      7,19,0,2,5
        db      7,17,0,2,3
        db      7,13,0,1,6
        db      13,17,0,1,4
        db      17,13,0,0,13
        db      0,13,4,0,13
        db      80h,87h,0,1,7
        db      1,255,0,255,0
        db      2,255,0,127,1
tt_a_tab_end:
        
        ; b.- <MUL>

        ; Do with MUL the same we just did with DIV. The test data table has
        ; the following format:
        ; denominator, numerator, product high byte, product low byte.

        ; DPTR will point to the start of the table, r0 will be the current data
        ; byte offset and r1 the number of test cases remaiining.
        mov     DPTR,#tt_b_tab
        mov     r0,#00h
        mov     r1,#((tt_b_tab_end-tt_b_tab)/4)

tt_b_loop:
        mov     a,r0                ; Load B with test data...
        inc     r0
        movc    a,@a+DPTR
        mov     B,a
        mov     a,r0                ; ...then load A with test data...
        inc     r0
        movc    a,@a+DPTR
        mul     ab                  ; and do the MUL
        mov     dir0,a              ; Save A for later checks

        mov     a,r0                ; Verify product high byte
        ;inc     r0
        movc    a,@a+DPTR
        jz      tt_b_noovf

        mov     a,PSW               ; overflow expected
        anl     a,#04h
        jz      tt_b0
        sjmp    tt_b_0

tt_b_noovf:
        mov     a,PSW               ; no overflow expected
        anl     a,#04h
        jnz     tt_b0

tt_b_0:
        mov     a,r0                ; Verify product high byte
        inc     r0
        movc    a,@a+DPTR
        cjne    a,B,tt_b0
        mov     a,r0                ; ...and verify low byte
        inc     r0
        movc    a,@a+DPTR
        cjne    a,dir0,tt_b0

        dec     r1                  ; go for next test vector, if any
        mov     a,r1
        jnz     tt_b_loop

        eot     'b',tt_b0
        sjmp    tt_b_tab_end

tt_b_tab:
        db      7,19,0,133
        db      7,17,0,119
        db      7,13,0,91
        db      13,17,0,221
        db      17,13,0,221
        db      0,13,0,0
        db      80h,87h,43h,80h
        db      1,255,0,255
        db      2,255,01h,0feh
tt_b_tab_end:

        put_crlf                    ; end of test series
        
        
        
        ;-- Test series U ------------------------------------------------------
        ; Register banks
        ; a.- Write to register, read from indirect address.
        ; a.- Write to indirect address, read from register.
        ;

        putc    #'U'                ; start of test series


        mov     PSW,#00h            ; Test bank 0
        mov     a,#00h + 1
        call    tu_a_test

        mov     PSW,#08h            ; Test bank 1
        mov     a,#08h + 1
        call    tu_a_test
        
        mov     PSW,#10h            ; Test bank 2
        mov     a,#10h + 1
        call    tu_a_test
        
        mov     PSW,#18h            ; Test bank 3
        mov     a,#18h + 1
        call    tu_a_test
        
        sjmp    tu_a_done
        
tu_a_test:
        mov     r0,a                ; R0 points to R1 in the selected bank.
        
        mov     r1,#12h             ; Write to registers R1 and R7
        mov     r7,#34h
        
        mov     a,@r0               ; Check R1
        cjne    a,#12h,tu_a0
        mov     a,#56h              ; Ok, now write to R1 with reg addressing...
        mov     @r0,a               ; ...and check by reading in indirect.
        cjne    r1,#56h,tu_a0
        
        mov     a,r0                ; Set R0 to point to R7 in selected bank
        add     a,#06h
        mov     r0,a
        mov     a,@r0               ; Check R7
        cjne    a,#34h,tu_a0
        
        mov     a,#78h              ; Ok, now write to R7 with reg addressing...
        mov     @r0,a               ; ...and check by reading in indirect.
        cjne    a,#78h,tu_a0
        
        ret

tu_a_done:
        nop
        eot     'a',tu_a0

        put_crlf                    ; end of test series
        
        
        ;-- Template for test series -------------------------------------------

        ;-- Test series X ------------------------------------------------------
        ;
        ; a.-

        ;putc    #'X'                ; start of test series
        ;put_crlf                    ; end of test series

        ;-----------------------------------------------------------------------

        ; Test cases finished. Now print completion message dependent on the
        ; value of the fail flag.
        
        mov     a,fail
        jnz     test_failed

        put_crlf
        putc    #'P'
        putc    #'A'
        putc    #'S'
        putc    #'S'
        put_crlf
        sjmp    quit
        
test_failed:
        put_crlf
        putc    #'F'
        putc    #'A'
        putc    #'I'
        putc    #'L'
        put_crlf
        sjmp    quit

        ;-- End of test program, enter single-instruction endless loop
quit:   ajmp    $
    

        ; We'll place a few test routines in the 2nd half of the code space so
        ; we can test long jumps and calls onto different code pages.
        org     8000h

        ; tr_sub1: part of the LCALL test.
tr_sub1:
        mov     A,SP
        cjne    A,#53h,tr_sub1_fail ; ...verify the SP value...
        mov     A,52h               ; ...and verify the pushed ret address
        cjne    A,#LOW(tr_rv1),tr_sub1_fail
        mov     A,53h
        cjne    A,#HIGH(tr_rv1),tr_sub1_fail
        ljmp    tr_rv2
tr_sub1_fail:
        ljmp    tr_b0
    
        end
