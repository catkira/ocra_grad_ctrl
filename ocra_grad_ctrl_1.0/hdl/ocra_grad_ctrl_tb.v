//-----------------------------------------------------------------------------
// Title         : ocra_grad_ctrl_tb
// Project       : OCRA
//-----------------------------------------------------------------------------
// File          : ocra_grad_ctrl_tb.v
// Author        :   <vlad@arch-ssd>
// Created       : 31.08.2020
// Last modified : 31.08.2020
//-----------------------------------------------------------------------------
// Description :
// Generic Verilog-2001 testbench for ocra_grad_ctrl
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 31.08.2020 : created
//-----------------------------------------------------------------------------

`ifndef _OCRA_GRAD_CTRL_TB_
 `define _OCRA_GRAD_CTRL_TB_

 `include "ocra_grad_ctrl.v"
 `include "ocra1_model.v"
 `include "gpa_fhdo_model.v"

 `timescale 1ns / 1ns

module ocra_grad_ctrl_tb;
   // Parameters copied from ocra_grad_ctrl for now (duplication of information, I know)
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
   
   reg clk, rst_n;
   wire s00_axi_aclk = clk, s_axi_intr_aclk = clk;
   wire s00_axi_aresetn = rst_n;
   reg 	err; // error flag in testbench

   wire [17:0] oc1_voutx, oc1_vouty, oc1_voutz, oc1_voutz2, fhd_sdi_i;
   
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			grad_bram_enb_i;	// To UUT of ocra_grad_ctrl.v
   reg [13:0]		grad_bram_offset_i;	// To UUT of ocra_grad_ctrl.v
   reg [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_araddr;// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s00_axi_arprot;		// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_arvalid;	// To UUT of ocra_grad_ctrl.v
   reg [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_awaddr;// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s00_axi_awprot;		// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_awvalid;	// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_bready;		// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_rready;		// To UUT of ocra_grad_ctrl.v
   reg [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_wdata;// To UUT of ocra_grad_ctrl.v
   reg [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb;// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_wvalid;		// To UUT of ocra_grad_ctrl.v
   reg [C_S_AXI_INTR_ADDR_WIDTH-1:0] s_axi_intr_araddr;// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_aresetn;	// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s_axi_intr_arprot;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_arvalid;	// To UUT of ocra_grad_ctrl.v
   reg [C_S_AXI_INTR_ADDR_WIDTH-1:0] s_axi_intr_awaddr;// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s_axi_intr_awprot;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_awvalid;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_bready;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_rready;	// To UUT of ocra_grad_ctrl.v
   reg [C_S_AXI_INTR_DATA_WIDTH-1:0] s_axi_intr_wdata;// To UUT of ocra_grad_ctrl.v
   reg [(C_S_AXI_INTR_DATA_WIDTH/8)-1:0] s_axi_intr_wstrb;// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_wvalid;	// To UUT of ocra_grad_ctrl.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			fhd_clk_o;		// From UUT of ocra_grad_ctrl.v
   wire			fhd_sdo_o;		// From UUT of ocra_grad_ctrl.v
   wire			fhd_ssn_o;		// From UUT of ocra_grad_ctrl.v
   wire			irq;			// From UUT of ocra_grad_ctrl.v
   wire			oc1_clk_o;		// From UUT of ocra_grad_ctrl.v
   wire			oc1_ldacn_o;		// From UUT of ocra_grad_ctrl.v
   wire			oc1_sdox_o;		// From UUT of ocra_grad_ctrl.v
   wire			oc1_sdoy_o;		// From UUT of ocra_grad_ctrl.v
   wire			oc1_sdoz2_o;		// From UUT of ocra_grad_ctrl.v
   wire			oc1_sdoz_o;		// From UUT of ocra_grad_ctrl.v
   wire			oc1_syncn_o;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_arready;	// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_awready;	// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s00_axi_bresp;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_bvalid;		// From UUT of ocra_grad_ctrl.v
   wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata;// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s00_axi_rresp;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_rvalid;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_wready;		// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_arready;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_awready;	// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s_axi_intr_bresp;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_bvalid;	// From UUT of ocra_grad_ctrl.v
   wire [C_S_AXI_INTR_DATA_WIDTH-1:0] s_axi_intr_rdata;// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s_axi_intr_rresp;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_rvalid;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_wready;	// From UUT of ocra_grad_ctrl.v
   // End of automatics

   // Clock generation: assuming 100 MHz for convenience (in real design it'll be 122.88, 125 or 144 MHz depending on what's chosen)
   always #5 clk = !clk;   

   reg [23:0] 		k;
   reg [2:0] 		extra_wait;
   reg [1:0] 		channel;
   reg 			broadcast;
   // Stimuli and read/write checks
   initial begin
      $dumpfile("icarus_compile/000_ocra_grad_ctrl_tb.lxt");
      $dumpvars(0, ocra_grad_ctrl_tb);

      // Initialise custom I/O
      clk = 1;
      rst_n = 0;
      grad_bram_offset_i = 0;
      grad_bram_enb_i = 0;

      // Initialise bus-related I/O
      s00_axi_araddr = 0;
      s00_axi_arprot = 0;
      s00_axi_arvalid = 0;
      s00_axi_awaddr = 0;
      s00_axi_awprot = 0;
      s00_axi_awvalid = 0;
      s00_axi_bready = 0;
      s00_axi_rready = 0;
      s00_axi_wdata = 0;
      s00_axi_wstrb = 0;
      s00_axi_wvalid = 0;
          
      // Zero all the interrupt-related I/O
      s_axi_intr_aresetn = 0;
      s_axi_intr_awaddr = 0;
      s_axi_intr_awprot = 0;
      s_axi_intr_awvalid = 0;
      s_axi_intr_wdata = 0;
      s_axi_intr_wstrb = 0;
      s_axi_intr_wvalid = 0;
      s_axi_intr_bready = 0;
      s_axi_intr_araddr = 0;
      s_axi_intr_arprot = 0;
      s_axi_intr_arvalid = 0;
      s_axi_intr_rready = 0;

      #107 rst_n = 1; // extra 7ns to ensure that TB stimuli occur a bit before the positive clock edges
      s00_axi_bready = 1; // TODO: make this more fine-grained if bus reads/writes don't work properly in hardware

      // Carry out similar tests to those in grad_bram_tb
      #10 wr32(16'd4, {26'd0, 6'd30}); // reg 1: LSBs set SPI clock divisor
      wr32(16'd8, 32'h00000001); // reg 2: enable ocra1, but disable gpa-fhdo for now
      wr32(16'd12, 32'h00abcdef); // reg 3
      wr32(16'd16, 32'h12345678); // reg 4 -- this write shouldn't do anything, since reg4 is read-only

      // register readback tests
      #10 rd32(16'd0, {22'd0, 10'd303});
      rd32(16'd4, {26'd0, 6'd30});
      rd32(16'd8, 32'h00000001);
      rd32(16'd12, 32'h00abcdef);
      rd32(16'd16, 32'd0);
      
      // Direct writes, DAC init words
      wr32(16'd12, {8'd0, 1'd0, 24'h200002});
      wr32(16'd12, {8'd1, 1'd0, 24'h200002});
      wr32(16'd12, {8'd2, 1'd0, 24'h200002});
      wr32(16'd12, {8'd3, 1'd1, 24'h200002});

      // Direct writes, DAC initial outputs
      #10000 wr32(16'd12, {8'd0, 1'd0, 4'h1, 18'd1234, 2'd0});
      wr32(16'd12, {8'd1, 1'd0, 4'h1, 18'd2345, 2'd0});
      wr32(16'd12, {8'd2, 1'd0, 4'h1, 18'd3456, 2'd0});
      wr32(16'd12, {8'd3, 1'd1, 4'h1, 18'd4567, 2'd0});

      // BRAM writes on all 4 channels, no extra waits, sustained
      // update interval of 4 * 3070 ns = 12280 ns (clock of 10ns
      // period; for 8ns period this ends up being 9824ns, i.e. 101.7
      // ksps
      for (k = 0; k < 100; k = k + 1) begin
	 channel = k[1:0];
	 broadcast = !( (k + 1) % 4); // broacast on k=3, k=7, k=11, etc
	 wr32_oc1(k, 0, channel, broadcast, k);
      end
      
      // always write first 4 words of new block with regular
      // commands, to avoid inadvertently carrying over values from
      // the previous block (since grad_bram_enb_i gets pulled low
      // after data has been transferred to the iface, but before it's
      // been serialised to the DACs)
      wr32_oc1(1000, 0, 0, 0, 1000);
      wr32_oc1(1001, 0, 1, 0, 1001);
      wr32_oc1(1002, 0, 2, 0, 1002);      
      wr32_oc1(1003, 1, 3, 1, 1003); // wait 1 extra unit before next data is sent

      // BRAM writes on only X and Z, each has an extra wait of 1 -
      // leading to a sustained update interval as above, but only for
      // 2 channels      
      for (k = 1004; k < 1100; k = k + 1) begin
	 channel = k[0] ? 2 : 0;
	 broadcast = channel == 2; // broadcast on Z updates
	 wr32_oc1(k, 1, channel, broadcast, k);
      end

      // BRAM writes on only Y and Z2, Y has no extra wait and Z2 has
      // an extra wait of 2 - leading to a sustained update interval
      // as above, but only for 2 channels (alternative timing)
      wr32_oc1(2000, 0, 0, 0, 2000);
      wr32_oc1(2001, 0, 1, 0, 2001);
      wr32_oc1(2002, 0, 2, 0, 2002);      
      wr32_oc1(2003, 2, 3, 1, 2003); // since this is a broadcast, wait 2
      for (k = 2004; k < 2100; k = k + 1) begin
	 channel = k[0] ? 3 : 1;
	 broadcast = channel == 3; // broadcast on Z2 updates
	 extra_wait = (channel == 3) ? 2 : 0;
	 wr32_oc1(k, extra_wait, channel, broadcast, k);
      end

      // BRAM writes on only Z, with extra waits of 3 each time
      wr32_oc1(3000, 0, 0, 0, 3000);
      wr32_oc1(3001, 0, 1, 0, 3001);
      wr32_oc1(3002, 0, 2, 0, 3002);      
      wr32_oc1(3003, 3, 3, 1, 3003); // since this is a broadcast, wait 2
      for (k = 3004; k < 3100; k = k + 1) begin
	 channel = 2; // always Z
	 broadcast = 1; // always broadcast
	 extra_wait = 3; // always wait
	 wr32_oc1(k, extra_wait, channel, broadcast, k);
      end

      // BRAM writes on only Z, with extra waits of 3 each time
      wr32_oc1(4000, 0, 0, 0, 4000);
      wr32_oc1(4001, 0, 1, 0, 4001);
      wr32_oc1(4002, 0, 2, 0, 4002);      
      wr32_oc1(4003, 0, 3, 1, 4003); // no extra wait, compared to previous inits
      for (k = 4004; k < 4100; k = k + 1) begin
	 // switch between a few different update modes in one block
	 if (k < 4020) begin
	    channel = k[1:0];
	    broadcast = channel == 3;
	    extra_wait = k == 4019 ? 3 : 0; // need an extra wait for the single-channel section
	 end else if (k < 4026) begin
	    channel = 0; // always x
	    broadcast = 1; // always broadcast
	    extra_wait = k == 4025 ? 1 : 3; // extra waits
	 end else if (k < 4034) begin
	    channel = k[0] ? 3 : 0; // x and z2
	    broadcast = k[0]; // broadcast on z2
	    extra_wait = k == 4033 ? 0 : 1;
	 end else begin
	    // back to 4-channel, but broadcast on a different channel
	    // (so that output results appear in a different order)
	    channel = k[1:0];
	    broadcast = channel == 1;
	    extra_wait = 0;
	 end
	 wr32_oc1(k, extra_wait, channel, broadcast, k);
      end // for (k = 4004; k < 4100; k = k + 1)

      // Extra test write to generate a data-loss error
      wr32_oc1(5000, 0, 0, 0, 5000);
      wr32_oc1(5001, 0, 1, 0, 5001);
      wr32_oc1(5002, 0, 2, 0, 5002);      
      wr32_oc1(5003, 0, 3, 1, 5003);
      wr32_oc1(5004, 0, 0, 0, 5004); // this data should get lost
      wr32_oc1(5005, 0, 1, 0, 5005);
      wr32_oc1(5006, 0, 2, 0, 5006);      
      wr32_oc1(5007, 0, 3, 1, 5007);
      wr32_oc1(5008, 0, 0, 0, 5008);

      // Start outputting data; address 0
      #100 grad_bram_enb_i = 1;

      // change output address: 2 channels updated in parallel
      #60000 grad_bram_enb_i = 0;
      grad_bram_offset_i = 1000;
      #10 grad_bram_enb_i = 1; // long enough pause to avoid it being busy

      // change output address: 2 channels updated in parallel, alternate timing
      #50000 grad_bram_enb_i = 0;
      grad_bram_offset_i = 2000;
      #10 grad_bram_enb_i = 1;

      // change output address, 1 channel updated
      #50000 grad_bram_enb_i = 0;
      grad_bram_offset_i = 3000;
      #10 grad_bram_enb_i = 1;
      
      // Change output rate to be faster (5us intervals, sped-up SPI clock)
      #50000 wr32(16'd4, {26'd0, 6'd19});
      wr32(16'd0, {22'd0, 10'd121});

      // Change output address, 4 channels updated again
      #50000 grad_bram_enb_i = 0;
      grad_bram_offset_i = 4000;
      #10 grad_bram_enb_i = 1;

      // Reset core, make sure it resumes correctly
      #50000 rst_n = 0;
      #10 rst_n = 1;

      // Test data lost error TODO: continue here -- data lost error
      // only occurs when grad_bram_enb_i is held low for too short a
      // time
      #67500 grad_bram_enb_i = 0;
      grad_bram_offset_i = 5000;
      #10 grad_bram_enb_i = 1;

      #10000 grad_bram_enb_i = 0;
      #100 rd32(16'd16, {14'd0, 2'b01, 16'h1388});
      #10 rd32(16'd16, {14'd0, 2'b00, 16'h1388});

      //// SWITCH TO GPA-FHDO
      #50000 
	
      // read ADC (without simulating it fully)
      #10 rd32(16'd20, {16'd0, 16'd0});      
      ////  TODO: properly test gpa_fhdo_iface -- below is a rough busy_error test to avoid causing them
      // wr32(16'd0, 10'd400);
      // wr32(16'd4, 6'd6);
      // #10 rd32(16'd16, {14'd0, 2'b00, 16'h1388});
      //#20000 grad_bram_enb_i = 1;

      #100000 if (err) begin
	 $display("THERE WERE ERRORS");
	 $stop; // to return a nonzero error code if the testbench is later scripted at a higher level
      end
      $finish;
   end // initial begin

   // DAC output checks at specific times
   integer n, p;
   initial begin
      check_ocra1(0, 0, 0, 0);
      #42845 check_ocra1(1234, 2345, 3456, 4567); // written directly
      #10 for (n = 0; n < 20; n = n + 4) begin
	 check_ocra1(n, n+1, n+2, n+3); #12280;
      end
      check_ocra1(1000, 1001, 1002, 1003); #12280;
      check_ocra1(1004, 1001, 1005, 1003); #12280;
      check_ocra1(1006, 1001, 1007, 1003); #12280;
      check_ocra1(1008, 1001, 1009, 1003);

      #14840 check_ocra1(1008, 1001, 1009, 1003);
      #10 check_ocra1(2000, 2001, 2002, 2003); #12280;
      check_ocra1(2000, 2004, 2002, 2005); #12280;
      check_ocra1(2000, 2006, 2002, 2007); #12280;
      check_ocra1(2000, 2008, 2002, 2009);

      #16230 check_ocra1(2000, 2008, 2002, 2009);
      #10 check_ocra1(3000, 3001, 3002, 3003); #12280;
      check_ocra1(3000, 3001, 3004, 3003); #12280;
      check_ocra1(3000, 3001, 3005, 3003); #7820;
      for (n = 3006; n < 3015; n = n + 1) begin
	 check_ocra1(3000, 3001, n, 3003); #5000;
      end
      check_ocra1(3000, 3001, 3015, 3003); #12200;

      // 4-channel updates
      for (n = 4000; n < 4020; n = n + 4) begin
	 check_ocra1(n, n+1, n+2, n+3); #5000;
      end

      // single-channel updates
      for (n = 4020; n < 4026; n = n + 1) begin
	 check_ocra1(n, 4017, 4018, 4019); #5000;
      end

      // update pairs at a time
      for (n = 4026; n < 4034; n = n + 2) begin
	 check_ocra1(n, 4017, 4018, n + 1); #5000;
      end
      
      // update out-of-order
      for (n = 4034; n < 4062; n = n + 4) begin
	 check_ocra1(n + 2, n + 3, n, n + 1); #5000;
      end
	 
      // // TODO: gpa-fhdo tests
      
   end // initial begin   

   // Tasks for AXI bus reads and writes, later interrupt control (if we choose to use it)
   task wr32; //write to bus
      input [31:0] addr, data;
      begin
         #10 s00_axi_wdata = data;
	 s00_axi_wstrb = 'hf;
         s00_axi_awaddr = addr;
         s00_axi_awvalid = 1;
         s00_axi_wvalid = 1;
         fork
            begin: wait_axi_write
               wait(s00_axi_awready && s00_axi_wready);
               disable axi_write_timeout;
            end
            begin: axi_write_timeout
               #10000 disable wait_axi_write;
	       $display("%d ns: AXI write timed out", $time);
            end
         join
         #13 s00_axi_awvalid = 0;
         s00_axi_wvalid = 0;
      end
   endtask // wr32

   task wr32_oc1; // convenience task for encoding ocra1 DAC words
      input [13:0] bram_offset;
      input [2:0]  extra_wait;
      input [1:0] channel;
      input 	  broadcast;
      input [17:0] dac_v;
      begin
	 // 2b spare, 3b extra wait, 2b channel, 1b broadcast, 24b DAC word (see ad5781 datasheet)
	 wr32(16'h8000 + (bram_offset << 2), {2'd0, extra_wait, channel, broadcast, 4'd1, dac_v, 2'd0});
      end
   endtask // wr32_oc1   

   task rd32; //read from bus
      input [31:0] addr;
      input [31:0] expected;
      begin
         #10 s00_axi_arvalid = 1;
         s00_axi_araddr = addr;
         wait(s00_axi_arready);
         #13 s00_axi_arvalid = 0;
         wait(s00_axi_rvalid);
         #13 if (expected !== s00_axi_rdata) begin
            $display("%d ns: Bus read error, address %x, expected output %x, read %x.",
		     $time, addr, expected, s00_axi_rdata);
            err <= 1'd1;
         end
         s00_axi_rready = 1;
         s00_axi_arvalid = 0;
         #10 s00_axi_rready = 0;
      end
   endtask // rd32

   task check_ocra1;
      input [17:0] exp_x, exp_y, exp_z, exp_z2;
      begin
	 if (exp_x != oc1_voutx) begin
            $display("%d ns: ocra1 X expected %x, read %x.",
		     $time, exp_x, oc1_voutx);
            err <= 1'd1;
	 end
	 if (exp_y != oc1_vouty) begin
            $display("%d ns: ocra1 Y expected %x, read %x.",
		     $time, exp_y, oc1_vouty);
            err <= 1'd1;
	 end
	 if (exp_z != oc1_voutz) begin
            $display("%d ns: ocra1 Z expected %x, read %x.",
		     $time, exp_z, oc1_voutz);
            err <= 1'd1;
	 end
	 if (exp_z2 != oc1_voutz2) begin
            $display("%d ns: ocra1 Z2 expected %x, read %x.",
		     $time, exp_z2, oc1_voutz2);
            err <= 1'd1;
	 end
      end
   endtask // check_ocra1   
   
   ocra_grad_ctrl UUT(
		      /*AUTOINST*/
		      // Outputs
		      .oc1_clk_o	(oc1_clk_o),
		      .oc1_syncn_o	(oc1_syncn_o),
		      .oc1_ldacn_o	(oc1_ldacn_o),
		      .oc1_sdox_o	(oc1_sdox_o),
		      .oc1_sdoy_o	(oc1_sdoy_o),
		      .oc1_sdoz_o	(oc1_sdoz_o),
		      .oc1_sdoz2_o	(oc1_sdoz2_o),
		      .fhd_clk_o	(fhd_clk_o),
		      .fhd_sdo_o	(fhd_sdo_o),
		      .fhd_ssn_o	(fhd_ssn_o),
		      .s00_axi_awready	(s00_axi_awready),
		      .s00_axi_wready	(s00_axi_wready),
		      .s00_axi_bresp	(s00_axi_bresp[1:0]),
		      .s00_axi_bvalid	(s00_axi_bvalid),
		      .s00_axi_arready	(s00_axi_arready),
		      .s00_axi_rdata	(s00_axi_rdata[C_S00_AXI_DATA_WIDTH-1:0]),
		      .s00_axi_rresp	(s00_axi_rresp[1:0]),
		      .s00_axi_rvalid	(s00_axi_rvalid),
		      .s_axi_intr_awready(s_axi_intr_awready),
		      .s_axi_intr_wready(s_axi_intr_wready),
		      .s_axi_intr_bresp	(s_axi_intr_bresp[1:0]),
		      .s_axi_intr_bvalid(s_axi_intr_bvalid),
		      .s_axi_intr_arready(s_axi_intr_arready),
		      .s_axi_intr_rdata	(s_axi_intr_rdata[C_S_AXI_INTR_DATA_WIDTH-1:0]),
		      .s_axi_intr_rresp	(s_axi_intr_rresp[1:0]),
		      .s_axi_intr_rvalid(s_axi_intr_rvalid),
		      .irq		(irq),
		      // Inputs
		      .grad_bram_offset_i(grad_bram_offset_i[13:0]),
		      .grad_bram_enb_i	(grad_bram_enb_i),
		      .fhd_sdi_i	(fhd_sdi_i),
		      .s00_axi_aclk	(s00_axi_aclk),
		      .s00_axi_aresetn	(s00_axi_aresetn),
		      .s00_axi_awaddr	(s00_axi_awaddr[C_S00_AXI_ADDR_WIDTH-1:0]),
		      .s00_axi_awprot	(s00_axi_awprot[2:0]),
		      .s00_axi_awvalid	(s00_axi_awvalid),
		      .s00_axi_wdata	(s00_axi_wdata[C_S00_AXI_DATA_WIDTH-1:0]),
		      .s00_axi_wstrb	(s00_axi_wstrb[(C_S00_AXI_DATA_WIDTH/8)-1:0]),
		      .s00_axi_wvalid	(s00_axi_wvalid),
		      .s00_axi_bready	(s00_axi_bready),
		      .s00_axi_araddr	(s00_axi_araddr[C_S00_AXI_ADDR_WIDTH-1:0]),
		      .s00_axi_arprot	(s00_axi_arprot[2:0]),
		      .s00_axi_arvalid	(s00_axi_arvalid),
		      .s00_axi_rready	(s00_axi_rready),
		      .s_axi_intr_aclk	(s_axi_intr_aclk),
		      .s_axi_intr_aresetn(s_axi_intr_aresetn),
		      .s_axi_intr_awaddr(s_axi_intr_awaddr[C_S_AXI_INTR_ADDR_WIDTH-1:0]),
		      .s_axi_intr_awprot(s_axi_intr_awprot[2:0]),
		      .s_axi_intr_awvalid(s_axi_intr_awvalid),
		      .s_axi_intr_wdata	(s_axi_intr_wdata[C_S_AXI_INTR_DATA_WIDTH-1:0]),
		      .s_axi_intr_wstrb	(s_axi_intr_wstrb[(C_S_AXI_INTR_DATA_WIDTH/8)-1:0]),
		      .s_axi_intr_wvalid(s_axi_intr_wvalid),
		      .s_axi_intr_bready(s_axi_intr_bready),
		      .s_axi_intr_araddr(s_axi_intr_araddr[C_S_AXI_INTR_ADDR_WIDTH-1:0]),
		      .s_axi_intr_arprot(s_axi_intr_arprot[2:0]),
		      .s_axi_intr_arvalid(s_axi_intr_arvalid),
		      .s_axi_intr_rready(s_axi_intr_rready));

   ocra1_model oc1_model(// Outputs
			 .voutx			(oc1_voutx[17:0]),
			 .vouty			(oc1_vouty[17:0]),
			 .voutz			(oc1_voutz[17:0]),
			 .voutz2		(oc1_voutz2[17:0]),
			 // Inputs
			 .clk			(oc1_clk_o),
			 .syncn			(oc1_syncn_o),
			 .ldacn			(oc1_ldacn_o),
			 .sdox			(oc1_sdox_o),
			 .sdoy			(oc1_sdoy_o),
			 .sdoz			(oc1_sdoz_o),
			 .sdoz2			(oc1_sdoz2_o));

   gpa_fhdo_model fhd_model(// Outputs
			    .sdi		(fhd_sdi_i),
			    .voutx		(voutx[15:0]),
			    .vouty		(vouty[15:0]),
			    .voutz		(voutz[15:0]),
			    .voutz2		(voutz2[15:0]),
			    // Inputs
			    .clk		(fhd_clk_o),
			    .csn		(fhd_ssn_o),
			    .sdo		(fhd_sdo_o));

   // Wires purely for debugging (since GTKwave can't access a single RAM word directly)
   wire [31:0] bram_a0 = UUT.grad_bram_inst.grad_brams[0],
	       bram_a1 = UUT.grad_bram_inst.grad_brams[1],
	       bram_a1024 = UUT.grad_bram_inst.grad_brams[1024],
	       bram_a5004 = UUT.grad_bram_inst.grad_brams[5004],
	       bram_a8000 = UUT.grad_bram_inst.grad_brams[8000],
	       bram_amax = UUT.grad_bram_inst.grad_brams[8191];
   
endmodule // ocra_grad_ctrl_tb
`endif //  `ifndef _OCRA_GRAD_CTRL_TB_

