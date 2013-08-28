//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version : 1.11
//  \   \         Application : Spartan-6 FPGA GTP Transceiver Wizard
//  /   /         Filename : s6_gtpwizard_v1_11_tile.v
// /___/   /\      
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Module s6_gtpwizard_v1_11_tile (a GTPA1_DUAL Tile Wrapper)
// Generated by Xilinx Spartan-6 FPGA GTP Transceiver Wizard
// 
// 
// (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps


//***************************** Entity Declaration ****************************

module s6_gtpwizard_v1_11_tile #
(
    // Simulation attributes
    parameter   TILE_SIM_GTPRESET_SPEEDUP  =   0,      // Set to 1 to speed up sim reset
    parameter   TILE_CLK25_DIVIDER_0       =   6,
    parameter   TILE_CLK25_DIVIDER_1       =   6,
    parameter   TILE_PLL_DIVSEL_FB_0       =   2,
    parameter   TILE_PLL_DIVSEL_FB_1       =   2,
    parameter   TILE_PLL_DIVSEL_REF_0      =   1,
    parameter   TILE_PLL_DIVSEL_REF_1      =   1,
    
    
    //
    parameter   TILE_PLL_SOURCE_0           = "PLL0",
    parameter   TILE_PLL_SOURCE_1           = "PLL1",
    parameter   C_BYPASS_TXBUF              =  0
)
(
    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   LOOPBACK0_IN,
    input   [2:0]   LOOPBACK1_IN,
    //------------------------------- PLL Ports --------------------------------
    input           CLK00_IN,
    input           CLK01_IN,
    input           GTPRESET0_IN,
    input           GTPRESET1_IN,
    output          PLLLKDET0_OUT,
    output          PLLLKDET1_OUT,
    output          RESETDONE0_OUT,
    output          RESETDONE1_OUT,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   RXCHARISCOMMA0_OUT,
    output  [3:0]   RXCHARISCOMMA1_OUT,
    output  [3:0]   RXCHARISK0_OUT,
    output  [3:0]   RXCHARISK1_OUT,
    output  [3:0]   RXDISPERR0_OUT,
    output  [3:0]   RXDISPERR1_OUT,
    output  [3:0]   RXNOTINTABLE0_OUT,
    output  [3:0]   RXNOTINTABLE1_OUT,
    output  [3:0]   RXRUNDISP0_OUT,
    output  [3:0]   RXRUNDISP1_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          RXBYTEISALIGNED0_OUT,
    output          RXBYTEISALIGNED1_OUT,
    input           RXENMCOMMAALIGN0_IN,
    input           RXENMCOMMAALIGN1_IN,
    input           RXENPCOMMAALIGN0_IN,
    input           RXENPCOMMAALIGN1_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  RXDATA0_OUT,
    output  [31:0]  RXDATA1_OUT,
    output          RXRECCLK0_OUT,
    output          RXRECCLK1_OUT,
    input           RXRESET0_IN,
    input           RXRESET1_IN,
    input           RXUSRCLK0_IN,
    input           RXUSRCLK1_IN,
    input           RXUSRCLK20_IN,
    input           RXUSRCLK21_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    input           GATERXELECIDLE0_IN,
    input           GATERXELECIDLE1_IN,
    input           IGNORESIGDET0_IN,
    input           IGNORESIGDET1_IN,
    output          RXELECIDLE0_OUT,
    output          RXELECIDLE1_OUT,
    input   [1:0]   RXEQMIX0_IN,
    input   [1:0]   RXEQMIX1_IN,
    input           RXN0_IN,
    input           RXN1_IN,
    input           RXP0_IN,
    input           RXP1_IN,
    //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
    output  [2:0]   RXSTATUS0_OUT,
    output  [2:0]   RXSTATUS1_OUT,
    //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
    input   [7:0]   DADDR_IN,
    input           DCLK_IN,
    input           DEN_IN,
    input   [15:0]  DI_IN,
    output          DRDY_OUT,
    output  [15:0]  DRPDO_OUT,
    input           DWE_IN,
    //-------------------------- TX/RX Datapath Ports --------------------------
    output  [1:0]   GTPCLKFBEAST_OUT,
    output  [1:0]   GTPCLKFBWEST_OUT,
    output  [1:0]   GTPCLKOUT0_OUT,
    output  [1:0]   GTPCLKOUT1_OUT,
    //----------------- Transmit Ports - 8b10b Encoder Control -----------------
    input   [3:0]   TXBYPASS8B10B0_IN,
    input   [3:0]   TXBYPASS8B10B1_IN,
    input   [3:0]   TXCHARDISPMODE0_IN,
    input   [3:0]   TXCHARDISPMODE1_IN,
    input   [3:0]   TXCHARDISPVAL0_IN,
    input   [3:0]   TXCHARDISPVAL1_IN,
    input   [3:0]   TXCHARISK0_IN,
    input   [3:0]   TXCHARISK1_IN,
    output  [3:0]   TXKERR0_OUT,
    output  [3:0]   TXKERR1_OUT,
    output  [3:0]   TXRUNDISP0_OUT,
    output  [3:0]   TXRUNDISP1_OUT,
    //------------- Transmit Ports - TX Buffer and Phase Alignment -------------
    input           TXENPMAPHASEALIGN0_IN,
    input           TXENPMAPHASEALIGN1_IN,
    input           TXPMASETPHASE0_IN,
    input           TXPMASETPHASE1_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  TXDATA0_IN,
    input   [31:0]  TXDATA1_IN,
    output          TXOUTCLK0_OUT,
    output          TXOUTCLK1_OUT,
    input           TXRESET0_IN,
    input           TXRESET1_IN,
    input           TXUSRCLK0_IN,
    input           TXUSRCLK1_IN,
    input           TXUSRCLK20_IN,
    input           TXUSRCLK21_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   TXDIFFCTRL0_IN,
    input   [3:0]   TXDIFFCTRL1_IN,
    output          TXN0_OUT,
    output          TXN1_OUT,
    output          TXP0_OUT,
    output          TXP1_OUT,
    input   [2:0]   TXPREEMPHASIS0_IN,
    input   [2:0]   TXPREEMPHASIS1_IN,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           TXELECIDLE0_IN,
    input           TXELECIDLE1_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    input           TXCOMSTART0_IN,
    input           TXCOMSTART1_IN,
    input           TXCOMTYPE0_IN,
    input           TXCOMTYPE1_IN


);



