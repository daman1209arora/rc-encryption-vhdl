library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debounce is
  Port (clk: IN std_logic;
        btn: IN std_logic;
        btnD: BUFFER std_logic:='0' );
end Debounce;

architecture Behavioral of Debounce is
signal count: integer := 0;
signal slowClk : std_logic := '0';
signal mem: std_logic := '0';
begin
    process(clk)
        begin
            if(clk = '1' and clk'event) then 
                if(count = 7813 ) then 
                     count<=0; 
                     slowClk<=not(slowClk);
                else 
                     count<=count+1;
                end if;
            end if;
        end process;
        
        
    process(slowClk, btn)
    begin
        if(slowClk = '1') then
            if(btn ='1'and mem ='0')then 
                btnD<='1';
                mem<='1';
            elsif(btn = '0' and mem = '1') then 
                mem<='0';
                btnD<='0';
            else 
                btnD<='0';
            end if; 
        end if;
    end process;
end Behavioral;
