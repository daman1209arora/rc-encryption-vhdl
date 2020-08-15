LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

entity Receiver is
  Port ( clk : IN std_logic;
         reset : IN std_logic;
         rx_data : OUT std_logic_vector(7 downto 0);
         rx_full : buffer std_logic;
         rx_in : IN std_logic   
        );
end Receiver;

architecture Behavioral of Receiver is
signal tempvec : std_logic_vector(7 downto 0):="00000000";
type r_state is(idle, start, si);
signal state : r_state := idle;
signal count_start : integer:=0;
signal count16 : integer:=0;
signal count8 : integer :=0;
begin

rx_data<=tempvec;
with state select
    rx_full <=  '0' when si,
                '1' when others;
process(clk,state)
	begin
		if(clk='1' and clk'event) then
			if(reset = '1') then 
			     state<=idle;
			     count_start<=0;
			     count8<=0;
			     count16<=0;
			     tempvec<="00000000";
			else 
			case state is 
				when idle =>
						if(rx_in='0') then 
						      count_start<=1; 
						      state<=start; 
						      count8<= 0;
						      count16<=0;
						end if;
				            
				
				
				when start => 
				            if(rx_in='0') then
								if(count_start=7) then
                                    count16<=0;  
                                    state<=si;
								end if;
								count_start<=count_start+1;
							 else 
							     state<=idle; 
							 end if;
				when si => 
				            if(count8 = 8) then 
				                state<=idle; 
				                count8 <= 0; 
							 else
							 	if(count16 = 15) then 
							 	   tempvec(7 downto 0) <= tempvec(6 downto 0)&rx_in;
							 	   count16<=0;
							 	   count8<= count8+1;
							 	else
							 	   count16<= count16+1;
							 	end if;
							 end if;
                when others=> 
                            state<=idle;
			end case;		   
		  end if;
		end if;

	end process;

end Behavioral;