library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity dzielnik is 
	port(
		d_CLK_in : in std_logic;
		d_CLK_divided : out std_logic
		);
end dzielnik;

architecture logic of dzielnik is
	signal counter : integer := 0;
	signal CLK_output : std_logic := '0';
begin
	process(d_CLK_in)
	begin
		if (d_CLK_in'event and d_CLK_in = '1') then
			if (counter > 8000000) then
				counter <= 0;
				CLK_output <= not CLK_output;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;
	d_CLK_divided<=CLK_output;
end logic;

