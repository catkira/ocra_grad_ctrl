//-----------------------------------------------------------------------------
// Title         : ocra_grad_ctrl
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : ocra_grad_ctrl.v
// Author        :   <vlad@arch-ssd>
// Created       : 31.08.2020
// Last modified : 31.08.2020
//-----------------------------------------------------------------------------
// Description :
// Top-level core file
//
// -----------------------------------------------------------------------------
// See LICENSE for GPL licensing information
// ------------------------------------------------------------------------------
// Modification history : 31.08.2020 : created
// -----------------------------------------------------------------------------

`ifndef _OCRA_GRAD_CTRL_
 `define _OCRA_GRAD_CTRL_

 `include "grad_bram.v"
 `include "ocra_grad_ctrl_S_AXI_INTR.v"
 `include "ocra1_iface.v"
 `include "gpa_fhdo_iface.v"

 `timescale 1ns / 1ns

module ocra_grad_ctrl #
  (
   // Users to add parameters here
   parameter test_param = 0
   // User parameters ends
   )
   (
    // Users to add ports here
    input [13:0] 			      grad_bram_offset_i,
    input 				      grad_bram_enb_i, // enable core execution

    // Outputs to the OCRA1 board (concatenation on the expansion header etc will be handled in Vivado's block diagram)
    output 				      oc1_clk_o, // SPI clock
    output 				      oc1_syncn_o, // sync (roughly equivalent to SPI CS)
    output 				      oc1_ldacn_o, // ldac
    output 				      oc1_sdox_o, // data out, X DAC
    output 				      oc1_sdoy_o, // data out, Y DAC
    output 				      oc1_sdoz_o, // data out, Z DAC
    output 				      oc1_sdoz2_o, // data out, Z2 DAC

    // I/O to the GPA-FHDO board
    output 				      fhd_clk_o, // SPI clock
    output 				      fhd_sdo_o, // data out
    output 				      fhd_ssn_o, // SPI CS
    input 				      fhd_sdi_i, // data in
   
    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S00_AXI
    input 				      s00_axi_aclk,
    input 				      s00_axi_aresetn,
    input [C_S00_AXI_ADDR_WIDTH-1 : 0] 	      s00_axi_awaddr,
    input [2 : 0] 			      s00_axi_awprot,
    input 				      s00_axi_awvalid,
    output 				      s00_axi_awready,
    input [C_S00_AXI_DATA_WIDTH-1 : 0] 	      s00_axi_wdata,
    input [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]    s00_axi_wstrb,
    input 				      s00_axi_wvalid,
    output 				      s00_axi_wready,
    output [1 : 0] 			      s00_axi_bresp,
    output 				      s00_axi_bvalid,
    input 				      s00_axi_bready,
    input [C_S00_AXI_ADDR_WIDTH-1 : 0] 	      s00_axi_araddr,
    input [2 : 0] 			      s00_axi_arprot,
    input 				      s00_axi_arvalid,
    output 				      s00_axi_arready,
    output [C_S00_AXI_DATA_WIDTH-1 : 0]       s00_axi_rdata,
    output [1 : 0] 			      s00_axi_rresp,
    output 				      s00_axi_rvalid,
    input 				      s00_axi_rready,

    // Ports of Axi Slave Bus Interface S_AXI_INTR
    input 				      s_axi_intr_aclk,
    input 				      s_axi_intr_aresetn,
    input [C_S_AXI_INTR_ADDR_WIDTH-1 : 0]     s_axi_intr_awaddr,
    input [2 : 0] 			      s_axi_intr_awprot,
    input 				      s_axi_intr_awvalid,
    output 				      s_axi_intr_awready,
    input [C_S_AXI_INTR_DATA_WIDTH-1 : 0]     s_axi_intr_wdata,
    input [(C_S_AXI_INTR_DATA_WIDTH/8)-1 : 0] s_axi_intr_wstrb,
    input 				      s_axi_intr_wvalid,
    output 				      s_axi_intr_wready,
    output [1 : 0] 			      s_axi_intr_bresp,
    output 				      s_axi_intr_bvalid,
    input 				      s_axi_intr_bready,
    input [C_S_AXI_INTR_ADDR_WIDTH-1 : 0]     s_axi_intr_araddr,
    input [2 : 0] 			      s_axi_intr_arprot,
    input 				      s_axi_intr_arvalid,
    output 				      s_axi_intr_arready,
    output [C_S_AXI_INTR_DATA_WIDTH-1 : 0]    s_axi_intr_rdata,
    output [1 : 0] 			      s_axi_intr_rresp,
    output 				      s_axi_intr_rvalid,
    input 				      s_axi_intr_rready,
    output 				      irq
    );

   // VN: I've made all these localparams, since they're seldom going to be modified by us
   // Parameters of Axi Slave Bus Interface S00_AXI
   localparam integer 			      C_S00_AXI_DATA_WIDTH = 32;
   localparam integer 			      C_S00_AXI_ADDR_WIDTH = 16;

   // Localparams of Axi Slave Bus Interface S_AXI_INTR
   localparam integer 			      C_S_AXI_INTR_DATA_WIDTH = 32;
   localparam integer 			      C_S_AXI_INTR_ADDR_WIDTH = 5;
   localparam integer 			      C_NUM_OF_INTR = 1;
   localparam C_INTR_SENSITIVITY = 32'hffffffff;
   localparam C_INTR_ACTIVE_STATE = 32'hffffffff;
   localparam integer 			      C_IRQ_SENSITIVITY = 1;
   localparam integer 			      C_IRQ_ACTIVE_STATE = 1;

   // Interface connections
   wire [31:0] 				      data;
   wire [3:0]				      data_valid;
   wire 				      oc1_data_valid = data_valid[0], gpa_fhdo_data_valid = data_valid[1];
   wire [5:0] 				      spi_clk_div;
   wire 				      clk = s00_axi_aclk; // alias
   wire [15:0] 				      fhd_adc; // ADC data from GPA-FHDO

   // for the ocra1, data can be written even while it's outputting to
   // SPI - for the fhd, this isn't the case. So don't use the
   // oc1_busy line in grad_bram, since it would mean that false
   // errors would get flagged - just fhd_busy for now.
   wire 				      fhd_busy;
   wire 				      oc1_busy, oc1_data_lost;
   
   // Instantiation of Axi Bus Interface S00_AXI
   grad_bram # ( 
		 .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		 .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
		 )
   grad_bram_inst (
		   .S_AXI_ACLK(s00_axi_aclk),
		   .S_AXI_ARESETN(s00_axi_aresetn),
		   .S_AXI_AWADDR(s00_axi_awaddr),
		   .S_AXI_AWPROT(s00_axi_awprot),
		   .S_AXI_AWVALID(s00_axi_awvalid),
		   .S_AXI_AWREADY(s00_axi_awready),
		   .S_AXI_WDATA(s00_axi_wdata),
		   .S_AXI_WSTRB(s00_axi_wstrb),
		   .S_AXI_WVALID(s00_axi_wvalid),
		   .S_AXI_WREADY(s00_axi_wready),
		   .S_AXI_BRESP(s00_axi_bresp),
		   .S_AXI_BVALID(s00_axi_bvalid),
		   .S_AXI_BREADY(s00_axi_bready),
		   .S_AXI_ARADDR(s00_axi_araddr),
		   .S_AXI_ARPROT(s00_axi_arprot),
		   .S_AXI_ARVALID(s00_axi_arvalid),
		   .S_AXI_ARREADY(s00_axi_arready),
		   .S_AXI_RDATA(s00_axi_rdata),
		   .S_AXI_RRESP(s00_axi_rresp),
		   .S_AXI_RVALID(s00_axi_rvalid),
		   .S_AXI_RREADY(s00_axi_rready),

		   .offset_i({2'd0, grad_bram_offset_i}),
		   .data_enb_i(grad_bram_enb_i),
		   .serial_busy_i(fhd_busy),
		   .adc_i(fhd_adc),
		   .data_lost_i(oc1_data_lost),
		   .data_o(data),
		   .valid_o(data_valid),
		   .spi_clk_div_o(spi_clk_div)
		   );

   // TODO: continue writing interfaces and mapping
   ocra1_iface ocra1_if (
			 // Outputs
			 .oc1_clk_o	(oc1_clk_o),
			 .oc1_syncn_o	(oc1_syncn_o),
			 .oc1_ldacn_o	(oc1_ldacn_o),
			 .oc1_sdox_o	(oc1_sdox_o),
			 .oc1_sdoy_o	(oc1_sdoy_o),
			 .oc1_sdoz_o	(oc1_sdoz_o),
			 .oc1_sdoz2_o	(oc1_sdoz2_o),
			 .busy_o       	(oc1_busy),
			 .data_lost_o   (oc1_data_lost),
			 // Inputs
			 .clk		(clk),
			 .rst_n         (grad_bram_enb_i), // purely for clearing data_lost for initial word
			 .data_i       	(data),
			 .valid_i      	(oc1_data_valid),
			 .spi_clk_div_i	(spi_clk_div));
   
   gpa_fhdo_iface gpa_fhdo_if (
			       // Outputs
			       .fhd_clk_o	(fhd_clk_o),
			       .fhd_sdo_o	(fhd_sdo_o),
			       .fhd_csn_o	(fhd_ssn_o),
			       .busy_o		(fhd_busy),
			       .adc_value_o	(fhd_adc),
			       // Inputs
			       .clk		(clk),
			       .data_i		(data),
			       .spi_clk_div_i	(spi_clk_div),
			       .valid_i		(gpa_fhdo_data_valid),
			       .fhd_sdi_i	(fhd_sdi_i));

   // Instantiation of Axi Bus Interface S_AXI_INTR
   ocra_grad_ctrl_S_AXI_INTR # ( 
				 .C_S_AXI_DATA_WIDTH(C_S_AXI_INTR_DATA_WIDTH),
				 .C_S_AXI_ADDR_WIDTH(C_S_AXI_INTR_ADDR_WIDTH),
				 .C_NUM_OF_INTR(C_NUM_OF_INTR),
				 .C_INTR_SENSITIVITY(C_INTR_SENSITIVITY),
				 .C_INTR_ACTIVE_STATE(C_INTR_ACTIVE_STATE),
				 .C_IRQ_SENSITIVITY(C_IRQ_SENSITIVITY),
				 .C_IRQ_ACTIVE_STATE(C_IRQ_ACTIVE_STATE)
				 ) 
   ocra_grad_ctrl_S_AXI_INTR_inst (
				   .S_AXI_ACLK(s_axi_intr_aclk),
				   .S_AXI_ARESETN(s_axi_intr_aresetn),
				   .S_AXI_AWADDR(s_axi_intr_awaddr),
				   .S_AXI_AWPROT(s_axi_intr_awprot),
				   .S_AXI_AWVALID(s_axi_intr_awvalid),
				   .S_AXI_AWREADY(s_axi_intr_awready),
				   .S_AXI_WDATA(s_axi_intr_wdata),
				   .S_AXI_WSTRB(s_axi_intr_wstrb),
				   .S_AXI_WVALID(s_axi_intr_wvalid),
				   .S_AXI_WREADY(s_axi_intr_wready),
				   .S_AXI_BRESP(s_axi_intr_bresp),
				   .S_AXI_BVALID(s_axi_intr_bvalid),
				   .S_AXI_BREADY(s_axi_intr_bready),
				   .S_AXI_ARADDR(s_axi_intr_araddr),
				   .S_AXI_ARPROT(s_axi_intr_arprot),
				   .S_AXI_ARVALID(s_axi_intr_arvalid),
				   .S_AXI_ARREADY(s_axi_intr_arready),
				   .S_AXI_RDATA(s_axi_intr_rdata),
				   .S_AXI_RRESP(s_axi_intr_rresp),
				   .S_AXI_RVALID(s_axi_intr_rvalid),
				   .S_AXI_RREADY(s_axi_intr_rready),
				   .irq(irq)
				   );

endmodule
`endif //  `ifndef _OCRA_GRAD_CTRL_