//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;


   

    //RX Datapath signals
    wire    [31:0]  rxdata0_i;       

    //TX Datapath signals
    wire    [31:0]  txdata0_i;           

   

    //RX Datapath signals
    wire    [31:0]  rxdata1_i;       

    //TX Datapath signals
    wire    [31:0]  txdata1_i;           




// 
//********************************* Main Body of Code**************************
                       
    //-------------------------  Static signal Assigments ---------------------   

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;
                                            

    //-------------------  GTP Datapath byte mapping  -----------------
    
    
    // The GTP provides little endian data (first byte received on RXDATA[7:0])     
    assign  RXDATA0_OUT    =   rxdata0_i;

    // The GTP transmits little endian data (TXDATA[7:0] transmitted first)     
    assign  txdata0_i    =   TXDATA0_IN;
    
    // The GTP provides little endian data (first byte received on RXDATA[7:0])     
    assign  RXDATA1_OUT    =   rxdata1_i;

    // The GTP transmits little endian data (TXDATA[7:0] transmitted first)     
    assign  txdata1_i    =   TXDATA1_IN;






    
    //------------------------ GTPA1_DUAL Instantiations  -------------------------   

    GTPA1_DUAL # 
    (
        //_______________________ Simulation-Only Attributes __________________

    
        .SIM_TX_ELEC_IDLE_LEVEL         ("Z"),
        .SIM_RECEIVER_DETECT_PASS       ("TRUE"),
        .SIM_VERSION                    ("2.0"),
 
        .SIM_REFCLK0_SOURCE             (3'b000),
        .SIM_REFCLK1_SOURCE             (3'b000),
 
        .SIM_GTPRESET_SPEEDUP           (TILE_SIM_GTPRESET_SPEEDUP),
        .CLK25_DIVIDER_0                (TILE_CLK25_DIVIDER_0),
        .CLK25_DIVIDER_1                (TILE_CLK25_DIVIDER_1),
        .PLL_DIVSEL_FB_0                (TILE_PLL_DIVSEL_FB_0), 
        .PLL_DIVSEL_FB_1                (TILE_PLL_DIVSEL_FB_1),  
        .PLL_DIVSEL_REF_0               (TILE_PLL_DIVSEL_REF_0), 
        .PLL_DIVSEL_REF_1               (TILE_PLL_DIVSEL_REF_1),
 
         
        

       //PLL Attributes
        .CLKINDC_B_0                            ("TRUE"),
        .CLKRCV_TRST_0                          ("TRUE"),
        .OOB_CLK_DIVIDER_0                      (6),
        .PLL_COM_CFG_0                          (24'h21680a),
        .PLL_CP_CFG_0                           (8'h00),
        .PLL_RXDIVSEL_OUT_0                     (1),
        .PLL_SATA_0                             ("FALSE"),
        .PLL_SOURCE_0                           (TILE_PLL_SOURCE_0),
        .PLL_TXDIVSEL_OUT_0                     (1),
        .PLLLKDET_CFG_0                         (3'b111),

       //
        .CLKINDC_B_1                            ("TRUE"),
        .CLKRCV_TRST_1                          ("TRUE"),
        .OOB_CLK_DIVIDER_1                      (6),
        .PLL_COM_CFG_1                          (24'h21680a),
        .PLL_CP_CFG_1                           (8'h00),
        .PLL_RXDIVSEL_OUT_1                     (1),
        .PLL_SATA_1                             ("FALSE"),
        .PLL_SOURCE_1                           (TILE_PLL_SOURCE_1),
        .PLL_TXDIVSEL_OUT_1                     (1),
        .PLLLKDET_CFG_1                         (3'b111),
        .PMA_COM_CFG_EAST                       (36'h000008000),
        .PMA_COM_CFG_WEST                       (36'h00000a000),
        .TST_ATTR_0                             (32'h00000000),
        .TST_ATTR_1                             (32'h00000000),

       //TX Interface Attributes
        .CLK_OUT_GTP_SEL_0                      ("TXOUTCLK0"),
        .TX_TDCC_CFG_0                          (2'b11),
        .CLK_OUT_GTP_SEL_1                      ("TXOUTCLK1"),
        .TX_TDCC_CFG_1                          (2'b11),

       //TX Buffer and Phase Alignment Attributes
        .PMA_TX_CFG_0                           (20'h80082),
        .TX_BUFFER_USE_0                        (C_BYPASS_TXBUF ? "FALSE" : "TRUE"),
        .TX_XCLK_SEL_0                          (C_BYPASS_TXBUF ? "TXUSR" : "TXOUT"),
        .TXRX_INVERT_0                          (C_BYPASS_TXBUF ? 3'b111  : 3'b011),
        .PMA_TX_CFG_1                           (20'h80082),
        .TX_BUFFER_USE_1                        (C_BYPASS_TXBUF ? "FALSE" : "TRUE"),
        .TX_XCLK_SEL_1                          (C_BYPASS_TXBUF ? "TXUSR" : "TXOUT"),
        .TXRX_INVERT_1                          (C_BYPASS_TXBUF ? 3'b111  : 3'b011),

       //TX Driver and OOB signalling Attributes
        .CM_TRIM_0                              (2'b00),
        .TX_IDLE_DELAY_0                        (3'b011),
        .CM_TRIM_1                              (2'b00),
        .TX_IDLE_DELAY_1                        (3'b011),

       //TX PIPE/SATA Attributes
        .COM_BURST_VAL_0                        (4'b1111),
        .COM_BURST_VAL_1                        (4'b1111),

       //RX Driver,OOB signalling,Coupling and Eq,CDR Attributes
        .AC_CAP_DIS_0                           ("FALSE"),
        .OOBDETECT_THRESHOLD_0                  (3'b110),
        .PMA_CDR_SCAN_0                         (27'h6404040),
        .PMA_RX_CFG_0                           (25'h05ce089),
        .PMA_RXSYNC_CFG_0                       (7'h00),
        .RCV_TERM_GND_0                         ("FALSE"),
        .RCV_TERM_VTTRX_0                       ("FALSE"),
        .RXEQ_CFG_0                             (8'b01111011),
        .TERMINATION_CTRL_0                     (5'b10100),
        .TERMINATION_OVRD_0                     ("FALSE"),
        .TX_DETECT_RX_CFG_0                     (14'h1832),
        .AC_CAP_DIS_1                           ("FALSE"),
        .OOBDETECT_THRESHOLD_1                  (3'b110),
        .PMA_CDR_SCAN_1                         (27'h6404040),
        .PMA_RX_CFG_1                           (25'h05ce089),
        .PMA_RXSYNC_CFG_1                       (7'h00),
        .RCV_TERM_GND_1                         ("FALSE"),
        .RCV_TERM_VTTRX_1                       ("FALSE"),
        .RXEQ_CFG_1                             (8'b01111011),
        .TERMINATION_CTRL_1                     (5'b10100),
        .TERMINATION_OVRD_1                     ("FALSE"),
        .TX_DETECT_RX_CFG_1                     (14'h1832),

       //PRBS Detection Attributes
        .RXPRBSERR_LOOPBACK_0                   (1'b0),
        .RXPRBSERR_LOOPBACK_1                   (1'b0),

       //Comma Detection and Alignment Attributes
        .ALIGN_COMMA_WORD_0                     (2),
        .COMMA_10B_ENABLE_0                     (10'b1111111111),
        .DEC_MCOMMA_DETECT_0                    ("TRUE"),
        .DEC_PCOMMA_DETECT_0                    ("TRUE"),
        .DEC_VALID_COMMA_ONLY_0                 ("FALSE"),
        .MCOMMA_10B_VALUE_0                     (10'b1010000011),
        .MCOMMA_DETECT_0                        ("TRUE"),
        .PCOMMA_10B_VALUE_0                     (10'b0101111100),
        .PCOMMA_DETECT_0                        ("TRUE"),
        .RX_SLIDE_MODE_0                        ("PCS"),
        .ALIGN_COMMA_WORD_1                     (2),
        .COMMA_10B_ENABLE_1                     (10'b1111111111),
        .DEC_MCOMMA_DETECT_1                    ("TRUE"),
        .DEC_PCOMMA_DETECT_1                    ("TRUE"),
        .DEC_VALID_COMMA_ONLY_1                 ("FALSE"),
        .MCOMMA_10B_VALUE_1                     (10'b1010000011),
        .MCOMMA_DETECT_1                        ("TRUE"),
        .PCOMMA_10B_VALUE_1                     (10'b0101111100),
        .PCOMMA_DETECT_1                        ("TRUE"),
        .RX_SLIDE_MODE_1                        ("PCS"),

       //RX Loss-of-sync State Machine Attributes
        .RX_LOS_INVALID_INCR_0                  (8),
        .RX_LOS_THRESHOLD_0                     (128),
        .RX_LOSS_OF_SYNC_FSM_0                  ("FALSE"),
        .RX_LOS_INVALID_INCR_1                  (8),
        .RX_LOS_THRESHOLD_1                     (128),
        .RX_LOSS_OF_SYNC_FSM_1                  ("FALSE"),

       //RX Elastic Buffer and Phase alignment Attributes
        .RX_BUFFER_USE_0                        ("TRUE"),
        .RX_EN_IDLE_RESET_BUF_0                 ("TRUE"),
        .RX_IDLE_HI_CNT_0                       (4'b1000),
        .RX_IDLE_LO_CNT_0                       (4'b0000),
        .RX_XCLK_SEL_0                          ("RXREC"),
        .RX_BUFFER_USE_1                        ("TRUE"),
        .RX_EN_IDLE_RESET_BUF_1                 ("TRUE"),
        .RX_IDLE_HI_CNT_1                       (4'b1000),
        .RX_IDLE_LO_CNT_1                       (4'b0000),
        .RX_XCLK_SEL_1                          ("RXREC"),

       //Clock Correction Attributes
        .CLK_COR_ADJ_LEN_0                      (4),
        .CLK_COR_DET_LEN_0                      (4),
        .CLK_COR_INSERT_IDLE_FLAG_0             ("FALSE"),
        .CLK_COR_KEEP_IDLE_0                    ("FALSE"),
        .CLK_COR_MAX_LAT_0                      (18),
        .CLK_COR_MIN_LAT_0                      (16),
        .CLK_COR_PRECEDENCE_0                   ("TRUE"),
        .CLK_COR_REPEAT_WAIT_0                  (0),
        .CLK_COR_SEQ_1_1_0                      (10'b0110111100),
        .CLK_COR_SEQ_1_2_0                      (10'b0001001010),
        .CLK_COR_SEQ_1_3_0                      (10'b0001001010),
        .CLK_COR_SEQ_1_4_0                      (10'b0001111011),
        .CLK_COR_SEQ_1_ENABLE_0                 (4'b1111),
        .CLK_COR_SEQ_2_1_0                      (10'b0100000000),
        .CLK_COR_SEQ_2_2_0                      (10'b0000000000),
        .CLK_COR_SEQ_2_3_0                      (10'b0000000000),
        .CLK_COR_SEQ_2_4_0                      (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_0                 (4'b0000),
        .CLK_COR_SEQ_2_USE_0                    ("FALSE"),
        .CLK_CORRECT_USE_0                      ("TRUE"),
        .RX_DECODE_SEQ_MATCH_0                  ("TRUE"),
        .CLK_COR_ADJ_LEN_1                      (4),
        .CLK_COR_DET_LEN_1                      (4),
        .CLK_COR_INSERT_IDLE_FLAG_1             ("FALSE"),
        .CLK_COR_KEEP_IDLE_1                    ("FALSE"),
        .CLK_COR_MAX_LAT_1                      (18),
        .CLK_COR_MIN_LAT_1                      (16),
        .CLK_COR_PRECEDENCE_1                   ("TRUE"),
        .CLK_COR_REPEAT_WAIT_1                  (0),
        .CLK_COR_SEQ_1_1_1                      (10'b0110111100),
        .CLK_COR_SEQ_1_2_1                      (10'b0001001010),
        .CLK_COR_SEQ_1_3_1                      (10'b0001001010),
        .CLK_COR_SEQ_1_4_1                      (10'b0001111011),
        .CLK_COR_SEQ_1_ENABLE_1                 (4'b1111),
        .CLK_COR_SEQ_2_1_1                      (10'b0100000000),
        .CLK_COR_SEQ_2_2_1                      (10'b0000000000),
        .CLK_COR_SEQ_2_3_1                      (10'b0000000000),
        .CLK_COR_SEQ_2_4_1                      (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_1                 (4'b0000),
        .CLK_COR_SEQ_2_USE_1                    ("FALSE"),
        .CLK_CORRECT_USE_1                      ("TRUE"),
        .RX_DECODE_SEQ_MATCH_1                  ("TRUE"),

       //Channel Bonding Attributes
        .CHAN_BOND_1_MAX_SKEW_0                 (1),
        .CHAN_BOND_2_MAX_SKEW_0                 (1),
        .CHAN_BOND_KEEP_ALIGN_0                 ("FALSE"),
        .CHAN_BOND_SEQ_1_1_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_2_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_0               (4'b0000),
        .CHAN_BOND_SEQ_2_1_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_0                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_0               (4'b0000),
        .CHAN_BOND_SEQ_2_USE_0                  ("FALSE"),
        .CHAN_BOND_SEQ_LEN_0                    (1),
        .RX_EN_MODE_RESET_BUF_0                 ("TRUE"),
        .CHAN_BOND_1_MAX_SKEW_1                 (1),
        .CHAN_BOND_2_MAX_SKEW_1                 (1),
        .CHAN_BOND_KEEP_ALIGN_1                 ("FALSE"),
        .CHAN_BOND_SEQ_1_1_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_2_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_1               (4'b0000),
        .CHAN_BOND_SEQ_2_1_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_1                    (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_1               (4'b0000),
        .CHAN_BOND_SEQ_2_USE_1                  ("FALSE"),
        .CHAN_BOND_SEQ_LEN_1                    (1),
        .RX_EN_MODE_RESET_BUF_1                 ("TRUE"),

       //RX PCI Express Attributes
        .CB2_INH_CC_PERIOD_0                    (8),
        .CDR_PH_ADJ_TIME_0                      (5'b01010),
        .PCI_EXPRESS_MODE_0                     ("FALSE"),
        .RX_EN_IDLE_HOLD_CDR_0                  ("FALSE"),
        .RX_EN_IDLE_RESET_FR_0                  ("TRUE"),
        .RX_EN_IDLE_RESET_PH_0                  ("TRUE"),
        .RX_STATUS_FMT_0                        ("SATA"),
        .TRANS_TIME_FROM_P2_0                   (12'h03c),
        .TRANS_TIME_NON_P2_0                    (8'h19),
        .TRANS_TIME_TO_P2_0                     (10'h064),
        .CB2_INH_CC_PERIOD_1                    (8),
        .CDR_PH_ADJ_TIME_1                      (5'b01010),
        .PCI_EXPRESS_MODE_1                     ("FALSE"),
        .RX_EN_IDLE_HOLD_CDR_1                  ("FALSE"),
        .RX_EN_IDLE_RESET_FR_1                  ("TRUE"),
        .RX_EN_IDLE_RESET_PH_1                  ("TRUE"),
        .RX_STATUS_FMT_1                        ("SATA"),
        .TRANS_TIME_FROM_P2_1                   (12'h03c),
        .TRANS_TIME_NON_P2_1                    (8'h19),
        .TRANS_TIME_TO_P2_1                     (10'h064),

       //RX SATA Attributes
        .SATA_BURST_VAL_0                       (3'b100),
        .SATA_IDLE_VAL_0                        (3'b100),
        .SATA_MAX_BURST_0                       (7),
        .SATA_MAX_INIT_0                        (22),
        .SATA_MAX_WAKE_0                        (7),
        .SATA_MIN_BURST_0                       (4),
        .SATA_MIN_INIT_0                        (12),
        .SATA_MIN_WAKE_0                        (4),
        .SATA_BURST_VAL_1                       (3'b100),
        .SATA_IDLE_VAL_1                        (3'b100),
        .SATA_MAX_BURST_1                       (7),
        .SATA_MAX_INIT_1                        (22),
        .SATA_MAX_WAKE_1                        (7),
        .SATA_MIN_BURST_1                       (4),
        .SATA_MIN_INIT_1                        (12),
        .SATA_MIN_WAKE_1                        (4)


     ) 
     gtpa1_dual_i 
     (



        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK0                      (LOOPBACK0_IN),
        .LOOPBACK1                      (LOOPBACK1_IN),
        .RXPOWERDOWN0                   (tied_to_ground_vec_i[1:0]),
        .RXPOWERDOWN1                   (tied_to_ground_vec_i[1:0]),
        .TXPOWERDOWN0                   (tied_to_ground_vec_i[1:0]),
        .TXPOWERDOWN1                   (tied_to_ground_vec_i[1:0]),
        //------------------------------- PLL Ports --------------------------------
        .CLK00                          (CLK00_IN),
        .CLK01                          (CLK01_IN),
        .CLK10                          (tied_to_ground_i),
        .CLK11                          (tied_to_ground_i),
        .CLKINEAST0                     (tied_to_ground_i),
        .CLKINEAST1                     (tied_to_ground_i),
        .CLKINWEST0                     (tied_to_ground_i),
        .CLKINWEST1                     (tied_to_ground_i),
        .GCLK00                         (tied_to_ground_i),
        .GCLK01                         (tied_to_ground_i),
        .GCLK10                         (tied_to_ground_i),
        .GCLK11                         (tied_to_ground_i),
        .GTPRESET0                      (GTPRESET0_IN),
        .GTPRESET1                      (GTPRESET1_IN),
        .GTPTEST0                       (8'b00010000),
        .GTPTEST1                       (8'b00010000),
        .INTDATAWIDTH0                  (tied_to_vcc_i),
        .INTDATAWIDTH1                  (tied_to_vcc_i),
        .PLLCLK00                       (tied_to_ground_i),
        .PLLCLK01                       (tied_to_ground_i),
        .PLLCLK10                       (tied_to_ground_i),
        .PLLCLK11                       (tied_to_ground_i),
        .PLLLKDET0                      (PLLLKDET0_OUT),
        .PLLLKDET1                      (PLLLKDET1_OUT),
        .PLLLKDETEN0                    (tied_to_vcc_i),
        .PLLLKDETEN1                    (tied_to_vcc_i),
        .PLLPOWERDOWN0                  (tied_to_ground_i),
        .PLLPOWERDOWN1                  (tied_to_ground_i),
        .REFCLKOUT0                     (),
        .REFCLKOUT1                     (),
        .REFCLKPLL0                     (),
        .REFCLKPLL1                     (),
        .REFCLKPWRDNB0                  (tied_to_vcc_i),
        .REFCLKPWRDNB1                  (tied_to_vcc_i),
        .REFSELDYPLL0                   (tied_to_ground_vec_i[2:0]),
        .REFSELDYPLL1                   (tied_to_ground_vec_i[2:0]),
        .RESETDONE0                     (RESETDONE0_OUT),
        .RESETDONE1                     (RESETDONE1_OUT),
        .TSTCLK0                        (tied_to_ground_i),
        .TSTCLK1                        (tied_to_ground_i),
        .TSTIN0                         (tied_to_ground_vec_i[11:0]),
        .TSTIN1                         (tied_to_ground_vec_i[11:0]),
        .TSTOUT0                        (),
        .TSTOUT1                        (),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISCOMMA0                 (RXCHARISCOMMA0_OUT),
        .RXCHARISCOMMA1                 (RXCHARISCOMMA1_OUT),
        .RXCHARISK0                     (RXCHARISK0_OUT),
        .RXCHARISK1                     (RXCHARISK1_OUT),
        .RXDEC8B10BUSE0                 (tied_to_vcc_i),
        .RXDEC8B10BUSE1                 (tied_to_vcc_i),
        .RXDISPERR0                     (RXDISPERR0_OUT),
        .RXDISPERR1                     (RXDISPERR1_OUT),
        .RXNOTINTABLE0                  (RXNOTINTABLE0_OUT),
        .RXNOTINTABLE1                  (RXNOTINTABLE1_OUT),
        .RXRUNDISP0                     (RXRUNDISP0_OUT),
        .RXRUNDISP1                     (RXRUNDISP1_OUT),
        .USRCODEERR0                    (tied_to_ground_i),
        .USRCODEERR1                    (tied_to_ground_i),
        //-------------------- Receive Ports - Channel Bonding ---------------------
        .RXCHANBONDSEQ0                 (),
        .RXCHANBONDSEQ1                 (),
        .RXCHANISALIGNED0               (),
        .RXCHANISALIGNED1               (),
        .RXCHANREALIGN0                 (),
        .RXCHANREALIGN1                 (),
        .RXCHBONDI                      (tied_to_ground_vec_i[2:0]),
        .RXCHBONDMASTER0                (tied_to_ground_i),
        .RXCHBONDMASTER1                (tied_to_ground_i),
        .RXCHBONDO                      (),
        .RXCHBONDSLAVE0                 (tied_to_ground_i),
        .RXCHBONDSLAVE1                 (tied_to_ground_i),
        .RXENCHANSYNC0                  (tied_to_ground_i),
        .RXENCHANSYNC1                  (tied_to_ground_i),
        //-------------------- Receive Ports - Clock Correction --------------------
        .RXCLKCORCNT0                   (),
        .RXCLKCORCNT1                   (),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED0               (RXBYTEISALIGNED0_OUT),
        .RXBYTEISALIGNED1               (RXBYTEISALIGNED1_OUT),
        .RXBYTEREALIGN0                 (),
        .RXBYTEREALIGN1                 (),
        .RXCOMMADET0                    (),
        .RXCOMMADET1                    (),
        .RXCOMMADETUSE0                 (tied_to_vcc_i),
        .RXCOMMADETUSE1                 (tied_to_vcc_i),
        .RXENMCOMMAALIGN0               (RXENMCOMMAALIGN0_IN),
        .RXENMCOMMAALIGN1               (RXENMCOMMAALIGN1_IN),
        .RXENPCOMMAALIGN0               (RXENPCOMMAALIGN0_IN),
        .RXENPCOMMAALIGN1               (RXENPCOMMAALIGN1_IN),
        .RXSLIDE0                       (tied_to_ground_i),
        .RXSLIDE1                       (tied_to_ground_i),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .PRBSCNTRESET0                  (tied_to_ground_i),
        .PRBSCNTRESET1                  (tied_to_ground_i),
        .RXENPRBSTST0                   (tied_to_ground_vec_i[2:0]),
        .RXENPRBSTST1                   (tied_to_ground_vec_i[2:0]),
        .RXPRBSERR0                     (),
        .RXPRBSERR1                     (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA0                        (rxdata0_i),
        .RXDATA1                        (rxdata1_i),
        .RXDATAWIDTH0                   (2'b10),
        .RXDATAWIDTH1                   (2'b10),
        .RXRECCLK0                      (RXRECCLK0_OUT),
        .RXRECCLK1                      (RXRECCLK1_OUT),
        .RXRESET0                       (RXRESET0_IN),
        .RXRESET1                       (RXRESET1_IN),
        .RXUSRCLK0                      (RXUSRCLK0_IN),
        .RXUSRCLK1                      (RXUSRCLK1_IN),
        .RXUSRCLK20                     (RXUSRCLK20_IN),
        .RXUSRCLK21                     (RXUSRCLK21_IN),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GATERXELECIDLE0                (GATERXELECIDLE0_IN),
        .GATERXELECIDLE1                (GATERXELECIDLE1_IN),
        .IGNORESIGDET0                  (IGNORESIGDET0_IN),
        .IGNORESIGDET1                  (IGNORESIGDET1_IN),
        .RCALINEAST                     (tied_to_ground_vec_i[4:0]),
        .RCALINWEST                     (tied_to_ground_vec_i[4:0]),
        .RCALOUTEAST                    (),
        .RCALOUTWEST                    (),
        .RXCDRRESET0                    (tied_to_ground_i),
        .RXCDRRESET1                    (tied_to_ground_i),
        .RXELECIDLE0                    (RXELECIDLE0_OUT),
        .RXELECIDLE1                    (RXELECIDLE1_OUT),
        .RXEQMIX0                       (RXEQMIX0_IN),
        .RXEQMIX1                       (RXEQMIX1_IN),
        .RXN0                           (RXN0_IN),
        .RXN1                           (RXN1_IN),
        .RXP0                           (RXP0_IN),
        .RXP1                           (RXP1_IN),
        //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
        .RXBUFRESET0                    (tied_to_ground_i),
        .RXBUFRESET1                    (tied_to_ground_i),
        .RXBUFSTATUS0                   (),
        .RXBUFSTATUS1                   (),
        .RXENPMAPHASEALIGN0             (tied_to_ground_i),
        .RXENPMAPHASEALIGN1             (tied_to_ground_i),
        .RXPMASETPHASE0                 (tied_to_ground_i),
        .RXPMASETPHASE1                 (tied_to_ground_i),
        .RXSTATUS0                      (RXSTATUS0_OUT),
        .RXSTATUS1                      (RXSTATUS1_OUT),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .RXLOSSOFSYNC0                  (),
        .RXLOSSOFSYNC1                  (),
        //------------ Receive Ports - RX Pipe Control for PCI Express -------------
        .PHYSTATUS0                     (),
        .PHYSTATUS1                     (),
        .RXVALID0                       (),
        .RXVALID1                       (),
        //------------------ Receive Ports - RX Polarity Control -------------------
        .RXPOLARITY0                    (tied_to_ground_i),
        .RXPOLARITY1                    (tied_to_ground_i),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (DADDR_IN),
        .DCLK                           (DCLK_IN),
        .DEN                            (DEN_IN),
        .DI                             (DI_IN),
        .DRDY                           (DRDY_OUT),
        .DRPDO                          (DRPDO_OUT),
        .DWE                            (DWE_IN),
        //-------------------------- TX/RX Datapath Ports --------------------------
        .GTPCLKFBEAST                   (GTPCLKFBEAST_OUT),
        .GTPCLKFBSEL0EAST               (2'b10),
        .GTPCLKFBSEL0WEST               (2'b00),
        .GTPCLKFBSEL1EAST               (2'b11),
        .GTPCLKFBSEL1WEST               (2'b01),
        .GTPCLKFBWEST                   (GTPCLKFBWEST_OUT),
        .GTPCLKOUT0                     (GTPCLKOUT0_OUT),
        .GTPCLKOUT1                     (GTPCLKOUT1_OUT),
        //----------------- Transmit Ports - 8b10b Encoder Control -----------------
        .TXBYPASS8B10B0                 (TXBYPASS8B10B0_IN),
        .TXBYPASS8B10B1                 (TXBYPASS8B10B1_IN),
        .TXCHARDISPMODE0                (TXCHARDISPMODE0_IN),
        .TXCHARDISPMODE1                (TXCHARDISPMODE1_IN),
        .TXCHARDISPVAL0                 (TXCHARDISPVAL0_IN),
        .TXCHARDISPVAL1                 (TXCHARDISPVAL1_IN),
        .TXCHARISK0                     (TXCHARISK0_IN),
        .TXCHARISK1                     (TXCHARISK1_IN),
        .TXENC8B10BUSE0                 (tied_to_vcc_i),
        .TXENC8B10BUSE1                 (tied_to_vcc_i),
        .TXKERR0                        (TXKERR0_OUT),
        .TXKERR1                        (TXKERR1_OUT),
        .TXRUNDISP0                     (TXRUNDISP0_OUT),
        .TXRUNDISP1                     (TXRUNDISP1_OUT),
        //------------- Transmit Ports - TX Buffer and Phase Alignment -------------
        .TXBUFSTATUS0                   (),
        .TXBUFSTATUS1                   (),
        .TXENPMAPHASEALIGN0             (TXENPMAPHASEALIGN0_IN),
        .TXENPMAPHASEALIGN1             (TXENPMAPHASEALIGN1_IN),
        .TXPMASETPHASE0                 (TXPMASETPHASE0_IN),
        .TXPMASETPHASE1                 (TXPMASETPHASE1_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA0                        (txdata0_i),
        .TXDATA1                        (txdata1_i),
        .TXDATAWIDTH0                   (2'b10),
        .TXDATAWIDTH1                   (2'b10),
        .TXOUTCLK0                      (TXOUTCLK0_OUT),
        .TXOUTCLK1                      (TXOUTCLK1_OUT),
        .TXRESET0                       (TXRESET0_IN),
        .TXRESET1                       (TXRESET1_IN),
        .TXUSRCLK0                      (TXUSRCLK0_IN),
        .TXUSRCLK1                      (TXUSRCLK1_IN),
        .TXUSRCLK20                     (TXUSRCLK20_IN),
        .TXUSRCLK21                     (TXUSRCLK21_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXBUFDIFFCTRL0                 (3'b101),
        .TXBUFDIFFCTRL1                 (3'b101),
        .TXDIFFCTRL0                    (TXDIFFCTRL0_IN),
        .TXDIFFCTRL1                    (TXDIFFCTRL1_IN),
        .TXINHIBIT0                     (tied_to_ground_i),
        .TXINHIBIT1                     (tied_to_ground_i),
        .TXN0                           (TXN0_OUT),
        .TXN1                           (TXN1_OUT),
        .TXP0                           (TXP0_OUT),
        .TXP1                           (TXP1_OUT),
        .TXPREEMPHASIS0                 (TXPREEMPHASIS0_IN),
        .TXPREEMPHASIS1                 (TXPREEMPHASIS1_IN),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXENPRBSTST0                   (tied_to_ground_vec_i[2:0]),
        .TXENPRBSTST1                   (tied_to_ground_vec_i[2:0]),
        .TXPRBSFORCEERR0                (tied_to_ground_i),
        .TXPRBSFORCEERR1                (tied_to_ground_i),
        //------------------ Transmit Ports - TX Polarity Control ------------------
        .TXPOLARITY0                    (tied_to_ground_i),
        .TXPOLARITY1                    (tied_to_ground_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXDETECTRX0                    (tied_to_ground_i),
        .TXDETECTRX1                    (tied_to_ground_i),
        .TXELECIDLE0                    (TXELECIDLE0_IN),
        .TXELECIDLE1                    (TXELECIDLE1_IN),
        .TXPDOWNASYNCH0                 (tied_to_ground_i),
        .TXPDOWNASYNCH1                 (tied_to_ground_i),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .TXCOMSTART0                    (TXCOMSTART0_IN),
        .TXCOMSTART1                    (TXCOMSTART1_IN),
        .TXCOMTYPE0                     (TXCOMTYPE0_IN),
        .TXCOMTYPE1                     (TXCOMTYPE1_IN)

     );
     
endmodule

