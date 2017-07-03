library IEEE;
use IEEE.numeric_std.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;

entity fsmtb is end fsmtb;

architecture tb of fsmtb is
	
	
	component fsm port(
	
		clock		:	in	std_logic; -- Rising up
		rx		:	in	std_logic;
		tx		:	out	std_logic;
		rst		:	in	std_logic; -- when is 1 - reset to state A
		wren_fsm 	: 	out 	std_logic;
		tkpic 		: 	in 	std_logic;
		vsinc_fsm 	: 	in 	std_logic;
		buffer_adr_fsm	: 	out 	std_logic_vector(12 downto 0);
		buffer_data	: 	in 	std_logic_vector(15 downto 0)

		);
	end component;
	
	
	--signals:
	
	signal	clock	   	:	std_logic; -- Rising up
	signal	rx		:	std_logic;
	signal	tx		:	std_logic; -- OUT
	signal	rst		:	std_logic; -- when is 1 - reset to state A
	signal  wren_fsm  	:    	std_logic; -- OUT
	signal	tkpic 	   	:    	std_logic;
	signal	vsinc_fsm 	:  	std_logic;
	signal	buffer_adr_fsm	: 	std_logic_vector(12 downto 0);-- OUT
	signal	buffer_data	: 	std_logic_vector(15 downto 0);
	signal  address 	:   	unsigned(12 downto 0) := (others => '0'); --std_logic_vector(12 downto 0);	
	

begin

	portFSM:fsm port map(
			
			clock => clock,   
			rx => rx,		  					
			tx => tx,				
			rst => rst,
			wren_fsm => wren_fsm,				
			tkpic => tkpic,
			vsinc_fsm => vsinc_fsm,
			buffer_adr_fsm => buffer_adr_fsm,	
			buffer_data => buffer_data
		); 



	--clock	   	<='0';
	
	--wren_fsm 	<='0';	
	--tkpic 	 	<='0';
	--vsinc_fsm 	<='0';
	--BUFFER_ADR_FSM	
	buffer_data	<="1100000000000011";                                       
	address 	<= (others => '0');


	rst0:process
	begin
		rst		<='1';
		wait for 10 ps;
		rst <= '0';
		wait;
	end process;
		
--------------------------------------------------------------	
		clk:process
		begin
			clock <='0';
			wait for 1ps;
        		clock <= '1';
			wait for 1ps;
		end process clk;
		
		tkp: process 
		begin
			tkpic<='0';
			wait for 2500ps;
			tkpic<='1';
			wait for 5ps;
			tkpic<='0';
			wait;		
		end process tkp;
		
		vsin:process
		begin
			vsinc_fsm<='0';
			wait for 10ps;
			vsinc_fsm<='1';
			wait for 10ps;
		end process vsin;
		



end tb;
