library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity vga_driver_tb is
end vga_driver_tb;

architecture arc of vga_driver_tb is

	component vga_driver
	Port ( 
	 iVGA_CLK	    : in  STD_LOGIC;
	 r	    : out STD_LOGIC_VECTOR(3 downto 0);
	 g	    : out STD_LOGIC_VECTOR(3 downto 0);
	 b	    : out STD_LOGIC_VECTOR(3 downto 0);
	 hs	    : out STD_LOGIC;
	 vs	    : out STD_LOGIC;
	 surv : in std_logic;
	 rgb : in std_logic;
	 debug : in natural;
	 debug2 : in natural;
	 buffer_addr : out STD_LOGIC_VECTOR(12 downto 0);
	 buffer_data : in  STD_LOGIC_VECTOR(15 downto 0);
	 newframe : out std_logic;
	 leftmotion : out natural;
	 rightmotion : out natural
       );
	end component;
	
	signal vclock : std_logic;
	signal r: std_logic_vector (3 downto 0);
	signal g	    :  STD_LOGIC_VECTOR(3 downto 0);
	signal b	    :  STD_LOGIC_VECTOR(3 downto 0);
	signal hs	    :  STD_LOGIC;
	signal vs	    : STD_LOGIC;
	signal surv : std_logic:= '0';
	signal rgb : std_logic :='0';
	signal debug : natural:= 0;
	signal debug2 :  natural := 0;
	signal buffer_addr :  STD_LOGIC_VECTOR(12 downto 0);
	signal buffer_data :  STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
	signal newframe :  std_logic;
	signal leftm :  natural;
	signal rightm :  natural;

	begin
	vga: vga_driver port map(
	iVGA_CLK => vclock ,
	 r => r,
	 g => g ,
	 b => b ,
	 hs =>hs ,
	 vs =>vs ,
	 surv => surv,
	 rgb => rgb ,
	 debug =>debug ,
	 debug2 =>debug2 ,
	 buffer_addr =>buffer_addr ,
	 buffer_data =>buffer_data ,
	 newframe => newframe ,
	 leftmotion =>leftm ,
	 rightmotion=>rightm
	);
	clock_proc : PROCESS
	BEGIN
   		 WHILE (true) LOOP
        	vclock <= '1'; WAIT FOR 1ns;
        	vclock <= '0'; WAIT FOR 1ns;
    		END LOOP;
    		WAIT;
	END PROCESS;
--	vclock_process : process
--	begin
--
--		vclock <= '0';
--		wait for 1us;
--		vclock<= '1';
--		wait for 1us;
--	
--	end process;
end;