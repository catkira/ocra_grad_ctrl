//-----------------------------------------------------------------------------
// Title         : grad_bram_tb
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : grad_bram_tb.v
// Author        :   <vlad@arch-ssd>
// Created       : 13.09.2020
// Last modified : 13.09.2020
//-----------------------------------------------------------------------------
// Description :
// 
// Testbench for grad_bram, testing out the various features of the core
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 13.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _GRAD_BRAM_TB_
 `define _GRAD_BRAM_TB_

 `include "grad_bram.v"

 `timescale 1ns/1ns

module grad_bram_tb;
   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH = 32;
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH = 16;
   reg 		     err = 0;
   reg [3:0] 	     valid_mask = 4'b1111;
		     
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			S_AXI_ACLK;		// To UUT of grad_bram.v
   reg [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;	// To UUT of grad_bram.v
   reg			S_AXI_ARESETN;		// To UUT of grad_bram.v
   reg [2:0]		S_AXI_ARPROT;		// To UUT of grad_bram.v
   reg			S_AXI_ARVALID;		// To UUT of grad_bram.v
   reg [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;	// To UUT of grad_bram.v
   reg [2:0]		S_AXI_AWPROT;		// To UUT of grad_bram.v
   reg			S_AXI_AWVALID;		// To UUT of grad_bram.v
   reg			S_AXI_BREADY;		// To UUT of grad_bram.v
   reg			S_AXI_RREADY;		// To UUT of grad_bram.v
   reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;	// To UUT of grad_bram.v
   reg [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB;// To UUT of grad_bram.v
   reg			S_AXI_WVALID;		// To UUT of grad_bram.v
   reg [15:0]		adc_i;			// To UUT of grad_bram.v
   reg			data_enb_i;		// To UUT of grad_bram.v
   reg			data_lost_i;		// To UUT of grad_bram.v
   reg [15:0]		offset_i;		// To UUT of grad_bram.v
   reg			serial_busy_i;		// To UUT of grad_bram.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			S_AXI_ARREADY;		// From UUT of grad_bram.v
   wire			S_AXI_AWREADY;		// From UUT of grad_bram.v
   wire [1:0]		S_AXI_BRESP;		// From UUT of grad_bram.v
   wire			S_AXI_BVALID;		// From UUT of grad_bram.v
   wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;	// From UUT of grad_bram.v
   wire [1:0]		S_AXI_RRESP;		// From UUT of grad_bram.v
   wire			S_AXI_RVALID;		// From UUT of grad_bram.v
   wire			S_AXI_WREADY;		// From UUT of grad_bram.v
   wire [31:0]		data_o;			// From UUT of grad_bram.v
   wire [5:0]		spi_clk_div_o;		// From UUT of grad_bram.v
   wire [3:0]		valid_o;		// From UUT of grad_bram.v
   // End of automatics

   // Clock generation: assuming 100 MHz for convenience (in real design it'll be 122.88, 125 or 144 MHz depending on what's chosen)   
   always #5 S_AXI_ACLK = !S_AXI_ACLK;

   integer 		k;

   // Stimuli and read/write checks
   initial begin
      $dumpfile("icarus_compile/000_grad_bram_tb.lxt");
      $dumpvars(0, grad_bram_tb);

      S_AXI_ACLK = 1;
      S_AXI_ARADDR = 0;
      S_AXI_ARESETN = 0;
      S_AXI_ARPROT = 0;
      S_AXI_ARVALID = 0;
      S_AXI_AWADDR = 0;
      S_AXI_AWPROT = 0;
      S_AXI_AWVALID = 0;
      S_AXI_BREADY = 0;
      S_AXI_RREADY = 0;
      S_AXI_WDATA = 0;
      S_AXI_WSTRB = 0;
      S_AXI_WVALID = 0;
      
      data_enb_i = 0;
      offset_i = 0;
      serial_busy_i = 0;
      data_lost_i = 0;

      #107 S_AXI_ARESETN = 1; // extra 7ns to ensure that TB stimuli occur a bit before the positive clock edges
      S_AXI_BREADY = 1; // TODO: make this more fine-grained if bus reads/writes don't work properly in hardware
      #10 wr32(16'd4, {26'd0, 6'd30}); // reg 1: LSBs set SPI clock divisor
      wr32(16'd8, {28'hcafebee, valid_mask}); // reg 2; note the final F
      wr32(16'd12, 32'habcd0123); // reg 3 -- this write should output the data immediately to the serialisers
      wr32(16'd16, 32'h12345678); // reg 4 -- this write should do nothing, since reg 4 isn't implemented

      // register readback tests
      #10 rd32(16'd0, {22'd0, 10'd303});
      rd32(16'd4, {26'd0, 6'd30});
      rd32(16'd8, 32'hcafebeef);
      rd32(16'd12, 32'habcd0123);
      rd32(16'd16, 32'd0);

      // BRAM writes, no delays
      for (k = 0; k < 1000; k = k + 1) begin
	 wr32(16'h8000 + (k << 2), k);
      end

      // BRAM writes, delays increasing from 0, 1 ... 7, down again
      for (k = 8000; k < 8192; k = k + 1) begin
	 wr32(16'h8000 + (k << 2), {2'd0, k[2:0], 3'd0, k[23:0]});
      end

      // Start outputting data; address 0
      #100 data_enb_i = 1;

      // Change output rate to be maximally fast (one output per 4 clock cycles), then change back to normal
      #29300 wr32(16'd0, {22'd0, 10'd0});
      #200 wr32(16'd0, {22'd0, 10'd303});

      // Change BRAM offset (before previous output is finished)
      #5000 offset_i = 10;
      #5000 data_enb_i = 0;
      #10 data_enb_i = 1;

      // Simulate a 'busy' blip
      #200 serial_busy_i = 1;
      #10 serial_busy_i = 0;
      #10 rd32(16'd16, {16'd0, 16'd11}); // no error bits

      // Data error blip
      #660 data_lost_i = 1;
      #10 data_lost_i = 0;
      #10 rd32(16'd16, {16'd1, 16'd11});

      // Simulate a 'busy' condition that stays for a while, and a data lost error at the same time
      #9000 serial_busy_i = 1; data_lost_i = 1;
      #3000 serial_busy_i = 0; data_lost_i = 0;
      #10 rd32(16'd16, {16'd3, 16'd15});

      // Simulate a longer 'busy' condition that will compromise the output integrity
      #10000 serial_busy_i = 1;
      #10000 serial_busy_i = 0;
      #10 rd32(16'd16, {16'd2, 16'd21});

      // Reset core, make sure it resumes correctly
      #500 S_AXI_ARESETN = 0;
      #10 S_AXI_ARESETN = 1;

      // TODO: reset behaviour in response to momentary reset isn't entirely clear.

      // Change to the part of the memory with waits
      #15000 S_AXI_ARESETN = 0;
      offset_i = 8000;
      data_enb_i = 0;
      #10 S_AXI_ARESETN = 1;
      #10 data_enb_i = 1;

      #200000 if (err) begin
	 $display("THERE WERE ERRORS");
	 $stop; // to return a nonzero error code if the testbench is later scripted at a higher level
      end
      $finish;
   end // initial begin

   // Output word checks at specific times
   integer n, p;
   wire [2:0] n_lsbs = n[2:0];
   initial begin
      // test readout and speed logic
      #225 check_output(32'habcd0123);
      
      #36180 for (n = 0; n < 9; n = n + 1) begin
	 check_output(n); #3070;
      end
      check_output(9); #1690; // speed up in the middle of pause
      for (n = 10; n < 15; n = n + 1) begin
      	 check_output(n); #40;
      end
      check_output(15); #3070; // slow down in the middle of pause
      for (n = 16; n < 18; n = n + 1) begin
      	 check_output(n); #3070;
      end
      check_output(18); #840;      

      // test address reset and offset
      for (n = 10; n < 13; n = n + 1) begin
      	 check_output(n); #3070;
      end

      // test busy causing a skipped valid output
      check_output(13); 
      #3070 if (valid_o == valid_mask) begin
	 $display("%d ns: valid_o high, expected low due to serial_busy_i", $time);
	 err <= 1;
      end
      #3070;
      check_output(15); #3070 check_output(16); #3070;
      check_output(17); #3070;
      for (n = 0; n < 3; n = n + 1) begin
	 if (valid_o == valid_mask) begin
	    $display("%d ns: valid_o high, expected low due to serial_busy_i", $time);
	    err <= 1;
	 end
	 #3070;
      end
      for (n = 21; n < 25; n = n + 1) begin
	 check_output(n); #3070;
      end
      check_output(25); #2600; // uneven delay just from timing of the reconfiguration
      // test larger intervals
      for (n = 0; n < 16; n = n + 1) begin
	 check_output({2'd0, n[2:0], 3'd0, 24'd8000 + n[23:0]});
	 for (p = 0; p <= n[2:0]; p = p + 1) #3070;
      end
   end // initial begin

   // Tasks for AXI bus reads and writes
   task wr32; //write to bus
      input [31:0] addr, data;
      begin
         #10 S_AXI_WDATA = data;
	 S_AXI_WSTRB = 'hf;
         S_AXI_AWADDR = addr;
         S_AXI_AWVALID = 1;
         S_AXI_WVALID = 1;
         fork
            begin: wait_axi_write
               wait(S_AXI_AWREADY && S_AXI_WREADY);
               disable axi_write_timeout;
            end
            begin: axi_write_timeout
               #10000 disable wait_axi_write;
	       $display("%d ns: AXI write timed out", $time);
            end
         join
         #13 S_AXI_AWVALID = 0;
         S_AXI_WVALID = 0;
      end
   endtask // wr32

   task rd32; //read from bus
      input [31:0] addr;
      input [31:0] expected;
      begin
         #10 S_AXI_ARVALID = 1;
         S_AXI_ARADDR = addr;
         wait(S_AXI_ARREADY);
         #13 S_AXI_ARVALID = 0;
         wait(S_AXI_RVALID);
         #13 if (expected !== S_AXI_RDATA) begin
            $display("%d ns: Bus read error, address %x, expected output %x, read %x.",
		     $time, addr, expected, S_AXI_RDATA);
            err <= 1'd1;
         end
         S_AXI_RREADY = 1;
         S_AXI_ARVALID = 0;
         #10 S_AXI_RREADY = 0;
      end
   endtask // rd32

   task check_output;
      input[31:0] expected;
      begin
	 if (valid_o == 0) begin
	    $display("%d ns: valid_o low, expected high", $time);
	    err <= 1;
	 end
	 if (expected != data_o) begin
	    $display("%d ns: data_o expected 0x%x, saw 0x%x", $time, expected, data_o);
	    err <= 1;
	 end
      end
   endtask // check_output   
   
   grad_bram UUT(/*AUTOINST*/
		 // Outputs
		 .data_o		(data_o[31:0]),
		 .valid_o		(valid_o[3:0]),
		 .spi_clk_div_o		(spi_clk_div_o[5:0]),
		 .S_AXI_AWREADY		(S_AXI_AWREADY),
		 .S_AXI_WREADY		(S_AXI_WREADY),
		 .S_AXI_BRESP		(S_AXI_BRESP[1:0]),
		 .S_AXI_BVALID		(S_AXI_BVALID),
		 .S_AXI_ARREADY		(S_AXI_ARREADY),
		 .S_AXI_RDATA		(S_AXI_RDATA[C_S_AXI_DATA_WIDTH-1:0]),
		 .S_AXI_RRESP		(S_AXI_RRESP[1:0]),
		 .S_AXI_RVALID		(S_AXI_RVALID),
		 // Inputs
		 .offset_i		(offset_i[15:0]),
		 .data_enb_i		(data_enb_i),
		 .serial_busy_i		(serial_busy_i),
		 .data_lost_i		(data_lost_i),
		 .adc_i			(adc_i[15:0]),
		 .S_AXI_ACLK		(S_AXI_ACLK),
		 .S_AXI_ARESETN		(S_AXI_ARESETN),
		 .S_AXI_AWADDR		(S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1:0]),
		 .S_AXI_AWPROT		(S_AXI_AWPROT[2:0]),
		 .S_AXI_AWVALID		(S_AXI_AWVALID),
		 .S_AXI_WDATA		(S_AXI_WDATA[C_S_AXI_DATA_WIDTH-1:0]),
		 .S_AXI_WSTRB		(S_AXI_WSTRB[(C_S_AXI_DATA_WIDTH/8)-1:0]),
		 .S_AXI_WVALID		(S_AXI_WVALID),
		 .S_AXI_BREADY		(S_AXI_BREADY),
		 .S_AXI_ARADDR		(S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1:0]),
		 .S_AXI_ARPROT		(S_AXI_ARPROT[2:0]),
		 .S_AXI_ARVALID		(S_AXI_ARVALID),
		 .S_AXI_RREADY		(S_AXI_RREADY));

   // Wires purely for debugging (since GTKwave can't access a single RAM word directly)
   wire [31:0] bram_a0 = UUT.grad_brams[0], bram_a1 = UUT.grad_brams[1], bram_a1024 = UUT.grad_brams[1024], bram_a8000 = UUT.grad_brams[8000], bram_amax = UUT.grad_brams[8191];
   wire [23:0] data_o_lower = data_o[23:0]; // to avoid all 32 bits; just for visual debugging
endmodule // grad_bram_tb
`endif //  `ifndef _GRAD_BRAM_TB_

