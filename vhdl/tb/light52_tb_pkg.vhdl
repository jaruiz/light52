
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;

--use modelsim_lib.util.all;
use std.textio.all;
use work.txt_util.all;

package light52_tb_pkg is

-- Maximum line size of for console output log. Lines longer than this will be
-- truncated.
constant CONSOLE_LOG_LINE_SIZE : integer := 1024*4;


type t_opcode_cycle_count is record
    min :                   natural;    -- Minimum observed cycle count
    max :                   natural;    -- Maximum observed cycle count
    exe :                   natural;    -- No. times the opcode was executed
end record t_opcode_cycle_count;

type t_cycle_count is array(0 to 255) of t_opcode_cycle_count;

type t_log_info is record
    a_reg_prev :            t_byte;
    sp_reg_prev :           t_byte;
    rom_size :              natural;
    
    psw_prev :              t_byte;
    psw_update_addr :       t_address;
    
    inc_dptr_prev :         std_logic;
       
    pc :                    t_address;
    pc_prev :               t_address;
    pc_z :                  t_addr_array;
    
    delayed_acc_log :       boolean;
    delayed_acc_value :     t_byte;
    
    -- Observed cycle count for all executed opcodes.
    cycles :                t_cycle_count;
    last_opcode :           std_logic_vector(7 downto 0);
    opcode :                std_logic_vector(7 downto 0);
    cycle_count :           natural;
    
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
                signal done :   out std_logic;
                file l_file :   TEXT;
                file con_file : TEXT);

