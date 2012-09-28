
library ieee,modelsim_lib;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;

use modelsim_lib.util.all;
use std.textio.all;
use work.txt_util.all;

package light52_tb_pkg is

-- Maximum line size of for console output log. Lines longer than this will be
-- truncated.
constant CONSOLE_LOG_LINE_SIZE : integer := 1024*4;

type t_addr_array is array(0 to 1) of t_address;
constant BRAM_ADDR_LEN : integer := log2(BRAM_SIZE);
subtype t_bram_addr is unsigned(BRAM_ADDR_LEN-1 downto 0);



type t_log_info is record
    acc_input :             t_byte;
    load_acc :              std_logic;
    a_reg_prev :            t_byte;
    update_sp :             std_logic;
    sp_reg_prev :           t_byte;
    sp :                    t_byte;
    rom_size :              natural;
    
    update_psw_flags :      std_logic_vector(1 downto 0);
    psw :                   t_byte;
    psw_prev :              t_byte;
    psw_update_addr :       t_address;
    
    inc_dptr :              std_logic;
    inc_dptr_prev :         std_logic;
    dptr :                  t_address;
    
    xdata_we :              std_logic;
    xdata_vma :             std_logic;
    xdata_addr :            t_address;
    xdata_wr :              t_byte;
    xdata_rd :              t_byte;
    
    code_addr :             t_address;
    pc :                    t_address;
    pc_prev :               t_address;
    next_pc :               t_address;
    pc_z :                  t_addr_array;
    ps :                    t_cpu_state;
    
    bram_we :               std_logic;
    bram_wr_addr :          t_bram_addr;
    bram_wr_data_p0 :       t_byte;
    
    sfr_we :                std_logic;
    sfr_wr :                t_byte;
    sfr_addr :              t_byte;
    
    -- Console log line buffer --------------------------------------
    con_line_buf :         string(1 to CONSOLE_LOG_LINE_SIZE);
    con_line_ix :          integer;
    
    -- Log trigger --------------------------------------------------
    -- Enable logging after fetching from a given address -----------
    log_trigger_address :   t_address;
    log_triggered :         boolean;

end record t_log_info;

function hstr(slv: unsigned) return string;

procedure log_cpu_status(
                signal info :   inout t_log_info;
                file l_file :   TEXT;
                file con_file : TEXT);

procedure log_cpu_activity(
                signal clk :    in std_logic;
                signal reset :  in std_logic;
                signal done :   in std_logic;   
                mcu :           string;
                signal info :   inout t_log_info; 
                rom_size :      natural;
                iname :         string;
                trigger_addr :  in t_address;
                file l_file :   TEXT;
                file con_file : TEXT);

-- Flush console output to log console file (in case the end of the
-- simulation caught an unterminated line in the buffer)
procedure log_flush_console(
                signal info :   in t_log_info;
                file con_file : TEXT);
                
end package;

package body light52_tb_pkg is

function hstr(slv: unsigned) return string is
begin
    return hstr(std_logic_vector(slv));
end function hstr;


procedure log_cpu_status(
                signal info :   inout t_log_info;
                file l_file :   TEXT;
                file con_file : TEXT) is
