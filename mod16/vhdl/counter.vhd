library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity counter is
		port(
		c_counting_direction_in: in std_logic;
		c_CLK_in : in std_logic;
		c_counter_out : out std_logic_vector(3 downto 0)
		);
end counter;

architecture logic of counter is
	signal cvalue : std_logic_vector(3 downto 0);
begin
	process(c_CLK_in, c_counting_direction_in)
	begin
		if(c_CLK_in'event and c_CLK_in = '1') then
			if ( c_counting_direction_in  = '1' ) then
				cvalue <= cvalue + 1;
			else 
				cvalue <= cvalue - 1;
			end if;
		end if;
	end process;
	c_counter_out <= cvalue;
end logic;	