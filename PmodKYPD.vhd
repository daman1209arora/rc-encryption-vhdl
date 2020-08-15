library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PmodKYPD is
    Port ( 
            reset: in std_logic;
            clk : in  STD_LOGIC;
            JA : inout  STD_LOGIC_VECTOR (7 downto 0); 
            an : out  STD_LOGIC_VECTOR (3 downto 0);  
            seg : out  STD_LOGIC_VECTOR (6 downto 0); 
            led : out std_logic_vector( 10 downto 0);
            key : BUFFER std_logic_vector(39 downto 0);
            input_done : out std_logic:= '0');
end PmodKYPD;

architecture Behavioral of PmodKYPD is

component Decoder is
	Port (
			 clk : in  STD_LOGIC;
          Row : in  STD_LOGIC_VECTOR (3 downto 0);
			 Col : out  STD_LOGIC_VECTOR (3 downto 0);
          DecodeOut : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;

component DisplayController is
	Port (
          DispVal : in  STD_LOGIC_VECTOR (3 downto 0);
           anode: out std_logic_vector(3 downto 0);
           segOut : out  STD_LOGIC_VECTOR (6 downto 0));
	end component;


component Timer is
  Port (    clk:IN std_logic;
            hex: IN std_logic_vector(3 downto 0);
            reset : IN std_logic;
            key : BUFFER std_logic_vector(39 downto 0);                                              
            done : OUT std_logic;
            led: OUT std_logic_vector(10 downto 0)
        );
end component;

signal Decode: STD_LOGIC_VECTOR (3 downto 0) := "1111";
signal wr_en: std_logic;
signal addr: std_logic_vector(3 downto 0);
begin
	C0: Decoder port map (clk=>clk, Row =>JA(7 downto 4), Col=>JA(3 downto 0), DecodeOut=> Decode);
	C1: DisplayController port map (DispVal=>Decode, anode=>an, segOut=>seg );
    C3: Timer port map(clk=>clk, hex=>Decode, reset=>reset, led=> led, key=>key, done=>input_done); 
end Behavioral;