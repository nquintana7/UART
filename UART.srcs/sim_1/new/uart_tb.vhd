LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD;



ENTITY uart_testbench IS
END uart_testbench;

ARCHITECTURE behavior OF uart_testbench IS 

    component baudclk is
        GENERIC(clk_frequency: integer := 100e6; -- in Hz
                baudrate : integer := 115200);
        PORT(clk: in std_logic;
             rst: in std_logic;
             bclk: out std_logic;
             b16clk : out std_logic);
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

    component uart_rx is
        port(
            clk : in std_logic;
            rst: in std_logic;
            b16clk: in std_logic;
            serial_line : in std_logic;
            dv: out std_logic;
            data: out std_logic_vector(7 downto 0));
    end component;

   constant clk_period : time := 10 ns;
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

    -- rx
   signal rx_enable : std_logic;
   signal data_rx : std_logic_vector(7 downto 0);
   signal serial_rx : std_logic;

    -- tx
   signal tx_busy : std_logic := '0';
   signal tx_enable: std_logic := '0';
   signal data_tx : std_logic_vector(7 downto 0);
   signal serial_tx : std_logic := '0';
   
   signal bclk : std_logic := '0';
   signal b16clk : std_logic := '0';


BEGIN
    -- Clock
   clk <= not clk after clk_period/2;

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
          enable => tx_enable,
          data => data_tx,
          busy => tx_busy,
          serial_line => serial_tx
   ); 

   RX: uart_rx 
                PORT MAP(clk => clk,
                        b16clk => b16clk,
                        rst => rst,
                        serial_line => serial_rx,
                        dv => rx_enable,
                        data => data_rx);
                        

   test: process
   begin        
        -- First we test the RX component
        wait for 100000ns;
        serial_rx <= '1'; --idle
        
        -- Byte 'A' = 0x41
        wait for clk_period*868; -- Period per bit
                serial_rx <= '0'; --start bit

        wait for clk_period*868;
                serial_rx <= '1'; --Bit 0

        wait for clk_period*868; 
                serial_rx<='0'; --Bit 1

        wait for clk_period*868;
                serial_rx<='0'; --Bit 2

        wait for clk_period*868;
               serial_rx<='0'; --Bit 3

        wait for clk_period*868;
               serial_rx<='0'; --Bit 4

        wait for clk_period*868;
               serial_rx<='0'; --Bit 5

        wait for clk_period*868;
               serial_rx<='1'; --Bit 6

        wait for clk_period*868;
               serial_rx<='0'; --Bit 7

        wait for clk_period*868;
                serial_rx<='1'; --stop bit
        
        wait for 1 ns;
        assert data_rx = "01000001" report "ERROR rx output should be 10000010" severity warning;
        
        -- Byte 'K' = 0x4b
        wait for clk_period*868;
                serial_rx<='0'; --start bit

        wait for clk_period*868;
                serial_rx<='1'; --Bit 0

        wait for clk_period*868; 
                serial_rx<='1'; --Bit 1

        wait for clk_period*868;
                serial_rx<='0'; --Bit 2

        wait for clk_period*868;
               serial_rx<='1'; --Bit 3

        wait for clk_period*868;
               serial_rx<='0'; --Bit 4

        wait for clk_period*868;
               serial_rx<='0'; --Bit 5

        wait for clk_period*868;
               serial_rx<='1'; --Bit 6

        wait for clk_period*868;
               serial_rx<='0'; --Bit 7
               
        wait for clk_period*868;
               serial_rx<='1'; --Stop       
               
        wait for 1ns;       
        assert data_rx = "01001011" report "ERROR rx output should be 01001011" severity warning;
   
        data_tx <= "01001011";
        tx_enable <= '1';

        wait for clk_period*868;
        assert serial_tx = '0' report "ERROR TX should be start bit at " & time'image(now) severity warning;
        
        wait for clk_period*868;
        assert serial_tx = '1' report "ERROR TX bit 0 should be 1 at " & time'image(now) severity warning;
        
        wait for clk_period*868;
        assert serial_tx = '1' report "ERROR TX bit 1 should be 1 at " & time'image(now) severity warning;
        
        wait for clk_period*868;
        assert serial_tx = '0' report "ERROR TX bit 2 should be 0 at " & time'image(now) severity warning;
        
        wait for clk_period*868;
        assert serial_tx = '1' report "ERROR TX bit 3 should be 1 at " & time'image(now) severity warning;
        
        wait for clk_period*868;
        assert serial_tx = '0' report "ERROR TX bit 4 should be 0 at " & time'image(now) severity warning;
        
        wait for clk_period*868;
        assert serial_tx = '0' report "ERROR TX bit 5 should be 0 at " & time'image(now) severity warning;
           
        wait for clk_period*868;
        assert serial_tx = '1' report "ERROR TX bit 6 should be 1 at " & time'image(now) severity warning;   
        tx_enable <= '0';
        wait for clk_period*868;
        assert serial_tx = '0' report "ERROR TX bit 7 should be 0 at " & time'image(now) severity warning;   
        
        wait for clk_period*868;
        assert serial_tx = '1' report "ERROR TX should be stop bit at " & time'image(now) severity warning;   


        wait for clk_period*2000;
        rst <= '1';
        
        
        wait for clk_period*900;
        rst <= '0';  
   end process;

END;