variable bram_wr_addr : unsigned(7 downto 0);
begin

    bram_wr_addr := info.bram_wr_addr(7 downto 0);

    -- Log writes to IDATA BRAM
    if info.bram_we='1' then
        print(l_file, "("& hstr(info.pc)& ") ["& hstr(bram_wr_addr) & "] = "&
              hstr(info.bram_wr_data_p0) );
    end if;
    
    -- Log writes to SFRs
    if info.sfr_we = '1' then
        print(l_file, "("& hstr(info.pc)& ") SFR["& 
              hstr(info.sfr_addr)& "] = "& hstr(info.sfr_wr));
    end if;
    
    -- Log ACC updates
    if (info.load_acc='1') then
        if info.a_reg_prev /= info.acc_input then
            print(l_file, "("& hstr(info.pc)& ") A = "& 
                hstr(info.acc_input) );
         end if;
        info.a_reg_prev <= info.acc_input;
    end if;

    -- Log XRAM writes
    if (info.xdata_we='1') then
         print(l_file, "("& hstr(info.pc)& ") <"&
                hstr(info.xdata_addr)& "> = "& 
                hstr(info.xdata_wr) );
    end if;    
    
    -- Log SP explicit and implicit updates.
    -- At the beginning of each instruction we log the SP change if there is 
    -- any. SP changes at different times for different instructions. This way,
    -- the log is always done at the end of the instruction execution, as is
    -- done in B51.
    if (info.ps=fetch_1) then
        if info.sp_reg_prev /= info.sp then
            print(l_file, "("& hstr(info.pc)& ") SP = "& 
                hstr(info.sp) );
         end if;
        info.sp_reg_prev <= info.sp;
    end if;
    
    -- Log DPTR increments
    if (info.inc_dptr_prev='1') then
         print(l_file, "("& hstr(info.pc)& ") DPTR = "& 
               hstr(info.dptr) );
    end if;    
    info.inc_dptr_prev <= info.inc_dptr;
   
    -- Console logging ---------------------------------------------------------
    -- TX data may come from the high or low byte (opcodes.s
    -- uses high byte, no_op.c uses low)
    if info.sfr_we = '1' and info.sfr_addr = X"99" then
    
        -- UART TX data goes to output after a bit of line-buffering
        -- and editing
        if info.sfr_wr = X"0A" then
            -- CR received: print output string and clear it
            print(con_file, info.con_line_buf(1 to info.con_line_ix));
            info.con_line_ix <= 1;
            info.con_line_buf <= (others => ' ');
        elsif info.sfr_wr = X"0D" then
            -- ignore LF
        else
            -- append char to output string
            if info.con_line_ix < info.con_line_buf'high then
                info.con_line_buf(info.con_line_ix) <= 
                        character'val(to_integer(info.sfr_wr));
                info.con_line_ix <= info.con_line_ix + 1;
                --print(str(info.con_line_ix));
            end if;
        end if;
    end if;    
    
    -- Log jumps 
    -- FIXME remove internal state dependency
    if info.ps = long_jump or 
       info.ps = lcall_4 or 
       info.ps = jmp_adptr_0 or
       info.ps = ret_3 or
       info.ps = rel_jump or 
       info.ps = cjne_a_imm_2 or
       info.ps = cjne_rn_imm_3 or
       info.ps = cjne_ri_imm_5 or
       info.ps = cjne_a_dir_3 or
       info.ps = jrb_bit_4 or
       info.ps = djnz_dir_4
       then
        -- Catch attempts to jump to addresses out of the ROM bounds -- assume
        -- mirroring is not expected to be useful in this case.
        -- Note it remains possible to just run into uninitialized ROM areas
        -- or out of ROM bounds, we're not checking any of that.
        assert info.next_pc < info.rom_size
        report "Jump to unmapped code address "& hstr(info.next_pc)& 
               "h at "& hstr(info.pc)& "h. Simulation stopped."
        severity failure;
        
        print(l_file, "("& hstr(info.pc)& ") PC = "& 
            hstr(info.next_pc) );
    end if;

    -- Log PSW implicit updates: first, whenever the PSW is updated, save the PC
    -- for later reference...
    if (info.update_psw_flags(0)='1' or info.load_acc='1') then
        info.psw_update_addr <= info.pc;
    end if;    
    -- ...then, when the PSW change is actually detected, log it along with the
    -- PC value we saved before.
    -- The PSW changes late in the instruction cycle and we need this trick to
    -- keep the logs ordered.
    if (info.psw) /= (info.psw_prev) then
        print(l_file, "("& hstr(info.psw_update_addr)& ") PSW = "& hstr(info.psw) );
        info.psw_prev <= info.psw;
    end if;
   
    -- Stop the simulation if we find an unconditional, one-instruction endless
    -- loop. This will not catch multi-instruction endless loops and is only
    -- intended to replicate the behavior of B51 and give the SW a means to 
    -- cleanly end the simulation.
    if info.ps = long_jump and (info.pc = info.next_pc) then
        assert 1 = 0
        report "NONE. Endless loop encountered. Simulation terminated."
        severity failure;
    end if;
   
    -- Update the address of the current instruction.
    -- The easiest way to know the address of the current instruction is to look
    -- at the state machine; when in state decode_0, we know that the opcode
    -- address was on code_addr bus two cycles earlier.
    -- We don't need to track the PC value cycle by cycle, we only need info.pc
    -- to be valid when the logs above are executed, and that's always after
    -- state decode_0.
    info.pc_z(1) <= info.pc_z(0);
    info.pc_z(0) <= info.code_addr;
    if info.ps = decode_0 then
        info.pc_prev <= info.pc;
        info.pc <= info.pc_z(1);
    end if;

