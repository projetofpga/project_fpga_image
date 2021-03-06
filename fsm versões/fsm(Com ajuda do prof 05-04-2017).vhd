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

type state is (S0, S1, S2, S3, S4, S5, S6, S7, S8);
	
	signal prst 		: 	state;
	signal nxst 		: 	state;
	signal data_send	: 	std_logic;
	signal data_in		:	std_logic_vector(7 downto 0); -- da placa para o PC
	signal busy			:	std_logic;
	signal data_out	:	std_logic_vector(7 downto 0);
	signal frame		:	std_logic;
	signal data_vld	:	std_logic;

  	signal address 	:   	unsigned(12 downto 0) := (others => '0');
	signal last_pixel : std_logic := '0';
	signal data 		: 	std_logic_vector(15 downto 0);
	constant MAX_PIXEL : natural := 4;
	
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

	fsmm : process(clock) -- tirar: ", tkpic, vsinc_fsm, data_send"
	begin
	
	   if rising_edge(clock) then
		case prst is
		
		
			when S0 => --------------------------------------  S0: Reset state 
				data_send<= '0';
				address <= (others => '0');
				wren_fsm <= '1';
		
				if (tkpic = '1')then
					nxst<=S1;
				else
					nxst<=S0;
				end if;
				
				
			when S1 =>  -------------------------------------  S1: Up vsinc
			
				if(vsinc_fsm = '1')then -- 1
					nxst<=S2;
				else
					nxst<=S1;
				end if;
				
		
			when S2 => --------------------------------------  S2: Down vsinc	
						
				if(vsinc_fsm = '0')then -- 0
					nxst<=S3;
				else
					nxst<=S2;
				end if;
				
				
			when S3 => --------------------------------------  S3: Up vsinc 			
				if(vsinc_fsm = '1')then -- 1
				  nxst<=S4;
				  wren_fsm <= '0'; 		-- Disable F.B.				  
				else
					nxst<=S3;
				end if;
				
			when S4 => ------------------------------------  S4: Read word and counter
				data <= buffer_data;    --Read word
				address <= address + 1; --Counter
				nxst<=S5;

			when S5 => --------------------------------------  S5: Send Most Significant Byte
			
				if (busy = '0')then
					data_send<='1'; 				  --Enable to send
					data_in<= data(15 downto 8); -- MSByte
					nxst<=S6;
				else
				   data_send<='0';
					nxst<=S5;
				end if;
				
			
			--when S5_a =>
				
				--data_send<='0';
				--nxst<=S6;
				
				
			when S6 => --------------------------------------  S5: Send Less Significant Byte
			
				if (busy = '0') then
					data_send<='1';
					data_in<= data(7 downto 0); -- byte menos significativo
					nxst<=S7;									
				else
				   data_send<='0';
					nxst<=S6;
				end if;
				
			--when S6_a =>
				
				--data_send<='0';
				--nxst<=S7;
				
			when S7 => -------------------------------------  S6: Break condition
			
				data_send<='0';
				if address = 4 then  -- Break condition				
					wren_fsm<='1';			-- Enable F.B.
					nxst<=S8;
				elsif busy = '1' then 
			      nxst <= S7;	
				else
					nxst<=S4; 
				end if;
				
		
			when S8 => -------------------------------------   
				nxst<=S8;
							
		end case;
		end if;
	end process fsmm;
end arch;

