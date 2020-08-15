library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    reset: IN std_logic;
    check: OUT std_logic_vector(15 downto 0)
  );
end memory;

architecture Behavioral of memory is

	type Memory_type is array (0 to 255) of std_logic_vector (7 downto 0);
	signal Memory_array : Memory_type;
	signal address : unsigned (7 downto 0);
begin
    check <= Memory_array(2) & Memory_array(3);
	process (clkb)
	begin
    if rising_edge(clkb) then    
        if (enb = '1') then
            address <= unsigned(addrb);    
        end if;
    end if;
    end process;
	doutb <= Memory_array (to_integer(address));
	
	
	process (clka)
	begin
		if rising_edge(clka) then	
			if(reset = '1') then Memory_array(0)<="00000000";
			else
			if (wea = '1') then
				Memory_array (to_integer(unsigned(addra))) <= dina (7 downto 0);	
			end if;
		    end if;
		end if;
	end process;
end Behavioral;