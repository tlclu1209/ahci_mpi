//-----------------------------------------------------------------------------
//-- (c) Copyright 2006 - 2009 Xilinx, Inc. All rights reserved.
//--
//-- This file contains confidential and proprietary information
//-- of Xilinx, Inc. and is protected under U.S. and
//-- international copyright and other intellectual property
//-- laws.
//--
//-- DISCLAIMER
//-- This disclaimer is not a license and does not grant any
//-- rights to the materials distributed herewith. Except as
//-- otherwise provided in a valid license issued to you by
//-- Xilinx, and to the maximum extent permitted by applicable
//-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//-- (2) Xilinx shall not be liable (whether in contract or tort,
//-- including negligence, or under any other theory of
//-- liability) for any loss or damage of any kind or nature
//-- related to, arising under or in connection with these
//-- materials, including for any direct, or any indirect,
//-- special, incidental, or consequential loss or damage
//-- (including loss of data, profits, goodwill, or any type of
//-- loss or damage suffered as a result of any action brought
//-- by a third party) even if such damage or loss was
//-- reasonably foreseeable or Xilinx had been advised of the
//-- possibility of the same.
//--
//-- CRITICAL APPLICATIONS
//-- Xilinx products are not designed or intended to be fail-
//-- safe, or for use in any application requiring fail-safe
//-- performance, such as life-support or safety devices or
//-- systems, Class III medical devices, nuclear facilities,
//-- applications related to the deployment of airbags, or any
//-- other applications that could lead to death, personal
//-- injury, or severe property or environmental damage
//-- (individually and collectively, "Critical
//-- Applications"). Customer assumes the sole risk and
//-- liability of any use of Xilinx products in Critical
//-- Applications, subject only to applicable laws and
//-- regulations governing limitations on product liability.
//--
//-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//-- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
// MPMC V5 MIG PHY DDR1 Initialization
//-------------------------------------------------------------------------
//
// Description:
//   This module is the intialization control logic of the memory interface. 
//   All commands are issued from here acoording to the burst, CAS Latency and 
//   the user commands.
//
// Structure:
//     
//--------------------------------------------------------------------------
//
// History:
//   Oct 02 2007:
//     Corrected asignment of cal_in_progress to be 2 cycles later.
//
//--------------------------------------------------------------------------

