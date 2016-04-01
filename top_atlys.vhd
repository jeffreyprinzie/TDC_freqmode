-- Top-level design for ipbus demo
--
-- This version is for xc6slx45 on Digilent ATLYS board
-- Uses the s6 soft TEMAC core with GMII inteface to an external Gb PHY
-- You will need a license for the core
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 16/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.ipbus.all;

library UNISIM;
use UNISIM.VComponents.all;


entity top is port(
	sysclk: in STD_LOGIC;
	leds: out STD_LOGIC_VECTOR(3 downto 0);
	gmii_gtx_clk, gmii_tx_en, gmii_tx_er : out STD_LOGIC;
	gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in STD_LOGIC;
	gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
	phy_rstb : out STD_LOGIC;
	dip_switch: in std_logic_vector(3 downto 0);
	
	--tdc
	ckref_tdc_p,ckref_tdc_n: in std_logic;
	PLLREF1_P,PLLREF1_N: out std_logic;
	PLLREF2_P,PLLREF2_N: out std_logic;
	hit1_P,hit1_N: in std_logic;
	--hit2_P,hit2_N: in std_logic;
	handshakeleds : out std_logic_vector(2 downto 0);

	
	--I2C
	sdai2c : inout std_logic;
	scli2c : in std_logic;
	sda,sck,reset,scapt,commBusy : out std_logic;
	TRIGGER : out std_logic
	);
end top;

architecture rtl of top is

	signal clk125, ipb_clk, locked, rst_125, rst_ipb, onehz : STD_LOGIC;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal pkt_rx, pkt_tx, pkt_rx_led, pkt_tx_led, sys_rst: std_logic;	
	
	signal hit1,hit1_ub : std_logic;
	signal sysclk_b : std_logic;
	signal REFPLL : std_logic;
	
	
   signal test_hier : std_logic;
	 
	signal divider : std_logic_vector (1 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_s6_extphy_100mhz port map(
		sysclk => sysclk,
		clko_125 => clk125,
		clko_ipb => ipb_clk,
		locked => locked,
		nuke => sys_rst,
		rsto_125 => rst_125,
		rsto_ipb => rst_ipb,
		onehz => onehz,
		sysclk_buffer=>sysclk_b
		);
		
	leds <= (pkt_rx_led, pkt_tx_led, locked, onehz);
	
-- Ethernet MAC core and PHY interface
-- In this version, consists of hard MAC core and GMII interface to external PHY
-- Can be replaced by any other MAC / PHY combination
	
	eth: entity work.eth_s6_gmii port map(
		clk125 => clk125,
		rst => rst_125,
		gmii_gtx_clk => gmii_gtx_clk,
		gmii_tx_en => gmii_tx_en,
		gmii_tx_er => gmii_tx_er,
		gmii_txd => gmii_txd,
		gmii_rx_clk => gmii_rx_clk,
		gmii_rx_dv => gmii_rx_dv,
		gmii_rx_er => gmii_rx_er,
		gmii_rxd => gmii_rxd,
		tx_data => mac_tx_data,
		tx_valid => mac_tx_valid,
		tx_last => mac_tx_last,
		tx_error => mac_tx_error,
		tx_ready => mac_tx_ready,
		rx_data => mac_rx_data,
		rx_valid => mac_rx_valid,
		rx_last => mac_rx_last,
		rx_error => mac_rx_error
	);
	
	phy_rstb <= '1';
	
-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
		port map(
			mac_clk => clk125,
			rst_macclk => rst_125,
			ipb_clk => ipb_clk,
			rst_ipb => rst_ipb,
			mac_rx_data => mac_rx_data,
			mac_rx_valid => mac_rx_valid,
			mac_rx_last => mac_rx_last,
			mac_rx_error => mac_rx_error,
			mac_tx_data => mac_tx_data,
			mac_tx_valid => mac_tx_valid,
			mac_tx_last => mac_tx_last,
			mac_tx_error => mac_tx_error,
			mac_tx_ready => mac_tx_ready,
			ipb_out => ipb_master_out,
			ipb_in => ipb_master_in,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			pkt_rx => pkt_rx,
			pkt_tx => pkt_tx,
			pkt_rx_led => pkt_rx_led,
			pkt_tx_led => pkt_tx_led
		);
		
	mac_addr <= X"020ddba115" & dip_switch & X"0"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a80a0a" ;--192.168.10.10& dip_switch & X"0"; -- 192.168.200.X

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.



	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
		rst_out => sys_rst,
		pkt_rx => pkt_rx,
		pkt_tx => pkt_tx,
		ckref_tdc=>hit1,--sysclk_b,
		hit1=>hit1,
		--hit2=>hit2,
		handshakeleds=>handshakeleds,
		REFPLL=>REFPLL,
		TRIGGER=>TRIGGER
	);
	
	
	myprogrammer: entity work.programmer port map(
	 clkin=>sysclk_b,
	 sda=>sdai2c,
	 scl=>scli2c,
	 commBusy=>commBusy,
	 p_sck_inv=>sck,
	 p_sda_inv=>sda,
	 p_scapt_inv=>scapt,
	 p_reset_inv=>reset
    );
	 
	 
	
	input_buffer_ckref: IBUFGDS 
   port map(
		O=>open,--ckref_tdc
		I=>ckref_tdc_p,
		IB=>ckref_tdc_n
		);
	 --hit1 <= not ckref_tdc;
	 
	 	input_buffer_hit1: IBUFGDS 
   port map(
		O=>hit1_ub,
		I=>hit1_P,
		IB=>hit1_N
		);
	Gbuffer_hit1: BUFG
	port map(
		O=> hit1,
		I=>hit1_ub
		);
--		input_buffer_hit2: IBUFGDS 
--   port map(
--		O=>hit2,
--		I=>hit2_P,
--		IB=>hit2_N
--		);
	 
	 output_buffer1_ckref: OBUFDS 
   port map(
		O=>PLLREF1_P,
		I=>REFPLL,
		OB=>PLLREF1_N
		);
	output_buffer2_ckref: OBUFDS 
	port map(
		O=>PLLREF2_P,
		I=>REFPLL,
		OB=>PLLREF2_N
		);
 

	 
	

end rtl;
