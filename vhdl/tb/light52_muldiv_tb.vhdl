--##############################################################################
-- light52_muldiv_tb.vhdl -- Development rig for the multiplier/divider module. 
-- Not a proper test bench, only a visual aid for development.
--##############################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.light52_pkg.all;
use work.light52_ucode_pkg.all;
use work.txt_util.all;
use work.light52_tb_pkg.all;

entity light52_muldiv_tb is
end light52_muldiv_tb;


architecture testbench of light52_muldiv_tb is

constant T : time := 10 ns;

-- Interface to UUT ------------------------------------------------------------
signal data_a, data_b :     t_byte;
signal product :            t_word;
signal quotient :           t_byte;
signal remainder :          t_byte;
signal load_a :             std_logic;
signal load_b :             std_logic;
signal mul_ready :          std_logic;
signal div_ready :          std_logic;
signal clk :                std_logic := '0';
signal reset :              std_logic := '0';


-- Simulation control ----------------------------------------------------------

type t_result_queue is array(integer range <>) of t_byte;

-- Queues with the expected divider and multiplier results.
-- These queues replicate the UUT latencies for easy result verification.
signal quot_result_queue :  t_result_queue(0 to 8);
signal rem_result_queue :   t_result_queue(0 to 8);
signal prod_result_queue :  t_result_queue(0 to 8);

-- Stimulus table & related stuff ----------------------------------------------

type t_stimulus is
record
    a :                     t_byte;
    b :                     t_byte;
end record t_stimulus;

type t_stim_vector is array(integer range <>) of t_stimulus;

constant stim_vector : t_stim_vector(1 to 5) := (
        (X"19",     X"07"),
        (X"13",     X"19"),
        (X"13",     X"19"),
        (X"13",     X"19"),
        (X"13",     X"19")
    );

function max(a: integer; b:integer) return integer is
begin
    if a>b then 
        return a;
    else
        return b;
    end if;
end function max;
    
begin

uut : entity work.light52_muldiv port map (
    clk =>              clk,
    reset =>            reset,
    
    data_a =>           data_a,
    data_b =>           data_b,
    load_a =>           load_a,
    load_b =>           load_b,
    
    prod_out =>         product,
    quot_out =>         quotient,
    rem_out =>          remainder,
    
    mul_ready =>        mul_ready,
    div_ready =>        div_ready
);

clock_source:
process(clk)
begin
  clk <= not clk after T/2;
end process clock_source;

feed_test_data:
process
variable i : integer;
variable a, b : natural;
variable computed_product, computed_quotient, computed_remainder : natural;
variable expected_product, expected_quotient, expected_remainder : natural;
begin
    -- Reset the UUT.
    reset <= '1';
    load_a <= '0'; 
    load_b <= '0';
    wait for T;
    reset <= '0';
    
    -- Feed all test vectors, updating A and B in the same clock cycle.
    for i in 1 to stim_vector'length loop
        data_a <= stim_vector(i).a;
        data_b <= stim_vector(i).b;
        load_a <= '1';
        load_b <= '1';

        a := to_integer(data_a);
        b := to_integer(data_b);

        wait for T;
        load_a <= '0';
        load_b <= '0';
        
        wait until clk'event and clk='1' and div_ready='1' and mul_ready='1';
        
        wait for T * 4;--max(DIV_OVERLAP, MUL_OVERLAP);
        wait for T * 4;
        
        computed_product := to_integer(product);
        computed_quotient := to_integer(quotient);
        computed_remainder := to_integer(remainder);
        
        expected_product := a * b;
        if b /= 0 then 
            expected_quotient := a / b;
            expected_remainder := a rem b;
        else 
            expected_remainder := a;
        end if;
        
        
        
        assert expected_product = computed_product
        report "Wrong product. Expected "& hstr(product)& 
               ", got "& hstr(to_unsigned(expected_product,16))& "h."
        severity error;

        if b /= 0 then 
            assert expected_quotient = computed_quotient
            report "Wrong quotient. Expected "& hstr(quotient)& 
                   "h, got "& hstr(to_unsigned(expected_quotient,8))& "h."
            severity error;
        end if;

        assert expected_remainder = computed_remainder
        report "Wrong remainder. Expected "& hstr(remainder)& 
               "h, got "& hstr(to_unsigned(expected_remainder,8))& "h."
        severity error;
        
        
        
    end loop;
   
    -- Wait a few clock cycles so that all ongoing operations have time to 
    -- finish, then stop the simulation.
    wait for T * 16;

    assert 1 = 0
    report "Test completed."
    severity failure;

end process feed_test_data;


end testbench;
