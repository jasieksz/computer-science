library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg7 is
		port(
		t_counter_in : std_logic_vector (3 downto 0);
		a_out,b_out,c_out,d_out,e_out,f_out,g_out,a1_out,b1_out,c1_out,d1_out,e1_out,f1_out,g1_out : out std_logic
		);	
end seg7;

architecture logic of seg7 is
	signal out7 : std_logic_vector (6 downto 0);
	signal out6 : std_logic_vector (6 downto 0);
begin 
	process(t_counter_in)
	begin
		case t_counter_in(3 downto 0) is
			when x"0" => 
				out7 <= "0000001";
				out6 <= "0000001";
			when x"1" =>
				out7 <= "1001111";
				out6 <= "0000001";
			when x"2" =>
				out7 <= "0010010";
				out6 <= "0000001";
			when x"3" =>
				out7 <= "0000110";
				out6 <= "0000001";
			when x"4" =>
				out7 <= "1001100";
				out6 <= "0000001";
			when x"5" =>
				out7 <= "0100100";
				out6 <= "0000001";
			when x"6" =>
				out7 <= "0100000";
				out6 <= "0000001";
			when x"7" =>
				out7 <= "0001111";
				out6 <= "0000001";
			when x"8" =>
				out7 <= "0000000";
				out6 <= "0000001";
			when x"9" =>
				out7 <= "0000100";
				out6 <= "0000001";
			when x"a" =>
				out7 <= "0000001";
				out6 <= "1001111";
			when x"b" =>
				out7 <= "1001111";
				out6 <= "1001111";
			when x"c" =>
				out7 <= "0010010"; --2
				out6 <= "1001111"; --1
			when x"d" =>
				out7 <= "0000110"; --3
				out6 <= "1001111";
			when x"e" =>
				out7 <= "1001100"; --4
				out6 <= "1001111";
			when x"f" =>
				out7 <= "0100100"; --5
				out6 <= "1001111";
		end case;
	end process;
	
	a_out <= out7(6);
	b_out <= out7(5);
	c_out <= out7(4);
	d_out <= out7(3);
	e_out <= out7(2);
	f_out <= out7(1);
	g_out <= out7(0);
	a1_out <= out6(6);
	b1_out <= out6(5);
	c1_out <= out6(4);
	d1_out <= out6(3);
	e1_out <= out6(2);
	f1_out <= out6(1);
	g1_out <= out6(0);
	
end logic;