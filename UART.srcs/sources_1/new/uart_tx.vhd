----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/16/2023 03:37:02 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
    port(clk : in std_logic;
        bclk : in std_logic;
        rst: in std_logic;
        enable: in std_logic;
        data: in std_logic_vector(7 downto 0);
        busy: out std_logic;
        serial_line: out std_logic);
end uart_tx;

architecture Behavioral of uart_tx is
    type state_type is (idle, wait_for_bclk, start_bit, transmit, stop_bit);
    signal state : state_type := idle;

    signal reg : std_logic_vector(7 downto 0) := (others => '0');
    
    signal current_bit : integer range 0 to 9 := 0;
begin
    fsm: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_bit <= 0;
                state <= idle;
                reg <= (others => '0');
            else
                case (state) is
                    when idle =>
                        if enable = '1' then
                            state <= wait_for_bclk;
                            reg <= data;
                        end if;
                    when wait_for_bclk =>
                        if bclk = '1' then
                            state <= start_bit;
                        end if;
                    when start_bit =>
                        if bclk = '1' then
                            state <= transmit;
                            current_bit <= 1;
                        end if;
                    when transmit =>
                        if bclk = '1' then
                            reg <= std_logic_vector(shift_right(unsigned(reg), 1));
                            if current_bit < 8 then
                                current_bit <= current_bit + 1;
                            else 
                                state <= stop_bit;
                            end if;
                        end if;
                    when stop_bit =>
                        current_bit <= 0;
                        if enable = '1' then
                            state <= wait_for_bclk;
                            reg <= data;
                        else
                            state <= idle;               
                        end if;
                end case;
            end if;
        end if;
    end process;
    busy <= '0' when state = idle or state = stop_bit else
            '1';  
    serial_line <= reg(0) when state = transmit else
                   '0' when state = start_bit else
                   '1';
end Behavioral;
