library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity KeyStream is
  Port (clk: in std_logic;
        reset : in std_logic := '0';
        start: in std_logic := '0';
        input: in std_logic_vector(7 downto 0);
        key: in std_logic_vector(39 downto 0);
        request: in std_logic;
        key_generation_done: out std_logic := '1'; 
        init_done: out std_logic := '0';
        output: buffer std_logic_vector(7 downto 0) := "00000000";
        stream: buffer std_logic_vector(7 downto 0) := "00000000"
        );
end KeyStream;

architecture Behavioral of KeyStream is
type states is (idle, init, swapping, swap1, swap2, temp1, temp2, ready);
signal state: states:= idle;
type t_states is(idle, busy);
type internal_t_states is (idle, swapping, swap1, swap2, temp1, temp2, done, assign, finish);
signal internal_t_state : internal_t_states:= idle;
signal t_state: t_states := idle;
signal initCount: integer := 0;
signal i: integer := 0;
signal j: integer := 0;
signal k: integer := 0;
signal req_i: integer := 0;
signal req_j : integer := 0;
type Memory_type is array (0 to 255) of std_logic_vector (7 downto 0);
signal temp: std_logic_vector(7 downto 0);
signal arr : Memory_type;
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                state <= init;
                i<=0;
                j<=0;
                k<=0;
                initCount<= 0;
                req_i<=0;
                req_j<=0;
            else
                if(state = idle) then 
                    if(start = '1') then
                        state <= init;
                        i <= 0;
                        j <= 0;
                        k <= 0;
                        initCount <= 0;
                     end if;
                elsif(state=init) then
                    if(initCount = 255) then     
                        arr(initCount) <= std_logic_vector(to_unsigned(initCount, 8));
                        state <= swapping;
                        initCount <= 0;
                    else
                        arr(initCount) <= std_logic_vector(to_unsigned(initCount, 8));
                        initCount <= initCount+1;
                    end if;
                elsif(state=swapping) then
                    if(i = 40 or i = 80 or i = 120 or i = 160 or i= 200 or i =240) then 
                        k <= 0;
                    end if;
                    if(i = 255) then 
                        state <= ready;
                    else
                        temp <= arr(i);
                        state <= temp1;
                    end if;
                elsif(state = temp1) then
                    if(key(39-k) = '1') then 
                        j <= to_integer(unsigned(std_logic_vector( to_unsigned( j + to_integer(unsigned(arr(i))) + 1, 8))));
                    else
                        j <= to_integer(unsigned(std_logic_vector( to_unsigned( j + to_integer(unsigned(arr(i))), 8))));
                    end if; 
                    state <= temp2;
                elsif(state=temp2) then
                    state<= swap1;
                elsif(state=swap1) then 
                    arr(i) <= arr(j);
                    state <= swap2;
               elsif(state=swap2) then
                    arr(j) <= temp;
                    state <= swapping;
                    k <= k + 1;
                    i<=i+1;
                elsif(state=ready) then 
                    if(t_state=idle and request = '1') then
                        key_generation_done <= '0';
                        t_state <= busy;
                        req_i <= to_integer(unsigned(std_logic_vector( to_unsigned(req_i + 1, 8))));
                        req_j <= to_integer(unsigned(std_logic_vector(to_unsigned(req_j, 8)) + arr(to_integer(unsigned(std_logic_vector( to_unsigned(req_i + 1, 8)))))));
                        internal_t_state <= swapping;
                    elsif(t_state=busy) then
                        if(internal_t_state=swapping) then
                                temp <= arr(req_i);
                                internal_t_state <= swap1;
                         elsif(internal_t_state=swap1) then
                                arr(req_i) <= arr(req_j);
                                internal_t_state <= swap2;
                         elsif(internal_t_state=swap2) then 
                                arr(req_j) <= temp;
                                internal_t_state <= done;
                         elsif(internal_t_state=done) then
                                stream <= arr(to_integer(unsigned(arr(req_i) + arr(req_j))));  
                                internal_t_state <= assign;
                                
                         elsif(internal_t_state = assign) then 
                                output <= stream xor input;
                                internal_t_state <= finish;
                         elsif(internal_t_state = finish) then 
                                key_generation_done <= '1';
                                t_state <= idle;
                         else
                                internal_t_state <= idle;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    
end Behavioral;