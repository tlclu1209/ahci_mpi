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
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module places the data mask signals into the IOBs.
//Reference:
//Revision History:
//  Jul 18 2008: Merged MIG 2.3 modifications into this file.
//*****************************************************************************

`timescale 1ns/1ps

module v5_phy_dm_iob_ddr2
  (
   input  clk90,
   input  dm_ce,
   input  mask_data_rise,
   input  mask_data_fall,
   output ddr_dm
   );

  wire    dm_out;
  wire    dm_ce_r;

  FDRSE_1 u_dm_ce
    (
     .Q    (dm_ce_r),
     .C    (clk90),
     .CE   (1'b1),
     .D    (dm_ce),
     .R    (1'b0),
     .S    (1'b0)
     ) /* synthesis syn_preserve=1 */;

  ODDR #
    (
     .SRTYPE("SYNC"),
     .DDR_CLK_EDGE("SAME_EDGE")
     )
    u_oddr_dm
      (
       .Q  (dm_out),
       .C  (clk90),
       .CE (dm_ce_r),
       .D1 (mask_data_rise),
       .D2 (mask_data_fall),
       .R  (1'b0),
       .S  (1'b0)
       );

  OBUF u_obuf_dm
    (
     .I (dm_out),
     .O (ddr_dm)
     );

endmodule
