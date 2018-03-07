--##############################################################################
-- light52 MCU demo on Digilent ZYBO board
--##############################################################################
-- 
-- This is a minimal demo of the light52 core targetting Digilent's ZYBO 
-- development board for Zynq FPGAs. 
-- Since the demo uses little board resources other than the serial port it 
-- should be easy to port it to other platforms.
-- This file is strictly for demonstration purposes and has not been tested.
--
-- This demo has been built from a generic template for designs targetting the
-- ZYBO development board. The entity defines all the inputs and outputs present
-- in the actual board, whether or not they are used in the design at hand.
--
-- IMPORTANT: The UART is NOT connected to the ZYBO USB UART (which is wired
-- to the PS and not the PL and thus is out of our reach).
-- Instead, it is connected to general purpose pins in header Pmod JE.
-- You need wire your own UART interface to that header to use the MCU UART.
--
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx PLL instance requires these libraries.
library UNISIM;
use UNISIM.vcomponents.all;


-- Package with utility functions for handling SoC object code.
use work.light52_pkg.all;
-- Package that contains the program object code in VHDL constant format.
use work.obj_code_pkg.all;

entity ZYBO_TOP is
  port(
    -- Clock from Ethernet PHY. @note1.
    clk_125MHz_i        : in std_logic;

    -- Pushbuttons.
    buttons_i           : in std_logic_vector(3 downto 0);
    -- Switches.
    switches_i          : in std_logic_vector(3 downto 0);
    -- LEDs.
    leds_o              : out std_logic_vector(3 downto 0);
    -- PMOD E (Std) connector -- PMOD UART (Digilent).
    pmod_e_2_txd_o      : out std_logic;
    pmod_e_3_rxd_i      : in std_logic
  );
end entity ZYBO_TOP;

architecture rtl of ZYBO_TOP is

signal clk :                std_logic;
signal reset :              std_logic;
signal reset_async :        std_logic;
signal reset_ffc :          std_logic_vector(2 downto 0);

signal clk_50MHz :          std_logic;
signal clk_fb :             std_logic;

signal extint :             std_logic_vector(7 downto 0);
signal p0_out :             std_logic_vector(7 downto 0);
signal p1_out :             std_logic_vector(7 downto 0);
signal p2_in :              std_logic_vector(7 downto 0);
signal p3_in :              std_logic_vector(7 downto 0);


