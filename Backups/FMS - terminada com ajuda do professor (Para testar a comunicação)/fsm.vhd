--
-- FSM MEALY
-- 
-- Searched sequence 111
--
-- Outhor: Wesley Sombra
--

library IEEE;
use IEEE.std_logic_1164.all;

entity fsm is port(

	clock	:	in	std_logic; -- Rising up
	rx		:	in	std_logic;
	tx		:	out	std_logic;
	rst	:	in	std_logic; -- when is 1 - reset to state A
	led1	: out	std_logic;
	led2	:	out 	std_logic;
	led3	:	out	std_logic
);
end entity;

architecture arch of fsm is


	type state is (A, B, C, D, E, F, G);
	--signal pr_S, nx_S	:	state;
	signal nst 			: 	state;
	signal data_send	: 	std_logic;
	signal data_in		:	std_logic_vector(7 downto 0);
	--signal reset		:	std_logic;
	signal busy			:	std_logic;
	signal data_out	:	std_logic_vector(7 downto 0);
	signal frame		:	std_logic;
	signal data_vld	:	std_logic;

	ATTRIBUTE ENUM_ENCODING: STRING;
	ATTRIBUTE ENUM_ENCODING OF state: TYPE IS "sequential";--"00 01 10 11" *obs QUARTUS II


	component uart
	    Generic (
        CLK_FREQ    : integer := 50e6;   -- set system clock frequency in Hz
        BAUD_RATE   : integer := 115200; -- baud rate value
        PARITY_BIT  : string  := "none"  -- legal values: "none", "even", "odd", "mark", "space"
    );
	Port (
		CLK         : in  std_logic; -- system clock
		RST         : in  std_logic; -- high active synchronous reset
		-- UART INTERFACE
		UART_TXD    : out std_logic;
		UART_RXD    : in  std_logic;
		-- USER DATA INPUT INTERFACE
		DATA_IN     : in  std_logic_vector(7 downto 0);
		DATA_SEND   : in  std_logic; -- when DATA_SEND = 1, data on DATA_IN will be transmit, DATA_SEND can set to 1 only when BUSY = 0
		BUSY        : out std_logic; -- when BUSY = 1 transiever is busy, you must not set DATA_SEND to 1
		-- USER DATA OUTPUT INTERFACE
		DATA_OUT    : out std_logic_vector(7 downto 0);
		DATA_VLD    : out std_logic; -- when DATA_VLD = 1, data on DATA_OUT are valid
		FRAME_ERROR : out std_logic  -- when FRAME_ERROR = 1, stop bit was invalid, current and next data may be invalid
	);
	end component;
	
	

	begin

		c1: uart 
    Generic map (
        CLK_FREQ    => 50e6,   -- set system clock frequency in Hz
        BAUD_RATE   => 115200, -- baud rate value
        PARITY_BIT  => "none"  -- legal values: "none", "even", "odd", "mark", "space"
    )		
		
		port map (
			CLK => clock,
			RST => not rst,
			UART_TXD => tx,
			UART_RXD => rx,
			DATA_IN => data_in,
			DATA_SEND => data_send,
			BUSY=>busy,
			DATA_OUT => data_out,
			DATA_VLD => data_vld,
			FRAME_ERROR => frame
			);

			--led3 <= data_vld;
-------------------------------------------------------- section combinational
		fsmm : process(clock,nst,rst)
		begin
			if rst = '0' then
				nst <= A;
			elsif (rising_edge(clock)) then
				case nst is
					when A => 				-- First state
						if(data_vld = '1') then
							nst <= B;
						else
							nst <= A;
						end if;

					when B => 
						if(data_out = x"01") then
							nst <= C;
						elsif(data_out = x"02") then
							nst <= D;
						elsif (data_out = x"04") then
							nst <= E;
						else
							nst <=B;
							
						end if;

					when C => 				
							nst <= F;
					when D => 				
							nst <= F;
					when E =>
							nst <= F;
					when F =>
							nst <= G;
					when G =>
							if (busy = '1')then
								nst <= G;
							end if;
							
				end case;
			end if;
		end process fsmm;
		
--------------------------------------------------------
	process (nst,data_out,data_send,data_in)
		begin
			case nst is
				when A=>
					led1<='0';
					led2<='0';
					--led3<='0';
					data_send <= '0';
									
				when B=>
					if(data_out = x"01") then
						led1<='1';
						led2<='0';
						--led3<='0';
						
					elsif(data_out = x"02") then
						led1<='0';
						led2<='1';
						--led3<='0';
						
					elsif (data_out = x"04") then
						led1<='0';
						led2<='0';
						--led3<='1';
						
					end if;
				
				when F=>
					data_in <= "01001111";--o
					data_send <= '1';
				when G=>
					--if (busy = '0')then
						data_send <= '0';
						led1<='1';
						led2<='1';						
					--end if;
				when others=>
				
			end case;
		end process;




end architecture;



























