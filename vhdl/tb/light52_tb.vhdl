--------------------------------------------------------------------------------
-- light52_tb.vhdl --
--------------------------------------------------------------------------------
-- Copyright (C) 2011 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

use work.light52_pkg.all;
use work.obj_code_pkg.all;
--use work.sim_params_pkg.all;
use work.light52_tb_pkg.all;
use work.txt_util.all;

entity light52_tb is
end;


architecture testbench of light52_tb is

-- FIXME these should be in parameter package
constant T : time := 20 ns;
constant SIMULATION_LENGTH : integer := 400000;

constant ROM_SIZE : natural := 8192;

signal done :               std_logic := '0';


-- MPU interface 
signal clk :                std_logic := '0';
signal reset :              std_logic := '1';

signal p0_out :             std_logic_vector(7 downto 0);
signal p1_out :             std_logic_vector(7 downto 0);
signal p2_in :              std_logic_vector(7 downto 0);
signal p3_in :              std_logic_vector(7 downto 0);

signal txd, rxd :           std_logic;

--------------------------------------------------------------------------------
-- Logging signals

-- Log file
file log_file: TEXT open write_mode is "hw_sim_log.txt";
-- Console output log file
file con_file: TEXT open write_mode is "hw_sim_console_log.txt";

signal log_info :           t_log_info;

begin

---- UUT instantiation ---------------------------------------------------------

uut: entity work.light52_mcu
    generic map (
        CODE_ROM_SIZE => ROM_SIZE,
        OBJ_CODE => object_code
    )
    port map (
        clk         => clk,
        reset       => reset,
        
        txd         => txd,
        rxd         => rxd,
                
        p0_out      => p0_out,
        p1_out      => p1_out,
        p2_in       => p2_in,
        p3_in       => p3_in
    );
    
    -- UART is looped back in the test bench.
    rxd <= txd;
    
    -- I/O ports are looped back and otherwise unused.
    p2_in <= p0_out;
    p3_in <= p1_out;

    ---- Master clock: free running clock used as main module clock ------------
    run_master_clock:
    process(done, clk)
    begin
        if done = '0' then
            clk <= not clk after T/2;
        end if;
    end process run_master_clock;


    ---- Main simulation process: reset MCU and wait for fixed period ----------

    drive_uut:
    process
    variable l : line;
    begin
        wait for T*4;
        reset <= '0';
        
        wait for T*SIMULATION_LENGTH;

        -- Flush console output to log console file (in case the end of the
        -- simulation caugh an unterminated line in the buffer)
        if log_info.con_line_ix > 1 then
            write(l, log_info.con_line_buf(1 to log_info.con_line_ix));
            writeline(con_file, l);
        end if;

        print("TB finished");
        done <= '1';
        wait;
        
    end process drive_uut;


    -- Logging process: launch logger function ---------------------------------
    log_execution:
    process
    begin
        log_cpu_activity(clk, reset, done,
                         log_info, ROM_SIZE, "log_info", 
                         X"0000", log_file, con_file);
        wait;
    end process log_execution;

end architecture testbench;
