library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity fsm is port(

	clock		: in	std_logic; -- Rising up
	rx		: in	std_logic;
	tx		: out	std_logic;
	rst		: in	std_logic; -- when is 1 - reset to state A
	wren_fsm	: out 	std_logic;
	tkpic 		: in 	std_logic;
	vsinc_fsm 	: in 	std_logic;
	buffer_adr_fsm	: out 	std_logic_vector(12 downto 0);
	buffer_data	: in 	std_logic_vector(15 downto 0)
	

);
end entity fsm;

architecture arch of fsm is

	type state is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10);
	
	signal prst 		: 	state;
	signal nxst 		: 	state;
	signal data_send	: 	std_logic;
	signal data_in		:	std_logic_vector(7 downto 0); -- da placa para o PC
	signal busy		:	std_logic;
	signal data_out		:	std_logic_vector(7 downto 0);
	signal frame		:	std_logic;
	signal data_vld		:	std_logic;

  	signal address 		:   	std_logic_vector(12 downto 0) := "0000000000000";--(others => '0');
	signal data 		: 	std_logic_vector(15 downto 0);
	
	--ATTRIBUTE ENUM_ENCODING			: STRING;
	--ATTRIBUTE ENUM_ENCODING OF state: TYPE IS "sequential";


	component uart
	    Generic (
        CLK_FREQ    : integer := 50e6;   -- set system clock frequency in Hz
        BAUD_RATE   : integer := 9600; -- baud rate value -- 115200
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
	
--------------------------------------------------------------	

begin
	buffer_adr_fsm<=std_logic_vector(address(12 downto 0)); -- Essa conversao eh necessaria? _Wesley.
	
	
	c1: uart 
   	Generic map (
       	CLK_FREQ    => 50e6,   -- set system clock frequency in Hz
       	BAUD_RATE   => 9600, -- baud rate value
       	PARITY_BIT  => "none"  -- legal values: "none", "even", "odd", "mark", "space"
   	)		
		
	port map (
		CLK => clock,
		RST => rst,
		UART_TXD => tx,
		UART_RXD => rx,
		DATA_IN => data_in,
		DATA_SEND => data_send,
		BUSY=>busy,
		DATA_OUT => data_out,
		DATA_VLD => data_vld,
		FRAME_ERROR => frame
	);

		--MAQUINA DE ESTADOS--
-----------------------------------------------------------------------------------------			
	clk : process (clock, rst)
		begin
			if(rst = '1')then
				prst <= S0;
			elsif(clock'event and clock='1')then
				prst <= nxst;
			end if;		
	end process clk;
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

	fsmm : process(prst, tkpic, vsinc_fsm) -- tirar: ", tkpic, vsinc_fsm, data_send"
	--variable count 	: 	integer range 1 to 4800;
	--constant MAX 	: 	integer := 4800;
	begin
		case prst is
		
		
			when S0 => --------------------------------------   S0
				data_send<= '0';
				address <= "0000000000000";--(others => '0');
				wren_fsm <= '1';
				--count := 1;	
		
				if (tkpic = '1')then
		
					nxst<=S1;
				else
					nxst<=S0;
				end if;
				
				
			when S1 =>  --------------------------------------   S1
			
				if(vsinc_fsm = '1')then -- 1
					nxst<=S2;
				else
					nxst<=S1;
				end if;
				
				
			when S2 => --------------------------------------   S2 	
						
				if(vsinc_fsm = '0')then -- 0
					nxst<=S3;
				else
					nxst<=S2;
				end if;
				
				
			when S3 => --------------------------------------   S3
			
				if(vsinc_fsm = '1')then -- 1
					nxst<=S4;
				else
					nxst<=S3;
				end if;
				
				
			when S4 => --------------------------------------   S4
			
				wren_fsm <= '0'; -- Desabilita F.B.
				nxst<=S5;
				
				
			when S5 => --------------------------------------   S5
			
				--address="0000000000101"
				-- 4800 = 1001011000000
				if(address="1001011000000") then  -- Habilita o F.B. e retorna para S0 apos leitura completa.					
					data_send<='0';
					wren_fsm<='1';
					nxst<=S0;	
				else
					nxst<=S6; 
				end if;
				
					
			when S6 => --------------------------------------   S6 --Ler do F.B.
			
				data <= buffer_data; -- Ler a palavra de 16 bits
				--count := count+1;
				address <= std_logic_vector( unsigned(address) + 1 );
				nxst<=S7;


			when S7 => --------------------------------------   S7
			
				if (busy = '0')then
					data_send<='1'; --
					data_in<= data(15 downto 8); -- byte mais significativo
					nxst<=S8;
				else
					nxst<=S7;
				end if;
				
				
			when S8 => --------------------------------------   S8
			
				data_send<='0';
				nxst<=S9;
				
				
			when S9 => --------------------------------------   S9
			
				if (busy = '0') then
					data_send<='1';
					data_in<= data(7 downto 0); -- byte menos significativo
					nxst<=S10;
				else
					nxst<=S9;
				end if;
				
				
			when S10 => -------------------------------------   S10
			
				data_send<='0';
				--nxst<=S11;
				nxst<=S5;--------
				
				
			--when S11 => -------------------------------------   S11
				--if(busy = '0')then
				--	nxst<=S5;
				--else
				--	nxst<=S11;
				--end if;
							
		end case;
	end process fsmm;
end arch;
