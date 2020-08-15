
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;


entity Control is
  Port (clk : IN std_logic;
        tx_start : IN std_logic;
        rx_in : IN std_logic;
        tx_out : OUT std_logic ;
        led: OUT std_logic_vector(15 downto 0);
        reset : IN std_logic;
        JA : inout std_logic_vector(7 downto 0);
        an: out std_logic_vector(3 downto 0);
        seg: out std_logic_vector(6 downto 0)
   );
end Control;

architecture Behavioral of Control is
signal clk9600 : std_logic;
signal clk9600_16 : std_logic;
signal eab1 : std_logic;
signal wea1 : std_logic;
signal rx_full : std_logic;
signal tx_empty : std_logic;
signal ld_tx : std_logic;
signal rx_data : std_logic_vector(7 downto 0);
signal tx_data : std_logic_vector(7 downto 0);
signal enc_data : std_logic_vector(7 downto 0);
signal rd_addr : std_logic_vector(7 downto 0);
signal wr_addr : std_logic_vector(7 downto 0);
signal resetD : std_logic:='0';
signal tx_startD : std_logic;
signal mem_data : std_logic_vector(7 downto 0);
signal key: std_logic_vector(39 downto 0);
signal key_done : std_logic;
signal init_done : std_logic;
signal stream : std_logic_vector(7 downto 0);
signal req: std_logic;
signal input_done : std_logic;
signal regenerate : std_logic;
signal check : std_logic_vector(15 downto 0);
signal clk_slow : std_logic;
signal status: std_logic_vector(10 downto 0);
begin
led(10 downto 0) <= status;
KeyPad:ENTITY WORK.PmodKYPD (Behavioral)
        PORT MAP(reset=>resetD, clk=>clk, JA=>JA, an=>an, seg=>seg, led=>status, key=>key, input_done=>input_done);
        
DebounceR:ENTITY WORK.Debounce(Behavioral)
          PORT MAP(clk=>clk, btn=>reset, btnD=>resetD);

DebounceT:ENTITY WORK.Debounce(Behavioral)
          PORT MAP(clk=>clk, btn=>tx_start, btnD=>tx_startD);

Clock:ENTITY WORK.Clock (Behavioral)
      PORT MAP (clk=>clk, clk_out16=>clk9600_16, clk_out=>clk9600, clk_slow=>clk_slow);

Timer:ENTITY WORK.TimingCkt (Behavioral)
        PORT MAP (clk=>clk9600, tx_empty=>tx_empty, rx_full=>rx_full,  tx_start=>tx_startD,ld_tx=> ld_tx, eab1=>eab1, wea1=>wea1, rd_addr=>rd_addr, wr_addr=>wr_addr, reset=>resetD, start=>input_done, key_done=>key_done, request=>req);

Encryptor:ENTITY WORK.KeyStream (Behavioral)
        PORT MAP (clk=>clk9600, reset=>resetD, start=>input_done, input=>mem_data, key=>key, request=>req, key_generation_done=>key_done,  init_done=>init_done, output=>enc_data, stream=>stream);
        
Receiver:ENTITY WORK.Receiver (Behavioral)
       PORT MAP (clk=>clk9600_16, reset=>resetD, rx_data=>rx_data, rx_full=>rx_full, rx_in=>rx_in);
       
Memory:ENTITY WORK.memory(Behavioral)
       PORT MAP (clka=>clk9600, wea=>eab1, addra=>rd_addr,  dina=>rx_data, clkb=>clk9600, enb=>wea1, addrb=>wr_addr, doutb=>mem_data, reset=>resetD);
       
Transmitter:ENTITY WORK.Transmitter(Behavioral)
        PORT MAP (tx_data=>enc_data, tx_out=>tx_out, txclk=>clk9600, ld_tx=>ld_tx, tx_empty=>tx_empty, reset=>resetD);        

end Behavioral;