procedure log_cpu_activity(
                signal clk :    in std_logic;
                signal reset :  in std_logic;
                signal done :   inout std_logic;
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

-- Log cycle count data to file.
procedure log_cycle_counts(
                signal info :   in t_log_info);
                
end package;

package body light52_tb_pkg is

function hstr(slv: unsigned) return string is
begin
    return hstr(std_logic_vector(slv));
end function hstr;


procedure log_cpu_status(
                signal info :   inout t_log_info;
                signal done :   out std_logic;
                file l_file :   TEXT;
                file con_file : TEXT) is
variable bram_wr_addr : unsigned(7 downto 0);
variable opc : natural;
variable num_cycles : natural;
variable jump_logged : boolean := false;
begin
    
    jump_logged := false;

    -- Update the opcode observed cycle counters.
    -- For every opcode, we count the cycles from its decode_0 state to the 
    -- next fetch_1 state. To this we have to add 2 (one each for states 
    -- decode_0 and fetch_1) and we have the cycle count.
    -- we store the min and the max because of conditional jumps.
    if (log_ps=decode_0) then
        info.opcode <= info.last_opcode;
        info.cycle_count <= 0;
    else
        if (log_ps=fetch_1) then
            -- In state fetch_1, get the opcode from the bus
            info.last_opcode <= log_code_rd;
            
            if info.opcode/="UUUUUUUU" then
                opc := to_integer(unsigned(info.opcode));
                num_cycles := info.cycle_count + 2;
                if info.cycles(opc).min > num_cycles then
                    info.cycles(opc).min <= num_cycles;
                end if;
                if info.cycles(opc).max < num_cycles then
                    info.cycles(opc).max <= num_cycles;
                end if;
                info.cycles(opc).exe <= info.cycles(opc).exe + 1;
            end if;
        end if;
        info.cycle_count <= info.cycle_count + 1;
    end if;
    
    
    bram_wr_addr := log_bram_wr_addr(7 downto 0);

    -- Log writes to IDATA BRAM
    if log_bram_we='1' then
        print(l_file, "("& hstr(info.pc)& ") ["& hstr(bram_wr_addr) & "] = "&
              hstr(log_bram_wr_data_p0) );
    end if;
    
    -- Log writes to SFRs
    if log_sfr_we = '1' then
        print(l_file, "("& hstr(info.pc)& ") SFR["& 
              hstr(log_sfr_addr)& "] = "& hstr(log_sfr_wr));
    end if;
     
    -- Log jumps 
    -- FIXME remove internal state dependency
    --if log_ps = jrb_bit_3 and info.jump_condition='1' then
        -- Catch attempts to jump to addresses out of the ROM bounds -- assume
        -- mirroring is not expected to be useful in this case.
        -- Note it remains possible to just run into uninitialized ROM areas
        -- or out of ROM bounds, we're not checking any of that.
        --assert log_next_pc < info.rom_size
        --report "Jump to unmapped code address "& hstr(log_next_pc)& 
        --       "h at "& hstr(info.pc)& "h. Simulation stopped."
        --severity failure;
        
    --    print(l_file, "("& hstr(info.pc)& ") PC = "& 
    --        hstr(info.rel_jump_target) );
    --end if;
     
    -- Log ACC updates.
    -- Note we exclude the 'intermediate update' of ACC in DA instruction, and
    -- we have to deal with another tricky special case: 
    -- the JBC instruction needs the ACC change log delayed so that it appears 
    -- after the PC change log -- a nasty hack meant to avoid a nastier hack
    -- in the SW simulator logging code.
    if (log_load_acc='1' and log_ps/=alu_daa_0) then
        if info.a_reg_prev /= log_acc_input then
            if log_ps = jrb_bit_2 then -- this state is only used in JBC
                info.delayed_acc_log <= true;
                info.delayed_acc_value <= log_acc_input;
            else
                print(l_file, "("& hstr(info.pc)& ") A = "& 
                    hstr(log_acc_input) );
            end if;
         end if;
        info.a_reg_prev <= log_acc_input;
    end if;

    -- Log XRAM writes
    if (log_xdata_we='1') then
         print(l_file, "("& hstr(info.pc)& ") <"&
                hstr(log_xdata_addr)& "> = "& 
                hstr(log_xdata_wr) );
    end if;    
    
    -- Log SP explicit and implicit updates.
    -- At the beginning of each instruction we log the SP change if there is 
    -- any. SP changes at different times for different instructions. This way,
    -- the log is always done at the end of the instruction execution, as is
    -- done in B51.
    if (log_ps=fetch_1) then
        if info.sp_reg_prev /= log_sp then
            print(l_file, "("& hstr(info.pc)& ") SP = "& 
                hstr(log_sp) );
         end if;
        info.sp_reg_prev <= log_sp;
    end if;
    
    -- Log DPTR increments
    if (info.inc_dptr_prev='1') then
         print(l_file, "("& hstr(info.pc)& ") DPTR = "& 
               hstr(log_dptr) );
    end if;    
    info.inc_dptr_prev <= log_inc_dptr;
   
    -- Console logging ---------------------------------------------------------
    -- TX data may come from the high or low byte (opcodes.s
    -- uses high byte, no_op.c uses low)
    if log_sfr_we = '1' and log_sfr_addr = X"99" then
        -- UART TX data goes to output after a bit of line-buffering
        -- and editing
        if log_sfr_wr = X"0D" then
            -- LF received: print output string and clear it
            print(con_file, info.con_line_buf(1 to info.con_line_ix));
            print(info.con_line_buf(1 to info.con_line_ix));
            info.con_line_ix <= 1;
            info.con_line_buf <= (others => ' ');
        elsif log_sfr_wr = X"0A" then
            -- ignore CR
        elsif log_sfr_wr = X"04" then
            -- EOT terminates simulation.
            print("Execution terminated by SW -- EOT written to SBUF.");
            done <= '1';
        else
            -- append char to output string
            if info.con_line_ix < info.con_line_buf'high then
                info.con_line_buf(info.con_line_ix) <= 
                        character'val(to_integer(log_sfr_wr));
                info.con_line_ix <= info.con_line_ix + 1;
                --print(str(info.con_line_ix));
            end if;
        end if;
    end if;    
    
    -- Log jumps 
    -- FIXME remove internal state dependency
    if log_ps = long_jump or 
       log_ps = lcall_4 or 
       log_ps = jmp_adptr_0 or
       log_ps = ret_3 or
       log_ps = rel_jump or 
       log_ps = cjne_a_imm_2 or
       log_ps = cjne_rn_imm_3 or
       log_ps = cjne_ri_imm_5 or
       log_ps = cjne_a_dir_3 or
       log_ps = jrb_bit_4 or
       log_ps = djnz_dir_4
       then
        -- Catch attempts to jump to addresses out of the ROM bounds -- assume
        -- mirroring is not expected to be useful in this case.
        -- Note it remains possible to just run into uninitialized ROM areas
        -- or out of ROM bounds, we're not checking any of that.
        assert log_next_pc < info.rom_size
        report "Jump to unmapped code address "& hstr(log_next_pc)& 
               "h at "& hstr(info.pc)& "h. Simulation stopped."
        severity failure;
        
        print(l_file, "("& hstr(info.pc)& ") PC = "& 
            hstr(log_next_pc) );
        jump_logged := true;
    end if;

    -- If this instruction needs the ACC change log delayed, display it now 
    -- but only if the PC change has been already logged.
    -- This only happens in instructions that jump AND can modify ACC: JBC.
    -- The PSW change, if any, is delayed too, see below.
    if info.delayed_acc_log and jump_logged then
        print(l_file, "("& hstr(info.pc)& ") A = "& 
            hstr(info.delayed_acc_value) );
        info.delayed_acc_log <= false;
    end if;
    
    -- Log PSW implicit updates: first, whenever the PSW is updated, save the PC
    -- for later reference...
    if (log_update_psw_flags(0)='1' or log_load_acc='1') then
        info.psw_update_addr <= info.pc;
    end if;    
    -- ...then, when the PSW change is actually detected, log it along with the
    -- PC value we saved before.
    -- The PSW changes late in the instruction cycle and we need this trick to
    -- keep the logs ordered.
    -- Note that if the ACC log is delayed, the PSW log is delayed too!
    if (log_psw) /= (info.psw_prev) and not info.delayed_acc_log then
        print(l_file, "("& hstr(info.psw_update_addr)& ") PSW = "& hstr(log_psw) );
        info.psw_prev <= log_psw;
    end if;
   
    -- Stop the simulation if we find an unconditional, one-instruction endless
    -- loop. This will not catch multi-instruction endless loops and is only
    -- intended to replicate the behavior of B51 and give the SW a means to 
    -- cleanly end the simulation.
    -- FIXME use some jump signal, not a single state
    if log_ps = long_jump and (info.pc = log_next_pc) then
        -- Before quitting, optionally log cycle count table to separate file.
        log_cycle_counts(info);
        
        assert false
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
    info.pc_z(0) <= log_code_addr;
    if log_ps = decode_0 then
        info.pc_prev <= info.pc;
        info.pc <= info.pc_z(1);
    end if;

end procedure log_cpu_status;

procedure log_cpu_activity(
                signal clk :    in std_logic;
                signal reset :  in std_logic;
                signal done :   inout std_logic;
                mcu :           string;
                signal info :   inout t_log_info; 
                rom_size :      natural;
                iname :         string;
                trigger_addr :  in t_address;
                file l_file :   TEXT;
                file con_file : TEXT) is

begin

    -- Initialize the console log line buffer...
    info.con_line_buf <= (others => ' ');
    -- ...and take note of the ROM size 
    -- FIXME this should not be necessary, we know the array size already.
    info.rom_size <= rom_size;

    -- Initialize the observed cycle counting logic...
    info.cycles <= (others => (999,0,0));
    info.cycle_count <= 0;
    info.last_opcode <= "UUUUUUUU";
    info.delayed_acc_log <= false;
    
    -- ...and we're ready to start monitoring the system
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
            log_cpu_status(info, done, l_file, con_file);
        end if;
    end loop;
    
    -- Once finished, optionally log the cycle count table to a separate file.
    log_cycle_counts(info);

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

procedure log_cycle_counts(
                signal info :   in t_log_info) is
variable cc : t_opcode_cycle_count;
variable opc : natural;
file log_cycles_file: TEXT open write_mode is "cycle_count_log.csv";
begin
    
    for row in 0 to 15 loop
        for col in 0 to 15 loop 
            opc := col*16 + row;
            cc := info.cycles(opc);
            print(log_cycles_file,
                  ""& hstr(to_unsigned(opc,8))& ","& 
                  str(cc.min)& ","& str(cc.max)& ","& str(cc.exe));
        end loop;
    end loop;

end procedure log_cycle_counts;


end package body;
