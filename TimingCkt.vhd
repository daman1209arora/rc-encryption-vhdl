LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

entity TimingCkt is
  Port (    clk:IN std_logic;
            tx_empty:IN std_logic := '1';
            rx_full : IN std_logic := '1';
            tx_start : IN std_logic := '0';
            ld_tx : OUT std_logic := '0';
            eab1 : OUT std_logic := '0';
            wea1 : OUT std_logic := '0';
            rd_addr : OUT std_logic_vector(7 downto 0) := "00000000";
            wr_addr : OUT std_logic_vector(7 downto 0) := "00000000";
            reset : IN std_logic;
            start : IN std_logic;
            key_done : IN std_logic;
            request: OUT std_logic := '0'
        );
end TimingCkt;

architecture Behavioral of TimingCkt is
signal r_count : integer :=0;
signal t_count : integer :=0;
type states is (rx, rx_busy, received, received_done, nextaddr, encrypt, req_done, keyDone, tx, tx_starting, tx_busy, extra0, extra1);
signal state : states :=rx;
signal state_vector: std_logic_vector(7 downto 0);
begin
rd_addr <= std_logic_vector(to_unsigned(r_count, rd_addr'length));
wr_addr <= std_logic_vector(to_unsigned(t_count, wr_addr'length));
                    
process(clk, reset)
begin
        if(reset = '1')then 
            r_count<=0;
            t_count<=0;
            state<=rx;
        end if;
        if(rising_edge(clk)) then 
           if(state = rx) then 
               if(rx_full = '0') then 
                    state <= rx_busy;
               else
                    if(tx_start = '1') then
                        state <= encrypt;
                    else
                        state <= rx;
                    end if;
               end if;
           elsif(state = rx_busy) then 
                if(rx_full = '1') then    
                    state <= received;
                else    
                    state <= rx_busy;
                end if;
           elsif(state = received) then  
                eab1 <= '1'; 
                state <= received_done;
           elsif(state = received_done) then 
                eab1 <= '0';
                state <= nextaddr;
           elsif(state = nextaddr) then 
                r_count <= r_count + 1;
                state <= rx;
           elsif(state = encrypt) then
                request <= '1';
                state <= req_done;
           elsif(state = req_done) then
                request <= '0';
                state <= keyDone;
            elsif(state = keyDone) then
                if(key_done = '1') then 
                    state <= extra1; 
                end if;
            elsif(state = extra1) then 
                wea1 <= '1';
                ld_tx <= '1';
                t_count <= t_count + 1;
                state <= tx;
            elsif(state <= tx) then
                wea1 <= '0';
                ld_tx <= '0';
                state <= tx_busy;
            elsif(state <= tx_busy) then 
                if(tx_empty = '1') then
                    if(t_count = r_count - 1) then 
                        state <= extra0;
                        t_count <= 0;
                    else
                       state <= encrypt;
                    end if;
                end if;
            elsif(state = extra0) then
                state <= rx;
            end if;
        end if;
 end process;
end Behavioral;