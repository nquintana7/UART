----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2023 12:21:54 AM
-- Design Name: 
-- Module Name: baudclk - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity baudclk is
    GENERIC(clk_frequency: integer := 100e6; -- in Hz
            baudrate : integer := 115200);
    PORT(clk: in std_logic;
         rst: in std_logic;
         bclk: out std_logic;    -- bclk is the clock for the baudrate
         b16clk: out std_logic); -- b16clk is the oversampled clock for the RX receiver
end baudclk;

architecture Behavioral of baudclk is
    constant clks_per_bit : integer := clk_frequency/baudrate;
    constant b16_clks_per_bit : integer := clk_frequency/(baudrate*16);
    signal bcounter : integer range 0 to clks_per_bit-1 := 0;
    signal b16counter: integer range 0 to b16_clks_per_bit-1 := 0;
begin
    baud_clock : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                bcounter <= 0;
                b16counter <= 0;
                bclk <= '0';
            else
                if bcounter = clks_per_bit-1 then
                    bclk <= '1';
                    bcounter <= 0;
                else   
                    bclk <= '0';
                    bcounter <= bcounter + 1;
                end if;

                if b16counter = b16_clks_per_bit-1 then
                    b16clk <= '1';
                    b16counter <= 0;
                else
                    b16clk <= '0';
                    b16counter <= b16counter + 1;
                end if;
            end if; 
        end if;    
    end process;   

end Behavioral;
