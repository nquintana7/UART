----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2023 06:46:32 PM
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- UART Protocol RX implementation with 115200 baudrate and 100 Mhz clock
-- 1 start bit | 8 data bits | 1 stop bit | no parity

entity uart_rx is
    port(
        clk : in std_logic;
        b16clk : in std_logic;
        rst: in std_logic;
        serial_line : in std_logic;
        dv: out std_logic;
        data: out std_logic_vector(7 downto 0));
end uart_rx;

architecture Behavioral of uart_rx is
    type state_type is (idle, start, receive, stop_b);
    signal state : state_type := idle;
    signal reg : std_logic_vector(7 downto 0) := (others => '0');

    -- For eventual spikes in the line we filter it
    signal filter_cnt : std_logic_vector(1 downto 0) := "11"; -- When filter_cnt = "00", the line bit is 0. When it is "11", the line bit is 1.
    signal filter_bit : std_logic := '1';

    signal sync_enable : std_logic := '0'; -- This is for the synchronization while receiving bits

    signal counter: integer range 0 to 15 := 0;
    signal current_bit: integer range 0 to 7 := 0;
begin       
    fsm: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= idle;
                current_bit <= 0;
                counter <= 0;
                reg <= (others => '0');
                filter_bit <= '1';
                filter_cnt <= "11";
                sync_enable <= '0';
            else
                if b16clk = '1' then
                    if serial_line = '1' and filter_cnt /= "11" then
                        filter_cnt <= std_logic_vector( unsigned(filter_cnt) + 1 );
                    elsif serial_line = '0' and filter_cnt /= "00" then
                        filter_cnt <= std_logic_vector( unsigned(filter_cnt) - 1 );
                    end if;

                    if filter_cnt = "11" then
                        filter_bit <= '1';
                    elsif filter_cnt = "00" then
                        filter_bit <= '0';
                    end if;

                    if counter = 15 or (state = start and counter = 7) then
                        counter <= 0;
                        sync_enable <= '1';
                    else
                        sync_enable <= '0';
                        counter <= counter + 1;
                    end if;

                    case state is
                        when idle =>
                            if filter_bit = '0' then
                                state <= start; 
                            end if;
                        when start =>
                            if sync_enable = '1' then
                                state <= receive;
                            end if;
                        when receive =>
                            if sync_enable = '1' then
                                reg(7) <= filter_bit;
                                reg(6 downto 0) <= reg(7 downto 1);
                                current_bit <= current_bit + 1;
                                if current_bit = 7 then
                                    state <= stop_b;
                                    current_bit <= 0;
                                end if;
                            end if;
                        when stop_b =>
                            if sync_enable = '1' then
                                state <= idle;
                            end if;
                    end case;
                end if;
            end if;
        end if; 
    end process;
    dv <= '1' when state = stop_b else
          '0';
    data <= reg;
end Behavioral;