begin

  -- Light52 MCU and glue logic ------------------------------------------------


  -- MCU instantiation 
  mcu: entity work.light52_mcu 
  generic map (
    -- Memory size is defined in package obj_code_pkg...
    CODE_ROM_SIZE => work.obj_code_pkg.XCODE_SIZE,
    XDATA_RAM_SIZE => work.obj_code_pkg.XDATA_SIZE,
    -- ...as is the object code initialization constant.
    OBJ_CODE => work.obj_code_pkg.object_code,
    -- Leave BCD opcodes disabled.
    IMPLEMENT_BCD_INSTRUCTIONS => false,
    -- UART baud rate isn't programmable in run time.
    UART_HARDWIRED => true,
    -- We're using the 50MHz clock of the ZYBO board.
    CLOCK_RATE => 50e6
  )
  port map (
    clk             => clk_50MHz,
    reset           => reset,
        
    txd             => pmod_e_2_txd_o,
    rxd             => pmod_e_3_rxd_i,
    
    external_irq    => extint, 
    
    p0_out          => p0_out,
    p1_out          => p1_out,
    p2_in           => p2_in,
    p3_in           => p3_in
  );

  -- IMPORTANT: The UART is NOT connected to the ZYBO USB UART (which is wired
  -- to the PS and not the PL and thus is out of our reach).
  -- Instead, it is connected to general purpose pins in header Pmod JE.
  -- You need wire your own UART interface to that header to use the MCU UART.

  -- These interconnections are meant only to fool the synth tool into NOT
  -- synthesizing away large chunks of logic. Otherwise they are useless.
  extint <= X"00";
  p2_in(3 downto 0) <= switches_i;
  p2_in(7 downto 4) <= buttons_i xor p0_out(7 downto 4);
  p3_in <= p2_in xor p1_out;

  -- Smoke test logic (to be removed when up and running) ----------------------

  -- Async reset source is the leftmost switch (not button).
  reset_async <= switches_i(3);

  -- Synchronize external reset input before feeding it into the main logic.
  process(clk)
  begin
    if clk'event and clk='1' then
      reset_ffc <=  reset_ffc(1 downto 0) & reset_async;
    end if;
  end process;
  reset <= reset_ffc(2);

  -- Multiplex 8 bits of P0 onto the only 4 LEDs we have.
  with switches_i(0) select leds_o <= 
    p0_out(7 downto 4)              when '1',
    p0_out(3 downto 0)              when others;
  

  -- Use a Zynq PLL to generate our main clock out of the input 125MHz clock.

  -- Note that we don't care about the phase relationships between input and 
  -- outputs or the outputs to each other (and we only use one output anyway).
  -- We only care about the frequency, and not even enough to do a good job of
  -- buffering the FB loop OR properly resetting the thing.

  clk <= clk_50MHz;

  PLLE2_BASE_inst : PLLE2_BASE
  generic map (
    BANDWIDTH => "OPTIMIZED",   -- OPTIMIZED, HIGH, LOW
    CLKFBOUT_MULT => 8,         -- Multiply value for all CLKOUT, (2-64)
    CLKFBOUT_PHASE => 0.0,      -- Phase offset in degrees of CLKFB.
    CLKIN1_PERIOD => 8.0,       -- Input clock period (125MHz - 8ns)
    -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
    CLKOUT0_DIVIDE => 20,
    CLKOUT1_DIVIDE => 20,
    CLKOUT2_DIVIDE => 20,
    CLKOUT3_DIVIDE => 20,
    CLKOUT4_DIVIDE => 20,
    CLKOUT5_DIVIDE => 20,
    -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: 
    -- Duty cycle for each CLKOUT (0.001 to 0.999).
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT2_DUTY_CYCLE => 0.5,
    CLKOUT3_DUTY_CYCLE => 0.5,
    CLKOUT4_DUTY_CYCLE => 0.5,
    CLKOUT5_DUTY_CYCLE => 0.5,
    -- CLKOUT0_PHASE - CLKOUT5_PHASE: 
    -- Phase offset for each CLKOUT (-360.000 to 360.000).
    CLKOUT0_PHASE => 0.0,
    CLKOUT1_PHASE => 0.0,
    CLKOUT2_PHASE => 0.0,
    CLKOUT3_PHASE => 0.0,
    CLKOUT4_PHASE => 0.0,
    CLKOUT5_PHASE => 0.0,
    DIVCLK_DIVIDE => 1,         -- Master division value, (1-56)
    REF_JITTER1 => 0.0,         -- Reference input jitter in UI, (0.000-0.999)
    STARTUP_WAIT => "FALSE"     -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
  )
  port map (
    -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
    CLKOUT0 => clk_50MHz,       -- 1-bit output: CLKOUT0
    CLKOUT1 => open,            -- 1-bit output: CLKOUT1
    CLKOUT2 => open,            -- 1-bit output: CLKOUT2
    CLKOUT3 => open,            -- 1-bit output: CLKOUT3
    CLKOUT4 => open,            -- 1-bit output: CLKOUT4
    CLKOUT5 => open,            -- 1-bit output: CLKOUT5
    -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
    CLKFBOUT => clk_fb,         -- 1-bit output: Feedback clock
    LOCKED => open,             -- 1-bit output: LOCK
    CLKIN1 => clk_125MHz_i,     -- 1-bit input: Input clock
    -- Control Ports: 1-bit (each) input: PLL control ports
    PWRDWN => '0',              -- 1-bit input: Power-down
    RST => '0',                 -- 1-bit input: Reset
    -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
    CLKFBIN => clk_fb           -- 1-bit input: Feedback clock
  );

end;

-- @note1: Clock active if PHYRSTB is high. PHYRSTB pin unused, pulled high.  
