library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity fsm is port(

	clock	:	in	std_logic; -- Rising up
	rx		:	in	std_logic;
	tx		:	out	std_logic;
	rst	:	in	std_logic; -- when is 1 - reset to state A
	wren_fsm : out std_logic;
	tkpic : in std_logic;
	vsinc_fsm : in std_logic;
	buffer_adr_fsm: out std_logic_vector(12 downto 0);
	buffer_data: in std_logic_vector(15 downto 0);
	led : out std_logic;
	led2 : out std_logic

);
end entity;

architecture arch of fsm is
	
	type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
	signal state 		: 	state_type;	
	
	
	--signal prst 		: 	state;
	
	shared variable count 	: 	integer := 1;
	constant MAX 	: 	integer := 4800;

	signal data_send	: 	std_logic;
	signal data_in		:	std_logic_vector(7 downto 0); -- da placa para o PC
	signal busy			:	std_logic;
	signal data_out		:	std_logic_vector(7 downto 0);
	signal frame		:	std_logic;
	signal data_vld		:	std_logic;
	
	
  	signal address 		:   unsigned(12 downto 0) := (others => '0');
	signal data 		: 	std_logic_vector(15 downto 0);
	
	--attribute syn_encoding : string;
	--attribute syn_encoding of state_type : type is "safe";
	--ATTRIBUTE ENUM_ENCODING			: STRING;
	--ATTRIBUTE ENUM_ENCODING OF state: TYPE IS "sequential";


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
	
--------------------------------------------------------------	

begin
buffer_adr_fsm<=std_logic_vector(address(12 downto 0));
	
	
	c1: uart 
   	Generic map (
       	CLK_FREQ    => 50e6,   -- set system clock frequency in Hz
       	BAUD_RATE   => 115200, -- baud rate value
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
	st : process (clock, rst)
		
		begin
		
			if(rst = '1')then
				state <= S0;
			
			elsif(rising_edge(clock))then -- clock'event and clock='1'
				
				case state is 
				
					when S0 =>
						if (tkpic = '1')then
							state<=S1;
						else
							state<=S0;
						end if;
					when S1 =>
						if(vsinc_fsm = '1')then -- 1
							state<=S2;
						else
							state<=S1;
						end if;
					when S2 => 				
						if(vsinc_fsm = '0')then -- 0
							state<=S3;
						else
							state<=S2;
						end if;
					when S3 => 				
						if(vsinc_fsm = '1')then -- 1
							state<=S4;
						else
							state<=S3;
						end if;
					when S4 =>  -- Estado para desabilitar F.B.
						state<=S5;
						
					when S5 =>  -- Estado para 
						if(count /= MAX)then 
							state<=S6;
						else
							state<=S0; 
						end if;
					
					when S6 =>  -- Estado para capturar palavra do F.B. e incrementar contador e endereço. 
						state<=S7;

					when S7 => --Estado para enviar o 1° byte(MSB) da palavra (15 to 8)
						if (busy = '0')then
							state<=S8;
						else
							state<=S7;
						end if;
					when S8 => -- Final da trasmissão. Vai para próximo estado
						state<=S9;
					when S9 => --Estado para enviar o 2° byte(LSB) da palavra (7 to 0)
						if (busy = '0') then
							state<=S10;
						else
							state<=S9;
						end if;
					when S10 => -- Final da trasmissão. Vai para próximo estado
						state<=S11;
					when S11 => -- Se terminol de transmitir a palavra volta para S5 para transmitir a próxima palavra
						if(busy = '0')then
							state<=S5;
						else
							state<=S11;
						end if;
						
				end case;
				
			end if;		
			
	end process st;
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

	io: process(state, tkpic, vsinc_fsm)
	
		
		
		begin
		
			case state is
				when S0 =>
					wren_fsm <= '1';
					count := 1;	
					data_send<= '0';
					address <= (others => '0');
					
				--when S1 
				--when S2 
				--when S3 
				when S4 =>
					wren_fsm <= '0'; -- Desabilita F.B.

				when S5 => -- Habilita o F.B. e retorna para S0 após leitura completa.					
					if(count = 4800)then
						data_send<='0';
						wren_fsm<='1';
						led <= '1';
					end if;
					
				when S6 =>  -- Captura do F.B. e incrementa contador e endereço.
					data <= buffer_data;
					count := count+1;
					address <= address+1;

				when S7 => -- Envia o 1° byte(MSB) da palavra, | (15 to 8).
					--if (busy = '0')then
						data_send<='1';
						data_in<=data(15 downto 8); -- byte mais significativo
					--end if;
					
				when S8 => -- Enviou 1° byte
					data_send<='0';

				when S9 => -- Envia o 2° byte(LSB) da palavra, | (7 to 0).
					--if (busy = '0') then
						data_send<='1'; --
						data_in<=data(7 downto 0); -- byte menos significativo
					--end if;
					
				when S10 => -- Enviou 2° byte
					data_send<='0';

				--when S11 
				when others =>
					
							
			end case;
			
	end process io;
	
end arch;