`timescale 1ns/1ps

(* rom_style = "distributed" *)
module v5_phy_init_ddr1 #
  (
   parameter DQ_WIDTH      = 72,
   parameter DQS_WIDTH     = 9,
   parameter BANK_WIDTH    = 2,
   parameter CKE_WIDTH     = 1,
   parameter COL_WIDTH     = 11,
   parameter CS_NUM        = 1,
   parameter ODT_WIDTH     = 0,
   parameter ROW_WIDTH     = 14,
   parameter ADDITIVE_LAT  = 0,
   parameter BURST_LEN     = 4,
   parameter BURST_TYPE    = 0,
   parameter CAS_LAT       = 2,
   parameter ODT_TYPE      = 0,
   parameter REDUCE_DRV    = 0,   
   parameter REG_ENABLE    = 0,
   parameter ECC_ENABLE    = 0,
   parameter DDR2_ENABLE   = 0,
   parameter DQS_GATE_EN   = 1,
   parameter SIM_ONLY      = 0
   )
  (
   input                                   clk0,
   input                                   rst0,
   input [3:0]                             calib_done,
   input                                   ctrl_ref_flag,
   input                                   calib_ref_req, 
   output reg [3:0]                        calib_start,
   output reg                              calib_ref_done,  
   output reg                              phy_init_wren,
   output reg                              phy_init_rden,
   output                                  phy_init_wdf_wren,
   output [63:0]                           phy_init_wdf_data,
   output [ROW_WIDTH-1:0]                  phy_init_addr,
   output [BANK_WIDTH-1:0]                 phy_init_ba,
   output                                  phy_init_ras_n,
   output                                  phy_init_cas_n,
   output                                  phy_init_we_n,
   output [CS_NUM-1:0]                     phy_init_cs_n,
   output [CKE_WIDTH-1:0]                  phy_init_cke,
   output reg                              phy_init_done
   );

  // time to wait between consecutive commands in PHY_INIT - this is a
  // generic number, and must be large enough to account for worst case
  // timing parameter (tRFC - refresh-to-active) across all memory speed
  // grades and operating frequencies. Expressed in CLK clock cycles. 
  localparam  CNTNEXT_CMD = 6'b101011;
  // time to wait between read and read or precharge for stage 3 & 4
  // the larger CNTNEXT_CMD can also be used, use smaller number to
  // speed up calibration - avoid tRAS violation, and speeds up simulation
  localparam  CNTNEXT_RD  = 5'b11110;

  localparam  INIT_IDLE                = 5'h00;
  localparam  INIT_CNT_200             = 5'h01;
  localparam  INIT_CNT_200_WAIT        = 5'h02;
  localparam  INIT_PRECHARGE           = 5'h03;
  localparam  INIT_PRECHARGE_WAIT      = 5'h04;
  localparam  INIT_LOAD_MODE           = 5'h05;
  localparam  INIT_MODE_REGISTER_WAIT  = 5'h06;
  localparam  INIT_AUTO_REFRESH        = 5'h07;
  localparam  INIT_AUTO_REFRESH_WAIT   = 5'h08;
  localparam  INIT_DEEP_MEMORY_ST      = 5'h09;
  localparam  INIT_DUMMY_ACTIVE        = 5'h0A;
  localparam  INIT_DUMMY_ACTIVE_WAIT   = 5'h0B;
  localparam  INIT_CAL1_WRITE          = 5'h0C;
  localparam  INIT_CAL1_WRITE_READ     = 5'h0D;
  localparam  INIT_CAL1_READ           = 5'h0E;
  localparam  INIT_CAL1_READ_WAIT      = 5'h0F;
  localparam  INIT_CAL2_WRITE          = 5'h10;
  localparam  INIT_CAL2_WRITE_READ     = 5'h11;
  localparam  INIT_CAL2_READ           = 5'h12;
  localparam  INIT_CAL2_READ_WAIT      = 5'h13;  
  localparam  INIT_CAL3_WRITE          = 5'h14;
  localparam  INIT_CAL3_WRITE_READ     = 5'h15;  
  localparam  INIT_CAL3_READ           = 5'h16;
  localparam  INIT_CAL3_READ_WAIT      = 5'h17;
  localparam  INIT_CAL4_READ           = 5'h18;
  localparam  INIT_CAL4_READ_WAIT      = 5'h19;
  localparam  INIT_CALIB_REF           = 5'h1A;

  localparam  INIT_CNTR_INIT            = 4'h0;
  localparam  INIT_CNTR_PRECH_1         = 4'h1;
  localparam  INIT_CNTR_EMR2_INIT       = 4'h2;
  localparam  INIT_CNTR_EMR3_INIT       = 4'h3;
  localparam  INIT_CNTR_EMR_EN_DLL      = 4'h4;
  localparam  INIT_CNTR_MR_RST_DLL      = 4'h5;
  localparam  INIT_CNTR_CNT_200_WAIT    = 4'h6;
  localparam  INIT_CNTR_PRECH_2         = 4'h7;
  localparam  INIT_CNTR_AR_1            = 4'h8;
  localparam  INIT_CNTR_AR_2            = 4'h9;
  localparam  INIT_CNTR_MR_ACT_DLL      = 4'hA;
  localparam  INIT_CNTR_EMR_DEF_OCD     = 4'hB;
  localparam  INIT_CNTR_EMR_EXIT_OCD    = 4'hC;
  localparam  INIT_CNTR_DEEP_MEM        = 4'hD;
  localparam  INIT_CNTR_PRECH_3         = 4'hE;
  localparam  INIT_CNTR_DONE            = 4'hF;

  reg [1:0]             burst_addr_r;
  reg [1:0]             burst_cnt_r;
  wire [1:0]            burst_val;
  wire                  cal_read;
  wire                  cal_write_i;
  wire                  cal_write;
  wire                  cal_write_read;
  reg [15:0]            calib_start_shift0_r;             
  reg                   cal1_started_r;
  reg                   cal2_started_r;
  reg                   cal4_started_r;  
  reg                   calib_ref_req_posedge;
  reg                   calib_ref_req_r;
  reg [15:0]            calib_start_shift1_r;             
  reg [15:0]            calib_start_shift2_r;                          
  reg [15:0]            calib_start_shift3_r;                          
  reg [1:0]             chip_cnt_r;
  reg [4:0]             cke_200us_cnt_r;
  reg [7:0]             cnt_200_cycle_r;
  reg                   cnt_200_cycle_done_r;
  reg [5:0]             cnt_cmd_r;
  reg [4:0]             cnt_rd_r;
  reg                   done_200us_r;
  reg [ROW_WIDTH-1:0]   ddr_addr_r;
  reg [ROW_WIDTH-1:0]   ddr_addr_r1;
  reg [ROW_WIDTH-1:0]   ddr_addr_r1a;
  reg [BANK_WIDTH-1:0]  ddr_ba_r;
  reg [BANK_WIDTH-1:0]  ddr_ba_r1;
  reg [BANK_WIDTH-1:0]  ddr_ba_r1a;
  reg                   ddr_cas_n_r;
  reg                   ddr_cas_n_r1;
  reg                   ddr_cas_n_r1a;
  reg [CKE_WIDTH-1:0]   ddr_cke_r;
  reg [CS_NUM-1:0]      ddr_cs_n_r;
  reg                   ddr_ras_n_r;
  reg                   ddr_ras_n_r1;
  reg                   ddr_ras_n_r1a;
  reg                   ddr_we_n_r;
  reg                   ddr_we_n_r1;
  reg                   ddr_we_n_r1a;
  wire [15:0]           ext_mode_reg;
  reg [3:0]             init_cnt_r  /* synthesis syn_maxfan = 1 */;
  reg [4:0]             init_next_state;
  reg [4:0]             init_state_r /* synthesis syn_maxfan = 3 */;
  reg [4:0]             init_state_r1;
  reg [4:0]             init_state_r2;
  wire [15:0]           load_mode_reg;
  reg                   refresh_req;
  wire [3:0]            start_cal;

  reg [3:0]             init_wdf_cnt_r;
  reg [63:0]            init_data_r;
  reg                   init_done_r;
  reg                   init_wr_done_r;
  reg                   init_wren_r;
  reg [3:0]             calib_done_r;
  wire                  cal_in_progress;
  
  //***************************************************************************

  //*****************************************************************
  // Mode Register (MR):
  //   [15:14] - unused          - 00
  //   [13]    - reserved        - 0
  //   [12]    - Power-down mode - 0 (normal)
  //   [11:9]  - write recovery  - same value as written to CAS LAT
  //   [8]     - DLL reset       - 0 or 1
  //   [7]     - Test Mode       - 0 (normal)
  //   [6:4]   - CAS latency     - CAS_LAT
  //   [3]     - Burst Type      - BURST_TYPE
  //   [2:0]   - Burst Length    - BURST_LEN
  //*****************************************************************

  generate
    if (DDR2_ENABLE) begin: gen_load_mode_reg_ddr2  
      assign load_mode_reg[2:0]   = (BURST_LEN == 8) ? 3'b011 : 
                                    ((BURST_LEN == 4) ? 3'b010 : 3'b111);
      assign load_mode_reg[3]     = BURST_TYPE;
      assign load_mode_reg[6:4]   = (CAS_LAT == 3) ? 3'b011 : 
                                    ((CAS_LAT == 4) ? 3'b100 :
                                     ((CAS_LAT == 5) ? 3'b101 : 3'b111));
      assign load_mode_reg[7]     = 1'b0;
      assign load_mode_reg[8]     = 1'b0;    // init value only (DLL not reset)
      assign load_mode_reg[11:9]  = load_mode_reg[6:4];
      assign load_mode_reg[15:12] = 4'b000;
    end else begin: gen_load_mode_reg_ddr1
      assign load_mode_reg[2:0]   = (BURST_LEN == 8) ? 3'b011 : 
                                    ((BURST_LEN == 4) ? 3'b010 : 
                                     ((BURST_LEN == 2) ? 3'b001 : 3'b111));
      assign load_mode_reg[3]     = BURST_TYPE;
      assign load_mode_reg[6:4]   = (CAS_LAT == 2) ? 3'b010 : 
                                    ((CAS_LAT == 3) ? 3'b011 :
                                     ((CAS_LAT == 25) ? 3'b110 : 3'b111));
      assign load_mode_reg[12:7]  = 6'b000000; // init value only 
      assign load_mode_reg[15:13]  = 3'b000;
    end
  endgenerate
  
  //*****************************************************************
  // Extended Mode Register (MR):
  //   [15:14] - unused          - 00
  //   [13]    - reserved        - 0
  //   [12]    - output enable   - 0 (enabled)
  //   [11]    - RDQS enable     - 0 (disabled)
  //   [10]    - DQS# enable     - 0 (enabled)
  //   [9:7]   - OCD Program     - 111 or 000 (first 111, then 000 during init)
  //   [6]     - RTT[1]          - RTT[1:0] = 0(no ODT), 1(75), 2(150), 3(50)
  //   [5:3]   - Additive CAS    - ADDITIVE_CAS
  //   [2]     - RTT[0]
  //   [1]     - Output drive    - REDUCE_DRV (= 0(full), = 1 (reduced)
  //   [0]     - DLL enable      - 0 (normal)
  //*****************************************************************

  generate
    if (DDR2_ENABLE) begin: gen_ext_mode_reg_ddr2  
      assign ext_mode_reg[0]     = 1'b0;
      assign ext_mode_reg[1]     = REDUCE_DRV;
      assign ext_mode_reg[2]     = ((ODT_TYPE == 1) || (ODT_TYPE == 3)) ? 
                                   1'b1 : 1'b0;
      assign ext_mode_reg[5:3]   = (ADDITIVE_LAT == 0) ? 3'b000 : 
                                   ((ADDITIVE_LAT == 1) ? 3'b001 :
                                    ((ADDITIVE_LAT == 2) ? 3'b010 : 
                                     ((ADDITIVE_LAT == 3) ? 3'b011 :
                                      ((ADDITIVE_LAT == 4) ? 3'b100 : 
                                      3'b111))));
      assign ext_mode_reg[6]     = ((ODT_TYPE == 2) || (ODT_TYPE == 3)) ? 
                                   1'b1 : 1'b0;
      assign ext_mode_reg[9:7]   = 3'b000;
      assign ext_mode_reg[15:10] = 6'b000000;
    end else begin: gen_ext_mode_reg_ddr1
      assign ext_mode_reg[0]     = 1'b0;
      assign ext_mode_reg[1]     = REDUCE_DRV;
      assign ext_mode_reg[12:2]  = 11'b00000000000;
      assign ext_mode_reg[15:13] = 3'b000;
    end
  endgenerate
  
  //***************************************************************************
  // Logic for calibration start, and for auto-refresh during cal request
  // CALIB_REF_REQ is used by calibration logic to request auto-refresh
  // durign calibration (used to avoid tRAS violation is certain calibration
  // stages take a long time). Once the auto-refresh is complete and cal can
  // be resumed, CALIB_REF_DONE is asserted by PHY_INIT. 
  //***************************************************************************

  // generate pulse for each of calibration start controls
  assign start_cal[0] = ((init_state_r1 == INIT_CAL1_READ) &&
                         (init_state_r2 != INIT_CAL1_READ));
  assign start_cal[1] = ((init_state_r1 == INIT_CAL2_READ) &&
                         (init_state_r2 != INIT_CAL2_READ));
  assign start_cal[2] = ((init_state_r1 == INIT_CAL3_READ) &&
                         (init_state_r2 == INIT_CAL3_WRITE_READ));
  assign start_cal[3] = ((init_state_r1 == INIT_CAL4_READ) &&
                         (init_state_r2 == INIT_DUMMY_ACTIVE_WAIT));

  // Generate positive-edge triggered, latched signal to force initialization
  // to pause calibration, and to issue auto-refresh. Clear flag as soon as 
  // refresh initiated
  always @(posedge clk0)
    if (rst0) begin
      calib_ref_req_r       <= 1'b0;
      calib_ref_req_posedge <= 1'b0;
      refresh_req           <= 1'b0;
    end else begin
      calib_ref_req_r       <= calib_ref_req;
      calib_ref_req_posedge <= calib_ref_req & ~calib_ref_req_r;
      if (init_state_r1 == INIT_AUTO_REFRESH)
        refresh_req <= 1'b0;
      else if (calib_ref_req_posedge)
        refresh_req <= 1'b1;
    end  
  // flag to tell cal1 calibration was started.
  // This flag is used for cal1 auto refreshes
  // some of these bits may not be needed - only needed for those stages that
  // need refreshes within the stage (i.e. very long stages)
  always @(posedge clk0)
    if (rst0) begin
      cal1_started_r <= 1'b0;
      cal2_started_r <= 1'b0;      
      cal4_started_r <= 1'b0;
    end else begin
      if (calib_start[0])
        cal1_started_r <= 1'b1;
      if (calib_start[1])
        cal2_started_r <= 1'b1;
      if (calib_start[3])
        cal4_started_r <= 1'b1;
    end
  
  // Delay start of each calibration by 16 clock cycles to
  // ensure that when calibration logic begins, that read data is already
  // appearing on the bus. Don't really need it, it's more for simulation
  // purposes. Each circuit should synthesize using an SRL16. 
  always @(posedge clk0) begin
    calib_start_shift0_r <= {calib_start_shift0_r[14:0], start_cal[0]};
    calib_start_shift1_r <= {calib_start_shift1_r[14:0], start_cal[1]};
    calib_start_shift2_r <= {calib_start_shift2_r[14:0], start_cal[2]};
    calib_start_shift3_r <= {calib_start_shift3_r[14:0], start_cal[3]};
    calib_start[0]       <= calib_start_shift0_r[15] & ~cal1_started_r;
    calib_start[1]       <= calib_start_shift1_r[15] & ~cal2_started_r;
    calib_start[2]       <= calib_start_shift2_r[15];
    calib_start[3]       <= calib_start_shift3_r[15] & ~cal4_started_r;
    calib_ref_done       <= calib_start_shift0_r[15] | 
                            calib_start_shift1_r[15] |
                            calib_start_shift3_r[15];
  end

  // generate delay for various states that require it (no maximum delay
  // requirement, make sure that terminal count is large enough to cover
  // all cases)
  always @(posedge clk0) begin
    case (init_state_r)
      INIT_PRECHARGE_WAIT, 
      INIT_MODE_REGISTER_WAIT, 
      INIT_AUTO_REFRESH_WAIT, 
      INIT_DUMMY_ACTIVE_WAIT, 
      INIT_CAL1_WRITE_READ,
      INIT_CAL1_READ_WAIT, 
      INIT_CAL2_WRITE_READ, 
      INIT_CAL2_READ_WAIT,
      INIT_CAL3_WRITE_READ:
        cnt_cmd_r <= cnt_cmd_r + 1;
      default:
        cnt_cmd_r <= 5'b00000;
    endcase
  end

  // smaller value for delay between consecutive reads for stage 3/4 cal
  always @(posedge clk0) begin
    case (init_state_r)
      INIT_CAL3_READ_WAIT,
      INIT_CAL4_READ_WAIT:
        cnt_rd_r <= cnt_rd_r + 1;
      default:
        cnt_rd_r <= 4'b0000;
    endcase
  end

  //***************************************************************************
  // Initial delay after power-on
  //***************************************************************************
    
  // 200us counter for cke
  always @(posedge clk0)
    if (rst0) begin
      // skip power-up count if only simulating
      if (SIM_ONLY)
        cke_200us_cnt_r <= 5'b00001;
      else 
        cke_200us_cnt_r <= 5'b11011;
    end else if (ctrl_ref_flag)
      cke_200us_cnt_r <= cke_200us_cnt_r - 1;

  // refresh detect in 266 MHz clock
  always @(posedge clk0)
    if (rst0)
      done_200us_r <= 1'b0;
    else if (!done_200us_r)
      done_200us_r <= (cke_200us_cnt_r == 5'b00000);

  // 200 clocks counter - count value : C8 required for initialization
  always @(posedge clk0)
    if (rst0 || (init_state_r == INIT_CNT_200))
      cnt_200_cycle_r <= 8'hC8;
    else if (cnt_200_cycle_r != 8'h00)
      cnt_200_cycle_r <= cnt_200_cycle_r - 1;

  always @(posedge clk0)
    if (rst0 || (init_state_r == INIT_CNT_200))
      cnt_200_cycle_done_r <= 1'b0;
    else if (cnt_200_cycle_r == 8'h00)
      cnt_200_cycle_done_r <= 1'b1;

  //*****************************************************************
  // handle deep memory configuration:
  //   During initialization: Repeat initialization sequence once for each
  //   chip select. Note that we could perform initalization for all chip
  //   selects simulataneously. Probably fine - any potential SI issues with
  //   auto refreshing all chip selects at once?
  //   Once initialization complete, assert only CS[0] for calibration. 
  //*****************************************************************

  always @(posedge clk0)
    if (rst0) begin
      chip_cnt_r <= 2'b00;
    end else if (init_state_r == INIT_DEEP_MEMORY_ST) begin
      if (chip_cnt_r != CS_NUM)
        chip_cnt_r <= chip_cnt_r + 1;
      else
        chip_cnt_r <= 2'b00;
    end      
      
  always @(posedge clk0)
    if (rst0)
      ddr_cs_n_r <= {CS_NUM{1'b1}};
    else begin
       if (cal_in_progress == 1'b1) begin
          ddr_cs_n_r <= {CS_NUM{1'b1}};
          ddr_cs_n_r[chip_cnt_r] <= 1'b0;
       end
       else begin
         ddr_cs_n_r <= {CS_NUM{1'b0}};
       end
    end
  
  //***************************************************************************
  // Write/read burst logic
  //***************************************************************************

  assign cal_in_progress = ((init_state_r2 == INIT_DUMMY_ACTIVE) ||
                            (init_state_r2 == INIT_DUMMY_ACTIVE_WAIT) ||
                            (init_state_r2 == INIT_CAL1_WRITE) ||
                            (init_state_r2 == INIT_CAL2_WRITE) ||
                            (init_state_r2 == INIT_CAL3_WRITE) ||
                            (init_state_r2 == INIT_CAL1_WRITE_READ) ||
                            (init_state_r2 == INIT_CAL2_WRITE_READ) ||
                            (init_state_r2 == INIT_CAL3_WRITE_READ) ||
                            (init_state_r2 == INIT_CAL1_READ) ||
                            (init_state_r2 == INIT_CAL2_READ) ||
                            (init_state_r2 == INIT_CAL3_READ) ||
                            (init_state_r2 == INIT_CAL4_READ) ||
                            (init_state_r2 == INIT_CAL1_READ_WAIT) ||
                            (init_state_r2 == INIT_CAL2_READ_WAIT) ||
                            (init_state_r2 == INIT_CAL3_READ_WAIT) ||
                            (init_state_r2 == INIT_CAL4_READ_WAIT));
  generate
     if (ECC_ENABLE == 0)
       begin : gen_cal_write_i_noecc
          assign cal_write_i = ((init_state_r == INIT_CAL1_WRITE) ||
                                (init_state_r == INIT_CAL2_WRITE) ||
                                (init_state_r == INIT_CAL3_WRITE));
       end
     else
       begin : gen_cal_write_i_ecc
          assign cal_write_i = ((init_next_state == INIT_CAL1_WRITE) ||
                                (init_next_state == INIT_CAL2_WRITE) ||
                                (init_next_state == INIT_CAL3_WRITE));
       end
  endgenerate
  assign cal_write = ((init_state_r == INIT_CAL1_WRITE) ||
                      (init_state_r == INIT_CAL2_WRITE) ||
                      (init_state_r == INIT_CAL3_WRITE));
  assign cal_read = ((init_state_r == INIT_CAL1_READ) ||
                     (init_state_r == INIT_CAL2_READ) ||
                     (init_state_r == INIT_CAL3_READ) ||
                     (init_state_r == INIT_CAL4_READ));
  assign cal_write_read = cal_write | cal_read;

  assign burst_val = (BURST_LEN == 4) ? 2'b01 :
                     (BURST_LEN == 8) ? 2'b11 : 2'b00;
  
  // keep track of current address - need this if burst length < 8 for
  // stage 2-4 calibration writes and reads. Make sure value always gets
  // initialized to 0 before we enter write/read state. This is used to
  // keep track of when another burst must be issued
  always @(posedge clk0)
    if (cal_write_read)
      burst_addr_r <= burst_addr_r + 1;
    else
      burst_addr_r <= 3'b000;

  // write/read burst count 
  always @(posedge clk0)
    if (cal_write_read)
      if (burst_cnt_r == 2'b00)
        burst_cnt_r <= burst_val;
      else
        burst_cnt_r <= burst_cnt_r - 1;
    else
      burst_cnt_r <= 2'b00;

  // indicate when a write is occurring
  always @(*)
    phy_init_wren      <= cal_write_i;
    
  // used for read enable calibration, pulse to indicate when read issued
  always @(posedge clk0)
    phy_init_rden <= cal_read;

  //***************************************************************************
  // State logic to write calibration training patterns to write data FIFO
  //***************************************************************************
  
  always @(posedge clk0) begin
    if (rst0) begin
      init_wdf_cnt_r  <= 4'd0;
      init_wren_r <= 1'b0;
      init_wr_done_r <= 1'b0;
      init_data_r <= {64{1'bx}};
    end else begin
      init_wdf_cnt_r  <= init_wdf_cnt_r + 1;
      init_wren_r <= 1'b1;
      case (init_wdf_cnt_r)
        // First stage calibration. Pattern (rise/fall) = 1(r)->0(f)
        // The rise data and fall data are already interleaved in the manner 
        // required for data into the WDF write FIFO 
        4'h0, 4'h1, 4'h2, 4'h3:
          init_data_r <= {4{{8{1'b0}},{8{1'b1}}}};
        // Second stage calibration. Pattern = 1(r)->1(f)->0(r)->0(f)
        4'h4: init_data_r <= {64{1'b1}};
        4'h5: init_data_r <= {64{1'b0}};
        4'h6: init_data_r <= {64{1'b1}};
        4'h7: init_data_r <= {64{1'b0}};
        // Third stage calibration. Pattern = FF->FF->AA->AA->55->55->00->00
        // Also make sure that last word is all zeros (because init_data_r is
        // OR'ed with app_wdf_data. 
        4'h8: init_data_r <= {64{1'b1}};
        4'h9: init_data_r <= {32{2'b10}};
        4'hA: init_data_r <= {32{2'b01}};
        // finished, stay in this state, and deassert WREN
        4'hB: begin
          init_data_r <= {64{1'b0}};
          init_wr_done_r <= 1'b1;
          init_wdf_cnt_r  <= init_wdf_cnt_r;
          if (init_wr_done_r) 
            init_wren_r <= 1'b0;
          else
            init_wren_r <= 1'b1;
        end
        default: begin
          init_data_r <= {(2*DQ_WIDTH){1'bx}};
          init_wren_r <= 1'bx;
          init_wr_done_r <= 1'bx;
          init_wdf_cnt_r  <= 4'bxxxx;
        end
      endcase
    end
  end

  //***************************************************************************
  
  //***************************************************************************
  // Initialization state machine
  //***************************************************************************

  // synthesis attribute max_fanout of init_cnt_r is 1
  always @(posedge clk0)
    // every time we need to initialize another rank of memory, need to
    // reset init count, and repeat the entire initialization (but not
    // calibration) sequence
    if (rst0 || (init_state_r == INIT_DEEP_MEMORY_ST))
      init_cnt_r <= INIT_CNTR_INIT;
    else if (!DDR2_ENABLE && (init_state_r == INIT_PRECHARGE) && 
             (init_cnt_r == INIT_CNTR_PRECH_1))
      // skip EMR(2) and EMR(3) register loads
      init_cnt_r <= INIT_CNTR_EMR_EN_DLL;
    else if (!DDR2_ENABLE && (init_state_r == INIT_LOAD_MODE) &&
             (init_cnt_r == INIT_CNTR_MR_ACT_DLL))
      // skip OCD calibration for DDR1
      init_cnt_r <= INIT_CNTR_DEEP_MEM;
    else if ((init_state_r == INIT_LOAD_MODE) || 
             ((init_state_r == INIT_PRECHARGE) 
              && (init_state_r1 != INIT_CALIB_REF))||
             ((init_state_r == INIT_AUTO_REFRESH) 
              && (~init_done_r))||
             (init_state_r == INIT_CNT_200)) 
      init_cnt_r <= init_cnt_r + 1;
  
  always @(posedge clk0)
    if ((init_state_r == INIT_IDLE) && (init_cnt_r == INIT_CNTR_DONE))
      phy_init_done <= 1'b1;
    else
      phy_init_done <= 1'b0;

  //synthesis translate_off
  always @(posedge calib_done[0])
    if ( calib_done[0])
      $display ("First Stage Calibration completed at time %t", $time);      

  always @(posedge calib_done[1])
    $display ("Second Stage Calibration completed at time %t", $time);

  always @(posedge calib_done[2]) 
    $display ("Third Stage Calibration completed at time %t", $time);

  always @(posedge calib_done[3]) begin
    $display ("Fourth Stage Calibration completed at time %t", $time);
    $display ("Calibration completed at time %t", $time);
  end
  //synthesis translate_on
  
  always @(posedge clk0) begin
    if (init_cnt_r >= INIT_CNTR_DEEP_MEM) begin
      init_done_r <= 1'b1;
    end else
      init_done_r <= 1'b0;
  end  

  //*****************************************************************

  //synthesis attribute max_fanout of init_state_r is 3                
  always @(posedge clk0)
    if (rst0) begin
      init_state_r  <= INIT_IDLE;
      init_state_r1 <= INIT_IDLE;
      init_state_r2 <= INIT_IDLE;
      calib_done_r  <= 4'b0000;
    end else begin
      init_state_r  <= init_next_state;
      init_state_r1 <= init_state_r;
      init_state_r2 <= init_state_r1;
      calib_done_r  <= calib_done; // register for timing
    end

  always @(*) begin     
    init_next_state = init_state_r;
    case (init_state_r)
      INIT_IDLE: begin
        if (done_200us_r) begin
          case (init_cnt_r) // synthesis parallel_case full_case
            INIT_CNTR_INIT: 
              init_next_state = INIT_CNT_200;
            INIT_CNTR_PRECH_1: 
              init_next_state = INIT_PRECHARGE;
            INIT_CNTR_EMR2_INIT: 
              init_next_state = INIT_LOAD_MODE; // EMR(2)
            INIT_CNTR_EMR3_INIT: 
              init_next_state = INIT_LOAD_MODE; // EMR(3);
            INIT_CNTR_EMR_EN_DLL: 
              init_next_state = INIT_LOAD_MODE; // EMR, enable DLL
            INIT_CNTR_MR_RST_DLL:
              init_next_state = INIT_LOAD_MODE; // MR, reset DLL
            INIT_CNTR_CNT_200_WAIT:
              init_next_state = INIT_CNT_200;   // Wait 200cc after reset DLL
            INIT_CNTR_PRECH_2:
              init_next_state = INIT_PRECHARGE;
            INIT_CNTR_AR_1: 
              init_next_state = INIT_AUTO_REFRESH;
            INIT_CNTR_AR_2: 
              init_next_state = INIT_AUTO_REFRESH;
            INIT_CNTR_MR_ACT_DLL: 
              init_next_state = INIT_LOAD_MODE; // MR, unreset DLL
            INIT_CNTR_EMR_DEF_OCD: 
              init_next_state = INIT_LOAD_MODE; // EMR, OCD default
            INIT_CNTR_EMR_EXIT_OCD: 
              init_next_state = INIT_LOAD_MODE; // EMR, enable OCD exit
            INIT_CNTR_DEEP_MEM: begin
              // Deep memory state/support disabled 
              //  if ((chip_cnt_r < CS_NUM-1)) 
              //  init_next_state = INIT_DEEP_MEMORY_ST;
              //else 
              if (cnt_200_cycle_done_r)
                init_next_state = INIT_DUMMY_ACTIVE; 
              else
                init_next_state = INIT_IDLE;
            end
            INIT_CNTR_PRECH_3: 
              init_next_state = INIT_PRECHARGE;
            INIT_CNTR_DONE:
              init_next_state = INIT_IDLE;        
            default : 
              init_next_state = INIT_IDLE;
          endcase
        end
      end
      INIT_CNT_200: 
        init_next_state = INIT_CNT_200_WAIT;
      INIT_CNT_200_WAIT: 
        if (cnt_200_cycle_done_r) 
          init_next_state = INIT_IDLE;
      INIT_PRECHARGE: 
        init_next_state = INIT_PRECHARGE_WAIT;
      INIT_PRECHARGE_WAIT: 
        if (cnt_cmd_r == CNTNEXT_CMD) begin
          // wait until all calibration stages are complete
          if (DQS_GATE_EN) begin
            if (init_done_r && (!(&calib_done_r[3:0])))
              init_next_state = INIT_AUTO_REFRESH;
            else
              init_next_state = INIT_IDLE;
          end else begin
            if (init_done_r && (!(&calib_done_r[2:0])))
              init_next_state = INIT_AUTO_REFRESH;
            else
              init_next_state = INIT_IDLE;
          end       
        end     
      INIT_LOAD_MODE: 
        init_next_state = INIT_MODE_REGISTER_WAIT;
      INIT_MODE_REGISTER_WAIT: 
        if (cnt_cmd_r == CNTNEXT_CMD) 
          init_next_state = INIT_IDLE;
      INIT_AUTO_REFRESH: 
        init_next_state = INIT_AUTO_REFRESH_WAIT;
      INIT_AUTO_REFRESH_WAIT: 
        if (cnt_cmd_r == CNTNEXT_CMD) begin
          if (init_done_r)
            init_next_state = INIT_DUMMY_ACTIVE;
          else
            init_next_state = INIT_IDLE;
        end             
      INIT_DEEP_MEMORY_ST: 
        init_next_state = INIT_IDLE;
      // single row activate. All subsequent calibration writes and read will 
      // take place in this row      
      INIT_DUMMY_ACTIVE: 
        init_next_state = INIT_DUMMY_ACTIVE_WAIT;
      INIT_DUMMY_ACTIVE_WAIT: 
        if (cnt_cmd_r == CNTNEXT_CMD) begin
          if (~calib_done_r[0]) begin
            // if returning to stg1 after refresh, don't need to write 
            if (cal1_started_r) 
              init_next_state = INIT_CAL1_READ;
            // if first entering stg1, need to write training pattern
            else
              init_next_state = INIT_CAL1_WRITE;
          end else if (~calib_done_r[1]) begin
            if (cal2_started_r) 
              init_next_state = INIT_CAL2_READ;
            else
              init_next_state = INIT_CAL2_WRITE;
          end else if (~calib_done_r[2])
             init_next_state = INIT_CAL3_WRITE;
          else
            init_next_state = INIT_CAL4_READ;
        end
      // Stage 1 calibration (write and continuous read)
      INIT_CAL1_WRITE:
        if (burst_addr_r == 2'b11)
          init_next_state = INIT_CAL1_WRITE_READ;
      INIT_CAL1_WRITE_READ: 
        if (cnt_cmd_r == CNTNEXT_CMD) 
          init_next_state = INIT_CAL1_READ;
      INIT_CAL1_READ:
        // Stage 1 requires inter-stage auto-refresh
        if (calib_done_r[0] || refresh_req)     
          init_next_state = INIT_CAL1_READ_WAIT;
      INIT_CAL1_READ_WAIT:
        if (cnt_cmd_r == CNTNEXT_CMD)
          init_next_state = INIT_CALIB_REF;     
      // Stage 2 calibration (write and continuous read)
      INIT_CAL2_WRITE:
        if (burst_addr_r == 2'b11)
          init_next_state = INIT_CAL2_WRITE_READ;
      INIT_CAL2_WRITE_READ: 
        if (cnt_cmd_r == CNTNEXT_CMD) 
          init_next_state = INIT_CAL2_READ;
      INIT_CAL2_READ: 
        // Stage 2 requires inter-stage auto-refresh
        if (calib_done_r[1] || refresh_req)
          init_next_state = INIT_CALIB_REF;
      INIT_CAL2_READ_WAIT:
        if (cnt_cmd_r == CNTNEXT_CMD)
          init_next_state = INIT_CALIB_REF; 
      // Stage 3 calibration (write and continuous read)      
      INIT_CAL3_WRITE:
        if (burst_addr_r == 2'b11)
          init_next_state = INIT_CAL3_WRITE_READ;
      INIT_CAL3_WRITE_READ: 
        if (cnt_cmd_r == CNTNEXT_CMD) 
          init_next_state = INIT_CAL3_READ;
      INIT_CAL3_READ: 
        if (burst_addr_r == 2'b11)
          init_next_state = INIT_CAL3_READ_WAIT;
      INIT_CAL3_READ_WAIT: begin
        if (cnt_rd_r == CNTNEXT_RD)
          if (calib_done_r[2]) begin
            if (DQS_GATE_EN)
              init_next_state = INIT_CALIB_REF;
            else
              init_next_state = INIT_PRECHARGE;   
          end else
            init_next_state = INIT_CAL3_READ;
      end
      // Stage 4 calibration (continuous read only, same pattern as stage 3)
      // only used if DQS_GATE supported
      INIT_CAL4_READ: 
        if (burst_addr_r == 2'b11)
          init_next_state = INIT_CAL4_READ_WAIT;
      INIT_CAL4_READ_WAIT: begin
        if (cnt_rd_r == CNTNEXT_RD)
          if (calib_done_r[3])
            init_next_state = INIT_PRECHARGE;
          // Stage 4 requires inter-stage auto-refresh
          else if (refresh_req)
            init_next_state = INIT_CALIB_REF;
          else
            init_next_state = INIT_CAL4_READ;
      end                 
      INIT_CALIB_REF: 
        init_next_state = INIT_PRECHARGE;  
    endcase
  end

  //***************************************************************************
  // Memory control/address
  //***************************************************************************
  
  generate
     if (ECC_ENABLE == 0)
       begin : gen_ddr_ctrl_noecc
          always @(posedge clk0)
            if ((init_state_r == INIT_DUMMY_ACTIVE) ||
                (init_state_r == INIT_PRECHARGE) ||
                (init_state_r == INIT_LOAD_MODE) ||
                (init_state_r == INIT_AUTO_REFRESH))
              ddr_ras_n_r <= 1'b0;
            else
              ddr_ras_n_r <= 1'b1;

          always @(posedge clk0)
            if ((init_state_r == INIT_LOAD_MODE) || 
                (init_state_r == INIT_AUTO_REFRESH) ||
                (cal_write_read && (burst_cnt_r == 2'b00)))
              ddr_cas_n_r <= 1'b0;
            else
              ddr_cas_n_r <= 1'b1;

          always @(posedge clk0)
            if ((init_state_r == INIT_LOAD_MODE) || 
                (init_state_r == INIT_PRECHARGE) ||
                (cal_write && (burst_cnt_r == 2'b00)))
              ddr_we_n_r <= 1'b0;
            else 
              ddr_we_n_r <= 1'b1;
       end
     else
       begin : gen_ddr_ctrl_ecc
          always @(posedge clk0)
            if ((init_state_r == INIT_DUMMY_ACTIVE) ||
                (init_state_r == INIT_PRECHARGE) ||
                (init_state_r == INIT_LOAD_MODE) ||
                (init_state_r == INIT_AUTO_REFRESH))
              ddr_ras_n_r <= 1'b0;
            else
              ddr_ras_n_r <= 1'b1;

          always @(posedge clk0)
            if ((init_state_r == INIT_LOAD_MODE) || 
                (init_state_r == INIT_AUTO_REFRESH) ||
                (cal_write_read && (burst_cnt_r == 2'b01)))
              ddr_cas_n_r <= 1'b0;
            else
              ddr_cas_n_r <= 1'b1;

          always @(posedge clk0)
            if ((init_state_r == INIT_LOAD_MODE) || 
                (init_state_r == INIT_PRECHARGE) ||
                (cal_write && (burst_cnt_r == 2'b01)))
              ddr_we_n_r <= 1'b0;
            else 
              ddr_we_n_r <= 1'b1;
       end
  endgenerate
  //*****************************************************************
  // memory address during init
  //*****************************************************************

  always @(posedge clk0) begin
    if (init_state_r == INIT_PRECHARGE) begin
      // Precharge all - set A10 = 1
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
      ddr_addr_r[10] <= 1'b1;             
    end else if (init_state_r == INIT_LOAD_MODE) begin
      ddr_ba_r <= {BANK_WIDTH{1'b0}};
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
      case (init_cnt_r)
        // EMR (2)
        INIT_CNTR_EMR2_INIT: begin
          ddr_ba_r[1:0] <= 2'b10;
          ddr_addr_r    <= {ROW_WIDTH{1'b0}};
        end
        // EMR (3)
        INIT_CNTR_EMR3_INIT: begin
          ddr_ba_r[1:0] <= 2'b11;
          ddr_addr_r    <= {ROW_WIDTH{1'b0}};
        end
        // EMR write - A0 = 0 for DLL enable
        INIT_CNTR_EMR_EN_DLL: begin
          ddr_ba_r[1:0] <= 2'b01;
          ddr_addr_r <= ext_mode_reg[ROW_WIDTH-1:0];
        end
        // MR write, reset DLL (A8=1)
        INIT_CNTR_MR_RST_DLL: begin
          ddr_ba_r[1:0] <= 2'b00;
          ddr_addr_r <= load_mode_reg[ROW_WIDTH-1:0];
          ddr_addr_r[8] <= 1'b1;
        end        
        // MR write, unreset DLL (A8=0)
        INIT_CNTR_MR_ACT_DLL: begin
          ddr_ba_r[1:0] <= 2'b00;
          ddr_addr_r <= load_mode_reg[ROW_WIDTH-1:0];
        end
        // EMR write, OCD default state
        INIT_CNTR_EMR_DEF_OCD: begin
          ddr_ba_r[1:0] <= 2'b01;
          ddr_addr_r <= ext_mode_reg[ROW_WIDTH-1:0];
          ddr_addr_r[9:7] <= 3'b111;
        end    
        // EMR write - OCD exit
        INIT_CNTR_EMR_EXIT_OCD: begin
          ddr_ba_r[1:0] <= 2'b01;
          ddr_addr_r <= ext_mode_reg[ROW_WIDTH-1:0];
        end
        default: begin
          ddr_ba_r <= {BANK_WIDTH{1'bx}};
          ddr_addr_r <= {ROW_WIDTH{1'bx}};
        end
      endcase
    end else if (cal_write_read) begin
      // when writing or reading for Stages 2-4, since training pattern is
      // either 4 (stage 2) or 8 (stage 3-4) long, if BURST LEN < 8, then
      // need to issue multiple bursts to read entire training pattern
      //ddr_addr_r[ROW_WIDTH-1:3] <= {ROW_WIDTH-3{1'b0}};
      //ddr_addr_r[2:0]           <= {burst_addr_r, 1'b0};
      //ddr_ba_r                  <= {BANK_WIDTH{1'b0}};
      // Calibrate top of memory
      ddr_addr_r[ROW_WIDTH-1:3] <= {ROW_WIDTH-3{1'b1}};
      ddr_addr_r[2:0]           <= {burst_addr_r, 1'b0};
      ddr_ba_r                  <= {BANK_WIDTH{1'b1}};
      ddr_addr_r[10] <= 1'b0;             
    end else if (init_state_r == INIT_DUMMY_ACTIVE) begin
      // all calibration writing read takes place in row 0x0 only
      //ddr_ba_r   <= {BANK_WIDTH{1'b0}};
      //ddr_addr_r <= {ROW_WIDTH{1'b0}};      
      // Calibrate top of memory
      ddr_ba_r   <= {BANK_WIDTH{1'b1}};
      ddr_addr_r <= {ROW_WIDTH{1'b1}};      
    end else begin
      // otherwise, cry me a river
      ddr_ba_r   <= {BANK_WIDTH{1'bx}};
      ddr_addr_r <= {ROW_WIDTH{1'bx}};
    end
  end
    
  // Keep CKE asserted after initial power-on delay
  always @(posedge clk0)
    ddr_cke_r <= {CKE_WIDTH{done_200us_r}};

  // register commands to memory. Two clock cycle delay from state -> output
   generate
      if (ECC_ENABLE == 0) begin : gen_ctrl_out
         reg cal_write_d1;
         always @(posedge clk0) begin
            cal_write_d1  <= cal_write;
            ddr_addr_r1a  <= ddr_addr_r;
            ddr_ba_r1a    <= ddr_ba_r;
            ddr_cas_n_r1a <= ddr_cas_n_r;
            ddr_ras_n_r1a <= ddr_ras_n_r;
            ddr_we_n_r1a  <= ddr_we_n_r;
            ddr_addr_r1   <= cal_write_d1 ? ddr_addr_r1a  : ddr_addr_r;
            ddr_ba_r1     <= cal_write_d1 ? ddr_ba_r1a    : ddr_ba_r;
            ddr_cas_n_r1  <= cal_write_d1 ? ddr_cas_n_r1a : ddr_cas_n_r;
            ddr_ras_n_r1  <= cal_write_d1 ? ddr_ras_n_r1a : ddr_ras_n_r;
            ddr_we_n_r1   <= cal_write_d1 ? ddr_we_n_r1a  : ddr_we_n_r;
         end
      end
      else begin : gen_ctrl_out_ecc
         reg cal_write_d1;
         reg cal_write_d2;
         always @(posedge clk0) begin
            cal_write_d1  <= cal_write;
            cal_write_d2  <= cal_write_d1;
            ddr_addr_r1a  <= ddr_addr_r;
            ddr_ba_r1a    <= ddr_ba_r;
            ddr_cas_n_r1a <= ddr_cas_n_r;
            ddr_ras_n_r1a <= ddr_ras_n_r;
            ddr_we_n_r1a  <= ddr_we_n_r;
            ddr_addr_r1   <= cal_write_d2 ? ddr_addr_r1a  : ddr_addr_r;
            ddr_ba_r1     <= cal_write_d2 ? ddr_ba_r1a    : ddr_ba_r;
            ddr_cas_n_r1  <= cal_write_d2 ? ddr_cas_n_r1a : ddr_cas_n_r;
            ddr_ras_n_r1  <= cal_write_d2 ? ddr_ras_n_r1a : ddr_ras_n_r;
            ddr_we_n_r1   <= cal_write_d2 ? ddr_we_n_r1a  : ddr_we_n_r;
         end
      end
   endgenerate

  assign phy_init_addr      = ddr_addr_r1;
  assign phy_init_ba        = ddr_ba_r1;
  assign phy_init_cas_n     = ddr_cas_n_r1;
  assign phy_init_cke       = ddr_cke_r;
  assign phy_init_cs_n      = ddr_cs_n_r;
  assign phy_init_ras_n     = ddr_ras_n_r1;
  assign phy_init_we_n      = ddr_we_n_r1;
  assign phy_init_wdf_wren  = init_wren_r;
  assign phy_init_wdf_data  = init_data_r;
 

endmodule
