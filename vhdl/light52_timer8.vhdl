--------------------------------------------------------------------------------
-- light52_timer8.vhdl -- 8-bit timer with prescaler.
--------------------------------------------------------------------------------
-- Basic timer, functionally equivalent to the MCS51 timer in mode 2: 8-bit 
-- autoreload. Note this timer is NOT compatible to the original; it has a 
-- different interface and is totally independent of the UART.
-- 
-- Status register flags:
-------------------------
--
--      7       6       5       4       3       2       1       0
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--  |   0   |   0   |  CEN  |  ARL  |   0   |   0   |   0   |  Irq  |
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--      h       h      r/w      r/w      h       h       h      W1C    
--
--  Bits marked 'h' are hardwired and can't be modified. 
--  Bits marked 'r' are read only; they are set and clear by the core.
--  Bits marked 'r/w' can be read and written to by the CPU.
--  Bits marked W1C ('Write 1 Clear') are set by the core when an interrupt 
--  has been triggered and must be cleared by the software by writing a '1'.
--
-- -# Flag CEN (Count ENable) must be set to 1 by the CPU to start the timer. 
--    Writing a 1 to CEN will load the counter with its reload value and start 
--    the count down.
--    Writing a 0 to CEN will stop the count without changing the counter value.
--    If flag ARL is 0 the core will clear flag CEN after the counter reaches 
--    zero and an interrupt is triggered.
--    If flag ARL is 1 then flag CEN will remain high until cleared by the CPU.
--    Note that writing a 1 to CEN after writing a 0 will start a new count from
--    the beginning and will not continue a previously stopped count.
-- -# Flag ARL (Auto ReLoad) must be set to 1 for autoreload mode. Its reset 
--    value is 0.
-- -# Status bit Irq is raised when the counter reaches zero and an interrupt 
--    is triggered, and is cleared when a 1 is written to it.
--
-- When writing to the status/control registers, only flags TxIrq and RxIrq are
-- affected, and only when writing a '1' as explained above. All other flags 
-- are read-only.
--
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
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
use ieee.numeric_std.all;

use work.light52_pkg.all;

entity light52_timer8 is
    generic (
        PRESCALER_STAGES : natural := 1
    );
    port(
        irq_o     : out std_logic;
        
        data_i    : in std_logic_vector(7 downto 0);
        data_o    : out std_logic_vector(7 downto 0);
        
        addr_i    : in std_logic;
        wr_i      : in std_logic;
        ce_i      : in std_logic;
        
        clk_i     : in std_logic;
        reset_i   : in std_logic

    );
end entity light52_timer8;


architecture plain of light52_timer8 is

signal clk, reset :         std_logic;

-- Prescaler reg is PRESCALER_STAGES+1 bits wide, msb used to catch rollovers.
signal prescaler_ctr_reg :  unsigned(PRESCALER_STAGES downto 0);
signal prescaler_msb_reg :  std_logic;
signal timer_ctr_reg :      unsigned(7 downto 0);
signal reload_reg :         unsigned(7 downto 0);
signal decrement_counter :  std_logic;
signal counter_rollover :   std_logic;
signal load_timer_ctr :     std_logic;
signal load_status_reg :    std_logic;

signal flag_autoreload_reg: std_logic;
signal flag_counting_reg :  std_logic;
signal flag_irq_reg :       std_logic;
signal status_reg :         std_logic_vector(7 downto 0);


begin

clk <= clk_i;
reset <= reset_i;

-- If the prescaler is longer than a reasonable arbitrary value, kill the
-- synthesis and let the user deal with this -- possibly modifying this 
-- file if a long prescaler is actually necessary.
assert PRESCALER_STAGES <= 31
report "Timer prescaler is wider than 31 bits."
severity failure;

prescaler_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if load_timer_ctr='1' or reset='1' then
            -- Loading the timer register initializes the prescaler too.
            prescaler_ctr_reg <= (others => '0');
            prescaler_msb_reg <= '0';
        else
            prescaler_msb_reg <= prescaler_ctr_reg(prescaler_ctr_reg'high);
            prescaler_ctr_reg <= prescaler_ctr_reg + 1;
        end if;
    end if;
end process prescaler_counter;

decrement_counter <= '1' when prescaler_ctr_reg(prescaler_ctr_reg'high) /=
                              prescaler_msb_reg
                     else '0';

                     
timer_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            reload_reg <= (others => '1');
            timer_ctr_reg <= (others => '1');
        else 
            if load_timer_ctr='1' then
                -- Loading the timer register updates the reload register too.
                timer_ctr_reg <= unsigned(data_i);
                reload_reg <= unsigned(data_i);
            else
                if load_status_reg='1' and data_i(5)='1' then
                    timer_ctr_reg <= reload_reg;
                else
                    if (flag_counting_reg and decrement_counter)='1' then
                        if counter_rollover='1' then
                            if flag_autoreload_reg='1' then 
                                timer_ctr_reg <= reload_reg;
                            end if;
                        else
                            timer_ctr_reg <= timer_ctr_reg - 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process timer_counter;

counter_rollover <= '1' when to_integer(timer_ctr_reg)=0 and 
                             flag_counting_reg='1' 
                    else '0';


---- Status register -----------------------------------------------------------

status_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            flag_irq_reg <= '0';
            flag_autoreload_reg <= '0';
            flag_counting_reg <= '0';
        else
            if counter_rollover='1' then
                flag_irq_reg <= '1';
            elsif load_status_reg='1' then
                if data_i(0)='1' then
                    flag_irq_reg <= '0';
                end if;
            end if;
            if load_status_reg='1' then
                flag_autoreload_reg <= data_i(4);
                flag_counting_reg <= data_i(5);
            elsif (counter_rollover and not flag_autoreload_reg)='1' then
                flag_counting_reg <= '0';
            end if;
        end if;
    end if;
end process status_register;

status_reg <= "00" & flag_counting_reg & flag_autoreload_reg & 
              "000" & flag_irq_reg;


---- SFR interface -------------------------------------------------------------

load_timer_ctr <= '1' when wr_i='1' and ce_i='1' and addr_i='1' else '0';
load_status_reg <= '1' when wr_i='1' and ce_i='1' and addr_i='0' else '0';

with addr_i select data_o <=
    status_reg                          when '0',
    std_logic_vector(timer_ctr_reg)     when others;

irq_o <= flag_irq_reg; --counter_rollover;
                     


end architecture plain;