end procedure log_cpu_status;

procedure log_cpu_activity(
                signal clk :    in std_logic;
                signal reset :  in std_logic;
                signal done :   in std_logic;   
                mcu :           string;
                signal info :   inout t_log_info; 
                rom_size :      natural;
                iname :         string;
                trigger_addr :  in t_address;
                file l_file :   TEXT;
                file con_file : TEXT) is

begin
    
    init_signal_spy(mcu& "/cpu/alu/"&"acc_input",    iname&".acc_input", 0);
    init_signal_spy(mcu& "/cpu/alu/"&"load_acc",     iname&".load_acc", 0);
    init_signal_spy(mcu& "/cpu/update_sp",    iname&".update_sp", 0);
    init_signal_spy(mcu& "/cpu/SP_reg",       iname&".sp", 0);
    init_signal_spy(mcu& "/cpu/"&"psw",          iname&".psw", 0);
    init_signal_spy(mcu& "/cpu/"&"update_psw_flags",iname&".update_psw_flags(0)", 0);
    init_signal_spy(mcu& "/cpu/"&"code_addr",    iname&".code_addr", 0);
    init_signal_spy(mcu& "/cpu/"&"ps",           iname&".ps", 0);
    init_signal_spy(mcu& "/cpu/"&"bram_we",      iname&".bram_we", 0);
    init_signal_spy(mcu& "/cpu/"&"bram_addr_p0", iname&".bram_wr_addr", 0);
    init_signal_spy(mcu& "/cpu/"&"bram_wr_data_p0",  iname&".bram_wr_data_p0", 0);
    init_signal_spy(mcu& "/cpu/"&"next_pc",      iname&".next_pc", 0);
    init_signal_spy(mcu& "/cpu/"&"sfr_we",       iname&".sfr_we", 0);
    init_signal_spy(mcu& "/cpu/"&"sfr_wr",       iname&".sfr_wr", 0);
    init_signal_spy(mcu& "/cpu/"&"sfr_addr",     iname&".sfr_addr", 0);
    init_signal_spy(mcu& "/cpu/"&"inc_dptr",     iname&".inc_dptr", 0);
    init_signal_spy(mcu& "/cpu/"&"DPTR_reg",     iname&".dptr", 0);
    init_signal_spy(mcu& "/"&"xdata_we",         iname&".xdata_we", 0);
    init_signal_spy(mcu& "/"&"xdata_vma",        iname&".xdata_vma", 0);
    init_signal_spy(mcu& "/"&"xdata_addr",       iname&".xdata_addr", 0);
    init_signal_spy(mcu& "/"&"xdata_wr",         iname&".xdata_wr", 0);
    

    info.con_line_buf <= (others => ' ');
    
    info.rom_size <= rom_size;
    
    while done='0' loop
        wait until clk'event and clk='1';
        if reset='1' then
            -- Initialize some aux vars so as to avoid spurious 'diffs' upon
            -- reset.
            info.pc <= X"0000";
            info.psw_prev <= X"00";
            info.sp_reg_prev <= X"07";
            info.a_reg_prev <= X"00";
            
            -- Logging must be enabled from outside by setting 
            -- log_trigger_address to a suitable value.
            info.log_trigger_address <= trigger_addr;
            info.log_triggered <= false;
            
            info.con_line_ix <= 1; -- uart log line buffer is empty
        else
            log_cpu_status(info, l_file, con_file);
        end if;
    end loop;

end procedure log_cpu_activity;



procedure log_flush_console(
                signal info :   in t_log_info;
                file con_file : TEXT) is
variable l : line;
begin
    -- If there's any character in the line buffer...
    if info.con_line_ix > 1 then
        -- ...then write the line buffer to the console log file.
        write(l, info.con_line_buf(1 to info.con_line_ix));
        writeline(con_file, l);
    end if;    
end procedure log_flush_console;

end package body;
