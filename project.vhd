LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY project IS
	GENERIC (MAX_WIDTH	: 	INTEGER := 8);
	PORT	(	clk			:	IN  STD_LOGIC;
				rst			:	IN  STD_LOGIC;
				PERIF1		:	OUT	STD_LOGIC;
				PERIF2		:  OUT	STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
				PERIF3		:  OUT	STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
				PERIF4		:  IN	STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
				int         :  IN STD_LOGIC);
				
END ENTITY;
------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE rtl OF project IS
   SIGNAL   BusC_s       :  STD_LOGIC_VECTOR(7 DOWNTO 0); 
	SIGNAL 	BusA_s       :  STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL	BusB_s       :  STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL   q_s          :  STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL	Bus_alu_s	 :  STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
	SIGNAL   Bus_Data_In	 :  STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
	SIGNAL   BusDataIn_s	 :  STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
	SIGNAL   BusDataOut_s :  STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
	SIGNAL   addr_bus_s	 :  STD_LOGIC_VECTOR(MAX_WIDTH-1 DOWNTO 0);
	SIGNAL   wr_dm        :  STD_LOGIC;
	SIGNAL   addr_dm      :  STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL   bus_dm         :  STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL	Controlunit  :  STD_LOGIC_VECTOR(4 DOWNTO 0); 
	SIGNAL   uinstruc     :  STD_LOGIC_VECTOR(20 DOWNTO 0); 
	SIGNAL   addr			 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL   int_reg_s	 :  STD_LOGIC;
	SIGNAL   iom		    :  STD_LOGIC;
	SIGNAL   wr_rdn	    :  STD_LOGIC;
	SIGNAL   wr_rdn_s		 :  STD_LOGIC;
	SIGNAL   enaf			 :  STD_LOGIC;
	SIGNAL   selop			 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL   shamt			 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL   BusB_addr    :  STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL   BusC_addr    :  STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL	bank_wr_en   :  STD_LOGIC;
	SIGNAL   mar_en       :  STD_LOGIC;
	SIGNAL   mdr_en       :  STD_LOGIC;
	SIGNAL   mdr_alu_n    :  STD_LOGIC;
	SIGNAL   int_clr 		 :  STD_LOGIC;
	SIGNAL   ir_en        :  STD_LOGIC;
	SIGNAL   ir_clr       :  STD_LOGIC;
	SIGNAL   en_uPC		 :  STD_LOGIC;
	SIGNAL   clr_uPC		 :	 STD_LOGIC;
	SIGNAL	C            :  STD_LOGIC;
	SIGNAL   M            :  STD_LOGIC;
	SIGNAL	Z            :  STD_LOGIC;
	SIGNAL   P            :   STD_LOGIC;
	
BEGIN 
	Controlunit <= q_s(7 DOWNTO 3);
	ir_clr     <= uinstruc(0);
	ir_en      <= uinstruc(1);
	wr_rdn     <= uinstruc(2);
	iom        <= uinstruc(3);
	int_clr    <= uinstruc(4);
	mdr_alu_n  <= uinstruc(5);
	mdr_en     <= uinstruc(6);
	mar_en     <= uinstruc(7);
	bank_wr_en <= uinstruc(8);
	busC_addr  <= uinstruc(11 DOWNTO 9);
	busB_addr  <= uinstruc(14 DOWNTO 12);
	shamt      <= uinstruc(16 DOWNTO 15);
	selop      <= uinstruc(19 DOWNTO 17);
	enaf       <= uinstruc(20);
	
	MAR:  ENTITY work.my_reg	      PORT MAP (clk, rst, mar_en, BusC_s, addr_bus_s);
	IR :  ENTITY work.int_reg_ir     GENERIC MAP(MAX_WIDTH => 8 )
                                    PORT MAP (clk, rst, ir_en, ir_clr, BusC_s, q_s);
	MDR:  ENTITY work.mdr 	         PORT MAP (clk, rst, mdr_alu_n, mdr_en, Bus_alu_s, BusDataIn_s ,BusC_s, BusDataOut_s);
	RB :  ENTITY work.reg_file       PORT MAP (clk, rst, bank_wr_en, BusC_addr, BusB_addr, BusC_s, BusA_s, BusB_s);
	ALU:  ENTITY work.alu            PORT MAP (clk, rst, BusA_s, BusB_s, selop, shamt, enaf, Bus_alu_s, C, M, P, Z);
	RAM:  ENTITY work.my_SPRAM       PORT MAP (clk, wr_dm, addr_dm, bus_dm, Bus_Data_In);	
	IREG: ENTITY work.int_reg		   PORT MAP (clk, rst, int, '1', int_clr,  int_reg_s); 
	CU:   ENTITY work.control_unit   PORT MAP (clk, rst, Z, M, C, P, int_reg_s, Controlunit, uinstruc);
	   
	--DEMUX 1
	wr_dm		<=  wr_rdn_s	WHEN  iom  = '0'	 ELSE '0';
	PERIF1	<=  wr_rdn_s	WHEN  iom  = '1'	 ELSE '0';
	
	--DEMUX 2
	addr_dm  <=	 addr_bus_s	WHEN	iom  = '0'	 ELSE	"00000000";
	PERIF2	<=  addr_bus_s	WHEN  iom  = '1'	 ELSE "00000000";
	
	--DEMUX 3
	bus_dm	<=	 BusDataOut_s	WHEN iom = '0'	 ELSE "00000000";
	PERIF3	<=  BusDataOut_s	WHEN iom = '1'	 ELSE "00000000";
	
	WITH iom SELECT
		BusDataIn_s	<=	 Bus_Data_In WHEN '0',
							 PERIF4		 WHEN OTHERS;
				  							  
END ARCHITECTURE;
	
	