-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity slaves is
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rst_out: out std_logic;
		eth_err_ctrl: out std_logic_vector(35 downto 0);
		eth_err_stat: in std_logic_vector(47 downto 0) := X"000000000000";
		pkt_rx: in std_logic := '0';
		pkt_tx: in std_logic := '0';
		ckref_tdc: in std_logic;
		hit1: in std_logic;
		handshakeleds : out std_logic_vector(2 downto 0);
		REFPLL : inout std_logic;
		TRIGGER : out std_logic;
		SEUcalin : in std_logic
	);

end slaves;

architecture rtl of slaves is

	constant NSLV: positive := 7;
	signal ipbw: ipb_wbus_array(NSLV-1 downto 0);
	signal ipbr, ipbr_d: ipb_rbus_array(NSLV-1 downto 0);
	signal ctrl_reg: std_logic_vector(31 downto 0);

--CH1
	signal ctrl_reg_PChandshake1: std_logic_vector(31 downto 0);
	signal ctrl_reg_FPGAhandshake1: std_logic_vector(31 downto 0);
	signal handshakeFPGA1 : std_logic;
	
	signal ramData1 : std_logic_vector (31 downto 0);
	signal ramAddress1 : std_logic_vector (7 downto 0);
	signal we1 : std_logic;
	
	signal hitcount1 : std_logic_vector (31 downto 0);
	signal lockCounter : integer range 0 to 4000000;
	signal lockLed : std_logic;
	
	signal SEUcounter : std_logic_vector (31 downto 0);
	
	
	signal SYSCLK : std_logic;
begin

  fabric: entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

-- Slave 0: id / rst reg

	slave0: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(0),
			ipbus_out => ipbr(0),
			d => SEUcounter,
			q => ctrl_reg
		);
		
		rst_out <= ctrl_reg(0);

	slave1: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(1),
			ipbus_out => ipbr(1),
			d => ctrl_reg_FPGAhandshake1,
			q => ctrl_reg_PChandshake1
		);
		
	slave2: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(2),
			ipbus_out => ipbr(2),
			d => hitcount1,
			q => open
		);
		
	slave3: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(3),
			ipbus_out => ipbr(3),
			d => X"00000000",
			q => open
		);
		
	slave4: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(4),
			ipbus_out => ipbr(4),
			d => X"00000000",
			q => open
		);

	RAM1: entity work.ipbus_dpram
		generic map(addr_width => 8)
		port map(
			clk => ipb_clk,
			rst => ipb_rst,
			ipb_in => ipbw(5),
			ipb_out => ipbr(5),
			rclk=>SYSCLK,
			we=>we1,
			d=>ramData1,
			q=>open,
			addr=>ramAddress1
		);
		
		
	RAM2: entity work.ipbus_dpram
		generic map(addr_width => 8)
		port map(
			clk => ipb_clk,
			rst => ipb_rst,
			ipb_in => ipbw(6),
			ipb_out => ipbr(6),
			rclk=>SYSCLK,
			we=>'0',
			d=>X"00000000",
			q=>open,
			addr=>X"00"
		);
		

		
	SEUcalibrator : entity work.SEUcounter
	port map(
		clk=>ipb_clk,
		SEUin => SEUcalin,
		CTRout=>SEUcounter	
	);
		
	process (handshakeFPGA1)
	begin
		if(handshakeFPGA1='1') then
				ctrl_reg_FPGAhandshake1<= X"00000001";
			else
				ctrl_reg_FPGAhandshake1<= X"00000000";
		
		end if;
	end process;
--	process (handshakeFPGA2)
--	begin
--		if(handshakeFPGA2='1') then
--				ctrl_reg_FPGAhandshake2<= X"00000001";
--			else
--				ctrl_reg_FPGAhandshake2<= X"00000000";
--		
--		end if;
--	end process;
	
	
	
	TDCchannels: entity TDCslave
	port map(
		ckref=>ckref_tdc,
		REFPLL=>REFPLL,
		RESET=>'0',
		hit1=>hit1,
		--hit2=>hit2,
		
		IPbus_RAM_data1=>ramData1, --DPRAM 
		IPbus_RAM_address1=>ramAddress1,
		IPbus_RAM_we1=>we1,
		handshakePC1=>ctrl_reg_PChandshake1(0),
		handshakeFPGA1=>handshakeFPGA1,
		
--		IPbus_RAM_data2=>ramData2, --DPRAM 
--		IPbus_RAM_address2=>ramAddress2,
--		IPbus_RAM_we2=>we2,
--		handshakePC2=>ctrl_reg_PChandshake2(0),
--		handshakeFPGA2=>handshakeFPGA2,
		
	
		
		hitCount1=>hitCount1,
		--hitCount2=>hitCount2,
		SYSCLK=>SYSCLK,
		TRIGGER=>TRIGGER
	);
	
	process (REFPLL)
	begin
		if(rising_edge(REFPLL)) then
			lockCounter<=lockCounter +1;
			if(lockCounter = 0) then
				lockLed<= not lockLed;
			end if;
		end if;
	end process;
	handshakeleds<=lockLed & handshakeFPGA1 & '0';-- & handshakeFPGA2;
	
--	datagen: entity test_datagen
--	port map(
--    clk=>ipb_clk,
--    handshakePC=>ctrl_reg_PChandshake(0),
--    handshakeFPGA=>handshakeFPGA,
--    we=>we,
--    data=>ramData,
--    address=>ramAddress,
--	 framecount=>hitcount
--    );


end rtl;
