LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
----------------------------------------------------------------------------
ENTITY Project1 IS 
	GENERIC (DATA_WIDTH			:	INTEGER := 8 ;
				ADDR_WIDTH  		:  INTEGER := 3); 
	PORT (	clk	  		 		:	 IN	STD_LOGIC;
				rst			 		:	 IN   STD_LOGIC;
				INT					:   IN   STD_LOGIC;	
				PERIF1				: 	 OUT	STD_LOGIC;
				PERIF2				: 	 OUT	STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
				PERIF3				:   OUT  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
				PERIFIN				: 	 IN	STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0));
END ENTITY Project1;
----------------------------------------------------------------------------
ARCHITECTURE rtl OF Project1 IS
	SIGNAL ADDR_BUS 			    : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL BusA, BusB, BusC     : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL s_units, s_tenths	 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL q_data, BUS_DATA_OUT : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL bus_alu, BUS_DATA_IN : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ir_clr					 : STD_LOGIC;
	SIGNAL C,N,P,Z					 : STD_LOGIC;
	SIGNAL mdr_alu_n	 			 : STD_LOGIC;
	SIGNAL mdr_en		 			 : STD_LOGIC;
	SIGNAL ir_en		    		 : STD_LOGIC;
	SIGNAL mar_en		 			 : STD_LOGIC;
	SIGNAL wr_rdn  		 		 : STD_LOGIC;
	SIGNAL bank_wr_en	 			 : STD_LOGIC;
	SIGNAL BusC_addr    			 : STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL BusB_addr    			 : STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL selop    	 			 : STD_LOGIC_VECTOR (2 DOWNTO 0);
   SIGNAL shamt   	    		 : STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL enaf         			 : STD_LOGIC;
	SIGNAL iom						 : STD_LOGIC;
	SIGNAL int_clr					 : STD_LOGIC;
	SIGNAL INT_reg					 : STD_LOGIC;
	SIGNAL UI						 : STD_LOGIC_VECTOR (20 DOWNTO 0);
	SIGNAL ADDR_BUS_DM 			 : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL BUS_DATA_OUT_DM		 : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL BUS_DATA_IN_M			 : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL WR_RDN_DM				 : STD_LOGIC;
	
BEGIN
   IREG: ENTITY work.int_reg      PORT MAP (clk, rst, INT, '1', int_clr,  INT_reg); 
	MAR:  ENTITY work.my_reg	    PORT MAP (clk, rst, mar_en, BusC, ADDR_BUS);
	IR :  ENTITY work.int_reg_ir   GENERIC MAP(MAX_WIDTH => 8 )
                                  PORT MAP (clk, rst, ir_en, ir_clr, BusC, q_data);
   MDR:  ENTITY work.mdr 	       PORT MAP (clk, rst, mdr_alu_n, mdr_en, bus_alu, BUS_DATA_IN_M ,BusC, BUS_DATA_OUT);
	RB :  ENTITY work.reg_file     PORT MAP (clk, rst, bank_wr_en, BusC_addr, BusB_addr, BusC, BusA, BusB);
	ALU:  ENTITY work.alu          PORT MAP (clk, rst, BusA, BusB, selop, shamt, enaf, bus_alu, C, N, P, Z);
	RAM:  ENTITY work.my_SPRAM     PORT MAP (clk, WR_RDN_DM, ADDR_BUS_DM, BUS_DATA_OUT_DM, BUS_DATA_IN);	
   CU:   ENTITY work.control_unit PORT MAP (clk, rst, Z, N, C, P, INT_reg, q_data(7 DOWNTO 3), UI);

	
	ir_clr     <= UI(0);
	ir_en      <= UI(1);
	wr_rdn     <= UI(2);
	iom        <= UI(3);
	int_clr    <= UI(4);
	mdr_alu_n  <= UI(5);
	mdr_en     <= UI(6);
	mar_en     <= UI(7);
	bank_wr_en <= UI(8);
	busC_addr  <= UI(11 DOWNTO 9);
	busB_addr  <= UI(14 DOWNTO 12);
	shamt      <= UI(16 DOWNTO 15);
	selop      <= UI(19 DOWNTO 17);
	enaf       <= UI(20);
	

		WR_RDN_DM	<= wr_rdn	WHEN	iom = '0' ELSE '0';
		PERIF1		<= wr_rdn   WHEN  iom = '1' ELSE '0';
	

		ADDR_BUS_DM	<= ADDR_BUS	WHEN	iom = '0' ELSE "00000000";
		PERIF2		<= ADDR_BUS   WHEN  iom = '1' ELSE "00000000";
		

		BUS_DATA_OUT_DM	<= BUS_DATA_OUT	WHEN	iom = '0' ELSE "00000000";
		PERIF3		<= BUS_DATA_OUT   WHEN  iom = '1' ELSE "00000000";
		

	WITH iom SELECT
		BUS_DATA_IN_M		<= BUS_DATA_IN		WHEN	'0',
								  PERIFIN 			WHEN	OTHERS;
	
					
END ARCHITECTURE;
-------------------------------------------------------------
	
					