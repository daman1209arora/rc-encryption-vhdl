LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

entity Timer is
  Port (    clk:IN std_logic;
            hex: IN std_logic_vector(3 downto 0);
            reset : IN std_logic;
            key: BUFFER std_logic_vector(39 downto 0);-----
            led : OUT std_logic_vector(10 downto 0) := "00000000000";                                               
            done : OUT std_logic := '0'
        );
end Timer;

architecture Behavioral of Timer is
signal hexPrev: std_logic_vector(3 downto 0) := "1111";
type states is (idle, s1, s2, s3, s4, s5, s6, s7, s8, s9, finish);
signal state: states := idle;
begin
    
    with state select
        done <= '1' when finish,
                '0' when others;
process(clk, reset)
begin
        if(reset = '1') then
            state <=idle;
        end if;
        
        
        if(clk='1' and clk'event) then 
            if(state = idle) then 
                key <= (others => '0');
            end if;
            if(not(hexPrev = hex)) then
                 if(state = idle) then  
                    led <= "00111111111";
                    state <= s1;
                    key <= key(35 downto 0) & hex;
                 end if;
                 if(state = s1) then  
                     led <= "00011111111"; 
                     state <= s2;
                     key <= key(35 downto 0) & hex;
                  end if;
                  if(state = s2) then  
                      led <= "00001111111"; 
                      state <= s3;
                      key <= key(35 downto 0) & hex;
                   end if;
                   if(state = s3) then
                   led <= "00000111111";   
                       state <= s4;
                       key <= key(35 downto 0) & hex;
                    end if;
                    if(state = s4) then 
                    led <= "00000011111";  
                       state <= s5;
                       key <= key(35 downto 0) & hex;
                    end if;
                    if(state = s5) then 
                        led<="00000001111"; 
                       state <= s6;
                      key <= key(35 downto 0) & hex;
                    end if;
                    if(state = s6) then  
                        led <= "00000000111";
                       state <= s7;
                       key <= key(35 downto 0) & hex;
                    end if;
                    if(state = s7) then  
                        led <= "00000000011";
                       state <= s8;
                       key <= key(35 downto 0) & hex;
                    end if;
                    if(state = s8) then  
                        led <= "00000000001";
                       state <= s9;
                       key <= key(35 downto 0) & hex;
                    end if;
                    if(state = s9) then  
                        led <= "10000000000";
                        state <= finish;
                        key <= key(35 downto 0) & hex;
                     end if; 
                     hexPrev <= hex;                                                
            end if;
        end if;
end process;

end Behavioral;