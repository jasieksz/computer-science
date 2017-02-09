library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mod16 is
	port(
		CLK : in std_logic;
		counter_direction : in std_logic;
		a,b,c,d,e,f,g,a1,b1,c1,d1,e1,f1,g1 : out std_logic
		);
end mod16;

architecture logic of mod16 is
	
	component dzielnik
		port(
		d_CLK_in : in std_logic;
		d_CLK_divided : out std_logic
		);
	end component;
	
	component counter
		port(
		c_counting_direction_in : in std_logic;
		c_CLK_in : in std_logic;
		c_counter_out : out std_logic_vector(3 downto 0)
		);
	end component;
	
	component seg7
		port(
		t_counter_in : in std_logic_vector (3 downto 0);
		a_out,b_out,c_out,d_out,e_out,f_out,g_out,a1_out,b1_out,c1_out,d1_out,e1_out,f1_out,g1_out : out std_logic
		);
	end component;

	signal divided_CLK : std_logic;
	signal counter_val : std_logic_vector(3 downto 0);

begin
	divideer : dzielnik port map (d_CLK_in => CLK, d_CLK_divided => divided_CLK);
	licznik : counter port map (c_counting_direction_in=>counter_direction, c_CLK_in=>divided_CLK,c_counter_out=>counter_val);
	transkoder : seg7 port map (t_counter_in=>counter_val,a_out=>a,b_out=>b,c_out=>c,d_out=>d,e_out=>e,f_out=>f,g_out=>g,a1_out=>a1,b1_out=>b1,c1_out=>c1,d1_out=>d1,e1_out=>e1,f1_out=>f1,g1_out=>g1);
end logic;	