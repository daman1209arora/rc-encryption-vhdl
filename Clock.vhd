LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

entity Clock is
  Port ( clk : IN std_logic;
         clk_out16 : buffer std_logic;
         clk_out : buffer std_logic;
         clk_slow: buffer std_logic
        );
end Clock;

architecture Behavioral of Clock is
    signal fast_count: integer :=0;
    signal slow_count : integer :=0;
    signal vslow_count : integer :=0;
begin
    process(clk)
	begin
		if(clk = '1' and clk'event) then 
		      if(vslow_count = 4999999) then 
		          clk_slow <= not(clk_slow);
		          vslow_count <= 0;
		      else
		          vslow_count <= vslow_count + 1;
		          
		       end if;
		       
			if(fast_count = 325 ) then 
			     if(slow_count = 15) then 
			         clk_out<= not clk_out;
			         slow_count<= 0; 
			     else 
                     slow_count<=slow_count+1; 
                 end if;
                     fast_count<=0; 
                     clk_out16<=not(clk_out16);
			else 
			     fast_count<=fast_count+1;
			end if;
        end if;
	end process;
end Behavioral;