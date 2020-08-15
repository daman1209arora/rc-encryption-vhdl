LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

entity Transmitter is
 Port ( tx_data : IN std_logic_vector(7 downto 0);
        tx_out : OUT std_logic;
        txclk : IN std_logic;
        ld_tx : IN std_logic;
        tx_empty : buffer std_logic := '1';
        reset : IN std_logic
 );
end Transmitter;

architecture Behavioral of Transmitter is
type t_states is (idle, tr);
signal t_state : t_states := idle;
signal count10 : integer:=0;
signal t_reg : std_logic_vector(9 downto 0);
begin
 
with t_state select
    tx_empty <= '1' when idle,
                '0' when others;
                
process(txclk,reset)
begin
        if(reset = '1')then 
           t_state<=idle;
           count10<=0;
           t_reg<="1111111111";
           tx_out<='1';
        else
        if(rising_edge(txclk)) then    
        if(t_state=idle) then 
            if(ld_tx='1') then 
                count10<=0; 
                tx_out<='1'; 
                t_state <= tr; 
                t_reg<='0' & tx_data(7 downto 0 )&'1'; 
             end if;
         else
            if(count10 = 10) then 
                t_state<=idle ; 
                count10<=0; 
            else 
                tx_out<=t_reg(9-count10);
                count10<=count10+1;
            end if;       
        end if;       
       end if;
    end if;
end process;
end Behavioral;