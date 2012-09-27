--------------------------------------------------------------------------------
-- obj_code_pkg.vhdl -- Application object code in vhdl constant string format.
--------------------------------------------------------------------------------
-- This is where the application code lives.
-- FIXME should only be used from top level entity
-- FIXME name of package should be application-related
-- FIXME convert to vhdl template
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
use ieee.numeric_std.all;
use work.light52_pkg.all;

package obj_code_pkg is

constant object_code : t_obj_code(0 to 252) := (
    X"02", X"00", X"30", X"02", X"00", X"ad", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"a3", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"ad", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"ad", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"ad", X"00", X"00", 
    X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
    X"75", X"a8", X"00", X"75", X"8a", X"0a", X"75", X"88", 
    X"20", X"75", X"60", X"00", X"7f", X"10", X"75", X"8a", 
    X"0a", X"75", X"88", X"20", X"df", X"fe", X"e5", X"60", 
    X"b4", X"00", X"41", X"d2", X"88", X"75", X"a8", X"02", 
    X"75", X"60", X"00", X"7f", X"10", X"75", X"8a", X"0a", 
    X"75", X"88", X"20", X"df", X"fe", X"e5", X"60", X"b4", 
    X"00", X"2a", X"d2", X"88", X"75", X"a8", X"82", X"75", 
    X"60", X"00", X"7f", X"10", X"75", X"8a", X"0a", X"75", 
    X"88", X"20", X"df", X"fe", X"e5", X"60", X"b4", X"01", 
    X"08", X"90", X"00", X"d0", X"12", X"00", X"97", X"01", 
    X"7f", X"90", X"00", X"ef", X"12", X"00", X"97", X"75", 
    X"a8", X"00", X"01", X"8a", X"90", X"00", X"be", X"12", 
    X"00", X"97", X"75", X"a8", X"00", X"01", X"95", X"78", 
    X"00", X"e8", X"08", X"93", X"60", X"04", X"f5", X"99", 
    X"80", X"f7", X"22", X"d2", X"88", X"05", X"60", X"90", 
    X"00", X"af", X"11", X"97", X"32", X"01", X"ad", X"3c", 
    X"54", X"69", X"6d", X"65", X"72", X"20", X"69", X"72", 
    X"71", X"3e", X"0d", X"0a", X"00", X"00", X"55", X"6e", 
    X"65", X"78", X"70", X"65", X"63", X"74", X"65", X"64", 
    X"20", X"49", X"52", X"51", X"0d", X"0a", X"00", X"00", 
    X"49", X"52", X"51", X"20", X"74", X"65", X"73", X"74", 
    X"20", X"66", X"69", X"6e", X"69", X"73", X"68", X"65", 
    X"64", X"2c", X"20", X"6e", X"6f", X"20", X"65", X"72", 
    X"72", X"6f", X"72", X"73", X"0d", X"0a", X"00", X"4d", 
    X"69", X"73", X"73", X"69", X"6e", X"67", X"20", X"49", 
    X"52", X"51", X"0d", X"0a", X"00" 
);


end package obj_code_pkg;
