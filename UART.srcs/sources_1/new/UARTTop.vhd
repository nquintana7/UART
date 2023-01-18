----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2023 07:29:52 PM
-- Design Name: 
-- Module Name: UARTTop - Behavioral
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

entity UARTTop is
    port (
        clk: in std_logic;
        rst: in std_logic;
        serial_rx: in std_logic;
        serial_tx: out std_logic);
end UARTTop;

architecture Behavioral of UARTTop is
    component baudclk is
        GENERIC(clk_frequency: integer := 100e6; -- in Hz
                baudrate : integer := 115200);
        PORT(clk: in std_logic;
             rst: in std_logic;
             bclk: out std_logic;
             b16clk: out std_logic);
    end component;
    
    component uart_rx is
        port(
            clk : in std_logic;
            b16clk : in std_logic;
            rst: in std_logic;
            serial_line : in std_logic;
            dv: out std_logic;
            data: out std_logic_vector(7 downto 0));
    end component;

    component uart_tx is
        port(clk: in std_logic;
            bclk : in std_logic;
            rst: in std_logic;
            enable: in std_logic;
            data: in std_logic_vector(7 downto 0);
            busy: out std_logic;
            serial_line: out std_logic);
    end component;
    
    signal transmit_register: std_logic_vector(7 downto 0) := (others => '0');
    signal receive_register: std_logic_vector(7 downto 0) := (others => '0');

    signal rx_dv : std_logic := '0';
    signal tx_busy: std_logic := '0';

    signal bclk : std_logic := '0';
    signal b16clk : std_logic := '0';
begin
    B_CLK: baudclk port map(
        clk => clk,
        rst => rst,
        bclk => bclk,
        b16clk => b16clk
    );
    
    TX: uart_tx  port map(
                    clk => clk,
                    bclk => bclk,
                    rst => rst,
                    enable => rx_dv,
                    data => receive_register,
                    busy => tx_busy,
                    serial_line => serial_tx
                );  

    RX: uart_rx  port map(
        clk => clk,
        b16clk => b16clk,
        rst => rst,
        data => receive_register,
        dv => rx_dv,
        serial_line => serial_rx
    ); 
end Behavioral;
