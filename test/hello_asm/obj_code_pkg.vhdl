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

constant object_code : t_obj_code(0 to 94) := (
    X"02", X"00", X"30", X"02", X"00", X"4c", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"4e", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"4c", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"4c", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"4d", X"00", X"00", 
    X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
    X"75", X"80", X"ab", X"75", X"90", X"87", X"90", X"00", 
    X"4f", X"78", X"00", X"e8", X"08", X"93", X"60", X"0a", 
    X"f5", X"99", X"e5", X"98", X"54", X"10", X"60", X"fa", 
    X"80", X"f1", X"01", X"4a", X"32", X"32", X"32", X"48", 
    X"65", X"6c", X"6c", X"6f", X"20", X"57", X"6f", X"72", 
    X"6c", X"64", X"21", X"0d", X"0a", X"00", X"00" 
);


end package obj_code_pkg;
